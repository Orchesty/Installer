#!/bin/bash
declare type=$1
[ -z "$type" ] && type='skeleton'
[ "$type" != "skeleton" ] && [ "$type" != "tutorial" ] && echo Only skeleton or tutorial is allowed && exit
read -p 'Project name: ' projectName
[ -z "$projectName" ] && echo Error: Project name must be specified && exit
read -p 'Output (Default: ./): ' output
[ -z "$output" ] && declare output='./'
mkdir -p $output
[ -d "$output" ] && echo $output was successfully created || (echo $output was not created && exit)
git clone https://github.com/Orchesty/orchesty-"$type".git $output/$projectName
echo Orchesty was successfully downloaded
cd $output/$projectName
rm -rf .git
sed -i 's/skeleton/'${projectName,,}'/g' .env.dist >> .env.dist
sed -i 's/Skeleton/'${projectName[@]^}'/' README.md >> README.md
sed -i 's/skeleton/'${projectName,,}'/g' nodejs-sdk/package.json >> package.json
sed -i 's/skeleton/'${projectName,,}'/g' php-sdk/composer.json >> composer.json
echo Project name: [$projectName] was created to directory: $output
