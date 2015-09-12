if not defined msys2 goto :error
if not defined mirrors goto :error
if not defined APPVEYOR_BUILD_FOLDER goto :error
if not exist %msys2% (
	appveyor DownloadFile ^
	http://downloads.sourceforge.net/project/msys2/Base/x86_64/%msys2%.xz ^
	|| goto :error
	7z x %msys2%.xz > nul || goto :error
	del %msys2%.xz || goto :error
)
if not exist %mirrors% (
	appveyor DownloadFile http://repo.msys2.org/msys/x86_64/%mirrors% ^
	|| goto :error
)
7z x -oC:\ %msys2% > nul || goto :error
C:\msys64\usr\bin\cygpath.exe -u %APPVEYOR_BUILD_FOLDER% > work_directory ^
|| goto :error
set /P work_directory= < work_directory || goto :error
del work_directory || goto :error
echo cd "%work_directory%" >> C:\msys64\etc\profile || goto :error
set work_directory= || goto error
set MSYSTEM=MSYS2 || goto :error
(
echo cd "${APPVEYOR_BUILD_FOLDER}" ^^^&^^^&
echo pacman --upgrade --noconfirm "${mirrors}"
) | C:\msys64\usr\bin\sh --login -s > nul 2>&1 || goto :error
(
echo pacman --sync --refresh ^^^&^^^&
echo pacman --sync --noconfirm --needed ^
	bash pacman msys2-runtime msys2-runtime-devel
) | C:\msys64\usr\bin\sh --login -s >nul 2>&1 || goto :error
(
echo pacman --sync --noconfirm --sysupgrade ^^^&^^^&
echo pacman --sync --needed --noconfirm base-devel mingw-w64-x86_64-gcc
) | C:\msys64\usr\bin\sh --login -s > nul 2>&1 || goto :error
set MSYSTEM= || goto :error
goto :EOF
:error
echo msys2.bat failed with errorlevel %errorlevel%
exit /b 1
