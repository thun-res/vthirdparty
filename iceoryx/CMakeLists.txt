cmake_minimum_required(VERSION 3.16...3.27)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(iceoryx)

set(CMAKE_CURRENT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/iceoryx_meta)

if(NOT WIN32)
  add_compile_options(-Wno-array-bounds)
endif()

add_subdirectory(iceoryx_meta)
