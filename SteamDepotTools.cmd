::---------------------------------------------------------------
::                Steam Depot Tools V1.0.0
::                   Steam Depot Tools
:: Github: https://github.com/oureveryday/Steam-Depot-Tools
:: Gitlab: https://gitlab.com/oureveryday/Steam-Depot-Tools
::---------------------------------------------------------------

::------------------Init---------------------
@echo off
color F1
set "_null=1>nul 2>nul"
set "Ver=V1.1.0"
chcp 65001 %_null%
title  Steam Depot Tools %Ver%
setlocal EnableDelayedExpansion
setlocal Enableextensions
cd /d %~dp0
cls
goto Menu

::-------------Main Menu---------------------
:Menu
set "Info=Main Menu"
call :MenuInfo
echo     1. Dump Depot Keys
echo     2. Dump Access Token
echo     3. Download App With Depot Key
echo     4. About
echo     5. Exit
echo.
choice /N /C 54321 /M "Select Options [1~4]:"
if errorlevel 5 goto :DumpKeys
if errorlevel 4 goto :DumpToken
if errorlevel 3 goto :Download
if errorlevel 2 goto :About
if errorlevel 1 Exit

:DumpToken
set "Info=Dump Access Token"
call :MenuInfo
echo Access Token Save folder: %~dp0depotkeys
set "SteamAcc="
set "SteamPass="
:DumpToken1
set /p SteamAcc=Steam Account Username:
if NOT defined SteamAcc ( echo Please Input vaild Steam Account Username. & goto :DumpToken1 )
:DumpToken2
set /p SteamPass=Steam Account Password:
if NOT defined SteamPass ( echo Please Input vaild Steam Account Password. & goto :DumpToken2 )
choice /N /C YN /M "Selective Dump (Default: No)[Y/N]:"
IF %ERRORLEVEL% EQU 1 (
echo Selective Dump Access Token Enabled.
echo Dumping...
echo -------------------------------
rd /s /q %~dp0depotkeys %_null%
mkdir "%~dp0depotkeys"
pushd "%~dp0depotkeys""
"%~dp0bin\AccessTokenDumper\AccessTokenDumper.exe" -username "%SteamAcc%" -password "%SteamPass%" -select
echo -------------------------------
echo Access Tokens Dumped to %~dp0depotkeys.
start "" "explorer.exe" "%~dp0depotkeys"
pause
popd
goto :menu
)
echo Selective Access Token Disabled.
echo Dumping...
echo -------------------------------
rd /s /q %~dp0depotkeys %_null%
mkdir "%~dp0depotkeys"
pushd "%~dp0depotkeys""
"%~dp0bin\AccessTokenDumper\AccessTokenDumper.exe" -username "%SteamAcc%" -password "%SteamPass%"
echo -------------------------------
echo Access Tokens Dumped to %~dp0depotkeys.
popd
goto :Menu




:DumpKeys
set "Info=Dump Depot Keys"
call :MenuInfo
echo Depot Key Save folder: %~dp0depottokens
set "SteamAcc="
set "SteamPass="
:DumpKeys1
set /p SteamAcc=Steam Account Username:
if NOT defined SteamAcc ( echo Please Input vaild Steam Account Username. & goto :DumpKeys1 )
:DumpKeys2
set /p SteamPass=Steam Account Password:
if NOT defined SteamPass ( echo Please Input vaild Steam Account Password. & goto :DumpKeys2 )
choice /N /C YN /M "Selective Dump Depot (Default: No)[Y/N]:"
IF %ERRORLEVEL% EQU 1 (
echo Selective Dump Depot Enabled.
echo Dumping...
echo -------------------------------
rd /s /q %~dp0depottokens %_null%
mkdir "%~dp0depottokens"
pushd "%~dp0depottokens""
"%~dp0bin\DepotDumper\DepotDumper.exe" -username "%SteamAcc%" -password "%SteamPass%" -select
echo -------------------------------
echo Depot Key Dumped to %~dp0depottokens.
start "" "explorer.exe" "%~dp0depottokens"
pause
popd
goto :menu
)

