@echo off

REM
REM This source file is part of appleseed.
REM Visit https://appleseedhq.net/ for additional information and resources.
REM
REM This software is released under the MIT license.
REM
REM Copyright (c) 2014-2019 Francois Beaune, The appleseedhq Organization
REM
REM Permission is hereby granted, free of charge, to any person obtaining a copy
REM of this software and associated documentation files (the "Software"), to deal
REM in the Software without restriction, including without limitation the rights
REM to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
REM copies of the Software, and to permit persons to whom the Software is
REM furnished to do so, subject to the following conditions:
REM
REM The above copyright notice and this permission notice shall be included in
REM all copies or substantial portions of the Software.
REM
REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
REM THE SOFTWARE.
REM

setlocal

if not defined VCINSTALLDIR (
    echo Please run this batch file from a Visual Studio Native Tools Command Prompt.
    goto end
)

set root=%~dp0
set root_fwd_slashes=%root:\=/%

set generator=%1
set boost_root=%2
set qt_root_path=%3
set python_include_dir=%4
set python_library=%5

if [%generator%] == [] goto syntax
if [%boost_root%] == [] goto syntax
if [%qt_root_path%] == [] goto syntax
if [%python_include_dir%] == [] goto syntax
if [%python_library%] == [] goto syntax

if [%generator%] == ["Visual Studio 14 2015 Win64"] (
    set platform=vc140
    goto start
)

if [%generator%] == ["Visual Studio 15 2017 Win64"] (
    set platform=vc141
    goto start
)

:syntax

echo Syntax:
echo   %~n0%~x0 ^<cmake-generator^> ^<boost-root^> ^<qt-root-path^> ^<python-include-dir^> ^<python-library^>
echo.
echo Supported values for ^<cmake-generator^>:
echo   "Visual Studio 14 2015 Win64"
echo   "Visual Studio 15 2017 Win64"
echo.
echo Example:
echo   %~n0%~x0 "Visual Studio 15 2017 Win64" C:\dev\boost_1_69_0 C:\dev\qt\5.12.2\msvc2017_64 C:\Python27\include C:\Python27\libs\python27.lib
goto end

:start

echo Build configuration:
echo.
echo   generator ............ %generator%
echo   platform ............. %platform%
echo   root ................. %root% (%root_fwd_slashes%)
echo   boost_root ........... %boost_root%
echo   qt_root_path ......... %qt_root_path%
echo   python_include_dir ... %python_include_dir%
echo   python_library ....... %python_library%
echo.

set src=%root%src
set devenv=call %root%tools\devenv-wrapper.bat
set redirect=^>^> BUILDLOG.txt 2^>^&1

mkdir %root%build\%platform% 2>nul
type nul > %root%build\%platform%\BUILDLOG.txt

REM ===============================================================================

:xercesc
echo %time% ^| [ 1/14] Building Xerces-C...

    mkdir %root%build\%platform%\xerces-c-debug 2>nul
    pushd %root%build\%platform%\xerces-c-debug
        echo === Xerces-C (Debug) ========================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\xerces-c-debug %src%\xerces-c %redirect%
        %devenv% xerces-c.sln /build Debug /project INSTALL %redirect%
        copy src\xerces-c.dir\Debug\*.pdb %root%stage\%platform%\xerces-c-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\xerces-c-release 2>nul
    pushd %root%build\%platform%\xerces-c-release
        echo === Xerces-C (Release) ======================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\xerces-c-release %src%\xerces-c %redirect%
        %devenv% xerces-c.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:llvm
echo %time% ^| [ 2/14] Building LLVM...

    mkdir %root%build\%platform%\llvm-debug 2>nul
    pushd %root%build\%platform%\llvm-debug
        echo === LLVM (Debug) ============================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -Thost=x64 -DCMAKE_BUILD_TYPE=Debug -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\llvm-debug %src%\llvm %redirect%
        %devenv% llvm.sln /build Debug /project INSTALL %redirect%
        for /R lib\ %%f in (*.pdb) do @copy /Y "%%f" %root%stage\%platform%\llvm-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\llvm-release 2>nul
    pushd %root%build\%platform%\llvm-release
        echo === LLVM (Release) ============================================================ > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -Thost=x64 -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=ON -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\llvm-release %src%\llvm %redirect%
        %devenv% llvm.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:zlib
