# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set(ORC_VENDOR_DEPENDENCIES)
set(ORC_SYSTEM_DEPENDENCIES)
set(ORC_INSTALL_INTERFACE_TARGETS)

set(ORC_FORMAT_VERSION "1.1.0")
set(LZ4_VERSION "1.10.0")
set(SNAPPY_VERSION "1.2.2")
set(ZLIB_VERSION "1.3.1")
set(GTEST_VERSION "1.12.1")
set(PROTOBUF_VERSION "3.5.1")
set(ZSTD_VERSION "1.5.7")
set(SPARSEHASH_VERSION "2.11.1")

option(ORC_PREFER_STATIC_PROTOBUF "Prefer static protobuf library, if available" ON)
option(ORC_PREFER_STATIC_SNAPPY   "Prefer static snappy library, if available"   ON)
option(ORC_PREFER_STATIC_LZ4      "Prefer static lz4 library, if available"      ON)
option(ORC_PREFER_STATIC_ZSTD     "Prefer static zstd library, if available"     ON)
option(ORC_PREFER_STATIC_ZLIB     "Prefer static zlib library, if available"     ON)
option(ORC_PREFER_STATIC_GMOCK    "Prefer static gmock library, if available"    ON)

# zstd requires us to add the threads
FIND_PACKAGE(Threads REQUIRED)

set(THIRDPARTY_DIR "${PROJECT_BINARY_DIR}/c++/libs/thirdparty")
set(THIRDPARTY_LOG_OPTIONS LOG_CONFIGURE 1
                           LOG_BUILD 1
                           LOG_INSTALL 1
                           LOG_DOWNLOAD 1)
set(THIRDPARTY_CONFIGURE_COMMAND "${CMAKE_COMMAND}" -G "${CMAKE_GENERATOR}")
if (CMAKE_GENERATOR_TOOLSET)
  list(APPEND THIRDPARTY_CONFIGURE_COMMAND -T "${CMAKE_GENERATOR_TOOLSET}")
endif ()

string(TOUPPER ${CMAKE_BUILD_TYPE} UPPERCASE_BUILD_TYPE)

if (DEFINED ENV{SNAPPY_HOME})
  set (SNAPPY_HOME "$ENV{SNAPPY_HOME}")
elseif (Snappy_ROOT)
  set (SNAPPY_HOME "${Snappy_ROOT}")
elseif (DEFINED ENV{Snappy_ROOT})
  set (SNAPPY_HOME "$ENV{Snappy_ROOT}")
elseif (SNAPPY_ROOT)
  set (SNAPPY_HOME "${SNAPPY_ROOT}")
elseif (DEFINED ENV{SNAPPY_ROOT})
  set (SNAPPY_HOME "$ENV{SNAPPY_ROOT}")
endif ()

if (DEFINED ENV{ZLIB_HOME})
  set (ZLIB_HOME "$ENV{ZLIB_HOME}")
elseif (ZLIB_ROOT)
  set (ZLIB_HOME "${ZLIB_ROOT}")
elseif (DEFINED ENV{ZLIB_ROOT})
  set (ZLIB_HOME "$ENV{ZLIB_ROOT}")
endif ()

if (DEFINED ENV{LZ4_HOME})
  set (LZ4_HOME "$ENV{LZ4_HOME}")
elseif (LZ4_ROOT)
  set (LZ4_HOME "${LZ4_ROOT}")
elseif (DEFINED ENV{LZ4_ROOT})
  set (LZ4_HOME "$ENV{LZ4_ROOT}")
endif ()

if (DEFINED ENV{PROTOBUF_HOME})
  set (PROTOBUF_HOME "$ENV{PROTOBUF_HOME}")
elseif (Protobuf_ROOT)
  set (PROTOBUF_HOME "${Protobuf_ROOT}")
elseif (DEFINED ENV{Protobuf_ROOT})
  set (PROTOBUF_HOME "$ENV{Protobuf_ROOT}")
elseif (PROTOBUF_ROOT)
  set (PROTOBUF_HOME "${PROTOBUF_ROOT}")
elseif (DEFINED ENV{PROTOBUF_ROOT})
  set (PROTOBUF_HOME "$ENV{PROTOBUF_ROOT}")
endif ()

if (DEFINED ENV{ZSTD_HOME})
  set (ZSTD_HOME "$ENV{ZSTD_HOME}")
elseif (ZSTD_ROOT)
  set (ZSTD_HOME "${ZSTD_ROOT}")
elseif (DEFINED ENV{ZSTD_ROOT})
  set (ZSTD_HOME "$ENV{ZSTD_ROOT}")
endif ()

if (DEFINED ENV{GTEST_HOME})
  set (GTEST_HOME "$ENV{GTEST_HOME}")
endif ()

# ----------------------------------------------------------------------
# Macros for adding third-party libraries
macro (orc_add_resolved_library target_name link_lib include_dir)
  add_library (${target_name} INTERFACE IMPORTED GLOBAL)
  target_link_libraries (${target_name} INTERFACE ${link_lib})
  target_include_directories (${target_name} SYSTEM INTERFACE ${include_dir})
