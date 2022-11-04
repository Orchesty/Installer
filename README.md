# Installer
Installer is script for fast create your own integration project.

## Prerequisites
- Bash

## How to use
- Script run via bash.
- You can use parameter to select type of project (skeleton or tutorial).

### Arguments (interactive)
- Project name: Enter what you want the project to be named. (required)
- Output: Enter where you want the project to be created. (optional)

### Orchesty (default)
```
bash InstallScript.sh
```
or 
```
bash InstallScript.sh skeleton
```

### Orchesty (with tutorial codes)
```
bash InstallScript.sh tutorial
```

## Sample
```
bash InstallScript.sh
Project name: MyOwnProject [ENTER]
Output (Default: ./): [ENTER]
...
Orchesty was successfully downloaded
Project name: [MyOwnProject] was created to directory: ./
```

- Now your project is created in ./ (actual directory in terminal)

