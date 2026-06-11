`timescale 1ns/1ps

module tb_bridge_rtl;

//====================================================
// INPUTS
//====================================================

reg hclk;
reg hresetn;
reg hselapb;
reg hwrite;
reg [1:0] htrans;
reg [31:0] haddr;
reg [31:0] hwdata;
reg [31:0] prdata;

//====================================================
// OUTPUTS
//====================================================

wire psel;
wire penable;
wire pwrite;
wire hresp;
wire hready;
wire [31:0] hrdata;

//====================================================
// DUT INSTANTIATION
//====================================================

bridge_rtl DUT (

    .hclk(hclk),
    .hresetn(hresetn),
    .hselapb(hselapb),
    .hwrite(hwrite),
    .htrans(htrans),
    .haddr(haddr),
    .hwdata(hwdata),
    .prdata(prdata),

    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .hresp(hresp),
    .hready(hready),
    .hrdata(hrdata)

);

//====================================================
// CLOCK GENERATION
//====================================================

always #5 hclk = ~hclk;

//====================================================
// INITIAL BLOCK
//====================================================

initial
begin

    // initialize signals
    hclk     = 0;
    hresetn  = 0;
    hselapb  = 0;
    hwrite   = 0;
    htrans   = 2'b00;
    haddr    = 32'h0000_0000;
    hwdata   = 32'h0000_0000;
    prdata   = 32'h1234_5678;

    //================================================
    // RESET
    //================================================

    #10;
    hresetn = 1;

    //================================================
    // WRITE TRANSFER
    //================================================

    #10;

    hselapb = 1;
    hwrite  = 1;
    htrans  = 2'b10;         // NONSEQ
    haddr   = 32'h8000_0000;
    hwdata  = 32'hAAAA_5555;

    #40;

    //================================================
    // READ TRANSFER
    //================================================

    hwrite  = 0;
    htrans  = 2'b10;
    haddr   = 32'h8000_0004;

    #40;

    //================================================
    // PIPELINED WRITE
    //================================================

    hwrite  = 1;
    htrans  = 2'b11;         // SEQ
    haddr   = 32'h8000_0008;
    hwdata  = 32'h1111_2222;

    #20;

    haddr   = 32'h8000_000C;
    hwdata  = 32'h3333_4444;

    #40;

    //================================================
    // END SIMULATION
    //================================================

    $finish;

end

//====================================================
// MONITOR
//====================================================

initial
begin

    $monitor("TIME=%0t RESET=%b HWRITE=%b HTRANS=%b PSEL=%b PENABLE=%b PWRITE=%b HRDATA=%h",
              $time,
              hresetn,
              hwrite,
              htrans,
              psel,
              penable,
              pwrite,
              hrdata);

end

endmodule
