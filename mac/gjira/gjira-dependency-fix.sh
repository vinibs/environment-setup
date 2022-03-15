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

PRE_COMMIT_PYTHON_ENV_DIR=./py_env-python/bin
PRE_COMMIT_PYTHON_ENV_DIR_ALT=./py_env-python3/bin

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
    cd $dir

    if ! (test -d "$PRE_COMMIT_PYTHON_ENV_DIR" || test -d "$PRE_COMMIT_PYTHON_ENV_DIR_ALT"); then
        ((NOT_FOUND_PYTHON_ENV_DIRS++))
        continue
    fi

    if [ -d "$PRE_COMMIT_PYTHON_ENV_DIR_ALT" ]; then
        PRE_COMMIT_PYTHON_ENV_DIR=$PRE_COMMIT_PYTHON_ENV_DIR_ALT
    fi

    cd $PRE_COMMIT_PYTHON_ENV_DIR
    chmod +x activate

    source ./activate

    CURRENT_MARKUPSAFE_VERSION=`pip show markupsafe | sed -E -n 's/Version: (.+)/\1/p'`
    if [ $TARGET_MARKUPSAFE_VERSION != $CURRENT_MARKUPSAFE_VERSION ]; then
        pip install markupsafe==$TARGET_MARKUPSAFE_VERSION
    fi
    
    source deactivate &> /dev/null
    cd ..
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