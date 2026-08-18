@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: ============================================================
:: Sistem Dil Kontrolü
:: ============================================================
set "SYS_LOCALE="
for /f "tokens=3 delims=\ " %%i in ('reg query "HKCU\Control Panel\International" /v LocaleName 2^>nul') do set "SYS_LOCALE=%%i"

if /i "%SYS_LOCALE:~0,2%"=="tr" (
    set "LANG=TR"
) else (
    set "LANG=EN"
)

if "%LANG%"=="TR" (
    set "TITLE_TEXT=MUK OPTIMIZER ARACI"
    set "CAT_1=[1] Windows / Android Betik Calistir (commands\)"
    set "CAT_2=[2] GUI Arayuzunu Baslat (mukoptimizerapp.exe)"
    set "CAT_3=[3] HTML / Tarayici Onbellek Temizligi"
    set "CAT_4=[4] Geri (Yenile / Ana Menu)"
    set "CAT_5=[5] Cikis"

    set "CMD_MENU_TITLE=Betik Turunu Secin"
    set "CMD_OPT_1=[1] .bat (Android ADB Optimizasyon)"
    set "CMD_OPT_2=[2] .sh (Android ADB Optimizasyon)"
    set "CMD_OPT_3=[3] .ps1 (Windows Optimizasyon)"
    set "CMD_OPT_4=[4] Geri (Ana Menu)"

    set "PROMPT_CHOICE=Lutfen bir secim yapin [1-5] (Varsayilan [1]): "
    set "SELECT_SCRIPT=Calistirmak istediginiz betigi secin: "
    set "WARN_RUN=[!] UYARI: Bu islem secilen optimizasyon betigini uygulayacaktir."
    set "CONFIRM_QUESTION=Baslatmak istiyor musunuz? [E/h] (Varsayilan: Evet): "
    set "ERR_NO_FILES=[HATA] 'commands' klasorunde gecerli dosya bulunamadi!"
    set "ERR_NO_LAUNCHER=[HATA] mukoptimizerapp.exe bulunamadi!"
    set "ERR_INVALID_CHOICE=Gecersiz secim!"
    set "RUNNING_TEXT=Calistiriliyor:"
    set "OK_SUCCESS=MUK Optimizer basariyla tamamlandi!"
    set "REBOOT_QUESTION=Cihazi/Sistemi yeniden baslatmak istiyor musunuz? [e/H] (Varsayilan: Hayir): "
    set "REBOOTING=Yeniden baslatiliyor..."
    set "REBOOT_TARGET=1: PC ^| 2: Telefon (ADB) ^| 3: Iptal: "
    set "BACK_LABEL=Geri"
    set "EXIT_LABEL=Cikis"
    set "CLEAN_CHROME=[*] Chrome / Webview Onbellegi Temizleniyor..."
    set "CLEAN_EDGE=[*] Edge Onbellegi Temizleniyor..."
    set "CLEAN_TEMP=[*] Windows WebCache ^& Temp Temizleniyor..."
) else (
    set "TITLE_TEXT=MUK OPTIMIZER TOOL"
    set "CAT_1=[1] Run Windows / Android Script (commands\)"
    set "CAT_2=[2] Launch GUI (mukoptimizerapp.exe)"
    set "CAT_3=[3] HTML / Browser Cache Cleanup"
    set "CAT_4=[4] Back (Refresh / Main Menu)"
    set "CAT_5=[5] Exit"

    set "CMD_MENU_TITLE=Select Script Type"
    set "CMD_OPT_1=[1] .bat (Android ADB Optimization)"
    set "CMD_OPT_2=[2] .sh (Android ADB Optimization)"
    set "CMD_OPT_3=[3] .ps1 (Windows Optimization)"
    set "CMD_OPT_4=[4] Back (Main Menu)"

    set "PROMPT_CHOICE=Please enter your choice [1-5] (Default [1]): "
    set "SELECT_SCRIPT=Select the script to execute: "
    set "WARN_RUN=[!] WARNING: This will apply the selected optimization."
    set "CONFIRM_QUESTION=Are you sure you want to start? [Y/n] (Default: Yes): "
    set "ERR_NO_FILES=[ERROR] No valid files found in 'commands' folder!"
    set "ERR_NO_LAUNCHER=[ERROR] mukoptimizerapp.exe not found!"
    set "ERR_INVALID_CHOICE=Invalid choice!"
    set "RUNNING_TEXT=Executing:"
    set "OK_SUCCESS=MUK Optimizer completed successfully!"
    set "REBOOT_QUESTION=Do you want to restart the system/device? [y/N] (Default: No): "
    set "REBOOTING=Restarting..."
    set "REBOOT_TARGET=1: PC ^| 2: Phone (ADB) ^| 3: Cancel: "
    set "BACK_LABEL=Back"
    set "EXIT_LABEL=Exit"
    set "CLEAN_CHROME=[*] Cleaning Chrome / Webview Cache..."
    set "CLEAN_EDGE=[*] Cleaning Edge Cache..."
    set "CLEAN_TEMP=[*] Cleaning Windows WebCache ^& Temp..."
)

