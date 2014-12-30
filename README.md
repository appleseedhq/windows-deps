Third-Party Dependencies for appleseed
======================================

This repository contains the source code of all third-party libraries required to build appleseed, except [Qt](http://qt-project.org/) and the [Boost C++ Libraries](http://www.boost.org/).

You can either build these libraries yourself using the instructions below, or download prebuilt packages from the [Releases](https://github.com/appleseedhq/appleseed-deps/releases) page.

## Build Instructions on Windows

#### Prerequisites

##### Tools

The following tools are required to build the third-party libraries and appleseed itself:

* [Microsoft Visual Studio](http://www.visualstudio.com/) 2012 or later. In principle, Visual Studio Community 2013 should work as well, but we haven't tested to confirm it. It may or may not work with earlier versions or with the Express edition of Visual Studio. The instructions below assume Visual Studio 2012 (internally version 11.0): if you are using Visual Studio 2013 or later, you will need to adapt the CMake commands accordingly.

* [Git](http://git-scm.com/). Not only is Git required to retrieve the source code from GitHub, it is also invoked by appleseed's build system to generate a version string from the Git repository. On Windows, we recommend [Git Extensions](https://code.google.com/p/gitextensions/) or [SourceTree](http://www.sourcetreeapp.com/).

* [CMake](http://www.cmake.org/) 2.8.12 or later. Some people reported that they were successful in building appleseed with slightly older versions. It may or may not work. Version 2.8.12 is the earliest we officially support.

* [Python](https://www.python.org/) 2.x. Python is required by LLVM's build system. We recommend using the Python 2.x series, version 2.7 or later. It may or may not work with earlier versions, or with the Python 3.x series.

**Important:** make sure both Python and Git are in your PATH.

##### Libraries

The following libraries are also required:

* [Boost C++ Libraries](http://www.boost.org/) 1.47 or later. We recommend using Boost 1.55 in order to match the version used in the [CY2015 VFX Reference Platform](http://www.vfxplatform.com/). You can download Boost 1.55 from the  [Boost Version History](http://www.boost.org/users/history/).

* [Qt](http://qt-project.org/) 4.8.x. We do not support Qt 5.x at this time. You can download the latest Qt 4.8.x from the [Qt Downloads archive](http://download.qt.io/archive/qt/4.8/).

##### Disk Space

Finally, you will need a lot of free disk space on your machine. Space requirements are as follow:

| Component          | Required Disk Space (*)   |
| ------------------ | ------------------------- |
| Boost 1.55         | 3.4 GB                    |
| Qt 4.8             | 4.1 GB                    |
| appleseed-deps     | 18.1 GB                   |
| appleseed          | 10.9 GB                   |
| **Total**          | **36.5 GB**               |

(*) Total maximum disk space, including source code, Git repository when applicable, intermediate build files and binaries for all build configurations.

#### Building the Third-Party Libraries

1. Clone this repository on your machine:
   ```
   git clone git://github.com/appleseedhq/appleseed-deps.git
   ```
   This will place everything inside an `appleseed-deps\` directory.

2. Open a VS 2012 or VS 2013 **x64** command prompt and navigate to the `appleseed-deps\` directory.

3. Type:
   ```
   BuildAll.bat "Visual Studio 11 Win64" C:\path\to\boost
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

4. Type:
   ```
   cmake -G "Visual Studio 11 Win64" ..
     -DWITH_OSL=ON -DWITH_DISNEY_MATERIAL=ON
     -DBOOST_ROOT=C:\path\to\boost
     -DQT_QMAKE_EXECUTABLE=C:\path\to\qmake.exe
     -DAPPLESEED_DEPS_STAGE_DIR=C:\path\to\appleseed-deps\stage
   ```

5. Open the solution file `build\appleseed.sln`.

6. Go to *Build* and select *Rebuild Solution*.

#### Configuring the appleseed Visual Studio Solution

In order to run appleseed.cli or appleseed.studio from within the Visual Studio solution, some things need to be adjusted:

1. Select the projects of all the executable programs (at the time of writing: `animatecamera`, `appleseed.cli`, `appleseed.studio`, `convertmeshfile`, `dumpmetadata`, `makefluffy`, `maketiledexr` and `updateprojectfile`) in the Solution Explorer.

2. Right-click on one of them, and select *Properties*.

3. Select *All Configurations*.

4. In *Configuration Properties* -> *Debugging*:
   - Set *Command* to `$(SolutionDir)..\sandbox\bin\$(Configuration)\$(TargetFileName)`
   - Set *Working Directory* to `$(SolutionDir)..\sandbox\`

   You should end up with something like this:
   
   ![](https://raw.github.com/appleseedhq/appleseed-wiki/master/images/vs-solution-configuration.png)

5. Click OK to close the *Property Pages* window.

6. Select appleseed.studio as the startup project (right-click on `appleseed.studio` in the Solution Explorer and select *Set as StartUp Project*).

7. Press F5 to start appleseed.studio.