echo Selective Dump Depot Disabled.
echo Dumping...
echo -------------------------------
rd /s /q %~dp0depottokens %_null%
mkdir "%~dp0depottokens"
pushd "%~dp0depottokens""
"%~dp0bin\DepotDumper\DepotDumper.exe" -username "%SteamAcc%" -password "%SteamPass%"
echo -------------------------------
echo Depot Key Dumped to %~dp0depottokens.
popd
goto :Menu

:Download
set "Info=Download App With Depot Key"
set "GameAPPID="
set "FilePath="
set "GameDepot="
set "GameManifest="
set "KeyPath="
set "DownloadPath="

set "DownloadPathArg="
set "KeyPathArg="
set "GameAPPIDArg="
set "GameDepotArg="
set "GameManifestArg="

call :MenuInfo

echo Select depot keys file:
call :FileSelect File .*
set KeyPath=%FilePath%
echo Depot Keys File: %KeyPath%

:Download1
set /p GameAPPID=Input Game APPID, then press Enter:
set "Num="
if NOT defined GameAPPID ( echo Please Input vaild Game APPID. & goto :Download1 )
for /f "delims=0123456789" %%i in ("%GameAPPID%") do set Num=%%i
if defined Num ( echo Please Input vaild Game APPID. & goto :Download1 ) 
if /I %GameAPPID% GTR 99999999 ( echo Please Input vaild Game APPID. & goto :Download1 ) 
:Download2
set /p GameDepot=Input Game Depot ID, then press Enter (If unspecified leave blank, Default: [Leave Blank]):
set "Num="
for /f "delims=0123456789" %%i in ("%GameDepot%") do set Num=%%i
if defined Num ( echo Please Input vaild Game Depot. & goto :Download2 ) 
:Download3
set /p GameManifest=Input Game Manifest ID, then press Enter (If unspecified leave blank, Default: [Leave Blank]):
set "Num="
for /f "delims=0123456789" %%i in ("%GameManifest%") do set Num=%%i
if defined Num ( echo Please Input vaild Game Manifest. & goto :Download3 ) 
:Download4
set /p GameAppToken=Input Game App Token, then press Enter (If unspecified leave blank, Default: [Leave Blank]):
set "Num="
for /f "delims=0123456789" %%i in ("%GameAppToken%") do set Num=%%i
if defined Num ( echo Please Input vaild Game App Token. & goto :Download4 ) 
:Download5
set /p GamePackageToken=Input Game Package Token, then press Enter (If unspecified leave blank, Default: [Leave Blank]):
set "Num="
for /f "delims=0123456789" %%i in ("%GamePackageToken%") do set Num=%%i
if defined Num ( echo Please Input vaild Game PackageToken. & goto :Download5 ) 

choice /N /C YN /M "Download to Script Folder? (Default: Yes)[Y/N]:"
IF %ERRORLEVEL% EQU 1 ( echo Download to Script Folder. & echo Download Path: "%~dp0depots" & set DownloadPath="%~dp0depots") else (
echo Select Download Folder:
call :FileSelect Folder
set DownloadPath=!FilePath!
echo Download Path: !FilePath!
)

echo Downloading......
echo --------------------------------
set "GameAPPIDArg=-app %GameAPPID% "
set "KeyPathArg=-depotkeys %KeyPath% "
set "DownloadPathArg=-dir %DownloadPath% "
if defined GameDepot ( set "GameDepotArg=-depot %GameDepot% " ) else ( set "GameDepotArg=")
if defined GameManifest ( set "GameManifestArg=-manifest %GameManifest% " ) else ( set "GameManifestArg=")
if defined GameAppToken ( set "GameAppTokenArg=-apptoken %GameAppToken% " ) else ( set "GameAppTokenArg=")
if defined GamePackageToken ( set "GamePackageTokenArg=-packagetoken %GamePackageToken% " ) else ( set "GamePackageTokenArg=")
"%~dp0bin\DepotDownloaderMod\DepotDownloaderMod.exe" -max-servers 128 -max-downloads 256 %GameAPPIDArg%%KeyPathArg%%GameDepotArg%%GameManifestArg%%DownloadPathArg%%GameAppTokenarg%%GamePackageTokenarg%
echo --------------------------------
echo Download Complete.
start "" "explorer.exe" "%DownloadPath%"
pause
goto :Menu 



