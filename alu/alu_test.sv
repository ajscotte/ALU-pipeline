//-------------------------------------------------------------
// Positive edge register
//-------------------------------------------------------------
// maybe want to save out_put data and valid bit here

module operation (out, valid, halt, out_data);
    wire    [11:0]           in0; // Rx
    wire    [11:0]           in1; // Ry
    wire   [3:0]            op;
    wire   [5:0]            imm;
    output   logic            valid;
    output   logic            halt;
    output   logic [11:0]     out;
    output   logic [11:0]     out_data;
    reg                      c;

  reg           clk;
  reg           write;
  reg           reset;
  reg           write_en;
  reg    [1:0]      wrAddr;
  integer i;
  reg [11:0]  rfile[3:0];
  reg [3:0]   op_help;

reg [12:0] addc_h;
reg [12:0] add_h;
    
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

      wire [1:0] rd;
      wire [1:0] rx;
      wire [1:0] ry;
      reg [ 11:0] instr;


//decode
  assign op     = instr [11:8];
  assign rd      = instr [7:6];
  assign rx      = instr [5:4];
  assign ry      = instr [3:2];
  assign imm     = instr [5:0];



  
  always@ (*) begin
    case( op )// may want to replace with <=
      'h0 : begin
              out = in0 | in1;// OR
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
               op_help <=  'h0;
      end  
      'h1 : begin // XOR
              out = in0 ^ in1;
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              op_help <=  'h1; 
      end
      'h2 : begin
              out = in0 & in1; // AND
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              op_help <=  'h2;
      end
      'h3 : begin 
              out = ~in0; // NOT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              op_help <=  'h3;
      end
      'h4 : begin
              out = in0 << 1; // LSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              op_help <=  'h4;
      end
      'h5 : begin
              out = in0 >> 1; // RSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              op_help <=  'h5;
      end
      'h6 :begin 
              out = $signed(in0) >>> 1; // ARSHIFT
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              op_help <=  'h6;
      end
      'h7 : begin //ADD   // ADD!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              add_h = in0 + in1;
              c     = add_h[12];
              out =   add_h[11:0]; 
              valid = 1'b0;
              halt  = 1'b0;
              write_en = 1'b1;
              op_help <=  'h7;
      end
      'h8 : begin //ADDC // ADDC!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
              addc_h = in0 + in1 + c;
              out   = addc_h[11:0]; 
              c     = addc_h[12];
              valid  = 1'b0;
              halt   = 1'b0;
              write_en = 1'b1;
              op_help <=  'h8;
      end
      'h9 :begin 
            out = in0 - in1; // SUB
            valid = 1'b0;
            halt = 1'b0;
            write_en = 1'b1;
            op_help <=  'h9;
      end
      'hA : begin 
              out ={6'bx, imm}; // LOADLO
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              op_help <=  'hA;
      end 
      'hB : begin 
              out ={6'bx, imm}; // LOADHI
              valid = 1'b0;
              halt = 1'b0;
              write_en = 1'b1;
              op_help <=  'hB;
      end 
      'hC : begin 
              // OUT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
              out_data = in0; 
              valid = 1'b1;
              halt = 1'b0;
              write_en = 1'b0;
              op_help <=  'hC;
      end 
      'hD : begin 
               // HALT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
              out_data = in0;
              valid = 1'b1;
              halt = 1'b1;
              write_en = 1'b0;
              op_help <=  'hD;
      end 

      default : begin 
                halt = 1'b0;
                valid = 1'b0;
                write_en = 1'b0;
                op_help <=  'hx;
      end 
    endcase
  end

always @(posedge clk) begin
        q            <= out;
        wrAddr       <= rd;
        write_en_out <= write_en;
        op_out       <= op_help;
        valid_out    <= valid;
        data_out     <= out_data;
        halt_out     <= halt; 
    end



  //reset register file
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

assign in0 = rfile[rx];
assign in1 = rfile[ry];

  always@(posedge clk) begin
    if(write_en_out & !reset) begin
        case(op_out)
           'hA: rfile[wrAddr] <= {rfile[wrAddr][11:6], q[5:0] };
           'hB: rfile[wrAddr] <= {q[5:0], rfile[wrAddr][5:0]};
           default : rfile[wrAddr] <= q;
        endcase
      end
    end
    
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
    

     
initial begin
  clk = 0;
reset = 1; instr = 12'b101001000001;    
  #10 $display("reset test: register b00 = %b, resister b1 = %b should all be zeros",in0, in1);
reset = 0; instr = 12'b101110000001;      
  #25 $display("out  = %b 00001, q = %b should all be x's, rd is %b, wrAddr is %b, %b",out, q, rd, wrAddr, op_out);
reset = 0; instr = 12'b101010000011;      
   #40 $display("out  = %b 00001, q = %b should all be x's, rd is %b, wrAddr is %b, %b",out, q, rd, wrAddr, op_out);
reset = 0; instr = 12'b101000000111;      
  #40 $display("out  = %b 00001, q = %b should all be x's, rd is %b, wrAddr is %b, %b",out, q, rd, wrAddr, op_out);
  //#40 $display("q = %b is 00001, wrAddr = %b should all be zeros",q, wrAddr, );
// //load low register file
//   in0=12'b011111111111;in1=12'b111111111110; op = 'hA; imm = 6'b111111; reset = 0; rAddrA = 2'b0; rAddrB = 2'b01; wrAddr = 2'b01;      
//   #40 $display("loadlo: register b00 = %b is 111111000000, resister b1 = %b is 000000111111",dataA, dataB);
end

always
 #20 clk = ~clk;

endmodule