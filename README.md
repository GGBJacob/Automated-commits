# Automatic commit script

A bash script pushing all files within a specified path to a git repository.

## Task Configuration

### Step 1:

Open Task Scheduler.

### Step 2:

Create a new task.

### Step 3:

Add a trigger that suits your needs.

### Step 4:

Enter cmd.exe as desired Program/Script and pass "/c start "" /min "path\to\my\file.bat" ^& exit" as arguments.

## Script Configuration


### Step 1:

Set the FOLDER variable to your local repository location.

### Step 2:

Set the LIMIT variable to skip pushing files above x bytes. 