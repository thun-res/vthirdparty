cmake_minimum_required(VERSION 3.16)

project(asio VERSION 1.28.2)

include(GNUInstallDirs)

install(
  FILES ${PROJECT_SOURCE_DIR}/include/asio.hpp
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
  DIRECTORY ${PROJECT_SOURCE_DIR}/include/asio
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
