module operation (out, valid, halt, out_data);
    reg    [11:0]           in0; // Rx
    reg    [11:0]           in1; // Ry
    reg   [3:0]            op;
    reg   [5:0]            imm;
    output   logic            valid;
    output   logic            halt;
    output   logic            c_out;
    output   logic [11:0]     out;
    output   logic [11:0]     out_data;
    reg                      c;
    reg    [12:0]            add_h;
    reg    [12:0]            addc_h;

  reg         signal;
  reg          write;
  reg    [1:0] wrAddr; 
  reg    [1:0] rAddrA;
  reg    [1:0] rAddrB;
  reg    [11:0] dataIn;
  reg           reset;
  reg           write_en;
  wire [11:0] dataA;
  wire [11:0] dataB;
  wire [11:0] helper; 
  reg [5:0] helper2;
  integer i;
  reg [11:0]  rfile[3:0];


    reg                           en;
    reg        [11:0]             rdData;
    reg                           signal2;
    reg                            write_en_in;
    reg                           valid_in;
    reg                           halt_in;
    reg         [1:0]             rd_in;
    reg         [3:0]             op_in;
    reg         [11:0]            data_in;
    reg         [11:0]            d;  
    output logic                    write_en_out;    
    output logic                    valid_out; 
    output logic                    halt_out;
    output logic  [1:0]             rd_out;
    output logic  [3:0]             op_out;
    output logic  [11:0]            data_out;
    output logic  [11:0]            q;
 
  //assign add_h = in0 + in1;
  //assign addc_h = in0 + in1 + c;
  always@(signal) begin
    rdData <= rfile[wrAddr];
    if(write_en) begin
        rfile[wrAddr] <= out;
        //dataA = rfile[rAddrA];
        //dataB = rfile[rAddrB];
        // case(op)
        //    'hA: rfile[wrAddr] <= {rfile[wrAddr][11:6], out[5:0] };
        //    'hB: rfile[wrAddr] <= {out[5:0], rfile[wrAddr][5:0]};
        //    default : rfile[wrAddr] <= out;
        // endcase
      end
    end
assign helper = rdData;
assign dataA = rfile[rAddrA];
assign dataB = rfile[rAddrB];


  always@ ( op, rdData ) begin
    case( op )// may want to replace with <=
      'h0 : begin
              out = in0 | in1;// OR
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end  
      'h1 : begin // XOR
              out = in0 ^ in1;
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end
      'h2 : begin
              out = in0 & in1; // AND
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end
      'h3 : begin 
              out = ~in0; // NOT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end
      'h4 : begin
              out = in0 << 1; // LSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end
      'h5 : begin
              out = in0 >> 1; // RSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end
      'h6 :begin 
              out = $signed(in0) >>> 1; // ARSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end
      'h7 : begin //ADD   // ADD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              add_h = in0 + in1;
              c     = add_h[12];
              out =   add_h[11:0]; 
              valid = 1'b0;
              halt  = 1'b0;
              write_en = 1'b1;
      end
      'h8 : begin //ADDC // ADDC!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              addc_h = in0 + in1 + c;
              out   = addc_h[11:0]; 
              c     = addc_h[12];
              valid  = 1'b0;
              halt   = 1'b0;
              write_en = 1'b1;
      end
      'h9 :begin 
            out = in0 - in1; // SUB
            valid = 1'b0;
            halt = 1'b0;
            write_en = 1'b1;
      end
      'hA : begin 
              out ={helper[11:6], imm };
              helper2 = rdData[11:6]; // LOADLO
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end 
      'hB : begin 
              out ={imm, helper[5:0]}; // LOADHI
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
      end 
      'hC : begin 
              // OUT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
              out_data = in0; 
              valid = 1'b1;
              halt = 1'b0;
              write_en = 1'b0;
      end 
      'hD : begin 
               // HALT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
              out_data = in0;
              valid = 1'b1;
              halt = 1'b1;
              write_en = 1'b0;
      end 

      default : begin 
                halt = 1'b0;
                valid = 1'b0;
                write_en = 1'b0;
      end 
    endcase
  end
  always@(reset) begin
    if(reset) begin
    out <= 12'b0;
    c <=0;
    write_en <= 1'b0;
        for (i = 0; i < 4; i = i + 1) begin
          rfile[i] <= 12'b0;
        end
    end
  end

//assign rdData = rfile[wrAddr];



    
    // always @ (reset) begin// maybe comment out 
    //   if(reset)begin
    //     q<=12'b0;
    //     rd_out <= 2'b00;
    //     write_en_out<= 1'b0;
    //     valid_out<= 1'b0;
    //     halt_out<= 1'b0;
    //     //op_out<='hC;
    //   end
    // end
    
    always @(signal2) begin
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

     
initial begin
//register tests
// d = 12'b10; rd_in = 2'b10; en = 1'b1; write_en_in = 1'b1; op_in = 4'b10; valid_in = 1'b1; data_in = 12'b10; halt_in = 12'b1;
// #1 $display("simple register test: q = %b is 000000000010, rd_out = %b is 10, write_en:%b, opt_out:%b, %b, %b, %b", q, rd_out, write_en_out, op_out, valid_out, data_out, halt_out);

