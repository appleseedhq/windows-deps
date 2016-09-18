@echo off

REM
REM This source file is part of appleseed.
REM Visit http://appleseedhq.net/ for additional information and resources.
REM
REM This software is released under the MIT license.
REM
REM Copyright (c) 2014-2015 Francois Beaune, The appleseedhq Organization
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

if not defined VCINSTALLDIR (
    echo Please run this batch file from a Visual Studio Native Tools Command Prompt.
    goto end
)

set root=%~dp0
set generator=%1
set boost_root=%2
set qt_qmake_path=%3
set python_include_dir=%4
set python_library=%5

if [%generator%] == [] goto syntax
if [%boost_root%] == [] goto syntax
if [%qt_qmake_path%] == [] goto syntax
if [%python_include_dir%] == [] goto syntax
if [%python_library%] == [] goto syntax

if [%generator%] == ["Visual Studio 12 2013 Win64"] (
    set pdb_file=vc120.pdb
    goto start
)

if [%generator%] == ["Visual Studio 14 2015 Win64"] (
    set pdb_file=vc140.pdb
    goto start
)

:syntax

echo Syntax:
echo   %~n0%~x0 ^<cmake-generator^> ^<boost-root^> ^<qmake-executable-path^> ^<python-include-dir^> ^<python-library^>
echo.
echo Supported values for ^<cmake-generator^>:
echo.
echo   "Visual Studio 12 2013 Win64"
echo   "Visual Studio 14 2015 Win64"
echo.
echo Example:
echo   %~n0%~x0 "Visual Studio 12 2013 Win64" C:\dev\boost_1_55_0 C:\dev\qt-everywhere-opensource-src-4.8.6\bin\qmake.exe C:\Python27\include C:\Python27\libs\python27.lib
goto end

:start

cd src

echo ===============================================================================
echo Building Xerces-C...
echo ===============================================================================

    cd xerces-c
        echo Compiling, messages are redirected to buildlog.txt...
        pushd Projects\Win32\VC12.appleseed\xerces-all
        mkdir build 2>nul
        devenv xerces-all.sln /build "Static Debug" /project all > build\buildlog.txt
        devenv xerces-all.sln /build "Static Release" /project all >> build\buildlog.txt
        popd

        pushd src
        xcopy /E /Q /Y *.hpp %root%stage\xerces-c\include\
        xcopy /E /Q /Y *.c %root%stage\xerces-c\include\
        popd
    cd ..

echo ===============================================================================
echo Building LLVM...
echo ===============================================================================

    cd llvm
        mkdir build-debug 2>nul
        cd build-debug
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_REQUIRES_RTTI=ON -DCMAKE_INSTALL_PREFIX=%root%stage\llvm-debug ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv llvm.sln /build Debug /project INSTALL > buildlog.txt
            copy lib\Transforms\IPO\LLVMipo.dir\Debug\%pdb_file% %root%stage\llvm-debug\lib
        cd ..

        mkdir build-release 2>nul
        cd build-release
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="X86" -DLLVM_REQUIRES_RTTI=ON -DCMAKE_INSTALL_PREFIX=%root%stage\llvm-release ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv llvm.sln /build Release /project INSTALL > buildlog.txt
        cd ..
    cd ..

echo ===============================================================================
echo Building zlib...
echo ===============================================================================

    cd zlib
        mkdir build 2>nul
        cd build
            cmake -Wno-dev -G %generator% -DCMAKE_INSTALL_PREFIX=%root%stage\zlib ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv zlib.sln /build Debug /project INSTALL > buildlog.txt
            devenv zlib.sln /build Release /project INSTALL >> buildlog.txt
            copy zlibstatic.dir\Debug\%pdb_file% %root%stage\zlib\lib
        cd ..
    cd ..

echo ===============================================================================
echo Building libpng...
echo ===============================================================================

    cd libpng
        mkdir build-debug 2>nul
        cd build-debug
            cmake -Wno-dev -G %generator% -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstaticd.lib -DCMAKE_INSTALL_PREFIX=%root%stage\libpng-debug ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv libpng.sln /build Debug /project INSTALL > buildlog.txt
            copy png16_static.dir\Debug\%pdb_file% %root%stage\libpng-debug\lib
        cd ..

        mkdir build-release 2>nul
        cd build-release
            cmake -Wno-dev -G %generator% -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstatic.lib -DCMAKE_INSTALL_PREFIX=%root%stage\libpng-release ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv libpng.sln /build Release /project INSTALL > buildlog.txt
        cd ..
    cd ..

echo ===============================================================================
echo Building libjpeg-turbo...
echo ===============================================================================

    cd libjpeg-turbo
        mkdir build-debug 2>nul
        cd build-debug
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DWITH_SIMD=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\libjpeg-turbo-debug ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv libjpeg-turbo.sln /build Debug /project INSTALL > buildlog.txt
            copy jpeg-static.dir\Debug\%pdb_file% %root%stage\libjpeg-turbo-debug\lib
        cd ..

        mkdir build-release 2>nul
        cd build-release
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DWITH_SIMD=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\libjpeg-turbo-release ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv libjpeg-turbo.sln /build Release /project INSTALL > buildlog.txt
        cd ..
    cd ..

