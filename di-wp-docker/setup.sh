#!/bin/bash

# DI_CORE
printf "Include trailing slash \nSuggested location: /Users/$(whoami)/code/dealerinspire/dealerinspire-core/\n"
read -e -p "What is the path to your dealerinspire_core/ directory? " dicore

# THIS DIR
printf "Include trailing slash \nSuggested location: $(pwd)\n"
read -e -p "What is the path to this directory? " wpdocker

# SQL CLI
read -e -p "What is your preferred mysql cli tool? [mysql|mycli]: " sqlcli


# Setup from above variables
cp ./docker-compose.yml.example ./docker-compose.yml
cp ./bin/bashrc.example ./bin/.bashrc

sed -i '' "s~{{DI_CORE}}~${dicore}~" docker-compose.yml bin/.bashrc
sed -i '' "s~{{DI_WP_DOCKER}}~${wpdocker}~" docker-compose.yml bin/.bashrc
sed -i '' "s~{{MYSQL_TOOL}}~${sqlcli}~" docker-compose.yml bin/.bashrc

echo "[ -f ${wpdocker}/bin/.bashrc ] && source ${wpdocker}/bin/.bashrc" >> /Users/$(whoami)/.bash_profile
