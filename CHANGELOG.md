# CHANGELOG

**v1.2.1 (2026-07-30)**

* Split the projects and comands into their own tables instead of a single large table when running `pm ls`
* Moved the CHANGELOG from `README.md` to `CHANGELOG.md`

**v1.2.0 (2026-07-27)**

Allow `TWD` and `TNAME` to be a substring of a config argument. This enables use of `pm` for applications like Git Bash.

**v1.1.0 (2026-04-18)**

The `<path>` argument for projects can now also be used to run commands. If the path starts with `#!` (a *[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))*), then the string loaded as the path will be executed as a command in a shell. Otherwise, the previous behavior of opening a terminal at the specified `<path>` is followed. There is no change to the config or db format version in this update.

An example might be to launch your project tracking spreadsheet: `pm add stat '#!/usr/bin/libreoffice -o /my/amazing/spreadsheet.ods'`
