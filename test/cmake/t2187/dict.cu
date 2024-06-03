#include "dict.cuh"
#include <cuda_runtime_api.h>

__device__ 
Dict::Dict(int max_dict_size, int max_array_size) : max_size(max_dict_size) {
	data = new KeyValuePair[max_size];
	for (int i = 0; i < max_size; ++i) {
		data[i].value = new float[max_array_size];
		data[i].value_size = max_array_size;
	}
}

__device__
Dict::~Dict() {
	for (int i = 0; i < max_size; i++) { delete[] data[i].value; }
	delete[] data;
}

__device__
void Dict::add_entry(float key, float value[], int position) {
	if (position == max_size) { return; }

	data[position].key = key;
	int value_size = data[position].value_size;
	for (int i = 0; i < value_size; i++) {
		data[position].value[i] = value[i];
	}
}


__device__
void Dict::get_value(float key, float value[]) {
	for (int i = 0; i < max_size; i++) {
		if (data[i].key == key) {
			for (int j = 0; j < data[i].value_size; j++) { value[j] = data[i].value[j]; }
		}
	}
}