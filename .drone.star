def main(ctx):
  return [
    step("1.7.10", "10.13.4.1558"),
    step("1.12.2", "14.23.5.2768"),
    step("1.14.4", "28.1.115"),
    step("1.15.1", "30.0.41", ["latest"]),
  ]

def step(mcver, forgever, tags=[]):
  mcforgever = "%s-%s" % (mcver, forgever)
  return {
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

