cmake_minimum_required(VERSION 3.10)

project(zstd_root)

set(CMAKE_CURRENT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/build/cmake)

if(NOT WIN32)
	add_compile_options(-Wno-uninitialized)
endif()

add_subdirectory(build/cmake)
