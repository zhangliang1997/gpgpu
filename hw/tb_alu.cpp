 #include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Valu.h"
#include "Valu___024unit.h"

#define MAX_SIM_TIME 200  // 仿真总时钟边沿数
vluint64_t sim_time = 0; // 用于计数时钟边沿

int main(int argc, char** argv, char** env) {
    Valu *dut = new Valu; // 例化转换后的 ALU 模块
	  // 接下来的四行代码用于设置波形存储为VCD文件
    Verilated::traceEverOn(true);
    VerilatedVcdC *m_trace = new VerilatedVcdC;  
    dut->trace(m_trace, 5);               
    m_trace->open("waveform.vcd");
	  // 实际进行仿真的代码
    while (sim_time < MAX_SIM_TIME) {
        dut->clk ^= 1; 
        dut->eval();  
        m_trace->dump(sim_time);
        sim_time++; // 更新仿真时间
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}
