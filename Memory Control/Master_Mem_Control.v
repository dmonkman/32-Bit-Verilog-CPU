module Master_Mem_control(CLK, PC_Instruction_Acces, Source_1, Source_2, ALU_out, OP_code, DataBus_in, DataBus_out, ADDRESS_bus, REG_bus, RW);
  input CLK;
  
  input [7:0] PC_Instruction_Acces;
  input [31:0] Source_1, Source_2;
  input [31:0] ALU_out;
  input [3:0] OP_code;
  
  input [31:0] DataBus_in;
  output[31:0] DataBus_out;
  
  
  wire [31:0] REG_bus_wire;
  wire [15:0] ADDRESS_bus_wire;
  wire ADD_selector, LDR_selector;
  
  output [31:0]  REG_bus;
  output [15:0] ADDRESS_bus;
  output RW;
  
  assign test = OP_code;

  Memory_Control mem (
  .CLK(CLK), 
  .Source_1(Source_1), 
  .Source_2(Source_2), 
  .OP_code(OP_code), 
  .DataBus_in(DataBus_in), 
  .DataBus_out(DataBus_out), 
  .ADD_selector(ADD_selector), 
  .LDR_selector(LDR_selector), 
  .ADD_bus(ADDRESS_bus_wire), 
  .REG_bus(REG_bus_wire), 
  .RW(RW));
  
  // IF ADD_selector = 1, ADDRESS_bus = ADDRESS_bus_wire; IF ADD_selector = 0, ADDRESS_bus = {8'b0, PC_Instruction_Acces}; 
  mux_16x2 ADD_bus_mux (ADD_selector, ADDRESS_bus_wire, {8'b0, PC_Instruction_Acces}, ADDRESS_bus);
  
  // IF LDR_selector = 1, REG_bus = REG_bus_wire; IF LDR_selector = 0, REG_bus = ALU_out; 
  mux_32x2 LDR_MUX (LDR_selector, REG_bus_wire, ALU_out, REG_bus);
  
endmodule