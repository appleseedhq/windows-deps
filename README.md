Third-Party Dependencies for appleseed
======================================

This repository contains the source code of all third-party libraries required to build appleseed, except [Qt](http://qt-project.org/) and the [Boost C++ Libraries](http://www.boost.org/).

You can either build these libraries yourself using the instructions below, or download prebuilt packages from the [Releases](https://github.com/appleseedhq/appleseed-deps/releases) page.

## Build Instructions on Windows

#### Prerequisites

##### Tools

The following tools are required to build the third-party libraries and appleseed itself:

* [Microsoft Visual Studio 2012](http://www.visualstudio.com/) or later. In principle, Visual Studio Community 2013 should work as well, but we haven't tested to confirm it. It may or may not work with earlier versions or with the Express edition of Visual Studio. The instructions below assume Visual Studio 2012 (internally version 11.0): if you are using Visual Studio 2013 or later, you will need to adapt the CMake commands accordingly.

* [Git](http://git-scm.com/). Not only is Git required to retrieve the source code from GitHub, it is also invoked by appleseed's build system to generate a version string from the Git repository. On Windows, we recommend [Git Extensions](https://code.google.com/p/gitextensions/) or [SourceTree](http://www.sourcetreeapp.com/).

* [CMake](http://www.cmake.org/) 2.8.12 or later. Some people reported that they were successful in building appleseed with slightly older versions. It may or may not work. Version 2.8.12 is the earliest we officially support.

* [Python 2.x](https://www.python.org/). Python is required by LLVM's build system. We recommend using the Python 2.x series, version 2.7 or later. It may or may not work with earlier versions, or with the Python 3.x series.

**Important:** make sure both Python and Git are in your PATH.

##### Libraries

The following libraries are also required:

* [Boost C++ Libraries](http://www.boost.org/).

* [Qt](http://qt-project.org/).

##### Others

Finally, you will need about 18 GB of available disk space on your machine.

#### Building the Libraries

1. Clone this repository on your machine:
   ```
   git clone git://github.com/appleseedhq/appleseed-deps.git
   ```
   This will place everything inside an `appleseed-deps\` directory.

2. Open a VS 2012 or VS 2013 **x64** command prompt and navigate to the `appleseed-deps\` directory.

3. If you're using VS 2012, run:
   ```
   BuildAll.bat "Visual Studio 11 Win64" C:\path\to\boost
   ```
   If you're using VS 2013, run:
   ```
   BuildAll.bat "Visual Studio 12 Win64" C:\path\to\boost
   ```

4. Wait a couple hours. You're done.

#### Building appleseed

1. Clone the appleseed repository on your machine:
   ```
   git clone git://github.com/appleseedhq/appleseed.git
   ```
   This will place everything inside an `appleseed\` directory.

2. Open a VS 2012 or VS 2013 **x64** command prompt and navigate to the `appleseed\` directory.

3. Type:
   ```
   mkdir build
   cd build
   ```

4. If you're using VS 2012, run:
   ```
   cmake -G "Visual Studio 11 Win64" ..
     -DWITH_OSL=ON -DWITH_DISNEY_MATERIAL=ON
     -DBOOST_ROOT=C:\path\to\boost
     -DQT_QMAKE_EXECUTABLE=C:\path\to\qmake.exe
     -DAPPLESEED_DEPS_STAGE_DIR=C:\path\to\appleseed-deps\stage
   ```
   If you're using VS 2013, run:
   ```
   cmake -G "Visual Studio 12 Win64" ..
     -DWITH_OSL=ON -DWITH_DISNEY_MATERIAL=ON
     -DBOOST_ROOT=C:\path\to\boost
     -DQT_QMAKE_EXECUTABLE=C:\path\to\qmake.exe
     -DAPPLESEED_DEPS_STAGE_DIR=C:\path\to\appleseed-deps\stage
   ```

5. Open the solution file `build\appleseed.sln`.

6. Go to *Build* and select *Rebuild Solution*.

7. [Configure the Visual Studio solution](https://github.com/appleseedhq/appleseed/wiki/Building-appleseed-on-Windows#configuring-the-visual-studio-solution).