echo %time% ^| [ 3/14] Building zlib...

    mkdir %root%build\%platform%\zlib-debug 2>nul
    pushd %root%build\%platform%\zlib-debug
        echo === zlib (Debug) ============================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\zlib-debug %src%\zlib %redirect%
        %devenv% zlib.sln /build Debug /project INSTALL %redirect%
        ren %src%\zlib\zconf.h.included zconf.h
        copy zlibstatic.dir\Debug\*.pdb %root%stage\%platform%\zlib-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\zlib-release 2>nul
    pushd %root%build\%platform%\zlib-release
        echo === zlib (Release) ============================================================ > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\zlib-release %src%\zlib %redirect%
        %devenv% zlib.sln /build Release /project INSTALL %redirect%
        ren %src%\zlib\zconf.h.included zconf.h
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:libpng
echo %time% ^| [ 4/14] Building libpng...

    mkdir %root%build\%platform%\libpng-debug 2>nul
    pushd %root%build\%platform%\libpng-debug
        echo === libpng (Debug) ============================================================ > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DZLIB_INCLUDE_DIR=%root%stage\%platform%\zlib-debug\include -DZLIB_LIBRARY=%root%stage\%platform%\zlib-debug\lib\zlibstaticd.lib -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\libpng-debug %src%\libpng %redirect%
        %devenv% libpng.sln /build Debug /project INSTALL %redirect%
        copy png16_static.dir\Debug\*.pdb %root%stage\%platform%\libpng-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\libpng-release 2>nul
    pushd %root%build\%platform%\libpng-release
        echo === libpng (Release) ========================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DZLIB_INCLUDE_DIR=%root%stage\%platform%\zlib-release\include -DZLIB_LIBRARY=%root%stage\%platform%\zlib-release\lib\zlibstatic.lib -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\libpng-release %src%\libpng %redirect%
        %devenv% libpng.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:libjpeg
echo %time% ^| [ 5/14] Building libjpeg-turbo...

    mkdir %root%build\%platform%\libjpeg-turbo-debug 2>nul
    pushd %root%build\%platform%\libjpeg-turbo-debug
        echo === libjpeg-turbo (Debug) ===================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DWITH_SIMD=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\libjpeg-turbo-debug %src%\libjpeg-turbo %redirect%
        %devenv% libjpeg-turbo.sln /build Debug /project INSTALL %redirect%
        copy jpeg-static.dir\Debug\*.pdb %root%stage\%platform%\libjpeg-turbo-debug\lib %redirect%
        copy turbojpeg-static.dir\Debug\*.pdb %root%stage\%platform%\libjpeg-turbo-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\libjpeg-turbo-release 2>nul
    pushd %root%build\%platform%\libjpeg-turbo-release
        echo === libjpeg-turbo (Release) =================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DWITH_SIMD=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\libjpeg-turbo-release %src%\libjpeg-turbo %redirect%
        %devenv% libjpeg-turbo.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:libtiff
