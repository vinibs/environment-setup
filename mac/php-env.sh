#!/bin/sh

if brew ls --versions php > /dev/null; then
    echo "PHP already installed. Skipping instalation..."
else
    echo "Install latest PHP version..."
    brew install php
fi


echo "\nInstall Composer..."
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"