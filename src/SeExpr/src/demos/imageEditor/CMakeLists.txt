
# Copyright Disney Enterprises, Inc.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License
# and the following modification to it: Section 6 Trademarks.
# deleted and replaced with:
#
# 6. Trademarks. This License does not grant permission to use the
# trade names, trademarks, service marks, or product names of the
# Licensor and its affiliates, except as required for reproducing
# the content of the NOTICE file.
#
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0

# Set application root dir for use inside the source code.
cmake_policy(SET CMP0005 NEW)
add_definitions(-DIMAGE_EDITOR_ROOT="${CMAKE_INSTALL_PREFIX}")

find_package(Qt5 COMPONENTS Core Gui) # find and setup Qt5 for this project
find_package(PNG)

if(QT5_FOUND AND PNG_FOUND)
    set(imageEditor_MOC_HDRS ImageEditorDialog.h)
    set(imageEditor_CPPS imageEditor.cpp)
    qt5_wrap_cpp(imageEditor_MOC_SRCS ${imageEditor_MOC_HDRS})

    add_executable(imageEditor ${imageEditor_CPPS} ${imageEditor_MOC_SRCS})
    include_directories(${Qt5Core_INCLUDE_DIRS})
    include_directories(${Qt5Gui_INCLUDE_DIRS})
    include_directories(${CMAKE_CURRENT_SOURCE_DIR})
    include_directories(${SEEXPR_EDITOR_INCLUDES})
    target_link_libraries(imageEditor Qt5::Core)
    target_link_libraries(imageEditor Qt5::Gui)
    target_link_libraries(imageEditor ${SEEXPR_LIBRARIES})
    target_link_libraries(imageEditor ${SEEXPR_EDITOR_LIBRARIES})

    INCLUDE_DIRECTORIES(${PNG_INCLUDE_DIR})
    TARGET_LINK_LIBRARIES(imageEditor ${PNG_LIBRARIES})
    install(TARGETS imageEditor DESTINATION bin)


endif(QT5_FOUND AND PNG_FOUND)


INSTALL( FILES fbm.se noisecolor1.se noisecolor2.se noise.se raytrace.se sinc.se DESTINATION ${CMAKE_INSTALL_PREFIX}/expressions/ )