echo %time% ^| [ 6/14] Building libtiff...

    mkdir %root%build\%platform%\libtiff-debug 2>nul
    pushd %root%build\%platform%\libtiff-debug
        echo === libtiff (Debug) =========================================================== > BUILDLOG.txt
        xcopy /E /Q /Y %src%\libtiff\*.* . %redirect%
        copy /Y nmake-debug.opt nmake.opt %redirect%
        nmake -f Makefile.vc JPEG_SUPPORT=1 JPEGDIR=%root%stage\%platform%\libjpeg-turbo-debug JPEG_INCLUDE=-I%root%stage\%platform%\libjpeg-turbo-debug\include JPEG_LIB=%root%stage\%platform%\libjpeg-turbo-debug\lib\jpeg-static.lib ZIP_SUPPORT=1 ZLIBDIR=%root%stage\%platform%\zlib-debug ZLIB_INCLUDE=-I%root%stage\%platform%\zlib-debug\include ZLIB_LIB=%root%stage\%platform%\zlib-debug\lib\zlibstaticd.lib %redirect%
        mkdir %root%stage\%platform%\libtiff-debug\lib %redirect%
        mkdir %root%stage\%platform%\libtiff-debug\include %redirect%
        copy libtiff\libtiff.lib %root%stage\%platform%\libtiff-debug\lib %redirect%
        copy libtiff\libtiff.pdb %root%stage\%platform%\libtiff-debug\lib %redirect%
        copy libtiff\*.h %root%stage\%platform%\libtiff-debug\include %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\libtiff-release 2>nul
    pushd %root%build\%platform%\libtiff-release
        echo === libtiff (Release) ========================================================= > BUILDLOG.txt
        xcopy /E /Q /Y %src%\libtiff\*.* . %redirect%
        copy /Y nmake-release.opt nmake.opt %redirect%
        nmake -f Makefile.vc JPEG_SUPPORT=1 JPEGDIR=%root%stage\%platform%\libjpeg-turbo-release JPEG_INCLUDE=-I%root%stage\%platform%\libjpeg-turbo-release\include JPEG_LIB=%root%stage\%platform%\libjpeg-turbo-release\lib\jpeg-static.lib ZIP_SUPPORT=1 ZLIBDIR=%root%stage\%platform%\zlib-release ZLIB_INCLUDE=-I%root%stage\%platform%\zlib-release\include ZLIB_LIB=%root%stage\%platform%\zlib-release\lib\zlibstatic.lib %redirect%
        mkdir %root%stage\%platform%\libtiff-release\lib %redirect%
        mkdir %root%stage\%platform%\libtiff-release\include %redirect%
        copy libtiff\libtiff.lib %root%stage\%platform%\libtiff-release\lib %redirect%
        copy libtiff\*.h %root%stage\%platform%\libtiff-release\include %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:ilmbase
echo %time% ^| [ 7/14] Building ilmbase...

    mkdir %root%build\%platform%\ilmbase-debug 2>nul
    pushd %root%build\%platform%\ilmbase-debug
        echo === ilmbase (Debug) =========================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\ilmbase-debug %src%\ilmbase %redirect%
        %devenv% ilmbase.sln /build Debug /project INSTALL %redirect%
        copy Half\Half.dir\Debug\*.pdb %root%stage\%platform%\ilmbase-debug\lib %redirect%
        copy Iex\Iex.dir\Debug\*.pdb %root%stage\%platform%\ilmbase-debug\lib %redirect%
        copy IexMath\IexMath.dir\Debug\*.pdb %root%stage\%platform%\ilmbase-debug\lib %redirect%
        copy IlmThread\IlmThread.dir\Debug\*.pdb %root%stage\%platform%\ilmbase-debug\lib %redirect%
        copy Imath\Imath.dir\Debug\*.pdb %root%stage\%platform%\ilmbase-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\ilmbase-release 2>nul
    pushd %root%build\%platform%\ilmbase-release
        echo === ilmbase (Release) ========================================================= > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\ilmbase-release %src%\ilmbase %redirect%
        %devenv% ilmbase.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:openexr
echo %time% ^| [ 8/14] Building OpenEXR...

    mkdir %root%build\%platform%\openexr-debug 2>nul
    pushd %root%build\%platform%\openexr-debug
        echo === OpenEXR (Debug) =========================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=OFF -DILMBASE_PACKAGE_PREFIX=%root%stage\%platform%\ilmbase-debug -DZLIB_INCLUDE_DIR=%root%stage\%platform%\zlib-debug\include -DZLIB_LIBRARY=%root%stage\%platform%\zlib-debug\lib\zlibstaticd.lib -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\openexr-debug %src%\openexr %redirect%
        %devenv% openexr.sln /build Debug /project INSTALL %redirect%
        copy IlmImf\IlmImf.dir\Debug\*.pdb %root%stage\%platform%\openexr-debug\lib %redirect%
        copy IlmImfUtil\IlmImfUtil.dir\Debug\*.pdb %root%stage\%platform%\openexr-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\openexr-release 2>nul
    pushd %root%build\%platform%\openexr-release
        echo === OpenEXR (Release) ========================================================= > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DILMBASE_PACKAGE_PREFIX=%root%stage\%platform%\ilmbase-release -DZLIB_INCLUDE_DIR=%root%stage\%platform%\zlib-release\include -DZLIB_LIBRARY=%root%stage\%platform%\zlib-release\lib\zlibstatic.lib -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\openexr-release %src%\openexr %redirect%
        %devenv% openexr.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:ocio
