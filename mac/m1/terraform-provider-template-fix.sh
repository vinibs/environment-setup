#!/bin/sh

if brew ls --versions terraform > /dev/null; then
    echo "Terraform already installed. Skipping instalation..."
else
    echo "Install Terraform..."
    brew install terraform &> /dev/null
fi

if brew ls --versions m1-terraform-provider-helper > /dev/null; then
    echo "M1-terraform-provider-helper already installed. Skipping instalation..."
else
    echo "Install M1-terraform-provider-helper..."
    brew install kreuzwerker/taps/m1-terraform-provider-helper &> /dev/null
fi

echo "\nBuild and install terraform-provider-template"
m1-terraform-provider-helper activate &> /dev/null
m1-terraform-provider-helper install hashicorp/template -v 2.2.0 &> /dev/null

echo "\nExtracting compiled checksum..."
TERRAFORM_SAMPLE_DIR=./temp_sample_terraform_project
MAIN_FILE=main.tf

if ! [ -d "$TERRAFORM_SAMPLE_DIR" ]; then
    mkdir $TERRAFORM_SAMPLE_DIR
fi
cd $TERRAFORM_SAMPLE_DIR

if [ -f "$MAIN_FILE" ]; then
    rm -f $MAIN_FILE
fi

touch $MAIN_FILE
echo "
terraform {
  required_providers {
    template = {
      source  = \"registry.terraform.io/hashicorp/template\"
      version = \"2.2.0\"
    }
  }
}
" >> $MAIN_FILE

INIT_LOG_FILE=terraform-init.log
INIT_LOG_FILE_PATH=../$INIT_LOG_FILE
if [ -f "$INIT_LOG_FILE_PATH" ]; then
    rm -f $INIT_LOG_FILE_PATH
fi

touch $INIT_LOG_FILE_PATH
terraform init &> $INIT_LOG_FILE_PATH

LOCK_FILE=.terraform.lock.hcl

if ! [ -f "$LOCK_FILE" ]; then
    echo "\n>> \033[31mError:\033[0m could not initialize terraform's lock file. Exiting..." >&2
    echo "\n\033[33mYou can check the error log for the background terraform init command in the \"$INIT_LOG_FILE\" file created on this script's directory.\033[0m\n"
    SUCCESS=false
else
    H1_HASH=`cat $LOCK_FILE | sed -E -n 's/[ ]+"(h1:.+)",/\1/p'`
    echo "\nAdd the following hash to your project's \033[33m.terraform.lock.hcl\033[0m file under the \"hashes\" array:"
    echo "\n\033[33m$H1_HASH\033[0m"
    echo "\nExample:"
    echo "
    provider \"registry.terraform.io/hashicorp/template\" {
    version = \"2.2.0\"
    hashes = [
        \"\033[32m$H1_HASH\033[0m\",
    ]    
    "
    SUCCESS=true
    rm -f $INIT_LOG_FILE_PATH
fi

cd ..
rm -rf $TERRAFORM_SAMPLE_DIR

if ! $SUCCESS; then
    exit 1
fi

echo "\nThen, run \033[33mterraform init\033[0m on your project and it should work properly."
echo "\n\033[32mAll done.\033[0m\n"