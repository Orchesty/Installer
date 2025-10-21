#!/bin/bash

set -e

DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --dry)
      DRY_RUN=true
      ;;
    *)
      ;;
  esac
done

sed_error() {
  echo "⚠️ Non-GNU sed detected ($(command -v sed))."
  echo "👉 Replace it by: brew install gnu-sed"
  echo "   and set PATH=\"/opt/homebrew/opt/gnu-sed/libexec/gnubin:\$PATH\" in your .zshrc"
  exit 1
}

echo "Checking prerequisites ..."
if ! command -v make >/dev/null 2>&1; then
  echo "❌ Make is missing. Please install it before use."
  echo "👉 MacOS: brew install make"
  echo "👉 Linux (Debian/Ubuntu): sudo apt install make"
  exit 1
else
  echo "✅ Make is present ($(command -v make))"
fi

if command -v sed >/dev/null 2>&1; then
  if sed --version >/dev/null 2>&1 2>/dev/null; then
    if sed --version 2>/dev/null | grep -q 'GNU'; then
      echo "✅ GNU sed is present ($(command -v sed))"
    else
      sed_error
    fi
  else
    # BSD sed (macOS)
    sed_error
  fi
else
  echo "❌ sed is not present. Please install it before use."
  echo "👉 MacOS: brew install gnu-sed"
  echo "👉 Linux (Debian/Ubuntu): sudo apt install sed"
  exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
  exit 0
fi

echo "Installing ..."

declare type=$1
[ -z "$type" ] && type='skeleton'
[ "$type" != "skeleton" ] && [ "$type" != "tutorial" ] && echo Only skeleton or tutorial is allowed && exit

echo "Select project version:"
options=("2.1" "2.0" "custom")
default=1

for i in "${!options[@]}"; do
  index=$((i + 1))
  if [ "$index" -eq "$default" ]; then
    echo " $index) ${options[$i]} (default)"
  else
    echo " $index) ${options[$i]}"
  fi
done

read -p "#? " choice

if [ -z "$choice" ]; then
  choice=$default
fi

version="${options[$((choice - 1))]}"

case $version in
  "2.0"|"2.1")
    echo "✅ Selected version: $version"
    ;;
  "custom")
    read -p "Enter custom version: " customVersion
    [ -z "$customVersion" ] && echo "Error: version must be specified" && exit 1
    version="$customVersion"
    echo "✅ Selected custom version: $version"
    ;;
  *)
    echo "Invalid choice. Please try again."
    exit 1
    ;;
esac

read -p 'Project name: ' projectName
[ -z "$projectName" ] && echo Error: Project name must be specified && exit

read -p 'Output (Default: ./): ' output
[ -z "$output" ] && declare output='./'

mkdir -p $output
[ -d "$output" ] && echo $output was successfully created || (echo $output was not created && exit)

projectNameLowercase=$(echo "$projectName" | tr '[:upper:]' '[:lower:]')

output="${output%/}"
path="${output}/${projectName}"

git clone https://github.com/Orchesty/orchesty-"$type".git $path
echo Orchesty was successfully downloaded

cd $path
rm -rf .git

sed -i 's/skeleton/'$projectName'/g' .env.dist >> .env.dist
sed -i 's/^VERSION=.*/VERSION='$version'/' .env.dist >> .env.dist
sed -i 's/Skeleton/'${projectName[@]^}'/' README.md >> README.md
sed -i 's/skeleton/'$projectNameLowercase'/g' worker/package.json >> worker/package.json

echo Project name: [$projectName] was created to directory: $output