echo ===============================================================================
echo Building libtiff...
echo ===============================================================================

    cd libtiff-debug
        nmake -f Makefile.vc
        mkdir %root%stage\libtiff-debug\lib 2>nul
        mkdir %root%stage\libtiff-debug\include 2>nul
        copy libtiff\libtiff.lib %root%stage\libtiff-debug\lib
        copy libtiff\libtiff.pdb %root%stage\libtiff-debug\lib
        copy libtiff\*.h %root%stage\libtiff-debug\include
    cd ..

    cd libtiff-release
        nmake -f Makefile.vc
        mkdir %root%stage\libtiff-release\lib 2>nul
        mkdir %root%stage\libtiff-release\include 2>nul
        copy libtiff\libtiff.lib %root%stage\libtiff-release\lib
        copy libtiff\*.h %root%stage\libtiff-release\include
    cd ..

echo ===============================================================================
echo Building ilmbase...
echo ===============================================================================

    cd ilmbase
        mkdir build-debug 2>nul
        cd build-debug
            cmake -Wno-dev -G %generator% -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\ilmbase-debug ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv ilmbase.sln /build Debug /project INSTALL > buildlog.txt
            copy Half\Half.dir\Debug\%pdb_file% %root%stage\ilmbase-debug\lib
        cd ..

        mkdir build-release 2>nul
        cd build-release
            cmake -Wno-dev -G %generator% -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_PREFIX=%root%stage\ilmbase-release ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv ilmbase.sln /build Release /project INSTALL > buildlog.txt
        cd ..
    cd ..

echo ===============================================================================
echo Building OpenEXR...
echo ===============================================================================

    cd openexr
        mkdir build-debug 2>nul
        cd build-debug
            cmake -Wno-dev -G %generator% -DBUILD_SHARED_LIBS=OFF -DILMBASE_PACKAGE_PREFIX=%root%stage\ilmbase-debug -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstaticd.lib -DCMAKE_INSTALL_PREFIX=%root%stage\openexr-debug ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv openexr.sln /build Debug /project INSTALL > buildlog.txt
            copy IlmImf\IlmImf.dir\Debug\%pdb_file% %root%stage\openexr-debug\lib
        cd ..

        mkdir build-release 2>nul
        cd build-release
            cmake -Wno-dev -G %generator% -DBUILD_SHARED_LIBS=OFF -DILMBASE_PACKAGE_PREFIX=%root%stage\ilmbase-release -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstatic.lib -DCMAKE_INSTALL_PREFIX=%root%stage\openexr-release ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv openexr.sln /build Release /project INSTALL > buildlog.txt
        cd ..
    cd ..

echo ===============================================================================
echo Building OIIO...
echo ===============================================================================

    cd oiio
        mkdir build-debug 2>nul
        cd build-debug
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DBUILDSTATIC=ON -DLINKSTATIC=ON -DEXTRA_CPP_ARGS="/DBOOST_ALL_NO_LIB /DBOOST_PYTHON_STATIC_LIB" -DILMBASE_HOME=%root%stage\ilmbase-debug -DOPENEXR_HOME=%root%stage\openexr-debug -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstaticd.lib -DPNG_PNG_INCLUDE_DIR=%root%stage\libpng-debug\include -DPNG_LIBRARY=%root%stage\libpng-debug\lib\libpng16_staticd.lib -DJPEG_INCLUDE_DIR=%root%stage\libjpeg-turbo-debug\include -DJPEG_LIBRARY=%root%stage\libjpeg-turbo-debug\lib\jpeg-static.lib -DTIFF_INCLUDE_DIR=%root%stage\libtiff-debug\include -DTIFF_LIBRARY=%root%stage\libtiff-debug\lib\libtiff.lib -DPYTHON_INCLUDE_DIR=%python_include_dir% -DPYTHON_LIBRARY=%python_library% -DCMAKE_INSTALL_PREFIX=%root%stage\oiio-debug ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv OpenImageIO.sln /build Debug /project INSTALL > buildlog.txt
            copy src\libOpenImageIO\OpenImageIO.dir\Debug\%pdb_file% %root%stage\oiio-debug\lib
        cd ..

        mkdir build-release 2>nul
        cd build-release
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DBUILDSTATIC=ON -DLINKSTATIC=ON -DEXTRA_CPP_ARGS="/DBOOST_ALL_NO_LIB /DBOOST_PYTHON_STATIC_LIB" -DILMBASE_HOME=%root%stage\ilmbase-release -DOPENEXR_HOME=%root%stage\openexr-release -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstatic.lib -DPNG_PNG_INCLUDE_DIR=%root%stage\libpng-debug\include -DPNG_LIBRARY=%root%stage\libpng-release\lib\libpng16_static.lib -DJPEG_INCLUDE_DIR=%root%stage\libjpeg-turbo-release\include -DJPEG_LIBRARY=%root%stage\libjpeg-turbo-release\lib\jpeg-static.lib -DTIFF_INCLUDE_DIR=%root%stage\libtiff-release\include -DTIFF_LIBRARY=%root%stage\libtiff-release\lib\libtiff.lib -DPYTHON_INCLUDE_DIR=%python_include_dir% -DPYTHON_LIBRARY=%python_library% -DCMAKE_INSTALL_PREFIX=%root%stage\oiio-release ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv OpenImageIO.sln /build Release /project INSTALL > buildlog.txt
        cd ..
    cd ..