// signal2 = 2; en = 1'b1;
// #1 $display("simple register test: q = %b is 000000000010, rd_out = %b is 10, write_en:%b, opt_out:%b, %b, %b, %b", q, rd_out, write_en_out, op_out, valid_out, data_out, halt_out);

// //operations test

// //or
//   in0=12'b111111111111;in1=12'b111111111110; op = 'h0;     
//   #1 $display("or test: out = %b is 111111111111",out);
// //xor
//   in0=12'b011111111111;in1=12'b111111111110; op = 'h1;     
//   #1 $display("xor test out = %b is 100000000001",out);
// //and
//   in0=12'b011111111111;in1=12'b111111111100; op = 'h2;     
//   #1 $display("and test: out = %b is 111111111100",out);
// //not
//   in0=12'b011111101111;in1=12'b111111111110; op = 'h3;    
//   #1 $display("not test: out = %b is 100000010000",out);
// //Lshift
//   in0=12'b111111111111;in1=12'b111111111110; op = 'h4;    
//   #1 $display("Lshift test: out = %b is 111111111110",out);
// //Rshift
//   in0=12'b011111111111;in1=12'b111111111110; op = 'h5;       
//   #1 $display("Rshift test: out = %b is 001111111111",out);
// //ARshift 1
//   in0=12'b111111111110;in1=12'b111111111110; op = 'h6;       
//   #1 $display("ARshift test 1 out = %b is 11111111111", out);
// //ARshift 0
//   in0=12'b011111111111;in1=12'b111111111110; op = 'h6;       
//   #1 $display("ARshift test 0 out = %b is 001111111111",out);
// //ADD updates carry to 0
//   in0=12'b001111111111;in1=12'b1; op = 'h7;    
//   #1 $display("Add carry 0: out = %b is 010000000000, carry = %b",out,c);
// //ADDC carry in 0 carry out 1
//   in0=12'b111111111111;in1=12'b111111111111; op = 'h8;      
//   #1 $display("Addc carry out is 1 out = %b is 111111111110, carry = %b",out, c);
// //ADDC with carry in 1
//   in0=12'b111111111111;in1=12'b111111111111; op = 'h8; imm = 6'b111111; signal = 1; rAddrA = 2'b00;       
//   #1 $display("Addc carry in 1 out = %b is 111111111111, carry = %b",out,c);
//   //SUB
//   in0=12'b10;in1=12'b1; op = 'h9; imm = 6'b111111; signal = 1; rAddrA = 2'b00;       
//   #1 $display("Sub test: out = %b is 000000000001",out);
//   //LoadLo
//   in0=12'b0;in1=12'b111111111110; op = 'hA; imm = 6'b111111;      
//   #1 $display("LoadLo test: out = %b is xxxxxx111111",out);
//   //LoadHi
//   in0=12'b011111111111;in1=12'b111111111110; op = 'hB; imm = 6'b111111;       
//   #1 $display("LoadHi test: out = %b is xxxxxx111111",out);
//   //OUT
//   in0=12'b011111111111;in1=12'b111111111110; op = 'hC;     
//   #1 $display("Out test: out_data = %b is 011111111111, valid = %b is 1",out_data, valid);
//   //Halt
//   in0=12'b011111111111;in1=12'b111111111110; op = 'hD;      
//   #1 $display("Halt test: out_data = %b is 011111111111, valid = %b is 1, halt = %b is 1 ",out_data, valid, halt);

//registerFile tests

  //reset the register file
  signal = 1; reset = 1; rAddrA = 2'b0; rAddrB = 2'b1;      
  #1 $display("reset test: register b00 = %b, resister b1 = %b should all be zeros",dataA, dataB);
  //load register file high
  in0=12'b011111111111;in1=12'b111111111110; op = 'hB; imm = 6'b111111;  signal = 0; reset = 0; rAddrA = 2'b0; rAddrB = 2'b1; wrAddr = 2'b00;      
  #1 $display("loadhi regfil test: register b00 = %b is 111111000000, resister b1 = %b is 0, %b, %b, %b",rfile[00], dataB, rdData, out, helper2 );
  // //load low register file
  // in0=12'b011111111111;in1=12'b111111111110; op = 'hA; imm = 6'b111111;  signal = 1; reset = 0; rAddrA = 2'b0; rAddrB = 2'b01; wrAddr = 2'b01;      
  // #1 $display("loadlo: register b00 = %b is 111111000000, resister b1 = %b is 000000111111",dataA, dataB);
  // //loading low initial register 0
  // op = 'hA; imm = 6'b111111;  signal = 0; reset = 0; rAddrA = 2'b0; rAddrB = 2'b01; wrAddr = 2'b00;      
  // #1 $display("load lo: register b00 = %b is 11111111111, resister b1 = %b is 000000111111",dataA, dataB);
  // //load or instruction
  // in0=12'b011111111111;in1=12'b111111111110; op = 'h1; imm = 6'b111111;  signal = 1; reset = 0; rAddrA = 2'b0; rAddrB = 2'b1; wrAddr = 2'b01;      
  // #1 $display("loadhi regfil test: register b10 = %b is 111111111111, resister b1 = %b is 111111111111",dataA, dataB);


end 
endmodule