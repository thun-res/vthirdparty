# =================================================================================================
#  Copyright (C) 2023-2024 MCAP_BUILDER Contributors
# =================================================================================================

cmake_minimum_required(VERSION 3.15...3.31)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

project(mcap LANGUAGES CXX VERSION "2.1.3")

option(ENABLE_ZSTD "Enable zstd" ON)

if(ENABLE_ZSTD)
    find_package(zstd REQUIRED)
endif()

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME} INTERFACE
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
if(ENABLE_ZSTD)
    if(TARGET zstd::libzstd_shared)
        target_link_libraries(${PROJECT_NAME} INTERFACE zstd::libzstd_shared)
    elseif(TARGET zstd::libzstd_static)
        target_link_libraries(${PROJECT_NAME} INTERFACE zstd::libzstd_static)
    endif()
else()
    target_compile_definitions(${PROJECT_NAME} INTERFACE "MCAP_COMPRESSION_NO_ZSTD")
endif()
target_compile_definitions(${PROJECT_NAME} INTERFACE "MCAP_COMPRESSION_NO_LZ4")

write_basic_package_version_file(
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
    VERSION ${CMAKE_PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)
configure_package_config_file(
    "${PROJECT_SOURCE_DIR}/cmake/${PROJECT_NAME}-config.cmake.in"
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}-targets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(EXPORT ${PROJECT_NAME}-targets NAMESPACE "${PROJECT_NAME}::" DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
install(FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
              "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
