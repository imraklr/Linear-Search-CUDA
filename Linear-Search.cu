#include <stdio.h>
#include <cuda.h>

struct SearchConfiguration {
    bool searchComplete;
    int searchValue;
};

__global__ void linearSearchKernel(int *arr, struct SearchConfiguration* searchConfiguration, int N) {
    if(!(searchConfiguration->searchComplete)) {
        int idx = blockIdx.x * blockDim.x + threadIdx.x;
        if(idx < N && (searchConfiguration->searchValue == arr[idx])) {
            // set the indicator to 1 (found)
            searchConfiguration->searchComplete = true;
        }
    }
}

__global__ void assignValue(int *indicator, int value) {
    *indicator = value;
}

int main() {

    int N = 10000000;

    // create and fill sample array
    int *arr = new int[N];
    for(int i=0;i<N;i++) {
        arr[i] = i+1;
    }

    // size of array in bytes
    size_t size = N * sizeof(int);

    // allocate memory on gddr
    int *d_arr;
    cudaMalloc(&d_arr, size);

    // copy contents from host to device
    cudaMemcpy(d_arr, arr, size, cudaMemcpyHostToDevice);

    // Host part of SearchConfiguration
    struct SearchConfiguration h_searchConfiguration;
    h_searchConfiguration.searchComplete = false;
    h_searchConfiguration.searchValue = -1;
    // Mention SearchConfiguration struct for device
    struct SearchConfiguration* d_searchConfiguration;

    // allocate space for struct SearchConfiguration on the device
    cudaMalloc((void**)&d_searchConfiguration, sizeof(h_searchConfiguration));

    // copy contents of host struct SearchConfiguration to device struct SearchConfiguration
    cudaMemcpy(d_searchConfiguration, &h_searchConfiguration, sizeof(h_searchConfiguration), cudaMemcpyHostToDevice);

    // kernel configurations
    int numberOfBlocksPerGrid = (N+1023)/1024;
    int numberOfThreadsPerBlock = 1024;

    // launch kernel
    linearSearchKernel<<<numberOfBlocksPerGrid, numberOfThreadsPerBlock>>>(d_arr, d_searchConfiguration, N);

    // synchronize to wait for result
    cudaDeviceSynchronize();

    // copy passed struct here
    cudaMemcpy(&h_searchConfiguration, d_searchConfiguration, sizeof(h_searchConfiguration), cudaMemcpyDeviceToHost);

    // display result
    printf("result = %d", h_searchConfiguration.searchComplete);

    // free device memory
    cudaFree(d_arr);
    // free host memory
    delete[] arr;

    return 0;
}