:MENU
cls
color 0B
echo.
echo  =============================================================
echo     ███╗   ███╗██╗   ██╗██╗  ██╗
echo     ████╗ ████║██║   ██║██║ ██╔╝
echo     ██╔████╔██║██║   ██║█████═╝ 
echo     ██║╚██╔╝██║██║   ██║██╔═██╗ 
echo     ██║ ╚═╝ ██║╚██████╔╝██║  ██╗
echo     ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
echo  =============================================================
echo                   %TITLE_TEXT%
echo  =============================================================
echo   %CAT_1%
echo   %CAT_2%
echo   %CAT_3%
echo   %CAT_4%
echo   %CAT_5%
echo  =============================================================
echo.

set "choice=1"
set /p choice="%PROMPT_CHOICE%"

if "%choice%"=="1" goto COMMANDS_MENU
if "%choice%"=="2" goto LAUNCH_GUI
if "%choice%"=="3" goto RUN_HTML_OPT
if "%choice%"=="4" goto MENU
if "%choice%"=="5" goto END
goto MENU

:COMMANDS_MENU
cls
echo.
echo  =============================================================
echo   %CMD_MENU_TITLE%
echo  =============================================================
echo   %CMD_OPT_1%
echo   %CMD_OPT_2%
echo   %CMD_OPT_3%
echo   %CMD_OPT_4%
echo  =============================================================
echo.

set "cmd_choice=1"
set /p cmd_choice="%PROMPT_CHOICE%"

if "%cmd_choice%"=="1" (
    set "SCRIPT_FILTER=*.bat"
    goto LIST_SCRIPTS
)
if "%cmd_choice%"=="2" (
    set "SCRIPT_FILTER=*.sh"
    goto LIST_SCRIPTS
)
if "%cmd_choice%"=="3" (
    set "SCRIPT_FILTER=*.ps1"
    goto LIST_SCRIPTS
)
if "%cmd_choice%"=="4" goto MENU
goto COMMANDS_MENU

:LAUNCH_GUI
if exist "mukoptimizerapp.exe" (
    start "" "mukoptimizerapp.exe"
    exit
) else if exist "mukoptimizerapp\bin\Release\net5.0-windows\win-x64\publish\mukoptimizerapp.exe" (
    start "" "mukoptimizerapp\bin\Release\net5.0-windows\win-x64\publish\mukoptimizerapp.exe"
    exit
) else (
    echo.
    echo %ERR_NO_LAUNCHER%
    pause
    goto MENU
)

:LIST_SCRIPTS
cls
echo.
echo  =============================================================
echo   MUK OPTIMIZER - %SCRIPT_FILTER%
echo  =============================================================
echo.

set count=0
if exist "commands\" (
    for /f "delims=" %%F in ('dir /b /s "commands\%SCRIPT_FILTER%" 2^>nul') do (
        set /a count+=1
        set "file_!count!=%%F"
        set "rel_path=%%F"
        set "rel_path=!rel_path:*commands\=!"
        echo   [!count!] !rel_path!
    )
)

if %count%==0 (
    echo   %ERR_NO_FILES%
    echo.
    pause
    goto COMMANDS_MENU
)

