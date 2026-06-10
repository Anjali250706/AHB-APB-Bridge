`timescale 1ns / 1ps
module bridge_rtl(

    input hclk,
    input hresetn,
    input hselapb,
    input hwrite,
    input [1:0] htrans,
    input [31:0] haddr,
    input [31:0] hwdata,
    input [31:0] prdata,

    output reg psel,
    output reg penable,
    output reg pwrite,
    output reg hresp,
    output reg hready,
    output reg [31:0] hrdata

);

//====================================================
// STATE DECLARATION
//====================================================

parameter idle    = 3'b000;
parameter read    = 3'b001;
parameter wwait   = 3'b010;
parameter write   = 3'b011;
parameter write_p = 3'b100;
parameter wenable = 3'b110;
parameter renable = 3'b111;

//====================================================
// INTERNAL REGISTERS
//====================================================

reg [31:0] haddr_temp, hwdata_temp;
reg [2:0] present_state, next_state;
reg valid, hwrite_temp;

//====================================================
// VALID SIGNAL GENERATION
//====================================================

always @(*)
begin
    if(hselapb == 1'b1 && (htrans == 2'b10 || htrans == 2'b11))
        valid = 1'b1;
    else
        valid = 1'b0;
end

//====================================================
// PRESENT STATE LOGIC
//====================================================

always @(posedge hclk or negedge hresetn)
begin
    if(!hresetn)
        present_state <= idle;
    else
        present_state <= next_state;
end

//====================================================
// TEMPORARY STORAGE
//====================================================

always @(posedge hclk)
begin
    if(valid)
    begin
        haddr_temp  <= haddr;
        hwdata_temp <= hwdata;
        hwrite_temp <= hwrite;
    end
end

//====================================================
// NEXT STATE LOGIC
//====================================================

always @(*)
begin

    case(present_state)

        idle:
        begin
            if(valid && hwrite)
                next_state = wwait;

            else if(valid && !hwrite)
                next_state = read;

            else
                next_state = idle;
        end

        wwait:
        begin
            next_state = write;
        end

        write:
        begin
            next_state = wenable;
        end

        wenable:
        begin
            if(valid && hwrite)
                next_state = write_p;

            else if(valid && !hwrite)
                next_state = read;

            else
                next_state = idle;
        end

        write_p:
        begin
            next_state = wenable;
        end

        read:
        begin
            next_state = renable;
        end

        renable:
        begin
            if(valid && hwrite)
                next_state = wwait;

            else if(valid && !hwrite)
                next_state = read;

            else
                next_state = idle;
        end

        default:
            next_state = idle;
    endcase
end

//====================================================
// OUTPUT LOGIC
//====================================================

always @(*)
begin
  // default values
    psel    = 0;
    penable = 0;
    pwrite  = 0;
    hready  = 1;
    hresp   = 0;

    case(present_state)

        idle:
        begin
            psel = 0;
            penable = 0;
        end
       read:
        begin
            psel = 1;
            penable = 0;
            pwrite = 0;
        end
        renable:
        begin
            psel = 1;
            penable = 1;
            pwrite = 0;
            hrdata = prdata;
        end
        write:
        begin
            psel = 1;
            penable = 0;
            pwrite = 1;
        end
        wenable:
        begin
            psel = 1;
            penable = 1;
            pwrite = 1;
        end
        write_p:
        begin
            psel = 1;
            penable = 0;
            pwrite = 1;
        end
    endcase
end
endmodule