endmacro ()

macro (orc_add_built_library external_project_name target_name link_lib include_dir)
  file (MAKE_DIRECTORY "${include_dir}")

  add_library (${target_name} STATIC IMPORTED)
  set_target_properties (${target_name} PROPERTIES IMPORTED_LOCATION "${link_lib}")
  target_include_directories (${target_name} BEFORE INTERFACE "${include_dir}")

  add_dependencies (${target_name} ${external_project_name})
  if (INSTALL_VENDORED_LIBS)
    install (FILES "${link_lib}" DESTINATION "${CMAKE_INSTALL_LIBDIR}")
  endif ()
endmacro ()

function(orc_provide_cmake_module MODULE_NAME)
  set(module "${PROJECT_SOURCE_DIR}/cmake_modules/${MODULE_NAME}.cmake")
  if(EXISTS "${module}")
    message(STATUS "Providing CMake module for ${MODULE_NAME} as part of CMake package")
    install(FILES "${module}" DESTINATION "${ORC_INSTALL_CMAKE_DIR}")
  endif()
endfunction()

function(orc_provide_find_module PACKAGE_NAME)
  orc_provide_cmake_module("Find${PACKAGE_NAME}")
endfunction()

# ----------------------------------------------------------------------
# ORC Format
if(DEFINED ENV{ORC_FORMAT_URL})
  set(ORC_FORMAT_SOURCE_URL "$ENV{ORC_FORMAT_URL}")
  message(STATUS "Using ORC_FORMAT_URL: ${ORC_FORMAT_SOURCE_URL}")
else()
  set(ORC_FORMAT_SOURCE_URL "https://www.apache.org/dyn/closer.lua/orc/orc-format-${ORC_FORMAT_VERSION}/orc-format-${ORC_FORMAT_VERSION}.tar.gz?action=download" )
  message(STATUS "Using DEFAULT URL: ${ORC_FORMAT_SOURCE_URL}")
endif()
ExternalProject_Add (orc-format_ep
  URL ${ORC_FORMAT_SOURCE_URL}
  URL_HASH SHA256=d4a7ac76c5442abf7119e2cb84e71b677e075aff53518aa866055e2ead0450d7
  CONFIGURE_COMMAND ""
  BUILD_COMMAND     ""
  INSTALL_COMMAND     ""
  TEST_COMMAND     ""
)

# ----------------------------------------------------------------------
# Snappy
if (ORC_PACKAGE_KIND STREQUAL "conan")
  find_package (Snappy REQUIRED CONFIG)
  add_library (orc_snappy INTERFACE)
  target_link_libraries(orc_snappy INTERFACE Snappy::snappy)
  list (APPEND ORC_SYSTEM_DEPENDENCIES Snappy)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:Snappy::snappy>")
elseif (ORC_PACKAGE_KIND STREQUAL "vcpkg")
  find_package(Snappy CONFIG REQUIRED)
  add_library (orc_snappy INTERFACE IMPORTED)
  target_link_libraries(orc_snappy INTERFACE Snappy::snappy)
  list (APPEND ORC_SYSTEM_DEPENDENCIES Snappy)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:Snappy::snappy>")
elseif (NOT "${SNAPPY_HOME}" STREQUAL "")
  find_package (Snappy REQUIRED)
  if (ORC_PREFER_STATIC_SNAPPY AND SNAPPY_STATIC_LIB)
    orc_add_resolved_library (orc_snappy ${SNAPPY_STATIC_LIB} ${SNAPPY_INCLUDE_DIR})
  else ()
    orc_add_resolved_library (orc_snappy ${SNAPPY_LIBRARY} ${SNAPPY_INCLUDE_DIR})
  endif ()
  list (APPEND ORC_SYSTEM_DEPENDENCIES Snappy)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:Snappy::snappy>")
  orc_provide_find_module (Snappy)
