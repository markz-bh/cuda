cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(cmake_and_cuda LANGUAGES CXX CUDA)
#set(CMAKE_CUDA_ARCHITECTURES 86) # For Compute Capability 8.6 - RTX A4500 - Ampere architecture 
include(CTest)
 
# add_library(seqcuda STATIC
#   randomize.cpp
#   randomize.h
#   particle.cu
#   particle.h
#   v3.cu
#   v3.h
#   )
 
# # Request that particles be built with -std=c++11
# # As this is a public compile feature anything that links to 
# # particles will also build with -std=c++11
# target_compile_features(particles PUBLIC cxx_std_11)
 
# # We need to explicitly state that we need all CUDA files in the 
# # particle library to be built with -dc as the member functions 
# # could be called by other libraries and executables
# set_target_properties( particles
#                        PROPERTIES CUDA_SEPARABLE_COMPILATION ON)
 
add_executable(seqCuda seqCuda.cu)
set_property(TARGET seqCuda 
             PROPERTY CUDA_SEPARABLE_COMPILATION ON)
# target_link_libraries(particle_test PRIVATE particles)

if(APPLE)
  # We need to add the path to the driver (libcuda.dylib) as an rpath, 
  # so that the static cuda runtime can find it at runtime.
  set_property(TARGET seqCuda 
               PROPERTY
               BUILD_RPATH ${CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES})
endif() 

set(t2187_srcs t2187/t2187.cu t2187/dict.cu)
add_executable(t2187 ${t2187_srcs})
target_include_directories(t2187 PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/t2187")
set_property(TARGET t2187 PROPERTY CUDA_SEPARABLE_COMPILATION ON)
if(MSVC)
set_target_properties(t2187 PROPERTIES LINK_FLAGS "/NODEFAULTLIB:LIBCMT")
endif()

set(ex3_srcs ex3/v3.cu ex3/particle.cu ex3/main.cu)
add_executable(ex3 ${ex3_srcs})
target_include_directories(ex3 PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/ex3")
set_property(TARGET ex3 PROPERTY CUDA_SEPARABLE_COMPILATION ON)
if(MSVC)
set_target_properties(ex3 PROPERTIES VS_DEBUGGER_COMMAND_ARGUMENTS "32 0")
endif()