def main(ctx):
  return [
    step("1.7.10", "10.13.4.1558", [],
            "forge-1.7.10-10.13.4.1558-1.7.10-universal.jar",
            "1.7.10-10.13.4.1558-1.7.10"), # 1.7 is special (and legacy)
    step("1.12.2", "14.23.5.2768", [],
            "forge-1.12.2-14.23.5.2768-universal.jar"),
    step("1.14.4", "28.1.115"),
    step("1.15.1", "30.0.41", ["latest"]),
  ]

def step(mcver, forgever, tags=[], jarfile=None, buildver=None):
  mcforgever = "%s-%s" % (mcver, forgever)
  pipeline = {
    "kind": "pipeline",
    "name": "build-%s" % mcforgever,
    "steps": [
      {
        "name": "build",
        "image": "spritsail/docker-build",
        "pull": "always",
        "settings": {
          "repo": "forge-dev-%s" % mcforgever,
          "build_args": [
            "MC_VER=%s" % mcver,
            "FORGE_VER=%s" % forgever,
          ],
        },
      },
      {
        "name": "test",
        "image": "spritsail/docker-test",
        "pull": "always",
        "settings": {
          "repo": "forge-dev-%s" % mcforgever,
          "exec_pre": "echo eula=true > eula.txt",
          "log_pipe": "grep -qm 1 \\'Done ([0-9]\\\\+\\\\.[0-9]\\\\+s)\\\\!\\'",
          "timeout": 60,
        },
      },
      {
        "name": "publish",
        "image": "spritsail/docker-publish",
        "pull": "always",
        "settings": {
          "from": "forge-dev-%s" % mcforgever,
          "repo": "spritsail/minecraftforge",
          "tags": [mcver, mcforgever] + tags,
          "username": {
            "from_secret": "docker_username",
          },
          "password": {
            "from_secret": "docker_password",
          },
        },
        "when": {
          "branch": ["master"],
          "event": ["push"],
        },
      },
    ]
  }

  if jarfile:
    pipeline["steps"][0]["settings"]["build_args"] += ["JAR_FILE=%s" % jarfile]
  if buildver:
    pipeline["steps"][0]["settings"]["build_args"] += ["BUILD_VER=%s" % buildver]

  return pipeline

