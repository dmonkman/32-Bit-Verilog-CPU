module Memory_Control (CLK, Source_1, Source_2, OP_code, DataBus_in, DataBus_out, ADD_selector, LDR_selector, ADD_bus, REG_bus, RW);
  input CLK;

  input [31:0] Source_1;
  input [31:0] Source_2;
    
  input [3:0] OP_code;
  
  input      [31:0] DataBus_in;
  output reg [31:0] DataBus_out;
  
  output reg ADD_selector;
  output reg LDR_selector;

  output reg [15:0] ADD_bus;
  output reg [31:0] REG_bus;
  
  output reg RW;
  
 
  always@* 
  begin
    ADD_bus <= Source_1[15:0];
    REG_bus <= DataBus_in;
    case(OP_code) // execute LDR operation
      4'b1001: begin
        RW <= 1'b0;
        ADD_selector <= 1'b1;
        LDR_selector <= 1'b1;  
              
      end

      4'b1010: begin //execute STR operation
        RW <= 1'b1;
        ADD_selector <= 1'b1;
        LDR_selector <= 1'b0;  
        DataBus_out <= Source_2; 
               
      end
      
      default: begin
        RW <= 1'b0;
        ADD_selector <= 1'b0;
        LDR_selector <= 1'b0;  
        
      end  
    endcase

    
  end
endmodule
      
      
  