echo %time% ^| [ 9/14] Building OpenColorIO...

    set OCIO_PATH_SAVE=%PATH%
    set PATH=%root%tools\patch;%PATH%

    mkdir %root%build\%platform%\ocio-debug 2>nul
    pushd %root%build\%platform%\ocio-debug
        echo === OpenColorIO (Debug) ======================================================= > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DOCIO_BUILD_SHARED=OFF -DOCIO_BUILD_TRUELIGHT=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_PYGLUE=OFF -DOCIO_USE_BOOST_PTR=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\ocio-debug %src%\ocio %redirect%
        %devenv% OpenColorIO.sln /build Debug /project INSTALL %redirect%
        copy ext\dist\lib\*.lib %root%stage\%platform%\ocio-debug\lib %redirect%
        copy ext\build\tinyxml\tinyxml.dir\Debug\*.pdb %root%stage\%platform%\ocio-debug\lib %redirect%
        copy ext\build\yaml-cpp\yaml-cpp.dir\Debug\*.pdb %root%stage\%platform%\ocio-debug\lib %redirect%
        copy src\core\OpenColorIO_STATIC.dir\Debug\*.pdb %root%stage\%platform%\ocio-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\ocio-release 2>nul
    pushd %root%build\%platform%\ocio-release
        echo === OpenColorIO (Release) ===================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DOCIO_BUILD_SHARED=OFF -DOCIO_BUILD_TRUELIGHT=OFF -DOCIO_BUILD_NUKE=OFF -DOCIO_BUILD_PYGLUE=OFF -DOCIO_USE_BOOST_PTR=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\ocio-release %src%\ocio %redirect%
        %devenv% OpenColorIO.sln /build Release /project INSTALL %redirect%
        copy ext\dist\lib\*.lib %root%stage\%platform%\ocio-release\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    set PATH=%OCIO_PATH_SAVE%

REM ===============================================================================

