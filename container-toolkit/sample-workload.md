# Running a Sample Workload

```{contents}
---
depth: 2
local: true
backlinks: none
---
```

## Running a Sample Workload with Docker

After you install and configure the toolkit and install an NVIDIA GPU Driver,
you can verify your installation by running a sample workload.

- Run a sample CUDA container:

   ```console
   sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
   ```

   Your output should resemble the following output:

   ```{literalinclude} ./output/nvidia-smi.txt
   ---
   language: output
   ---
   ```

## Running a Sample Workload with Podman

After you install and configura the toolkit (including [generating a CDI specification](cdi-support.md)) and install an NVIDIA GPU Driver,
you can verify your installation by running a sample workload.

- Run a sample CUDA container:

   ```console
   podman run --rm --security-opt=label=disable \
      --device=nvidia.com/gpu=all \
      ubuntu nvidia-smi
   ```

   Your output should resemble the following output:

   ```{literalinclude} ./output/nvidia-smi.txt
   ---
   language: output
   ---
   ```

## Running Sample Workloads with containerd or CRI-O

These runtimes are more common with Kubernetes than desktop computing.
Refer to {doc}`gpuop:index` in the NVIDIA GPU Operator documentation for more information.