:: Geri/Cikis numaralari artik dinamik - dosya listesiyle asla cakismaz
set /a BACK_OPT=%count%+1
set /a EXIT_OPT=%count%+2

echo.
echo   [%BACK_OPT%] %BACK_LABEL% (Alt Menu)
echo   [%EXIT_OPT%] %EXIT_LABEL%
echo  =============================================================
echo.

set "script_choice=1"
set /p script_choice="%SELECT_SCRIPT%"

if "%script_choice%"=="%BACK_OPT%" goto COMMANDS_MENU
if "%script_choice%"=="%EXIT_OPT%" goto END

if not defined file_%script_choice% (
    echo %ERR_INVALID_CHOICE%
    pause
    goto LIST_SCRIPTS
)

set "SELECTED_FILE=!file_%script_choice%!"
goto CONFIRM_RUN

:RUN_HTML_OPT
cls
echo.
echo  =============================================================
echo   %CAT_3%
echo  =============================================================
echo.

set "confirm=E"
set /p confirm="%CONFIRM_QUESTION%"

if /i not "%confirm%"=="E" if /i not "%confirm%"=="Y" if /i not "%confirm%"=="evet" if /i not "%confirm%"=="yes" if /i not "%confirm%"=="" goto MENU

echo.
echo %CLEAN_CHROME%
del /q /s /f "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" 2>nul

echo %CLEAN_EDGE%
del /q /s /f "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" 2>nul

echo %CLEAN_TEMP%
del /q /s /f "%TEMP%\*.*" 2>nul

echo.
echo =============================================================
echo %OK_SUCCESS%
echo =============================================================
echo.
pause
goto MENU

:CONFIRM_RUN
cls
echo.
echo %WARN_RUN%
echo Secilen Dosya / Selected File: %SELECTED_FILE%
echo.

:: Enter basilirsa direkt 'E' (Evet) / Yes
set "confirm=E"
set /p confirm="%CONFIRM_QUESTION%"

if /i "%confirm%"=="E" goto EXECUTE_SCRIPT
if /i "%confirm%"=="Y" goto EXECUTE_SCRIPT
if /i "%confirm%"=="evet" goto EXECUTE_SCRIPT
if /i "%confirm%"=="yes" goto EXECUTE_SCRIPT
if "%confirm%"=="" goto EXECUTE_SCRIPT
goto LIST_SCRIPTS

:EXECUTE_SCRIPT
cls
echo.
echo %RUNNING_TEXT% %SELECTED_FILE%
echo -------------------------------------------------------------
echo.

:: Dosya uzantısını güvenli şekilde al
for %%A in ("%SELECTED_FILE%") do set "EXT=%%~xA"

if /i "%EXT%"==".bat" (
    call "%SELECTED_FILE%"
) else if /i "%EXT%"==".ps1" (
    powershell -ExecutionPolicy Bypass -File "%SELECTED_FILE%"
) else if /i "%EXT%"==".sh" (
    bash "%SELECTED_FILE%"
) else (
    echo %ERR_INVALID_CHOICE%
)

echo.
echo =============================================================
echo %OK_SUCCESS%
echo =============================================================
echo.

:: Enter basilirsa direkt 'H' (Hayir) / No
set "reboot_confirm=H"
set /p reboot_confirm="%REBOOT_QUESTION%"

if /i "%reboot_confirm%"=="E" goto REBOOT_MENU
if /i "%reboot_confirm%"=="Y" goto REBOOT_MENU
if /i "%reboot_confirm%"=="evet" goto REBOOT_MENU
if /i "%reboot_confirm%"=="yes" goto REBOOT_MENU
pause
goto MENU

:REBOOT_MENU
echo.
set "reboot_target=1"
set /p reboot_target="%REBOOT_TARGET%"

if "%reboot_target%"=="1" (
    echo %REBOOTING% PC...
    shutdown /r /t 0
) else if "%reboot_target%"=="2" (
    echo %REBOOTING% Phone via ADB...
    adb reboot
    pause
    goto MENU
) else (
    goto MENU
)
goto MENU

:END
exit