#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vcpu.h"
#include <iostream>
#include <iomanip>
#include "vbuddy.cpp"    
#define MAX_SIM_CYC 1000000

int main(int argc, char **argv, char **env) {
  int simcyc;     // Simulation Cycle 
  int trigcyc;    // Cycle trigger is set
  int tick;       // Clock ticks

  Verilated::commandArgs(argc, argv);
  
  // init cpu verilog instance
  Vcpu* cpu = new Vcpu;
  
  // init trace dump
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  cpu->trace (tfp, 99);
  tfp->open ("cpu.vcd");

  // init Vbuddy
  if (vbdOpen()!=1) return(-1);
  vbdHeader("CPU Test");
  vbdSetMode(1);

  // initialize simulation inputs
  cpu->CLK = 0;
  cpu->rst = 0;
  cpu->trigger = 0;

  for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++) {

    // Clock ticks
    for (tick=0; tick<2; tick++) {
      tfp->dump (2*simcyc+tick);
      cpu->CLK = !cpu->CLK;
      cpu->eval ();
    }

    // Test Reference
    if (simcyc>500000) {
      vbdCycle(simcyc);
      vbdPlot(cpu->a0,0,255);
    } 

    // Test F1Lights
    //cpu->trigger = vbdFlag() || vbdGetkey() == 't'; 
    //vbdBar(cpu->a0);
    //vbdCycle(simcyc);
    
  }
  // Exit 2
  vbdClose();
  tfp->close(); 
  exit(0);
}
