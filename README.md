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

## Credit

- To <https://github.com/jmanc> for figuring out original solution.
- To ChatGPT for shell-scripting help.

---