:oiio
echo %time% ^| [10/14] Building OpenImageIO...

    mkdir %root%build\%platform%\oiio-debug 2>nul
    pushd %root%build\%platform%\oiio-debug
        echo === OpenImageIO (Debug) ======================================================= > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DCMAKE_PREFIX_PATH=N:\appleseed\Qt\5.12.2\msvc2015_64 -DBUILDSTATIC=ON -DLINKSTATIC=ON -DUSE_SIMD=sse2 -DOIIO_BUILD_TESTS=OFF -DUSE_PYTHON=OFF -DUSE_FIELD3D=OFF -DUSE_OPENVDB=OFF -DUSE_TBB=OFF -DUSE_FFMPEG=OFF -DUSE_OPENJPEG=OFF -DUSE_OPENCV=OFF -DUSE_FREETYPE=OFF -DUSE_GIF=OFF -DUSE_PTEX=OFF -DUSE_WEBP=OFF -DUSE_LIBRAW=OFF -DUSE_NUKE=OFF -DUSE_DICOM=OFF -DEXTRA_CPP_ARGS="/DBOOST_ALL_NO_LIB /DBOOST_PYTHON_STATIC_LIB" -DILMBASE_ROOT_DIR=%root_fwd_slashes%stage/%platform%/ilmbase-debug -DOPENEXR_ROOT_DIR=%root_fwd_slashes%stage/%platform%/openexr-debug -DZLIB_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/zlib-debug/include -DZLIB_LIBRARY=%root_fwd_slashes%stage/%platform%/zlib-debug/lib/zlibstaticd.lib -DPNG_PNG_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libpng-debug/include -DPNG_LIBRARY=%root_fwd_slashes%stage/%platform%/libpng-debug/lib/libpng16_staticd.lib -DJPEG_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libjpeg-turbo-debug/include -DJPEG_LIBRARY=%root_fwd_slashes%stage/%platform%/libjpeg-turbo-debug/lib/jpeg-static.lib -DTIFF_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libtiff-debug/include -DTIFF_LIBRARY=%root_fwd_slashes%stage/%platform%/libtiff-debug/lib/libtiff.lib -DOCIO_INCLUDE_PATH=%root_fwd_slashes%stage/%platform%/ocio-debug/include -DOCIO_LIBRARY_PATH=%root_fwd_slashes%stage/%platform%/ocio-debug/lib -DCMAKE_LIBRARY_PATH=%root%build\%platform%\ocio-debug\ext\dist\lib -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\oiio-debug %src%\oiio %redirect%
        %devenv% OpenImageIO.sln /build Debug /project INSTALL %redirect%
        copy src\libOpenImageIO\OpenImageIO.dir\Debug\*.pdb %root%stage\%platform%\oiio-debug\lib %redirect%
        copy src\libutil\OpenImageIO_Util.dir\Debug\*.pdb %root%stage\%platform%\oiio-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\oiio-release 2>nul
    pushd %root%build\%platform%\oiio-release
        echo === OpenImageIO (Release) ===================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DCMAKE_PREFIX_PATH=N:\appleseed\Qt\5.12.2\msvc2015_64 -DBUILDSTATIC=ON -DLINKSTATIC=ON -DUSE_SIMD=sse2 -DOIIO_BUILD_TESTS=OFF -DUSE_PYTHON=OFF -DUSE_FIELD3D=OFF -DUSE_OPENVDB=OFF -DUSE_TBB=OFF -DUSE_FFMPEG=OFF -DUSE_OPENJPEG=OFF -DUSE_OPENCV=OFF -DUSE_FREETYPE=OFF -DUSE_GIF=OFF -DUSE_PTEX=OFF -DUSE_WEBP=OFF -DUSE_LIBRAW=OFF -DUSE_NUKE=OFF -DUSE_DICOM=OFF -DEXTRA_CPP_ARGS="/DBOOST_ALL_NO_LIB /DBOOST_PYTHON_STATIC_LIB" -DILMBASE_ROOT_DIR=%root_fwd_slashes%stage/%platform%/ilmbase-release -DOPENEXR_ROOT_DIR=%root_fwd_slashes%stage/%platform%/openexr-release -DZLIB_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/zlib-release/include -DZLIB_LIBRARY=%root_fwd_slashes%stage/%platform%/zlib-release/lib/zlibstatic.lib -DPNG_PNG_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libpng-debug/include -DPNG_LIBRARY=%root_fwd_slashes%stage/%platform%/libpng-release/lib/libpng16_static.lib -DJPEG_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libjpeg-turbo-release/include -DJPEG_LIBRARY=%root_fwd_slashes%stage/%platform%/libjpeg-turbo-release/lib/jpeg-static.lib -DTIFF_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libtiff-release/include -DTIFF_LIBRARY=%root_fwd_slashes%stage/%platform%/libtiff-release/lib/libtiff.lib -DOCIO_INCLUDE_PATH=%root_fwd_slashes%stage/%platform%/ocio-release/include -DOCIO_LIBRARY_PATH=%root_fwd_slashes%stage/%platform%/ocio-release/lib -DCMAKE_LIBRARY_PATH=%root%build\%platform%\ocio-release\ext\dist\lib -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\oiio-release %src%\oiio %redirect%
        %devenv% OpenImageIO.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    REM Build a Ship variant of OIIO (same as release bu with /GL (Whole Program Optimization) enabled) to work around a bug that causes VS 2015 builds of appleseed in Ship configuration to crash.
    REM See https://developercommunity.visualstudio.com/content/problem/701555/stdthread-with-lambda-crashes-when-compiled-withou.html for more information.
    mkdir %root%build\%platform%\oiio-ship 2>nul
    pushd %root%build\%platform%\oiio-ship
        echo === OpenImageIO (Ship) ===================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DCMAKE_PREFIX_PATH=N:\appleseed\Qt\5.12.2\msvc2015_64 -DBUILDSTATIC=ON -DLINKSTATIC=ON -DUSE_SIMD=sse2 -DOIIO_BUILD_TESTS=OFF -DUSE_PYTHON=OFF -DUSE_FIELD3D=OFF -DUSE_OPENVDB=OFF -DUSE_TBB=OFF -DUSE_FFMPEG=OFF -DUSE_OPENJPEG=OFF -DUSE_OPENCV=OFF -DUSE_FREETYPE=OFF -DUSE_GIF=OFF -DUSE_PTEX=OFF -DUSE_WEBP=OFF -DUSE_LIBRAW=OFF -DUSE_NUKE=OFF -DUSE_DICOM=OFF -DEXTRA_CPP_ARGS="/DBOOST_ALL_NO_LIB /DBOOST_PYTHON_STATIC_LIB /GL" -DILMBASE_ROOT_DIR=%root_fwd_slashes%stage/%platform%/ilmbase-release -DOPENEXR_ROOT_DIR=%root_fwd_slashes%stage/%platform%/openexr-release -DZLIB_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/zlib-release/include -DZLIB_LIBRARY=%root_fwd_slashes%stage/%platform%/zlib-release/lib/zlibstatic.lib -DPNG_PNG_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libpng-debug/include -DPNG_LIBRARY=%root_fwd_slashes%stage/%platform%/libpng-release/lib/libpng16_static.lib -DJPEG_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libjpeg-turbo-release/include -DJPEG_LIBRARY=%root_fwd_slashes%stage/%platform%/libjpeg-turbo-release/lib/jpeg-static.lib -DTIFF_INCLUDE_DIR=%root_fwd_slashes%stage/%platform%/libtiff-release/include -DTIFF_LIBRARY=%root_fwd_slashes%stage/%platform%/libtiff-release/lib/libtiff.lib -DOCIO_INCLUDE_PATH=%root_fwd_slashes%stage/%platform%/ocio-release/include -DOCIO_LIBRARY_PATH=%root_fwd_slashes%stage/%platform%/ocio-release/lib -DCMAKE_LIBRARY_PATH=%root%build\%platform%\ocio-release\ext\dist\lib -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\oiio-ship %src%\oiio %redirect%
        %devenv% OpenImageIO.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:osl
