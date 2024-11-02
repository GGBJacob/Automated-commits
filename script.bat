@echo off
setlocal enabledelayedexpansion

REM Path to repo folder
set FOLDER="X:\your\path"
cd /d "%FOLDER%"

set LOG=latest.log

REM Check if any changes were made
git diff-index --quiet HEAD
IF %ERRORLEVEL% EQU 0 (
    echo %date% %time% > %LOG%
    echo No changes to commit. >> %LOG%
    REM Push logs to github (add logs to .gitignore to prevent [and run git rm -r --cached if already commited])
    git add %LOG%
    git commit -m "Log update: %date% %time%"
    git push origin main
    exit
)

(
    git add -A
    REM Fetch all deleted files and remove them from the repo
    for /f "delims=" %%j in ('git ls-files --deleted') do (
        echo Removing from repo: %%j
        git rm "%%j"
    )

    git status --porcelain

    echo.
    echo Committing...
    echo.

    REM Finalize everything
    git commit -m "Automated commit: %date% %time%"
    git push origin main

) > %LOG% 2>&1

REM Push logs to github (add logs to .gitignore to prevent [and run git rm -r --cached if already commited])
git add %LOG%
git commit -m "Log update: %date% %time%"
git push origin main


REM Finish
exit