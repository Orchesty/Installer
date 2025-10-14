#!/bin/bash

set -e
echo "Checking prerequisites ..."
if ! command -v make >/dev/null 2>&1; then
  echo "❌ Make is missing. Please install it before use."
  echo "👉 MacOS: brew install make"
  echo "👉 Linux (Debian/Ubuntu): sudo apt install make"
  exit 1
else
  echo "✅ Make is present ($(command -v make))"
fi

if command -v gsed >/dev/null 2>&1; then
  echo "✅ GNU sed (gsed) is present ($(command -v gsed))"
elif command -v sed >/dev/null 2>&1; then
  if sed --version 2>/dev/null | grep -q 'GNU'; then
    echo "✅ GNU sed (gsed) is present ($(command -v gsed))"
  else
    echo "⚠️ BSD sed is present ($(command -v sed)), instead of GNU sed."
    echo "👉 Replace it by: brew install gnu-sed"
    echo "   and set alias for it: alias sed='gsed'"
    exit 1
  fi
else
  echo "❌ GNU sed is not present. Please install it before use."
  echo "👉 MacOS: brew install gnu-sed"
  echo "👉 Linuxu (Debian/Ubuntu): sudo apt install sed"
  exit 1
fi

echo "Installing ..."

declare type=$1
[ -z "$type" ] && type='skeleton'
[ "$type" != "skeleton" ] && [ "$type" != "tutorial" ] && echo Only skeleton or tutorial is allowed && exit

echo "Select project version:"
options=("2.1" "2.0" "custom")

select version in "${options[@]}"; do
  case $version in
    "2.0"|"2.1")
      echo "✅ Selected version: $version"
      break
      ;;
    "custom")
      read -p "Enter custom version: " customVersion
      [ -z "$customVersion" ] && echo "Error: version must be specified" && exit 1
      version="$customVersion"
      echo "✅ Selected custom version: $version"
      break
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac
done

read -p 'Project name: ' projectName
[ -z "$projectName" ] && echo Error: Project name must be specified && exit

read -p 'Output (Default: ./): ' output
[ -z "$output" ] && declare output='./'

mkdir -p $output
[ -d "$output" ] && echo $output was successfully created || (echo $output was not created && exit)

path="${output}/${projectName}"
path="${path//\/\//\/}"

git clone https://github.com/Orchesty/orchesty-"$type".git $path
echo Orchesty was successfully downloaded

cd $path
rm -rf .git

sed -i 's/skeleton/'$projectName'/g' .env.dist >> .env.dist
sed -i 's/^VERSION=.*/VERSION='$version'/' .env.dist >> .env.dist
sed -i 's/Skeleton/'${projectName[@]^}'/' README.md >> README.md
sed -i 's/skeleton/'$projectName'/g' nodejs-sdk/package.json >> nodejs-sdk/package.json
sed -i 's/skeleton/'$projectName'/g' php-sdk/composer.json >> php-sdk/composer.json
echo Project name: [$projectName] was created to directory: $output
