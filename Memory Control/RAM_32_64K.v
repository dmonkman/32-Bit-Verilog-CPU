
module RAM_32_64K(
    input RW,                       // 0 = READ, 1 = WRITE
    input [15:0] AddressBus,       // 2^16 MEMORY ADDRESSES
    input [31:0] DataIn,           // 32-BIT BI-DIRECTIONAL DATA BUS
    output [31:0] DataOut);

    parameter Dwidth = 32;          // 32-BIT DATA
    parameter Awidth = 16;          // 2^16 MEMORY ADDRESSES

    reg [Dwidth-1:0] mem[0:1<<(Awidth-1)];    // PHYSICAL MEMORY REGISTERS

    // If Enable + Read, write mem[Address] to the DataBus: otherwise z
    assign DataOut = (!RW) ? (mem[AddressBus]) : 32'bz;

    // If Enable + Write
    always @*
    begin
        if (RW)
            mem[AddressBus] <= DataIn; 
    end
endmodule