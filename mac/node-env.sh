#!/bin/sh

if brew ls --versions nvm > /dev/null; then
    echo "NVM already installed. Skipping instalation..."
else
    echo "Install NVM..."
    brew install nvm
    mkdir ~/.nvm
fi


echo "\nSetup NVM to work with zsh..."
ZSH_PROFILE=~/.zshrc

if ! grep -q "NVM_DIR" "$ZSH_PROFILE"; then
    echo '\n' >> $ZSH_PROFILE
    echo '# NVM settings' >> $ZSH_PROFILE
    echo 'export NVM_DIR=~/.nvm' >> $ZSH_PROFILE
    echo 'source $(brew --prefix nvm)/nvm.sh' >> $ZSH_PROFILE
fi

source $ZSH_PROFILE


echo "\nInstall latest Node version..."
nvm install node

echo "\nCurrent default Node version:"
node -v

echo "\nCurrent NPM version:"
npm -v