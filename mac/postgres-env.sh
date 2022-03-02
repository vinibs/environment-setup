#!/bin/sh

if brew ls --versions postgresql > /dev/null; then
    echo "Postgres already installed. Skipping instalation..."
else
    echo "Install Postgres..."
    brew install postgresql
fi

echo "\nSetup default postgres user"
brew services start postgres
psql postgres -c "CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres';"
psql postgres -c "ALTER ROLE postgres CREATEDB;"
brew services stop postgres