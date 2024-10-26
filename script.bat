@echo off
setlocal enabledelayedexpansion

REM TEST

REM Path to repo folder
set FOLDER="path\to\your\file.bat"
cd /d "%FOLDER%"

set LOG=latest.log

echo %date% %time% > %LOG%

REM Check if any changes were made
git diff-index --quiet HEAD
IF %ERRORLEVEL% EQU 0 (
    echo No changes to commit. >> %LOG%
    exit
)
(
    REM File size limit
    set LIMIT=30000000

    REM File iteration (adding only those below limit)
    for /r %%i in (*.*) do (
        set "currentPath=%%~dpi"
        set "currentPath=!currentPath:\=\\!"

        if "!currentPath!" neq "!currentPath:.git=!" (
            echo Skipping %%i - .git content
        ) else (
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
    )

    REM Fetch all deleted files and remove them from the repo
    for /f "delims=" %%j in ('git ls-files --deleted') do (
        echo Removing from repo: %%j
        git rm "%%j"
    )

    REM Finalize everything
    git commit -m "Automated commit: %date% %time%"
    git push origin main
) >> %LOG% 2>&1
REM Finish
exit