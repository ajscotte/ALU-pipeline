`default_nettype none
`timescale 1ns/1ns
//-------------------------------------------------------------
// Positive edge register
//-------------------------------------------------------------
// maybe want to save out_put data and valid bit here

module vc_en_Reg (clk, reset, write_en_in, rd_in, op_in, en, d, write_en_out, rd_out, op_out, q, valid_in, valid_out, data_in, data_out, halt_in, halt_out);
    input                           clk;
    input                           reset;
    input                           en;
    input                           write_en_in;
    input                           valid_in;
    input                           halt_in;
    input         [1:0]             rd_in;
    input         [3:0]             op_in;
    input         [11:0]            data_in;
    input         [11:0]            d; 
    output logic                    write_en_out;    
    output logic                    valid_out; 
    output logic                    halt_out;
    output logic  [1:0]             rd_out;
    output logic  [3:0]             op_out;
    output logic  [11:0]            data_out;
    output logic  [11:0]            q;
    
    always @ (reset) begin// maybe comment out 
      if(reset)begin
        q<=12'b0;
        rd_out <= 2'bx;
        write_en_out<= 1'b0;
        valid_out<= 1'b0;
        halt_out<= 1'b0;
        op_out<='hx;
      end
    end
    
    always @(posedge clk) begin
      if( en )begin
        q            <= d;
        rd_out       <= rd_in;
        write_en_out <= write_en_in;
        op_out       <= op_in;
        valid_out    <= valid_in;
        data_out     <= data_in;
        halt_out     <= halt_in; 
      end
    end
