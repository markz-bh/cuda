find_package(CUDAToolkit REQUIRED)

message(STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")

add_executable(bicgstab_example ${CMAKE_CURRENT_SOURCE_DIR}/bicgstab_example.c)

target_include_directories(bicgstab_example
  PUBLIC ${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES} 
)
target_link_libraries(bicgstab_example
  PUBLIC cudart cusparse cublas
)
set_target_properties(bicgstab_example
  PROPERTIES LINKER_LANGUAGE CUDA)