echo %time% ^| [11/14] Building OpenShadingLanguage...

    set OSL_PATH_SAVE=%PATH%

    mkdir %root%build\%platform%\osl-debug 2>nul
    pushd %root%build\%platform%\osl-debug
        echo === OpenShadingLanguage (Debug) =============================================== > BUILDLOG.txt
        set PATH=%root%tools\FlexBison\bin;%root%stage\%platform%\llvm-debug\bin;%OSL_PATH_SAVE%
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DOSL_BUILD_PLUGINS=OFF -DOSL_BUILD_TESTS=OFF -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DCMAKE_PREFIX_PATH=N:\appleseed\Qt\5.12.2\msvc2015_64 -DBUILDSTATIC=ON -DLINKSTATIC=ON -DENABLERTTI=ON -DLLVM_STATIC=ON -DUSE_SIMD=sse2 -DUSE_PARTIO=OFF -DILMBASE_ROOT_DIR=%root%stage\%platform%\ilmbase-debug -DOPENEXR_ROOT_DIR=%root%stage\%platform%\openexr-debug -DOPENIMAGEIO_ROOT_DIR=%root%stage\%platform%\oiio-debug -DZLIB_INCLUDE_DIR=%root%stage\%platform%\zlib-debug\include -DZLIB_LIBRARY=%root%stage\%platform%\zlib-debug\lib\zlibstaticd.lib -DEXTRA_CPP_ARGS="/DOIIO_STATIC_BUILD /DTINYFORMAT_ALLOW_WCHAR_STRINGS" -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\osl-debug %src%\osl %redirect%
        %devenv% osl.sln /build Debug /project INSTALL %redirect%
        copy src\liboslcomp\oslcomp.dir\Debug\*.pdb %root%stage\%platform%\osl-debug\lib %redirect%
        copy src\liboslexec\oslexec.dir\Debug\*.pdb %root%stage\%platform%\osl-debug\lib %redirect%
        copy src\liboslnoise\oslnoise.dir\Debug\*.pdb %root%stage\%platform%\osl-debug\lib %redirect%
        copy src\liboslquery\oslquery.dir\Debug\*.pdb %root%stage\%platform%\osl-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\osl-release 2>nul
    pushd %root%build\%platform%\osl-release
        echo === OpenShadingLanguage (Release) ============================================= > BUILDLOG.txt
        set PATH=%root%tools\FlexBison\bin;%root%stage\%platform%\llvm-release\bin;%OSL_PATH_SAVE%
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DOSL_BUILD_PLUGINS=OFF -DOSL_BUILD_TESTS=OFF -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DCMAKE_PREFIX_PATH=N:\appleseed\Qt\5.12.2\msvc2015_64 -DBUILDSTATIC=ON -DLINKSTATIC=ON -DENABLERTTI=ON -DLLVM_STATIC=ON -DUSE_SIMD=sse2 -DUSE_PARTIO=OFF -DILMBASE_ROOT_DIR=%root%stage\%platform%\ilmbase-release -DOPENEXR_ROOT_DIR=%root%stage\%platform%\openexr-release -DOPENIMAGEIO_ROOT_DIR=%root%stage\%platform%\oiio-release -DZLIB_INCLUDE_DIR=%root%stage\%platform%\zlib-release\include -DZLIB_LIBRARY=%root%stage\%platform%\zlib-release\lib\zlibstatic.lib -DEXTRA_CPP_ARGS="/DOIIO_STATIC_BUILD /DTINYFORMAT_ALLOW_WCHAR_STRINGS" -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\osl-release %src%\osl %redirect%
        %devenv% osl.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    set PATH=%OSL_PATH_SAVE%

