## Purpose

This script hacks Django's sqlite connector package to enable it to work with an old version of sqlite3. 

Useful where it _is_ possible to use newer versions of Django, but is _not_ possible to use a newer version of sqlite3.

---


## Flow

- Checks if `django` and `pysqlite3` and `pysqlite3-binary` are installed in the virtual environment.
- If required packages are not found, the script alerts and exits.
- If required packages are found, the script updates Django's `sqlite3/base.py` file.

---


## Usage

`$ ./hack_django_sqlite_connector.sh '/path/to/venv_dir'`

---

## Notes

- _Requires_ a venv-dir-path to be passed in; doesn't auto-use an existing activated one. This was largely a function of me not having done this update before, and wanting to be careful and explicit, but I think it's a reasonable design.

- Doesn't try to install any packages. I figured if the two pysqlite packages are needed to run the app on dev, they should be in the `staging.in`/`staging.txt` requirements-files. So this script checks for the two pysqlite packages (and django package), and alerts and quits if they're not installed.

- Allows either `uv` (yay!) or `pip` to be used to generate the freeze output -- which is used to check for the three required packages.

- Figures out the python version from the activated venv. My thinking: we'll increasingly start new projects with `python 3.12`, and may have the sqlite issue on some of our dev-servers for some time.

---


## Credit

- To <https://github.com/jmanc> for figuring out original solution.
- To ChatGPT for shell-scripting help.

---