endmodule
//-------------------------------------------------------------
// operations for ALU
//-------------------------------------------------------------
module operation (in0, in1, reset, op, imm, out, valid, halt, out_data, write_en, rdData, out_op);
    input    [11:0]           in0; // Rx
    input    [11:0]           in1; // Ry
    input                     reset;
    input    [3:0]            op;
    input    [5:0]            imm;
    input    [11:0]           rdData; 
    output   logic            write_en;
    output   logic            valid;
    output   logic            halt;
    output   logic [11:0]     out;
    output   logic [11:0]     out_data;
    output   logic [3:0]      out_op;
    //local 
    reg    [12:0]            add_h;
    reg    [12:0]            addc_h;
    reg                      c;

  always@ (*) begin
    case( op )// may want to replace with <=
      'h0 : begin
              out = in0 | in1;// OR
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'h0;
      end  
      'h1 : begin // XOR
              out = in0 ^ in1;
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'h1;
      end
      'h2 : begin
              out = in0 & in1; // AND
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'h2;
      end
      'h3 : begin 
              out = ~in0; // NOT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'h3;
      end
      'h4 : begin
              out = in0 << 1; // LSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'h4;
      end
      'h5 : begin
              out = in0 >> 1; // RSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'h5;
      end
      'h6 :begin 
              out = $signed(in0) >>> 1; // ARSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'h6;
      end
      'h7 : begin //ADD  
              add_h = in0 + in1;
              c     = add_h[12];
              out =   add_h[11:0]; 
              valid = 1'b0;
              halt  = 1'b0;
              write_en = 1'b1;
              out_op <= 'h7;
      end
      'h8 : begin //ADDC
              addc_h = in0 + in1 + c;
              out   = addc_h[11:0]; 
              c     = addc_h[12];
              valid  = 1'b0;
              halt   = 1'b0;
              write_en = 1'b1;
              out_op <= 'h8;
      end
      'h9 :begin 
            out = in0 - in1; // SUB
            valid = 1'b0;
            halt = 1'b0;
            write_en = 1'b1;
            out_op <= 'h9;
      end
      'hA : begin 
             out ={6'bx, imm};
             //out = {rdData[11:6], imm}; // LOADLO
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'hA;
      end 
      'hB : begin 
              out ={6'bx, imm}; // LOADHI
              //out = {imm, rdData[5:0]};
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              out_op <= 'hB;
      end 
      'hC : begin 
              // OUT 
              out_data = in0; 
              valid = 1'b1;
              halt = 1'b0;
              write_en = 1'b0;
              out_op <= 'hC;
      end 
      'hD : begin 
               // HALT 
              out_data = in0;
              valid = 1'b1;
              halt = 1'b1;
              write_en = 1'b0;
              out_op <= 'hD;
      end 

      default : begin 
                halt = 1'b0;
                valid = 1'b0;
                write_en = 1'b0;
                out_op <= 'hX;
      end 
    endcase
  end
  always@(reset) begin
    if(reset) begin
    out <= 12'b0;
    c <=0;
    write_en <= 1'b0;
    end
  end

endmodule

//-------------------------------------------------------------
// 2r1w register file with reset
//-------------------------------------------------------------
module reg_file(clk, write, wrAddr, rAddrA, rAddrB, dataIn, dataA, dataB, op, reset, rdData);
  input          clk;
  input          write;
  input    [1:0] wrAddr; 
  input    [1:0] rAddrA;
  input    [1:0] rAddrB;
  input    [11:0] dataIn;
  input    [3:0]  op;
  input           reset;
  output   logic [11:0] dataA;
  output   logic [11:0] dataB;
  output   logic [11:0] rdData;
  integer i;
  reg  [3:0]       op_help;
  reg [31:0]  counter;
  reg [11:0]  rfile[3:0];
  reg [3:0]   opStor[1:0];
//read
 
  //assign rdData = rfile[wrAddr];

// reset
  always@(reset) begin
    if(reset) begin
        for (i = 0; i < 4; i = i + 1) begin
          rfile[i] <= 12'b0;
      //    counter <= 0;
        end
    end
  end
//write
 
  always@( posedge  clk) begin
   // counter <= counter + 1;
    //opStor[counter%2]  <= op; 
    //op_help <= opStor[(counter+1)%2];
   
     if(write && !reset) begin
       // rfile[wrAddr] <= dataIn;
      case(op)
           'hA: rfile[wrAddr] <= {rfile[wrAddr][11:6], dataIn[5:0] };
           'hB: rfile[wrAddr] <= {dataIn[5:0], rfile[wrAddr][5:0]};
           default : rfile[wrAddr] <= dataIn;
        endcase
    end
  end
  assign dataA = rfile[rAddrA];
  assign dataB = rfile[rAddrB];
  //assign  rdData = rfile[wrAddr];
    

endmodule
//-------------------------------------------------------------
// decodes instruction
//-------------------------------------------------------------
module decode(instr, op_code, rd, rx, ry, imm);
  input [11:0] instr;
  output   [3:0] op_code;
  output [1:0] rd;
  output  [1:0] rx;
  output  [1:0] ry;
  output   [5:0] imm;
    assign op_code = instr [11:8];
    assign rd      = instr [7:6];
    assign rx      = instr [5:4];
    assign ry      = instr [3:2];
    assign imm     = instr [5:0];
endmodule


module alu
  #(parameter int data_width = 12,
    parameter int instruction_width = 12)
   (// A rising edge should trigger clocked logic
    input wire clk,

    // Active high reset
    input wire                         rst,

    // Instructions for the ALU to perform, a new instruction will be
    // given each clock cycle.
    input wire [instruction_width-1:0] instruction,

    // Data output from the ALU, its value is considered undefined if
    // out_valid is deasserted.
    output logic [data_width-1:0]      out_data,
    output logic                       out_valid,

    // Stop execution if asserted
    output logic                       halt);

    // The ALU should have four 12 bits general purpose register.
    localparam int num_registers = 4;

    // Your code here...
  wire        write_en;
  wire [3:0]  op_code;
  wire        write_en_op;
  wire        write_en_reg;
  wire        valid_oper;
  wire        halt_oper;
  wire [1:0]  rd_addr_in;
  wire [1:0]  rd_addr_reg;
  wire [3:0]  op_code_in;
  wire [3:0]  op_code_reg;
  wire [5:0]  imm;
  wire  [1:0] rxAddr;
  wire  [1:0] ryAddr;
  wire  [11:0] rdData;
  wire  [11:0] rxOut;
  wire  [11:0] ryOut;
  wire  [11:0] out_data_oper;
  wire  [11:0] rd_data_oper;
  wire  [11:0] rd_data_reg;
  wire  [3:0]  op_out;
//--------------------------------------------------------------------
//Stage 1 get decode istruction, get register data, and operate
//--------------------------------------------------------------------
     decode instruct (
              .instr(instruction),
              .op_code(op_code_in),
              .rx(rxAddr),
              .ry(ryAddr),
              .rd(rd_addr_in),
              .imm(imm)
    );
    //reading from register file
    reg_file reg_f2(
              .clk(clk),
              .reset(rst),
              .write(write_en_reg),
              .wrAddr(rd_addr_reg),/////
              .rAddrA(rxAddr),
              .rAddrB(ryAddr),
              .op(op_code_reg),
              .dataIn(rd_data_reg),
              .dataA(rxOut),
              .dataB(ryOut)
              
              //.rdData(rdData)
    );
   // assign valid = valid_h;
    //operating on registers
    operation arith_imm2 (

              .in0(rxOut), // Rx
              .in1(ryOut), // Ry
              .reset(rst),
              .op(op_code_in),
              .imm(imm),
              .out(rd_data_oper),
              .valid(out_valid),
              .halt(halt),
              .out_data(out_data),
              .write_en(write_en_op),
              .out_op(op_out)
              //.rdData(rdData)
    );
// ------------------------------------------
// stage 2 write back to register file
// ------------------------------------------
    vc_en_Reg opReg(
                .clk(clk),
                .reset(rst),
                .write_en_in(write_en_op),
                .write_en_out(write_en_reg),
                .rd_in(rd_addr_in),
                .rd_out(rd_addr_reg),
                .op_in(op_out),
                .op_out(op_code_reg),
                .en(1'b1),
                .d(rd_data_oper),                  
                .q(rd_data_reg),
                .valid_in(),
                .valid_out(),
                .halt_in(),
                .halt_out(),
                .data_in(),
                .data_out()

    );

endmodule

// DO NOT REMOVE THE FOLLOWING LINES OR PUT ANY CODE/COMMENTS AFTER THIS LINE
// hw_intern_test-20211001.zip
// 5758c30fea56167563887d52e49cf8b03a194cd7
