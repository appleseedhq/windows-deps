
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

find_package(OpenGL)
find_package(Qt5 COMPONENTS Core Gui OpenGL REQUIRED) # find and setup Qt5 for this project

BuildParserScanner(SeExprSpecParserLex SeExprSpecParser SeExprSpec editor_parser_cpp)
set(SeExprEd_MOC_HDRS SeExprEdBrowser.h SeExprEdColorCurve.h SeExprEdControlCollection.h
    SeExprEdControl.h SeExprEdCurve.h SeExprEdDialog.h SeExprEditor.h SeExprEdFileDialog.h SeExprEdGrapher2d.h
    SeExprEdPopupDocumentation.h SeExprEdShortEdit.h)
set(SeExprEd_CPPS SeExprEdFileDialog.cpp SeExprEdControl.cpp SeExprEditor.cpp SeExpressionEditor.cpp
    SeExprEdShortEdit.cpp SeExprEdCurve.cpp  SeExprEdColorCurve.cpp SeExprEdEditableExpression.cpp 
    SeExprEdPopupDocumentation.cpp SeExprEdCompletionModel.cpp SeExprEdDialog.cpp SeExprEdControlCollection.cpp
    SeExprEdGrapher2d.cpp SeExprEdBrowser.cpp SeExprEdExpression.cpp)

qt5_wrap_cpp(SeExprEd_MOC_SRCS ${SeExprEd_MOC_HDRS})
    
IF(WIN32)
    add_library(SeExprEditor ${SeExprEd_CPPS} ${SeExprEd_MOC_SRCS} ${editor_parser_cpp})
    GENERATE_EXPORT_HEADER( SeExprEditor
             BASE_NAME SeExprEditor
             EXPORT_MACRO_NAME SeExprEditor
             EXPORT_FILE_NAME SeExprEditor_Export.h
             STATIC_DEFINE SeExprEditor_BUILT_AS_STATIC
    )
ELSE()
    add_library(SeExprEditor SHARED ${SeExprEd_CPPS} ${SeExprEd_MOC_SRCS} ${editor_parser_cpp})
ENDIF(WIN32)

    
install(TARGETS SeExprEditor DESTINATION ${CMAKE_INSTALL_LIBDIR})
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/${SeExprEd_MOC_HDRS} DESTINATION include/SeExprEditor)
include_directories(${Qt5Core_INCLUDE_DIRS})
include_directories(${Qt5Gui_INCLUDE_DIRS})
include_directories(${Qt5OpenGL_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(SeExprEditor Qt5::Core)
target_link_libraries(SeExprEditor Qt5::Gui)
target_link_libraries(SeExprEditor Qt5::OpenGL)
target_link_libraries(SeExprEditor ${GLUT_LIBRARY} ${OPENGL_LIBRARY})

IF(WIN32)
    target_link_libraries(SeExprEditor opengl32)
ENDIF(WIN32)

target_link_libraries(SeExprEditor ${SEEXPR_LIBRARIES})
