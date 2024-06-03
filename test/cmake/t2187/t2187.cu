#include <iostream>
#include <cuda_runtime_api.h>
#include <device_launch_parameters.h>
#include "dict.cuh"
using namespace std;

/*
__device__   
void cuda_max(float i, float j, float& result) {
	if (i > j) { result = i; } result = j;
}
__device__  
void  cuda_min(float i, float j, float& result) {
	if (i > j) { result = j; } result = i;
}
*/
__global__  
void Set_on_Gpu(int max_dict_size, int max_array_size, Dict** d_dict) {
	int thr_idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (thr_idx == 0) { *d_dict = new Dict(max_dict_size, max_array_size); }
}

__global__ 
void Add_on_Gpu(float key, float value[], int position, Dict** d_dict) {
	int thr_idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (thr_idx == 0) { (*d_dict)->add_entry(key, value, position); }
}

__global__  
void Show_on_Gpu(float key, Dict** d_dict, int size, float* res) {
	int thr_idx = blockIdx.x * blockDim.x + threadIdx.x;
	if (thr_idx == 0) {
		(*d_dict)->get_value(key, res);
	}
}

int main() {
	int max_array_size = 3;
	int max_dict_size = 1;
	float key = 0.;

	float* values = (float*)malloc(3 * sizeof(float));
	float* h_result = (float*)malloc(3 * sizeof(float));
	values[0] = 1.0;
	values[1] = 2.0;
	values[2] = 3.0;

	float* d_values;
	float* d_result;

	cudaMalloc((void**)&d_values, 3 * sizeof(float));
	cudaMemcpy(d_values, values, 3 * sizeof(float), cudaMemcpyHostToDevice);
	cudaMalloc((void**)&d_result, 3 * sizeof(float));

	Dict** dev_test;
	cudaMalloc((void**)&dev_test, sizeof(Dict*));

	Set_on_Gpu<<<32, 64 >>>(max_dict_size, max_array_size, dev_test);
	Add_on_Gpu<<<32, 64 >>>(key, d_values, 0, dev_test);
	Show_on_Gpu << <32, 64 >> > (key, dev_test, max_array_size, d_result);

	cudaMemcpy(h_result, d_result, 3 * sizeof(float), cudaMemcpyDeviceToHost);
	for (int i = 0; i < 3; i++)
		cout << h_result[i] << endl;
	return 0;
}