else ()
  set(SNAPPY_HOME "${THIRDPARTY_DIR}/snappy_ep-install")
  set(SNAPPY_INCLUDE_DIR "${SNAPPY_HOME}/include")
  set(SNAPPY_STATIC_LIB_NAME "${CMAKE_STATIC_LIBRARY_PREFIX}snappy${CMAKE_STATIC_LIBRARY_SUFFIX}")
  set(SNAPPY_STATIC_LIB "${SNAPPY_HOME}/lib/${SNAPPY_STATIC_LIB_NAME}")
  set(SNAPPY_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${SNAPPY_HOME}
                        -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_LIBDIR=lib
                        -DSNAPPY_BUILD_BENCHMARKS=OFF)

  if (BUILD_POSITION_INDEPENDENT_LIB)
    set(SNAPPY_CMAKE_ARGS ${SNAPPY_CMAKE_ARGS} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
  endif ()

  ExternalProject_Add (snappy_ep
    URL "https://github.com/google/snappy/archive/${SNAPPY_VERSION}.tar.gz"
    CMAKE_ARGS ${SNAPPY_CMAKE_ARGS} -DSNAPPY_BUILD_TESTS=OFF
    ${THIRDPARTY_LOG_OPTIONS}
    BUILD_BYPRODUCTS "${SNAPPY_STATIC_LIB}")

  orc_add_built_library (snappy_ep orc_snappy ${SNAPPY_STATIC_LIB} ${SNAPPY_INCLUDE_DIR})

  list (APPEND ORC_VENDOR_DEPENDENCIES "orc::vendored_snappy|${SNAPPY_STATIC_LIB_NAME}")
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:orc::vendored_snappy>")
endif ()

add_library (orc::snappy ALIAS orc_snappy)

# ----------------------------------------------------------------------
# ZLIB

if (ORC_PACKAGE_KIND STREQUAL "conan")
  find_package (ZLIB REQUIRED CONFIG)
  add_library (orc_zlib INTERFACE)
  target_link_libraries(orc_zlib INTERFACE ZLIB::ZLIB)
  list (APPEND ORC_SYSTEM_DEPENDENCIES ZLIB)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:ZLIB::ZLIB>")
elseif (ORC_PACKAGE_KIND STREQUAL "vcpkg")
  find_package(ZLIB REQUIRED)
  add_library (orc_zlib INTERFACE IMPORTED)
  target_link_libraries(orc_zlib INTERFACE ZLIB::ZLIB)
  list (APPEND ORC_SYSTEM_DEPENDENCIES ZLIB)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:ZLIB::ZLIB>")
elseif (NOT "${ZLIB_HOME}" STREQUAL "")
  find_package (ZLIB REQUIRED)
  if (ORC_PREFER_STATIC_ZLIB AND ZLIB_STATIC_LIB)
    orc_add_resolved_library (orc_zlib ${ZLIB_STATIC_LIB} ${ZLIB_INCLUDE_DIR})
  else ()
    orc_add_resolved_library (orc_zlib ${ZLIB_LIBRARY} ${ZLIB_INCLUDE_DIR})
  endif ()
  list (APPEND ORC_SYSTEM_DEPENDENCIES ZLIB)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:ZLIB::ZLIB>")
  orc_provide_find_module (ZLIB)
else ()
  set(ZLIB_PREFIX "${THIRDPARTY_DIR}/zlib_ep-install")
  set(ZLIB_INCLUDE_DIR "${ZLIB_PREFIX}/include")
  if (MSVC)
    set(ZLIB_STATIC_LIB_NAME zlibstatic)
    if (${UPPERCASE_BUILD_TYPE} STREQUAL "DEBUG")
      set(ZLIB_STATIC_LIB_NAME ${ZLIB_STATIC_LIB_NAME}d)
    endif ()
  else ()
    set(ZLIB_STATIC_LIB_NAME z)
  endif ()
  set(ZLIB_STATIC_LIB_NAME "${CMAKE_STATIC_LIBRARY_PREFIX}${ZLIB_STATIC_LIB_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
  set(ZLIB_STATIC_LIB "${ZLIB_PREFIX}/lib/${ZLIB_STATIC_LIB_NAME}")
  set(ZLIB_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${ZLIB_PREFIX}
                      -DBUILD_SHARED_LIBS=OFF)

  if (BUILD_POSITION_INDEPENDENT_LIB)
    set(ZLIB_CMAKE_ARGS ${ZLIB_CMAKE_ARGS} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
  endif ()

  ExternalProject_Add (zlib_ep
    URL "https://zlib.net/fossils/zlib-${ZLIB_VERSION}.tar.gz"
    CMAKE_ARGS ${ZLIB_CMAKE_ARGS}
    ${THIRDPARTY_LOG_OPTIONS}
    BUILD_BYPRODUCTS "${ZLIB_STATIC_LIB}")

  orc_add_built_library (zlib_ep orc_zlib ${ZLIB_STATIC_LIB} ${ZLIB_INCLUDE_DIR})

  list (APPEND ORC_VENDOR_DEPENDENCIES "orc::vendored_zlib|${ZLIB_STATIC_LIB_NAME}")
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:orc::vendored_zlib>")
endif ()

add_library (orc::zlib ALIAS orc_zlib)

# ----------------------------------------------------------------------
# Zstd

if (ORC_PACKAGE_KIND STREQUAL "conan")
  find_package (ZSTD REQUIRED CONFIG)
  add_library (orc_zstd INTERFACE)
  target_link_libraries (orc_zstd INTERFACE
    $<TARGET_NAME_IF_EXISTS:zstd::libzstd_static>
    $<TARGET_NAME_IF_EXISTS:zstd::libzstd_shared>
  )
  list (APPEND ORC_SYSTEM_DEPENDENCIES ZSTD)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:$<IF:$<TARGET_EXISTS:zstd::libzstd_shared>,zstd::libzstd_shared,zstd::libzstd_static>>")
elseif (ORC_PACKAGE_KIND STREQUAL "vcpkg")
  find_package(zstd CONFIG REQUIRED)
  add_library(orc_zstd INTERFACE)
  target_link_libraries(orc_zstd INTERFACE $<IF:$<TARGET_EXISTS:zstd::libzstd_shared>,zstd::libzstd_shared,zstd::libzstd_static>)
  list(APPEND ORC_SYSTEM_DEPENDENCIES zstd)
  list(APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:$<IF:$<TARGET_EXISTS:zstd::libzstd_shared>,zstd::libzstd_shared,zstd::libzstd_static>>")
elseif (NOT "${ZSTD_HOME}" STREQUAL "")
  find_package (ZSTD REQUIRED)
  if (ORC_PREFER_STATIC_ZSTD AND ZSTD_STATIC_LIB)
    orc_add_resolved_library (orc_zstd ${ZSTD_STATIC_LIB} ${ZSTD_INCLUDE_DIR})
    list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:zstd::libzstd_static>")
  else ()
    orc_add_resolved_library (orc_zstd ${ZSTD_LIBRARY} ${ZSTD_INCLUDE_DIR})
    list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:$<IF:$<TARGET_EXISTS:zstd::libzstd_shared>,zstd::libzstd_shared,zstd::libzstd_static>>")
  endif ()
  list (APPEND ORC_SYSTEM_DEPENDENCIES ZSTD)
  orc_provide_find_module (ZSTD)
else ()
  set(ZSTD_HOME "${THIRDPARTY_DIR}/zstd_ep-install")
  set(ZSTD_INCLUDE_DIR "${ZSTD_HOME}/include")
  if (MSVC)
    set(ZSTD_STATIC_LIB_NAME zstd_static)
    if (${UPPERCASE_BUILD_TYPE} STREQUAL "DEBUG")
      set(ZSTD_STATIC_LIB_NAME ${ZSTD_STATIC_LIB_NAME})
    endif ()
  else ()
    set(ZSTD_STATIC_LIB_NAME zstd)
  endif ()
  set(ZSTD_STATIC_LIB_NAME "${CMAKE_STATIC_LIBRARY_PREFIX}${ZSTD_STATIC_LIB_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
  set(ZSTD_STATIC_LIB "${ZSTD_HOME}/lib/${ZSTD_STATIC_LIB_NAME}")
  set(ZSTD_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${ZSTD_HOME}
          -DBUILD_SHARED_LIBS=OFF -DCMAKE_INSTALL_LIBDIR=lib)

  if (BUILD_POSITION_INDEPENDENT_LIB)
    set(ZSTD_CMAKE_ARGS ${ZSTD_CMAKE_ARGS} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
  endif ()

  if (CMAKE_VERSION VERSION_GREATER "3.7")
    set(ZSTD_CONFIGURE SOURCE_SUBDIR "build/cmake" CMAKE_ARGS ${ZSTD_CMAKE_ARGS})
  else()
    set(ZSTD_CONFIGURE CONFIGURE_COMMAND "${THIRDPARTY_CONFIGURE_COMMAND}" ${ZSTD_CMAKE_ARGS}
            "${CMAKE_CURRENT_BINARY_DIR}/zstd_ep-prefix/src/zstd_ep/build/cmake")
  endif()

  ExternalProject_Add(zstd_ep
          URL "https://github.com/facebook/zstd/archive/v${ZSTD_VERSION}.tar.gz"
          ${ZSTD_CONFIGURE}
          ${THIRDPARTY_LOG_OPTIONS}
          BUILD_BYPRODUCTS ${ZSTD_STATIC_LIB})

  orc_add_built_library (zstd_ep orc_zstd ${ZSTD_STATIC_LIB} ${ZSTD_INCLUDE_DIR})

  list (APPEND ORC_VENDOR_DEPENDENCIES "orc::vendored_zstd|${ZSTD_STATIC_LIB_NAME}")
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:orc::vendored_zstd>")
endif ()

add_library (orc::zstd ALIAS orc_zstd)

# ----------------------------------------------------------------------
# LZ4
if (ORC_PACKAGE_KIND STREQUAL "conan")
  find_package (LZ4 REQUIRED CONFIG)
  add_library (orc_lz4 INTERFACE)
  target_link_libraries (orc_lz4 INTERFACE
    $<TARGET_NAME_IF_EXISTS:LZ4::lz4_shared>
    $<TARGET_NAME_IF_EXISTS:LZ4::lz4_static>
  )
  list (APPEND ORC_SYSTEM_DEPENDENCIES LZ4)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:$<IF:$<TARGET_EXISTS:LZ4::lz4_shared>,LZ4::lz4_shared,LZ4::lz4_static>>")
elseif (ORC_PACKAGE_KIND STREQUAL "vcpkg")
  find_package(lz4 CONFIG REQUIRED)
  add_library (orc_lz4 INTERFACE IMPORTED)
  target_link_libraries(orc_lz4 INTERFACE LZ4::lz4)
  list (APPEND ORC_SYSTEM_DEPENDENCIES lz4)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:LZ4::lz4>")
elseif (NOT "${LZ4_HOME}" STREQUAL "")
  find_package (LZ4 REQUIRED)
  if (ORC_PREFER_STATIC_LZ4 AND LZ4_STATIC_LIB)
    orc_add_resolved_library (orc_lz4 ${LZ4_STATIC_LIB} ${LZ4_INCLUDE_DIR})
  else ()
    orc_add_resolved_library (orc_lz4 ${LZ4_LIBRARY} ${LZ4_INCLUDE_DIR})
  endif ()
  list (APPEND ORC_SYSTEM_DEPENDENCIES LZ4)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:LZ4::lz4>")
  orc_provide_find_module (LZ4)
else ()
  set(LZ4_PREFIX "${THIRDPARTY_DIR}/lz4_ep-install")
  set(LZ4_INCLUDE_DIR "${LZ4_PREFIX}/include")
  set(LZ4_STATIC_LIB_NAME "${CMAKE_STATIC_LIBRARY_PREFIX}lz4${CMAKE_STATIC_LIBRARY_SUFFIX}")
  set(LZ4_STATIC_LIB "${LZ4_PREFIX}/lib/${LZ4_STATIC_LIB_NAME}")
  set(LZ4_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${LZ4_PREFIX}
                     -DCMAKE_INSTALL_LIBDIR=lib
                     -DBUILD_SHARED_LIBS=OFF)

  if (BUILD_POSITION_INDEPENDENT_LIB)
    set(LZ4_CMAKE_ARGS ${LZ4_CMAKE_ARGS} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
  endif ()

  if (CMAKE_VERSION VERSION_GREATER "3.7")
    set(LZ4_CONFIGURE SOURCE_SUBDIR "build/cmake" CMAKE_ARGS ${LZ4_CMAKE_ARGS})
  else()
    set(LZ4_CONFIGURE CONFIGURE_COMMAND "${THIRDPARTY_CONFIGURE_COMMAND}" ${LZ4_CMAKE_ARGS}
                                        "${CMAKE_CURRENT_BINARY_DIR}/lz4_ep-prefix/src/lz4_ep/build/cmake")
  endif()

  ExternalProject_Add(lz4_ep
    URL "https://github.com/lz4/lz4/archive/v${LZ4_VERSION}.tar.gz"
    ${LZ4_CONFIGURE}
    ${THIRDPARTY_LOG_OPTIONS}
    BUILD_BYPRODUCTS ${LZ4_STATIC_LIB})

  orc_add_built_library (lz4_ep orc_lz4 ${LZ4_STATIC_LIB} ${LZ4_INCLUDE_DIR})

  list (APPEND ORC_VENDOR_DEPENDENCIES "orc::vendored_lz4|${LZ4_STATIC_LIB_NAME}")
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:orc::vendored_lz4>")
endif ()

add_library (orc::lz4 ALIAS orc_lz4)

# ----------------------------------------------------------------------
# IANA - Time Zone Database

if (WIN32)
  SET(CURRENT_TZDATA_FILE "")
  SET(CURRENT_TZDATA_SHA512 "")
  File(DOWNLOAD "https://ftp.osuosl.org/pub/cygwin/noarch/release/tzdata/sha512.sum" ${CMAKE_CURRENT_BINARY_DIR}/sha512.sum)
  File(READ ${CMAKE_CURRENT_BINARY_DIR}/sha512.sum TZDATA_SHA512_CONTENT)
  string(REPLACE "\n" ";" TZDATA_SHA512_LINE ${TZDATA_SHA512_CONTENT})
  foreach (LINE IN LISTS TZDATA_SHA512_LINE)
      if (LINE MATCHES ".tar.xz$" AND (NOT LINE MATCHES "src.tar.xz$"))
          string(REPLACE " " ";" FILE_ARGS ${LINE})
          list (GET FILE_ARGS 0 FILE_SHA512)
          list (GET FILE_ARGS 2 FILE_NAME)
          if (FILE_NAME STRGREATER CURRENT_TZDATA_FILE)
              SET(CURRENT_TZDATA_FILE ${FILE_NAME})
              SET(CURRENT_TZDATA_SHA512 ${FILE_SHA512})
          endif()
      endif()
  endforeach()

  if (NOT "${CURRENT_TZDATA_FILE}" STREQUAL "")
    ExternalProject_Add(tzdata_ep
      URL "https://cygwin.osuosl.org/noarch/release/tzdata/${CURRENT_TZDATA_FILE}"
      URL_HASH SHA512=${CURRENT_TZDATA_SHA512}
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND "")
    ExternalProject_Get_Property(tzdata_ep SOURCE_DIR)
    set(TZDATA_DIR ${SOURCE_DIR}/share/zoneinfo)
  else()
    message(STATUS "WARNING: tzdata were not found")
  endif()
endif ()

# ----------------------------------------------------------------------
# GoogleTest (gtest now includes gmock)

if (BUILD_CPP_TESTS)
  if (NOT "${GTEST_HOME}" STREQUAL "")
    find_package (GTest REQUIRED)
    set (GTEST_VENDORED FALSE)
  else ()
    set(GTEST_PREFIX "${THIRDPARTY_DIR}/googletest_ep-install")
    set(GTEST_INCLUDE_DIR "${GTEST_PREFIX}/include")
    set(GMOCK_STATIC_LIB "${GTEST_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gmock${CMAKE_STATIC_LIBRARY_SUFFIX}")
    set(GTEST_STATIC_LIB "${GTEST_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}gtest${CMAKE_STATIC_LIBRARY_SUFFIX}")
    set(GTEST_SRC_URL "https://github.com/google/googletest/archive/release-${GTEST_VERSION}.tar.gz")
    if(APPLE)
      set(GTEST_CMAKE_CXX_FLAGS " -DGTEST_USE_OWN_TR1_TUPLE=1 -Wno-unused-value -Wno-ignored-attributes")
    else()
      set(GTEST_CMAKE_CXX_FLAGS "")
    endif()

    set(GTEST_CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                         -DCMAKE_INSTALL_PREFIX=${GTEST_PREFIX}
                         -DCMAKE_INSTALL_LIBDIR=lib
                         -Dgtest_force_shared_crt=ON
                         -DCMAKE_CXX_FLAGS=${GTEST_CMAKE_CXX_FLAGS})

  if (BUILD_POSITION_INDEPENDENT_LIB)
    set(GTEST_CMAKE_ARGS ${GTEST_CMAKE_ARGS} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
  endif ()

    ExternalProject_Add(googletest_ep
      BUILD_IN_SOURCE 1
      URL ${GTEST_SRC_URL}
      ${THIRDPARTY_LOG_OPTIONS}
      CMAKE_ARGS ${GTEST_CMAKE_ARGS}
      BUILD_BYPRODUCTS "${GMOCK_STATIC_LIB}" "${GTEST_STATIC_LIB}")

    set(GMOCK_LIBRARY ${GMOCK_STATIC_LIB})
    set(GTEST_LIBRARY ${GTEST_STATIC_LIB})
    set(GTEST_VENDORED TRUE)
  endif ()

  # This is a bit special cased because gmock requires gtest and some
  # distributions statically link gtest inside the gmock shared lib
  add_library (orc_gmock INTERFACE)
  add_library (orc::gmock ALIAS orc_gmock)
  add_library (orc_gtest INTERFACE)
  add_library (orc::gtest ALIAS orc_gtest)
  if (ORC_PREFER_STATIC_GMOCK AND GMOCK_STATIC_LIB)
    target_link_libraries (orc_gmock INTERFACE ${GMOCK_STATIC_LIB})
    target_link_libraries (orc_gtest INTERFACE ${GTEST_STATIC_LIB})
  else ()
    target_link_libraries (orc_gmock INTERFACE ${GMOCK_LIBRARY})
    target_link_libraries (orc_gtest INTERFACE ${GTEST_LIBRARY})
  endif ()
  target_include_directories (orc_gmock SYSTEM INTERFACE ${GTEST_INCLUDE_DIR})
  target_include_directories (orc_gtest SYSTEM INTERFACE ${GTEST_INCLUDE_DIR})

  if (GTEST_VENDORED)
    add_dependencies (orc_gmock googletest_ep)
    add_dependencies (orc_gtest googletest_ep)
  endif ()

  if (NOT APPLE AND NOT MSVC)
    target_link_libraries (orc_gmock INTERFACE Threads::Threads)
    target_link_libraries (orc_gtest INTERFACE Threads::Threads)
  endif ()
endif ()

# ----------------------------------------------------------------------
# Protobuf

if (ORC_PACKAGE_KIND STREQUAL "conan")
  find_package (Protobuf REQUIRED CONFIG)
  add_library (orc_protobuf INTERFACE)
  target_link_libraries(orc_protobuf INTERFACE protobuf::protobuf)
  list (APPEND ORC_SYSTEM_DEPENDENCIES Protobuf)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:protobuf::protobuf>")
elseif (ORC_PACKAGE_KIND STREQUAL "vcpkg")
  find_package(Protobuf CONFIG REQUIRED)
  add_library (orc_protobuf INTERFACE IMPORTED)
  target_link_libraries(orc_protobuf INTERFACE protobuf::libprotobuf)
  list (APPEND ORC_SYSTEM_DEPENDENCIES Protobuf)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:protobuf::libprotobuf>")
  set (PROTOBUF_EXECUTABLE protobuf::protoc)
elseif (NOT "${PROTOBUF_HOME}" STREQUAL "")
  find_package (Protobuf REQUIRED)

  if (ORC_PREFER_STATIC_PROTOBUF AND PROTOBUF_STATIC_LIB)
    orc_add_resolved_library (orc_protobuf ${PROTOBUF_STATIC_LIB} ${PROTOBUF_INCLUDE_DIR})
  else ()
    orc_add_resolved_library (orc_protobuf ${PROTOBUF_LIBRARY} ${PROTOBUF_INCLUDE_DIR})
  endif ()

  if (ORC_PREFER_STATIC_PROTOBUF AND PROTOC_STATIC_LIB)
    orc_add_resolved_library (orc_protoc ${PROTOC_STATIC_LIB} ${PROTOBUF_INCLUDE_DIR})
  else ()
    orc_add_resolved_library (orc_protoc ${PROTOC_LIBRARY} ${PROTOBUF_INCLUDE_DIR})
  endif ()

  list (APPEND ORC_SYSTEM_DEPENDENCIES Protobuf)
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:protobuf::libprotobuf>")
  orc_provide_find_module (Protobuf)
else ()
  set(PROTOBUF_PREFIX "${THIRDPARTY_DIR}/protobuf_ep-install")
  set(PROTOBUF_INCLUDE_DIR "${PROTOBUF_PREFIX}/include")
  set(PROTOBUF_CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${PROTOBUF_PREFIX}
                          -DCMAKE_INSTALL_LIBDIR=lib
                          -DCMAKE_POLICY_VERSION_MINIMUM=3.12
                          -DBUILD_SHARED_LIBS=OFF
                          -Dprotobuf_BUILD_TESTS=OFF)

  if (BUILD_POSITION_INDEPENDENT_LIB)
    set(PROTOBUF_CMAKE_ARGS ${PROTOBUF_CMAKE_ARGS} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
  endif ()

  if (MSVC)
    set(PROTOBUF_STATIC_LIB_PREFIX lib)
    list(APPEND PROTOBUF_CMAKE_ARGS -Dprotobuf_MSVC_STATIC_RUNTIME=OFF
                                    -Dprotobuf_DEBUG_POSTFIX=)
  else ()
    set(PROTOBUF_STATIC_LIB_PREFIX ${CMAKE_STATIC_LIBRARY_PREFIX})
  endif ()
  set(PROTOBUF_STATIC_LIB_NAME "${PROTOBUF_STATIC_LIB_PREFIX}protobuf${CMAKE_STATIC_LIBRARY_SUFFIX}")
  set(PROTOBUF_STATIC_LIB "${PROTOBUF_PREFIX}/lib/${PROTOBUF_STATIC_LIB_NAME}")
  set(PROTOC_STATIC_LIB "${PROTOBUF_PREFIX}/lib/${PROTOBUF_STATIC_LIB_PREFIX}protoc${CMAKE_STATIC_LIBRARY_SUFFIX}")
  set(PROTOBUF_EXECUTABLE "${PROTOBUF_PREFIX}/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}")

  if (CMAKE_VERSION VERSION_GREATER "3.7")
    set(PROTOBUF_CONFIGURE SOURCE_SUBDIR "cmake" CMAKE_ARGS ${PROTOBUF_CMAKE_ARGS})
  else()
    set(PROTOBUF_CONFIGURE CONFIGURE_COMMAND "${THIRDPARTY_CONFIGURE_COMMAND}" ${PROTOBUF_CMAKE_ARGS}
                                             "${CMAKE_CURRENT_BINARY_DIR}/protobuf_ep-prefix/src/protobuf_ep/cmake")
  endif()

  ExternalProject_Add(protobuf_ep
    URL "https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz"
    ${PROTOBUF_CONFIGURE}
    ${THIRDPARTY_LOG_OPTIONS}
    BUILD_BYPRODUCTS "${PROTOBUF_STATIC_LIB}" "${PROTOC_STATIC_LIB}")

  orc_add_built_library (protobuf_ep orc_protobuf ${PROTOBUF_STATIC_LIB} ${PROTOBUF_INCLUDE_DIR})
  orc_add_built_library (protobuf_ep orc_protoc ${PROTOC_STATIC_LIB} ${PROTOBUF_INCLUDE_DIR})

  list (APPEND ORC_VENDOR_DEPENDENCIES "orc::vendored_protobuf|${PROTOBUF_STATIC_LIB_NAME}")
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:orc::vendored_protobuf>")
endif ()

add_library (orc::protobuf ALIAS orc_protobuf)
if (NOT (ORC_PACKAGE_KIND STREQUAL "conan" OR ORC_PACKAGE_KIND STREQUAL "vcpkg"))
  add_library (orc::protoc ALIAS orc_protoc)
endif ()

# ----------------------------------------------------------------------
# SPARSEHASH
if(BUILD_SPARSEHASH)
  set(SPARSEHASH_HOME "${THIRDPARTY_DIR}/sparsehash_ep-install")
  set(SPARSEHASH_INCLUDE_DIR "${SPARSEHASH_HOME}/include/google")
  set(SPARSEHASH_CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${SPARSEHASH_HOME}
      -DBUILD_SHARED_LIBS=OFF
      -DCMAKE_INSTALL_LIBDIR=lib
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
  )
  if (BUILD_POSITION_INDEPENDENT_LIB)
    set(SPARSEHASH_CMAKE_ARGS ${SPARSEHASH_CMAKE_ARGS} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
  endif ()

  if (CMAKE_VERSION VERSION_GREATER "3.7")
      set(SPARSEHASH_CONFIGURE SOURCE_SUBDIR "" CMAKE_ARGS ${SPARSEHASH_CMAKE_ARGS})
    else()
      set(SPARSEHASH_CONFIGURE CONFIGURE_COMMAND "${THIRDPARTY_CONFIGURE_COMMAND}" ${SPARSEHASH_CMAKE_ARGS}
              "${CMAKE_CURRENT_BINARY_DIR}/sparsehash_ep-prefix/src/sparsehash_ep/")
  endif()

  ExternalProject_Add(sparsehash_ep
      URL "https://github.com/sparsehash/sparsehash-c11/archive/refs/tags/v${SPARSEHASH_VERSION}.tar.gz"
      ${SPARSEHASH_CONFIGURE}
      ${THIRDPARTY_LOG_OPTIONS})

  # sparsehash-c11 is header-only, create interface library
  add_library(orc_sparsehash INTERFACE)
  target_include_directories(orc_sparsehash INTERFACE 
      $<BUILD_INTERFACE:${SPARSEHASH_INCLUDE_DIR}>
      $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
  add_dependencies(orc_sparsehash sparsehash_ep)

  list (APPEND ORC_VENDOR_DEPENDENCIES "orc::vendored_sparsehash")
  list (APPEND ORC_INSTALL_INTERFACE_TARGETS "$<INSTALL_INTERFACE:orc::vendored_sparsehash>")

  add_library (orc::sparsehash ALIAS orc_sparsehash)
  set (SPARSEHASH_LIBRARIES orc::sparsehash)
endif()

# ----------------------------------------------------------------------
# LIBHDFSPP
if(BUILD_LIBHDFSPP)
  set (BUILD_LIBHDFSPP FALSE)
  if(ORC_CXX_HAS_THREAD_LOCAL)
    find_package(CyrusSASL)
    find_package(OpenSSL)
    find_package(Threads)
    if (CYRUS_SASL_SHARED_LIB AND OPENSSL_LIBRARIES)
      set (BUILD_LIBHDFSPP TRUE)
      set (LIBHDFSPP_PREFIX "${THIRDPARTY_DIR}/libhdfspp_ep-install")
      set (LIBHDFSPP_INCLUDE_DIR "${LIBHDFSPP_PREFIX}/include")
      set (LIBHDFSPP_STATIC_LIB_NAME hdfspp_static)
      set (LIBHDFSPP_STATIC_LIB "${LIBHDFSPP_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}${LIBHDFSPP_STATIC_LIB_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
      set (LIBHDFSPP_SRC_URL "${PROJECT_SOURCE_DIR}/c++/libs/libhdfspp/libhdfspp.tar.gz")
      set (LIBHDFSPP_CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                                -DCMAKE_INSTALL_PREFIX=${LIBHDFSPP_PREFIX}
                                -DPROTOBUF_INCLUDE_DIR=${PROTOBUF_INCLUDE_DIR}
                                -DPROTOBUF_LIBRARY=${PROTOBUF_STATIC_LIB}
                                -DPROTOBUF_PROTOC_LIBRARY=${PROTOC_STATIC_LIB}
                                -DPROTOBUF_PROTOC_EXECUTABLE=${PROTOBUF_EXECUTABLE}
                                -DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR}
                                -DCMAKE_C_FLAGS=${EP_C_FLAGS}
                                -DBUILD_SHARED_LIBS=OFF
                                -DHDFSPP_LIBRARY_ONLY=TRUE
                                -DBUILD_SHARED_HDFSPP=FALSE)

      if (BUILD_POSITION_INDEPENDENT_LIB)
        set(LIBHDFSPP_CMAKE_ARGS ${LIBHDFSPP_CMAKE_ARGS} -DCMAKE_POSITION_INDEPENDENT_CODE=ON)
      endif ()

      ExternalProject_Add (libhdfspp_ep
        DEPENDS orc::protobuf
        URL ${LIBHDFSPP_SRC_URL}
        LOG_DOWNLOAD 0
        LOG_CONFIGURE 0
        LOG_BUILD 0
        LOG_INSTALL 0
        BUILD_BYPRODUCTS "${LIBHDFSPP_STATIC_LIB}"
        CMAKE_ARGS ${LIBHDFSPP_CMAKE_ARGS})

      orc_add_built_library(libhdfspp_ep libhdfspp ${LIBHDFSPP_STATIC_LIB} ${LIBHDFSPP_INCLUDE_DIR})

      set (LIBHDFSPP_LIBRARIES
           libhdfspp
           ${CYRUS_SASL_SHARED_LIB}
           ${OPENSSL_LIBRARIES}
           ${CMAKE_THREAD_LIBS_INIT})

    elseif(CYRUS_SASL_SHARED_LIB)
      message(STATUS
      "WARNING: Libhdfs++ library was not built because the required OpenSSL library was not found")
    elseif(OPENSSL_LIBRARIES)
      message(STATUS
      "WARNING: Libhdfs++ library was not built because the required CyrusSASL library was not found")
    else ()
      message(STATUS
      "WARNING: Libhdfs++ library was not built because the required CyrusSASL and OpenSSL libraries were not found")
    endif(CYRUS_SASL_SHARED_LIB AND OPENSSL_LIBRARIES)
  else(ORC_CXX_HAS_THREAD_LOCAL)
    message(STATUS
    "WARNING: Libhdfs++ library was not built because the required feature
    thread_local storage is not supported by your compiler. Known compilers that
    support this feature: GCC, Visual Studio, Clang (community version),
    Clang (version for iOS 9 and later), Clang (version for Xcode 8 and later)")
  endif(ORC_CXX_HAS_THREAD_LOCAL)
endif(BUILD_LIBHDFSPP)