REM ===============================================================================

:seexpr
echo %time% ^| [12/14] Building SeExpr...

    mkdir %root%build\%platform%\seexpr-debug 2>nul
    pushd %root%build\%platform%\seexpr-debug
        echo === SeExpr (Debug) ============================================================ > BUILDLOG.txt
        mkdir src\SeExpr\generated %redirect%
        mkdir src\SeExprEditor\generated %redirect%
        copy %src%\seexpr\windows7\SeExpr\generated\*.* src\SeExpr\generated %redirect%
        copy %src%\seexpr\windows7\SeExprEditor\generated\*.* src\SeExprEditor\generated %redirect%
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DZLIB_INCLUDE_DIR=%root%stage\%platform%\zlib-debug\include -DZLIB_LIBRARY=%root%stage\%platform%\zlib-debug\lib\zlibstaticd.lib -DPNG_PNG_INCLUDE_DIR=%root%stage\%platform%\libpng-debug\include -DPNG_LIBRARY=%root%stage\%platform%\libpng-debug\lib\libpng16_staticd.lib -DCMAKE_PREFIX_PATH=%qt_root_path% -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\seexpr-debug %src%\seexpr %redirect%
        %devenv% SeExpr.sln /build Debug /project INSTALL %redirect%
        copy src\SeExpr\SeExpr-static.dir\Debug\*.pdb %root%stage\%platform%\seexpr-debug\lib %redirect%
        copy src\SeExprEditor\SeExprEditor.dir\Debug\*.pdb %root%stage\%platform%\seexpr-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\seexpr-release 2>nul
    pushd %root%build\%platform%\seexpr-release
        echo === SeExpr (Release) ========================================================== > BUILDLOG.txt
        mkdir src\SeExpr\generated %redirect%
        mkdir src\SeExprEditor\generated %redirect%
        copy %src%\seexpr\windows7\SeExpr\generated\*.* src\SeExpr\generated %redirect%
        copy %src%\seexpr\windows7\SeExprEditor\generated\*.* src\SeExprEditor\generated %redirect%
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DZLIB_INCLUDE_DIR=%root%stage\%platform%\zlib-release\include -DZLIB_LIBRARY=%root%stage\%platform%\zlib-release\lib\zlibstatic.lib -DPNG_PNG_INCLUDE_DIR=%root%stage\%platform%\libpng-release\include -DPNG_LIBRARY=%root%stage\%platform%\libpng-release\lib\libpng16_static.lib -DCMAKE_PREFIX_PATH=%qt_root_path% -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\seexpr-release %src%\seexpr %redirect%
        %devenv% SeExpr.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:embree

