cmake_minimum_required(VERSION 2.8.12)

# Detect if the project is being bundled.

if(NOT DEFINED PROJECT_NAME)
  set(NOT_SUBPROJECT ON)
endif()

# The project information.

project(looptools C Fortran)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

if(NOT_SUBPROJECT)
  option(LOOPTOOLS_INSTALL_EXECUTABLES "install looptools executables" ON)
  option(LOOPTOOLS_INSTALL_LIBRARIES "install looptools libraries" ON)
  option(LOOPTOOLS_INSTALL_HEADERS "install looptools header files" ON)
else()
  option(LOOPTOOLS_INSTALL_EXECUTABLES "install looptools executables" OFF)
  option(LOOPTOOLS_INSTALL_LIBRARIES "install looptools libraries" OFF)
  option(LOOPTOOLS_INSTALL_HEADERS "install looptools header files" OFF)
endif()

# Default build type.
#
# * See: https://blog.kitware.com/cmake-and-the-default-build-type/

set(default_build_type "Release")

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(
    STATUS
      "Setting build type to '${default_build_type}' as none was specified.")
  set(CMAKE_BUILD_TYPE
      "${default_build_type}"
      CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
                                               "MinSizeRel" "RelWithDebInfo")
endif()

# Source tree.

add_subdirectory(src)
