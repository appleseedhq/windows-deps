@echo off

REM
REM This source file is part of appleseed.
REM Visit http://appleseedhq.net/ for additional information and resources.
REM
REM This software is released under the MIT license.
REM
REM Copyright (c) 2014 Francois Beaune, The appleseedhq Organization
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

cd src

echo Removing LLVM build files...

    cd llvm
        rmdir /S /Q build-debug 2>nul
        rmdir /S /Q build-release 2>nul
    cd ..

echo Removing zlib build files...

    cd zlib
        rmdir /S /Q build 2>nul
    cd ..

echo Removing libpng build files...

    cd libpng
        rmdir /S /Q build-debug 2>nul
        rmdir /S /Q build-release 2>nul
    cd ..

echo Removing libjpeg-turbo build files...

    cd libjpeg-turbo
        rmdir /S /Q build-debug 2>nul
        rmdir /S /Q build-release 2>nul
    cd ..

echo Removing libtiff build files...

    cd libtiff
        nmake -f Makefile.vc clean >nul 2>nul
    cd ..

echo Removing ilmbase build files...

    cd ilmbase
        rmdir /S /Q build-debug 2>nul
        rmdir /S /Q build-release 2>nul
    cd ..

echo Removing OpenEXR build files...

    cd openexr
        rmdir /S /Q build-debug 2>nul
        rmdir /S /Q build-release 2>nul
    cd ..

echo Removing OIIO build files...

    cd oiio
        rmdir /S /Q build-debug 2>nul
        rmdir /S /Q build-release 2>nul
    cd ..

echo Removing OSL build files...

    cd osl
        rmdir /S /Q build-debug 2>nul
        rmdir /S /Q build-release 2>nul
    cd ..

echo Removing SeExpr build files...

    cd SeExpr
        rmdir /S /Q build-debug 2>nul
        rmdir /S /Q build-release 2>nul
    cd ..

:done

cd ..
echo Done.
echo.

:end
