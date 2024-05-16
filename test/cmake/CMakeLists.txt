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