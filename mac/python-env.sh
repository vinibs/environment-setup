#!/bin/sh

if brew ls --versions pyenv > /dev/null && brew ls --versions pyenv-virtualenv > /dev/null; then
    echo "Pyenv and virtualenv already installed. Skipping instalation..."
else
    echo "Install pyenv and virtualenv..."
    brew install pyenv pyenv-virtualenv
fi


echo "\nSetup pyenv and virtualenv to work with zsh..."
ZSH_PROFILE=~/.zshrc

if ! grep -q "pyenv" "$ZSH_PROFILE"; then
    echo '# Pyenv and pyenv-virtualenv settings' >> $ZSH_PROFILE
    echo 'eval "$(pyenv init --path)"' >> $ZSH_PROFILE
    echo 'eval "$(pyenv init -)"' >> $ZSH_PROFILE
    echo 'if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi' >> $ZSH_PROFILE
    echo '\n' >> $ZSH_PROFILE
fi

source $ZSH_PROFILE


LATEST_PYTHON_VERSION=`echo $(pyenv install --list | grep --extended-regexp "^\s*[0-9][0-9.]*[0-9]\s*$" | tail -1) | sed 's/ *$//g'`

if pyenv versions | grep -q "$LATEST_PYTHON_VERSION"; then
    echo "\nLatest Python version ($LATEST_PYTHON_VERSION) already installed."
else
    echo "\nInstall latest Python version ($LATEST_PYTHON_VERSION)..."
    pyenv install $LATEST_PYTHON_VERSION
fi

echo "\nSet latest Python version as default..."
pyenv global $LATEST_PYTHON_VERSION

echo "\nCurrent default Python version:"
python -V