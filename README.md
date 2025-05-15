
<h1>📦 Parameterized FIFO Buffer – Verilog Implementation</h1> <br>
✅ Summary <br>
This project implements a parameterized synchronous FIFO (First-In First-Out) buffer in Verilog HDL.<br> 
It supports configurable DATA_WIDTH, DEPTH, and corresponding ADDR_WIDTH.<br>
The design ensures reliable data transfer with edge-detected write and read pulses and dynamic buf_empty and buf_full status flags.<br>

<h1>Key features include:</h1><br>
Parameterized data width and depth.<br>
FIFO counter to monitor occupancy level.<br>
Debounce and edge detection using 2-bit synchronizers (wr_sync, rd_sync) for stable input control signals.<br>
Separate read (rd_ptr) and write (wr_ptr) pointers for managing memory access.<br>
Memory implemented as a register array (buf_mem) for simulation, which can be mapped to block RAM on FPGAs.<br>
Outputs buf_empty, buf_full, and current fifo_counter value.<br>

## 📊 FIFO Simulation Waveform

Below is the simulation waveform showing FIFO write and read operations:

![FIFO Simulation Waveform](Waveforms/fifo-waveform.png)
