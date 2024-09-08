# linear-search-cuda
Linear search method that can be employed on CUDA-enabled GPUs.

You can change the number of items in the array by altering value of variable `N` and to change which number to find, you can alter the member of `struct SearchConfiguration` for host.

# How to run on Windows
Please note that the command mentioned here is based on the specific GPU model I am using: a GeForce 940MX.

- Open x64 Native Tools Command Prompt for VS 2022 and run the following command to compile:

```cmd
nvcc -arch=sm_50 -o Linear-Search Linear-Search.cu
```

- Now three files will be generated with extensions: .exe, .lib, .exp
- To run just use the command `Linear-Search.exe` and press Enter.
