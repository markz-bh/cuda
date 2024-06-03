#pragma once

class Dict {
private:
	struct KeyValuePair {
		float key;
		float* value;
		int value_size;
	};

	KeyValuePair* data;
	int max_size;

public:
	__device__ Dict(int max_dict_size, int max_array_size);
	__device__ ~Dict();
	__device__ void add_entry(float key, float value[], int position);
	__device__ void get_value(float key, float value[]);
};