echo ===============================================================================
echo Building OSL...
echo ===============================================================================

    cd osl
        set PATH=%root%tools\FlexBison\bin;%PATH%
        set PATHSAVE=%PATH%

        mkdir build-debug 2>nul
        cd build-debug
            set PATH=%root%stage\llvm-debug\bin;%PATHSAVE%
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DOSL_BUILD_TESTS=OFF -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DBUILDSTATIC=ON -DLINKSTATIC=ON -DENABLERTTI=ON -DLLVM_STATIC=ON -DILMBASE_HOME=%root%stage\ilmbase-debug -DILMBASE_CUSTOM=ON -DILMBASE_CUSTOM_LIBRARIES="Half Iex-2_2 IexMath-2_2 IlmThread-2_2 Imath-2_2" -DOPENIMAGEIOHOME=%root%stage\oiio-debug -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstaticd.lib -DEXTRA_CPP_ARGS="/DOIIO_STATIC_BUILD /DTINYFORMAT_ALLOW_WCHAR_STRINGS" -DCMAKE_INSTALL_PREFIX=%root%stage\osl-debug ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv osl.sln /build Debug /project INSTALL > buildlog.txt
            copy src\liboslcomp\oslcomp.dir\Debug\%pdb_file% %root%stage\osl-debug\lib
        cd ..

        mkdir build-release 2>nul
        cd build-release
            set PATH=%root%stage\llvm-release\bin;%PATHSAVE%
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DOSL_BUILD_TESTS=OFF -DBOOST_ROOT=%boost_root% -DBoost_USE_STATIC_LIBS=ON -DBUILDSTATIC=ON -DLINKSTATIC=ON -DENABLERTTI=ON -DLLVM_STATIC=ON -DILMBASE_HOME=%root%stage\ilmbase-release -DILMBASE_CUSTOM=ON -DILMBASE_CUSTOM_LIBRARIES="Half Iex-2_2 IexMath-2_2 IlmThread-2_2 Imath-2_2" -DOPENIMAGEIOHOME=%root%stage\oiio-release -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstatic.lib -DEXTRA_CPP_ARGS="/DOIIO_STATIC_BUILD /DTINYFORMAT_ALLOW_WCHAR_STRINGS" -DCMAKE_INSTALL_PREFIX=%root%stage\osl-release ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv osl.sln /build Release /project INSTALL > buildlog.txt
        cd ..
    cd ..

echo ===============================================================================
echo Building SeExpr...
echo ===============================================================================

    cd SeExpr
        mkdir build-debug 2>nul
        cd build-debug
            mkdir src\SeExpr\generated 2>nul
            mkdir src\SeExprEditor\generated 2>nul
            copy ..\windows7\SeExpr\generated\*.* src\SeExpr\generated
            copy ..\windows7\SeExprEditor\generated\*.* src\SeExprEditor\generated
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Debug -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstaticd.lib -DPNG_PNG_INCLUDE_DIR=%root%stage\libpng-debug\include -DPNG_LIBRARY=%root%stage\libpng-debug\lib\libpng16_staticd.lib -DQT_QMAKE_EXECUTABLE=%qt_qmake_path% -DCMAKE_INSTALL_PREFIX=%root%stage\SeExpr-debug ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv SeExpr.sln /build Debug /project INSTALL > buildlog.txt
            copy src\SeExpr\SeExpr-static.dir\Debug\%pdb_file% %root%stage\SeExpr-debug\lib
        cd ..

        mkdir build-release 2>nul
        cd build-release
            mkdir src\SeExpr\generated 2>nul
            mkdir src\SeExprEditor\generated 2>nul
            copy ..\windows7\SeExpr\generated\*.* src\SeExpr\generated
            copy ..\windows7\SeExprEditor\generated\*.* src\SeExprEditor\generated
            cmake -Wno-dev -G %generator% -DCMAKE_BUILD_TYPE=Release -DZLIB_INCLUDE_DIR=%root%stage\zlib\include -DZLIB_LIBRARY=%root%stage\zlib\lib\zlibstatic.lib -DPNG_PNG_INCLUDE_DIR=%root%stage\libpng-release\include -DPNG_LIBRARY=%root%stage\libpng-release\lib\libpng16_static.lib -DQT_QMAKE_EXECUTABLE=%qt_qmake_path% -DCMAKE_INSTALL_PREFIX=%root%stage\SeExpr-release ..
            echo Compiling, messages are redirected to buildlog.txt...
            devenv SeExpr.sln /build Release /project INSTALL > buildlog.txt
        cd ..
    cd ..

:done

cd ..

echo ===============================================================================
echo Done.
echo ===============================================================================
echo.

:end
