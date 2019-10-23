# Systolic Array Matrix Multiplication

This repository realizes a 4x4 systolic array matrix multiplication in verilog HDL. The whole Vivado project is all here. We use the latest Vivado 2019.1 to accomplish this work. You can directly clone it and open in Xinlinx Vivado design suite.

The whole process engine is composed of two parts. The read/write buffers for multiplier, multiplicand and result matrix respectively. 16 process units shapes in a 4 x 4 fashion.