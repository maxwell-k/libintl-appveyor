rem Add mirrors and automatically move to APPVEYOR_BUILD_FOLDER
if not defined mirrors goto :error
if not defined APPVEYOR_BUILD_FOLDER goto :error
if not exist %mirrors% (
	appveyor DownloadFile http://repo.msys2.org/msys/x86_64/%mirrors% ^
	|| goto :error
)
cygpath.exe -u %APPVEYOR_BUILD_FOLDER% > work_directory || goto :error
set /P work_directory= < work_directory || goto :error
del work_directory || goto :error
echo cd "%work_directory%" >> C:\msys64\etc\profile || goto :error
set work_directory= || goto error
set MSYSTEM=MSYS2 || goto :error
(
echo cd "${APPVEYOR_BUILD_FOLDER}" ^^^&^^^&
echo pacman --upgrade --noconfirm "${mirrors}"
) | sh --login -s > nul 2>&1 || goto :error
set MSYSTEM= || goto :error
goto :EOF
:error
echo msys2.bat failed with errorlevel %errorlevel%
exit /b 1
