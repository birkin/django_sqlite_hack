#!/bin/bash

## Purpose:
## This script hacks Django's sqlite package to enable it to work with an old version
##   of sqlite3 on an old version of RedHat.
##
## Flow:
## It checks if django and pysqlite3 and pysqlite3-binary are installed in the virtual environment.
## If the required packages are not found, the script alerts the user and exits.
## If the packages are found, it proceeds to update Django's `sqlite3/base.py` file.
##
## Usage:
## $ ./hack_django_sqlite_connector.sh '/path/to/venv_dir'
##
## Credit to <https://github.com/jmanc> for figuring out original solution.


function usage() {
    echo "Usage:"
    echo "./$(basename \"${0}\") '/path/to/venv_dir'"
    echo
    exit
}


function sourceVirtEnv() {
    ## Flow:
    ## - `cd` to venv directory
    ## - source the venv
    ## Called by main()

    if ! cd "${envDir}"; then
        echo "Exiting. ${envDir} does not exist"; echo
        exit
    fi

    if source "${envDir}/bin/activate"; then
        echo "Sourcing virtual environment for: ${envDir}"
    else
        echo "Exiting. Unable to source virtual environment"
        exit
    fi
}


function checkDependencies() {
    ## Checks if required packages are installed
    ## Tries `uv pip freeze` first, falls back to `pip freeze`.
    ## Parses the output to check for dependencies.
    ## Called by main()

    packages=$(uv pip freeze 2>/dev/null || pip freeze 2>/dev/null)

    if [ -z "$packages" ]; then
        echo "Error: Unable to retrieve installed packages."; echo
        deactivate
        exit
    fi

    if ! echo "$packages" | grep -qi "^pysqlite3=="; then
        echo "Error: pysqlite3 is not installed in the virtual environment."; echo
        deactivate
        exit
    fi

    if ! echo "$packages" | grep -qi "^pysqlite3-binary=="; then
        echo "Error: pysqlite3-binary is not installed in the virtual environment."; echo
        deactivate
        exit
    fi

    if ! echo "$packages" | grep -qi "^django=="; then
        echo "Error: Django is not installed in the virtual environment."; echo
        deactivate
        exit
    fi

    echo "All required dependencies are installed."
}


function hackDjangoSqlite() {
    ## Verifies that target file exists.
    ## Backs up target file.
    ## Updates target file to `from pysqlite3` instead of original `from sqlite3`.
    ## Called by main()

    pythonVersion=$(python -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')
    targetFile="${envDir}/lib/${pythonVersion}/site-packages/django/db/backends/sqlite3/base.py"

    if [ ! -f "$targetFile" ]; then
        echo "Error: Target file does not exist: $targetFile"; echo
        deactivate
        exit
    fi

    backupFile="${targetFile}.bak"
    cp "$targetFile" "$backupFile"
    echo "Backup created at: $backupFile"

    sed -i 's/from sqlite3 import/from pysqlite3 import/g' "$targetFile"
}


## main script -----------------------------------------

main () { echo; }

ARGS=( $@ )
if [ ${#ARGS[@]} -lt 1 ]; then
    echo "Error: No virtual environment path specified."; echo
    usage
elif [ $1 == "--help" ] || [ $1 == "-h" ]; then
    usage
else
    ## Normalize the provided path to remove any trailing slash.
    ## This ensures consistent behavior when appending subdirectories.
    envDir="${1%/}"
fi

sourceVirtEnv

checkDependencies

hackDjangoSqlite

deactivate

echo "Project's Django package has been updated to use pysqlite."

echo "Suggestion, run the code update script to update permissions."
