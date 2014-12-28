Third-Party Dependencies for appleseed
======================================

This repository contains the source code of all third-party libraries required to build appleseed, except [Qt](http://qt-project.org/) and the [Boost C++ Libraries](http://www.boost.org/).

You can either build these libraries yourself using the instructions below, or download prebuilt packages from the [Releases](https://github.com/appleseedhq/appleseed-deps/releases) page.

## Build Instructions on Windows

#### Prerequisites

You will need to have Git and CMake to build these libraries. Check out the [Required Tools](https://github.com/appleseedhq/appleseed/wiki/Building-appleseed#required-tools) section from appleseed's build guide for details.

You will also need to have a build of Boost C++ Libraries. Please refer to the [Building Boost C++ Libraries](https://github.com/appleseedhq/appleseed/wiki/Building-appleseed-on-Windows#building-boost-c-libraries-1470-or-later) section from appleseed's build guide.

#### Building the Libraries

1. Clone this repository on your machine:
   ```
   git clone git://github.com/appleseedhq/appleseed-deps.git
   ```
   This will place everything inside an `appleseed-deps\` directory.

2. Open a VS 2012 or VS 2013 x64 command prompt.
3. If you're using VS 2012, run:
   ```
   BuildAll.bat "Visual Studio 11 Win64" C:\path\to\boost
   ```
   If you're using VS 2013, run:
   ```
   BuildAll.bat "Visual Studio 12 Win64" C:\path\to\boost
   ```

4. Wait a long time. You're done.

#### Building appleseed

Follow the [instructions](https://github.com/appleseedhq/appleseed/wiki/Building-appleseed-on-Windows#building-appleseed) from appleseed's build guide, but make sure to add
```
-DAPPLESEED_DEPS_STAGE_DIR=C:\path\to\appleseed-deps\stage
```
to CMake's command line.