echo %time% ^| [13/14] Building Embree...

    mkdir %root%build\%platform%\embree-debug 2>nul
    pushd %root%build\%platform%\embree-debug
        echo === Embree (Debug) ============================================================ > BUILDLOG.txt
        cmake -G %generator% -DCMAKE_BUILD_TYPE=Debug -DEMBREE_STATIC_LIB=ON -DEMBREE_TUTORIALS=OFF -DEMBREE_RAY_MASK=ON -DEMBREE_TASKING_SYSTEM=INTERNAL -DEMBREE_ISPC_SUPPORT=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\embree-debug %src%\embree %redirect%
        %devenv% embree3.sln /build Debug /project INSTALL %redirect%
        copy common\algorithms\algorithms.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy common\lexers\lexers.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy common\math\math.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy common\simd\simd.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy common\sys\sys.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy common\tasking\tasking.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy kernels\embree.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy kernels\embree_avx.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy kernels\embree_avx2.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        copy kernels\embree_sse42.dir\Debug\*.pdb %root%stage\%platform%\embree-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\embree-release 2>nul
    pushd %root%build\%platform%\embree-release
        echo === Embree (Release) ========================================================== > BUILDLOG.txt
        if [%platform%] == [vc140] (
            REM The CMake argument
            REM   -DCMAKE_CXX_FLAGS="-d2SSAOptimizer-"
            REM is required to work around a bug in the new SSA optimizer introduced in VS 2015:
            REM https://github.com/embree/embree/issues/157#issuecomment-334696351
            cmake -G %generator% -DCMAKE_BUILD_TYPE=Release -DEMBREE_STATIC_LIB=ON -DEMBREE_TUTORIALS=OFF -DEMBREE_RAY_MASK=ON -DEMBREE_TASKING_SYSTEM=INTERNAL -DEMBREE_ISPC_SUPPORT=OFF -DCMAKE_CXX_FLAGS="-d2SSAOptimizer-" -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\embree-release %src%\embree %redirect%
        ) else (
            cmake -G %generator% -DCMAKE_BUILD_TYPE=Release -DEMBREE_STATIC_LIB=ON -DEMBREE_TUTORIALS=OFF -DEMBREE_RAY_MASK=ON -DEMBREE_TASKING_SYSTEM=INTERNAL -DEMBREE_ISPC_SUPPORT=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\embree-release %src%\embree %redirect%
        )
        %devenv% embree3.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

:end_embree

REM ===============================================================================

:lz4
echo %time% ^| [14/14] Building lz4...

    mkdir %root%build\%platform%\lz4-debug 2>nul
    pushd %root%build\%platform%\lz4-debug
        echo === lz4 (Debug) =============================================================== > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DLZ4_BUILD_LEGACY_LZ4C=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\lz4-debug %src%\lz4\contrib\cmake_unofficial %redirect%
        %devenv% lz4.sln /build Debug /project INSTALL %redirect%
        copy lz4_static.dir\Debug\*.pdb %root%stage\%platform%\lz4-debug\lib %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

    mkdir %root%build\%platform%\lz4-release 2>nul
    pushd %root%build\%platform%\lz4-release
        echo === lz4 (Release) ============================================================= > BUILDLOG.txt
        cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DLZ4_BUILD_LEGACY_LZ4C=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\%platform%\lz4-release %src%\lz4\contrib\cmake_unofficial %redirect%
        %devenv% lz4.sln /build Release /project INSTALL %redirect%
        type BUILDLOG.txt >> %root%build\%platform%\BUILDLOG.txt
    popd

REM ===============================================================================

:done

echo %time% ^| Build complete.
echo.

:end

endlocal