::------------------------------Files---------------------------------------------------------------------
::------------Check File--------------------------
:checkfile
if /I ["%~nx1"]==["%2"] set "result=1"
if /I NOT ["%~nx1"]==["%2"] set "result=0"
set "CheckFileName=%~nx1"
goto :eof
::------------File Selector-------------------------
:FileSelect
set "FilePath="
set "FileType=%1"
set "FileExt=%2"
if /i %FileType%==File (
choice /N /C CIS /M "Please [S]elect File or [I]nput File Full path or [C]ancel: [S,I,C]:"
if errorlevel 3 goto :selectpath 
if errorlevel 2 goto :inputpath  
if errorlevel 1 echo Cenceled. & pause & goto :Menu
)

if /i %FileType%==Folder (
choice /N /C CIS /M "Please [S]elect Folder or [I]nput Folder Full path or [C]ancel: [S,I,C]:"
if errorlevel 3 goto :selectpath 
if errorlevel 2 goto :inputpath
if errorlevel 1 echo Cenceled. & pause & goto :Menu
)

:FileSelect1
if NOT exist %FilePath% echo %FileType% Not Found. & echo -------- & goto :FileSelect
goto :eof

::---------------Select File Path---------------
:selectpath
for %%i in (powershell.exe) do if "%%~$path:i"=="" (
echo Powershell is not installed in the system.
echo Please use Input %FileType% Path.
goto :FileSelect
)

if /i %FileType%==File goto :selectfile 
if /i %FileType%==Folder goto :selectfolder

:selectfile
set "dialog=powershell -sta "Add-Type -AssemblyName System.windows.forms^|Out-Null;$f=New-Object System.Windows.Forms.OpenFileDialog;$f.InitialDirectory=pwd;$f.showHelp=$false;$f.Filter='%FileExt% files (*%FileExt%)^|*%FileExt%^|All files (*.*)^|*.*';$f.ShowDialog()^|Out-Null;$f.FileName""
for /f "delims=" %%I in ('%dialog%') do set "FilePath="%%I""
if NOT defined FilePath echo No %FileType% selected. & goto :FileSelect
goto :FileSelect1

:selectfolder
set "dialog=powershell -sta "Add-Type -AssemblyName System.windows.forms^|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.ShowNewFolderButton=$true;$f.ShowDialog();$f.SelectedPath""
for /F "delims=" %%I in ('%dialog%') do set "FilePath="%%I""
if NOT defined FilePath echo No %FileType% selected. & goto :FileSelect
goto :FileSelect1
::---------------Input File Path---------------
:inputpath
if /i %FileType%==File echo Drag and Drop File or Input File Full Path, then press Enter:
if /i %FileType%==Folder echo Drag and Drop Folder or Input Folder Full Path, then press Enter:
set /p FilePath=
if NOT defined FilePath echo No %FileType% selected. & goto :FileSelect
set FilePath=%FilePath:"=%
set FilePath="%FilePath%"
goto :FileSelect1

::--------------------------------------------------------------------------------------------------------------

::-------------About---------------------
:About
set "Info=About"
call :MenuInfo
echo.
echo              Steam Depot Tools %Ver%
echo                 Steam Depot Tools
echo  Github: https://github.com/oureveryday/Steam-Depot-Tools
echo  Gitlab: https://gitlab.com/oureveryday/Steam-Depot-Tools
echo.
pause
goto :Menu

::--------------------Info------------------------
:MenuInfo
cls
echo ---------------------------------------------
echo ---------- Steam Depot Tools %Ver% ------------
echo ---------------------------------------------
echo.
echo ---------------%Info%---------------------
goto :eof






