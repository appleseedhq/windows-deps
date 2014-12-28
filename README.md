appleseed-deps
==============

Third-party dependencies for appleseed.

## Build Instructions on Windows

#### Building Boost C++ Libraries

Follow the [instructions](https://github.com/appleseedhq/appleseed/wiki/Building-appleseed-on-Windows#building-boost-c-libraries-1470-or-later) from appleseed's build guide.

### Building the Third-Party Dependencies

1. Clone this repository on your machine.
2. Open a VS 2012 or VS 2013 x64 command prompt.
3. If you're using VS 2012, run:
   ~~~
   BuildAll.bat "Visual Studio 11 Win64" C:\path\to\boost
   ~~~
   If you're using VS 2013, run:
   ~~~
   BuildAll.bat "Visual Studio 12 Win64" C:\path\to\boost
   ~~~
   where `C:\path\to\boost` is the absolute path to the root directory of your copy of the [Boost C++ Libraries](http://www.boost.org/).
   
4. Wait a long time. You're done.

#### Building appleseed

Follow the [instructions](https://github.com/appleseedhq/appleseed/wiki/Building-appleseed-on-Windows#building-appleseed) from appleseed's build guide, but make sure to add
```
-DAPPLESEED_DEPS_STAGE_DIR=<absolute-path-to-appleseed-deps\stage>
```
to CMake's command line.
