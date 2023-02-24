include(FetchContent)

function(FetchContent_MakeAvailable_One dep exclude)
  message(STATUS "Fetching ${dep} (exclude: ${exclude})")
  FetchContent_GetProperties(${dep})
  if(NOT ${dep}_POPULATED)
    FetchContent_Populate(${dep})
    if(${dep} STREQUAL "spdlog" AND NOT DEFINED SPDLOG_PATCHED)
      # hack spdlog
      execute_process(COMMAND sed -i "s/^\\([^p].*mutex_;.*\\)$/public:\\1 private:/" ${${dep}_SOURCE_DIR}/include/spdlog/sinks/ansicolor_sink.h)
      message(STATUS "Patched spdlog")
      set(SPDLOG_PATCHED ON CACHE INTERNAL "")
    elseif(${dep} STREQUAL "websocketpp" AND NOT DEFINED WEBSOCKETPP_PATCHED)
      # hack websocketpp so that it can be used in-project
      execute_process(COMMAND sed -i [=[s/cmake_minimum_required.*$/cmake_minimum_required(VERSION 3.0.0)/]=] ${${dep}_SOURCE_DIR}/CMakeLists.txt)
      execute_process(COMMAND sed -i [=[$ a add_library(websocketpp INTERFACE)\nset_target_properties(websocketpp PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${PROJECT_SOURCE_DIR}")]=] ${${dep}_SOURCE_DIR}/CMakeLists.txt)
      message(STATUS "Patched websocketpp")
      set(WEBSOCKETPP_PATCHED ON CACHE INTERNAL "")
    endif()
    if(exclude)
      add_subdirectory(${${dep}_SOURCE_DIR} ${${dep}_BINARY_DIR} EXCLUDE_FROM_ALL)
    else()
      add_subdirectory(${${dep}_SOURCE_DIR} ${${dep}_BINARY_DIR})
    endif()
  endif()
endfunction()

function (FetchContent_MakeAvailable_Exclude)
  foreach(dep IN LISTS ARGV)
    FetchContent_MakeAvailable_One(${dep} 1)
  endforeach()
endfunction()

function (FetchContent_MakeAvailable_Include)
  foreach(dep IN LISTS ARGV)
    FetchContent_MakeAvailable_One(${dep} 0)
  endforeach()
endfunction()
