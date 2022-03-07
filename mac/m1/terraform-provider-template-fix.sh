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
    brew install m1-terraform-provider-helper &> /dev/null
fi

echo "\nBuild and install terraform-provider-template"
LOG_FILE=./install-log.txt
touch $LOG_FILE
m1-terraform-provider-helper activate &> $LOG_FILE
m1-terraform-provider-helper install hashicorp/template -v 2.2.0 &> $LOG_FILE
rm $LOG_FILE

echo "\nExtracting compiled checksum..."
TERRAFORM_SAMPLE_DIR=./terraform
MAIN_FILE=main.tf

mkdir $TERRAFORM_SAMPLE_DIR
cd $TERRAFORM_SAMPLE_DIR

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

terraform init &> /dev/null

LOCK_FILE=.terraform.lock.hcl

if ! [ -f "$LOCK_FILE" ]; then
    echo "\n>> \033[31mError:\033[0m could not initialize terraform's lock file. Exiting...\n" >&2
    exit 1
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
fi

cd ..
rm -rf $TERRAFORM_SAMPLE_DIR

echo "\nThen, run \033[33mterraform init\033[0m on your project and it should work properly."
echo "\n\033[32mAll done.\033[0m\n"