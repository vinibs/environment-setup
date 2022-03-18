#!/bin/sh

if ! brew ls --versions pre-commit > /dev/null; then
    echo "\033[31mError:\033[0m Pre-commit is not installed through Homebrew. Exiting..."
    exit 1
fi

if ! (brew ls --versions pyenv > /dev/null && brew ls --versions pyenv-virtualenv > /dev/null); then
    echo "Pyenv and virtualenv are not installed. Installing...\n"
    brew install pyenv pyenv-virtualenv &> /dev/null

    echo "\033[33mPlease restart your terminal application and run this script again to ensure the fix will be able to proceed.\033[0m"
    exit 0
fi


PRE_COMMIT_BASE_DIR=~/.cache/pre-commit/

if ! [ -d "$PRE_COMMIT_BASE_DIR" ]; then
    echo "\033[31mError:\033[0m Pre-commit directory does not exist. Exiting..."
    exit 1
fi

cd $PRE_COMMIT_BASE_DIR

REPO_DIRS=( $(file */ | grep ^repo.*/ | awk -F/ '{print $1}') )
REPO_DIRS_COUNT="${#REPO_DIRS[@]}"

if [ $REPO_DIRS_COUNT == 0 ]; then
    echo "\033[31mError:\033[0m No Gjira repo directory found. Exiting..."
    exit 1
fi

NOT_FOUND_PYTHON_ENV_DIRS=0
TARGET_MARKUPSAFE_VERSION=2.0.1

for dir in "${REPO_DIRS[@]}"; do
    cd $PRE_COMMIT_BASE_DIR/$dir

    PYTHON_ENV_DIRS=( $(file */ | grep ^py_env-python.*/ | awk -F/ '{print $1}') )
    PYTHON_ENV_DIRS_COUNT="${#PYTHON_ENV_DIRS[@]}"

    if [[ "$PYTHON_ENV_DIRS_COUNT" == "0" ]]; then
        ((NOT_FOUND_PYTHON_ENV_DIRS++))
        continue
    fi

    for env_dir in "${PYTHON_ENV_DIRS[@]}"; do
        BIN_DIR=$env_dir/bin

        if ! [ -d "$BIN_DIR" ]; then 
            continue
        fi

        cd $BIN_DIR

        chmod +x activate

        source ./activate

        CURRENT_MARKUPSAFE_VERSION=$((pip show markupsafe | sed -E -n 's/Version: (.+)/\1/p') 2>/dev/null)
        
        if [[ "$CURRENT_MARKUPSAFE_VERSION" != "" && "$TARGET_MARKUPSAFE_VERSION" != "$CURRENT_MARKUPSAFE_VERSION" ]]; then
            pip install markupsafe==$TARGET_MARKUPSAFE_VERSION &> /dev/null
        fi
        
        source deactivate &> /dev/null
    done
done


if [ "$NOT_FOUND_PYTHON_ENV_DIRS" -gt "0" ]; then
    if [ $NOT_FOUND_PYTHON_ENV_DIRS == $REPO_DIRS_COUNT ]; then
        echo "\033[33mNo Gjira repo directory was fixed.\nIts directories were not found.\033[0m"
    else
        echo "\033[33mNot all Gjira repo directories could be fixed.\nThere was a total of $NOT_FOUND_PYTHON_ENV_DIRS directories that were not found.\033[0m"
    fi

    echo "\n\n\033[33mDid you try to make a commit in a project to activate it already?\033[0m"
    exit 1
fi


echo "\n\033[32mAll done.\033[0m\n"
echo "\033[33mNow you should be able to successfully use Gjira when making your commits.\033[0m\n"