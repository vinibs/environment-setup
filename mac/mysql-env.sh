#!/bin/sh

if brew ls --versions nvm > /dev/null; then
    echo "MySQL already installed. Skipping instalation..."
else
    echo "Install MySQL..."
    brew install mysql
fi


echo "\nConfigure MySQL root user..."
ROOT_PSWD="root"
brew services start mysql
mysqladmin -u root password $ROOT_PSWD
mysql -u root -p=$ROOT_PSWD -Bse "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
brew services stop mysql