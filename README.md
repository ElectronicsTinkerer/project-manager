# Project Manager

A simple python-based CLI tool for keeping track of where you put all those projects.

## USAGE

To view full options, run `pm help`

```
USAGE:
$ pm <sub-command|project-name> [args]

SUB COMMANDS:
  add <name> <path> ............. Add a project to the db
  ls ............................ List all projects in db
  rm <name> ..................... Remove project <name>
  chdir <name> <path> ........... Change a project's path
  rename <old-name> <new-name> .. Rename a project
  help .......................... Display this menu
```


## CONFIG

The project manager config file is, by default, located at `~/.config/pm/`. There are two files in this directory: `config.json`, which stores the project manager config settings, and `projects.json`, which is the "db" of projects.

### Customization

Currently, the terminal which is launched can be set by the user. To do this, the key "term" must be set in the config file. Two values will be automatically filled in by the project manager:
1) `TNAME`: Will be filled in with the name of the project.
2) `TWD`: Will be set to the project's associated directory (terminal worki9ng directory).

#### Example: Gnome Terminal

```
"term":[
    "/usr/bin/gnome-terminal",
    "--title", "TNAME",
    "--working-directory", "TWD",
    "--tab"
]
```

#### Example: Konsole

```
"term":[
    "/usr/bin/konsole",
    "--workdir", "TWD",
    "--new-tab"
]
```

#### Example: Windows Terminal

```
"term":[
    "wt.exe",
    "new-tab",
    "--title", "TNAME",
    "--startingDirectory", "TWD",
    "wsl"
]
```


