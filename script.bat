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

REM Clear logs prior to commiting
echo. > %LOG%

(
    REM File size limit (30 MB)
    set LIMIT=30000000
    
    echo Scanning dirs...
    echo.
    
    REM Iterate through directories excluding .git (faster than skipping all files within .git)
    for /D %%d in (*) do (
        if /i not "%%~nd"==".git" (
            REM Recursive file iteration in non-.git directories
            for /r "%%d" %%i in (*.*) do (
                set "file=%%i"
                set size=0
                for %%s in (%%~zi) do set size=%%s

                REM Check size
                if !size! LSS !LIMIT! (
                    echo Adding: !file!
                    git add "!file!"
                ) else (
                    echo Skipping !file! - file size exceeds !LIMIT! bytes
                )
            )
        ) else (
            echo Skipping .git directory: %%d
        )
    )

    echo.
    echo Scanning files...
    echo.

    REM Iterate through files only in main directory
    for %%i in (*.*) do (
            set "file=%%i"
            set size=0
            for %%s in (%%~zi) do set size=%%s

            REM Check size
            if !size! LSS !LIMIT! (
                echo Adding: !file!
                git add "!file!"
            ) else (
                echo Skipping !file! - file size exceeds !LIMIT! bytes
            )
        )
    
    REM Fetch all deleted files and remove them from the repo
    for /f "delims=" %%j in ('git ls-files --deleted') do (
        echo Removing from repo: %%j
        git rm "%%j"
    )

    echo.
    echo Committing...
    echo.

    REM Finalize everything
    git commit -m "Automated commit: %date% %time%"
    git push origin main

) >> %LOG% 2>&1

REM Push logs to github (add logs to .gitignore to prevent [and run git rm -r --cached if already commited])
git add %LOG%
git commit -m "Log update: %date% %time%"
git push origin main


REM Finish
exit