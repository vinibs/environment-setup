#!/bin/sh

if brew ls --versions pre-commit > /dev/null; then
    echo "Pre-commit already installed. Skipping instalation..."
else
    echo "Install pre-commit..."
    brew install pre-commit
fi


echo "\nGetting project's directory reference..."
while [ -z "$PROJECT_DIR" ]
do
    echo ">> What is the path to the project's root directory?"
    read PROJECT_DIR

    if ! [ -z "$PROJECT_DIR" ]; then
        if [[ ${PROJECT_DIR::1} == "~" ]]
        then
            echo "\n>> Do not use user's home shortcut (~/). Please enter the full path (/Users/[username]).\n";
            PROJECT_DIR=""
        else
            if ! [ -d "$PROJECT_DIR" ]; then
                echo "\n>> \033[31mError:\033[0m the given directory ($PROJECT_DIR) does not exist. Exiting...\n" >&2
                exit 1
            fi
        fi
    fi
done


echo "\nSetup default commit template file..."
GITHUB_DIR=$PROJECT_DIR/.github
TEMPLATE_FILE=$GITHUB_DIR/COMMIT_TEMPLATE

if ! [ -f "$TEMPLATE_FILE" ]; then
    if ! [ -d "$GITHUB_DIR" ]; then
        mkdir $GITHUB_DIR
    fi

    touch $TEMPLATE_FILE
    echo 'Task ID: {{ key }}' >> $TEMPLATE_FILE
    echo '{% if parent__key %}Story ID: {{ parent__key }}{% endif %}' >> $TEMPLATE_FILE
    echo '{% if summary %}Summary: {{ summary }}{% endif %}' >> $TEMPLATE_FILE
fi


echo "\nSetup pre-commit hook..."
PRE_COMMIT_FILE_BASE=$PROJECT_DIR/.pre-commit-config
PRE_COMMIT_FILE=$PRE_COMMIT_FILE_BASE.yml
PRE_COMMIT_FILE_ALT=$PRE_COMMIT_FILE_BASE.yaml

if ! [ -f "$PRE_COMMIT_FILE" ] && ! [ -f "$PRE_COMMIT_FILE_ALT" ]; then

    while [ -z "$BOARD" ]
    do
        echo ">> What is the Jira's board for this project (THAW, BBXB, etc.)?"
        read BOARD
    done

    while [ -z "$BOARD_PATTERN" ]
    do
        echo ">> What is the Jira's pattern this project? Leave blank to use the default based on the board ($BOARD-1234)."
        read $BOARD_PATTERN

        if [ -z "$BOARD_PATTERN" ]; then
            BOARD_PATTERN="$BOARD-\d+"
        fi
    done

    touch $PRE_COMMIT_FILE
    echo "repos:" >> $PRE_COMMIT_FILE
    echo "  - repo: https://github.com/CheesecakeLabs/gjira" >> $PRE_COMMIT_FILE
    echo "    rev: v3.2.0" >> $PRE_COMMIT_FILE
    echo "    hooks:" >> $PRE_COMMIT_FILE
    echo "      - id: gjira" >> $PRE_COMMIT_FILE
    echo "        args:" >> $PRE_COMMIT_FILE
    echo "          [" >> $PRE_COMMIT_FILE
    echo "            '--board=$BOARD'," >> $PRE_COMMIT_FILE
    echo "            '--regex=$BOARD_PATTERN'," >> $PRE_COMMIT_FILE
    echo "            '--template=.github/COMMIT_TEMPLATE'," >> $PRE_COMMIT_FILE
    echo "          ]" >> $PRE_COMMIT_FILE
fi


echo "\nSet environment variables..."
ZSH_PROFILE=~/.zshrc
COMPANY_DOMAIN=cheesecakelabs

if ! grep -q "jiraserver" "$ZSH_PROFILE"; then

    while [ -z "$JIRA_EMAIL" ]
    do
        echo ">> What is your e-mail address used on Jira?"
        read JIRA_EMAIL
    done

    while [ -z "$JIRA_TOKEN" ]
    do
        echo ">> What is your Jira's access token? (Get it from https://id.atlassian.com/manage-profile/security/api-tokens)"
        read JIRA_TOKEN
    done

    echo "# Jira token" >> $ZSH_PROFILE
    echo "export jiraserver=\"https://$COMPANY_DOMAIN.atlassian.net\"" >> $ZSH_PROFILE
    echo "export jirauser=\"$JIRA_EMAIL\"" >> $ZSH_PROFILE
    echo "export jiratoken=\"$JIRA_TOKEN\"" >> $ZSH_PROFILE
    echo "\n" >> $ZSH_PROFILE
fi


echo "\nInstall pre-commit hook..."
cd $PROJECT_DIR
pre-commit install --hook-type prepare-commit-msg


echo "\nCurrent pre-commit version:"
pre-commit --version


source $ZSH_PROFILE
echo "\n\033[32mAll done.\033[0m"
echo "\n\033[33mIf you happen to have issues related to markupsafe library while making a commit, check out the following Slack message to get a palliative solution: https://cheesecake.slack.com/archives/C03JDJ39V/p1645211881902949\033[0m"