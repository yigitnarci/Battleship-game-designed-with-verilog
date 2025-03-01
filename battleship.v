// DO NOT MODIFY THE MODULE NAMES, SIGNAL NAMES, SIGNAL PROPERTIES

module battleship (
  input            clk  ,
  input            rst  ,
  input            start,
  input      [1:0] X    ,
  input      [1:0] Y    ,
  input            pAb  ,
  input            pBb  ,
  output reg [7:0] disp0,
  output reg [7:0] disp1,
  output reg [7:0] disp2,
  output reg [7:0] disp3,
  output reg [7:0] led
);


parameter IDLE = 4'b0000;
parameter SHOW_A = 4'b0001;
parameter A_IN = 4'b0010;
parameter ERROR_A = 4'b0011;
parameter SHOW_B = 4'b0100;
parameter B_IN = 4'b0101;
parameter ERROR_B = 4'b0110;
parameter SHOW_SCORE = 4'b0111;
parameter A_SHOOT = 4'b1000;
parameter A_SINK = 4'b1001;
parameter A_WIN = 4'b1010;
parameter B_SHOOT = 4'b1011;
parameter B_SINK = 4'b1100;
parameter B_WIN = 4'b1101;

reg [3:0] current_state;
reg [2:0] Score_A, Score_B;
reg [1:0] A_input_counter, B_input_counter;      
reg [1:0] sink_count_A, sink_count_B;
reg [15:0] mapA;
reg [15:0] mapB;
reg [8:0] clock;
reg Z; 

always @(posedge clk ) begin
  if (rst) begin
      A_input_counter <=0;
      B_input_counter <=0;
      sink_count_A <= 0;
      sink_count_B <= 0;
      mapA <= 0;
      mapB <= 0;
      Score_A <= 0;
      Score_B <= 0;
      clock <= 0;
      Z <=0;
      current_state <= IDLE;
  end
  else begin
    case (current_state)
      IDLE: begin
          if (start) begin
              current_state <=SHOW_A;
          end
          else begin
              current_state <=IDLE;
          end
      end
      SHOW_A: begin
          if (clock < 50) begin //1sec
              clock <= clock + 1;
              current_state <= SHOW_A;
          end
          else begin
              current_state <= A_IN;
          end
          end

      SHOW_B: begin
          if (clock <50)begin
            clock <= clock +1;
            current_state <= SHOW_B;
          end
          else begin
            current_state <=B_IN;
          end
        end

      A_IN: begin
        clock <= 0; //clock reset
        if (pAb) begin
          if (mapA[4*X+Y]==1) current_state <= ERROR_A;
          else begin
            if (A_input_counter >2)begin
              mapA[4*X+Y]<=1;
              current_state <= SHOW_B;
            end
            else begin
              mapA[4*X+Y] <=1;
              A_input_counter <= A_input_counter +1;
              current_state <=A_IN;
            end
          end
        end
        else begin
          current_state <=A_IN;
        end
      end

      B_IN: begin

      clock <=0;
      if (pBb) begin
          if (mapB[4*X+Y]==1) current_state <= ERROR_B;
          else begin
          if (B_input_counter >2)begin
              mapB[4*X+Y]<=1;
              current_state <= SHOW_SCORE;
          end
          else begin
              mapB[4*X+Y] <=1;
              B_input_counter <= B_input_counter + 1;
              current_state <=B_IN;
          end
          end
      end
      else begin
          current_state <= B_IN;
      end
      end

      ERROR_A: begin
        if (clock <50)begin
          clock <= clock +1;
          current_state <= ERROR_A;
        end
        else  begin
          current_state <= A_IN;
        end
      end

      ERROR_B: begin
        if (clock <50)begin
          clock <= clock +1;
          current_state <= ERROR_B;
        end
        else begin
          current_state <=B_IN;
        end  
      end

      SHOW_SCORE: begin
        if (clock < 50) begin  //1sec
          clock <= clock + 1;
          current_state <= SHOW_SCORE;
        end
        else begin
          current_state <= A_SHOOT;
        end
      end

      A_SHOOT: begin
        clock <= 0; //clock reset
        if (pAb)begin
          if (mapB[4*X+Y]==1)begin
            mapB[4*X+Y]<=0;
            Z <= 1;
            sink_count_A <= sink_count_A +1;
            Score_A <= Score_A +1 ;
            current_state <=A_SINK;
          end
          else begin 
            current_state <=A_SINK;
            Z <=0;
          end
        end
        else current_state <=A_SHOOT;
      end

      B_SHOOT: begin
      clock <= 0; //clock reset
      if (pBb)begin
          if (mapA[4*X+Y]==1)begin
          mapA[4*X+Y]<=0;
          Z <= 1;
          sink_count_B <= sink_count_B + 1 ;
          Score_B<= Score_B+1;
          current_state <=B_SINK;
          end
          else begin 
          current_state <=B_SINK;
          Z <=0;
          end
      end
      else current_state <=B_SHOOT;
      end

      A_SINK:
      begin
        if (clock < 50) begin //1sec
          clock <= clock + 1;
          current_state <= A_SINK; 

        end
        else begin
          if (Score_A > 3) current_state <= A_WIN;
          else current_state <= B_SHOOT;
        end
      end

      B_SINK: begin
          if (clock < 50) begin //1sec
          clock <= clock + 1;
          current_state <= B_SINK;
          end
          else begin
          if (Score_B > 3) current_state <= B_WIN;
          else current_state <= A_SHOOT;
          end
      end
  
      A_WIN: begin
          if (Z) begin
          Z <= 0;
          current_state <= A_WIN;
          end
  
          else begin
          Z <= 1;
          current_state <= A_WIN;
          end
      end
  
      B_WIN: begin
          if (Z) begin
          Z <= 0;
          current_state <= B_WIN;
          end
  
          else begin
          Z <= 1;
          current_state <= B_WIN;
          end
      end
      default: begin
          if (start) current_state <= SHOW_A;
          else current_state <= IDLE;
      end
      endcase
  end
end
  always @(*) begin
      if (rst) begin
      disp3 = 8'b00110000; // I
      disp2 = 8'b01011110; // D
      disp1 = 8'b00111000; // L
      disp0 = 8'b01111001; // E
      led = 8'b10011001;   // 7, 4, 3, 0 
      end
      case (current_state)
      IDLE:begin
          disp3 = 8'b00110000; // I
          disp2 = 8'b01011110; // D
          disp1 = 8'b00111000; // L
          disp0 = 8'b01111001; // E
          led = 8'b10011001; // 7, 4, 3, 0 
      end 
      SHOW_A: begin
          disp3 = 8'b01110111; // A
          disp2 = 8'b10000000; // " "
          disp1 = 8'b10000000; // " "
          disp0 = 8'b10000000; // " "
          led = 8'b10011001; // 7, 4, 3, 0 
      end

      SHOW_B: begin
          disp3 = 8'b01111100; // B
          disp2 = 8'b10000000; // " "
          disp1 = 8'b10000000; // " " 
          disp0 = 8'b10000000; // " " 
          led = 8'b10011001;   // 7, 4, 3, 0
      end

      A_IN: begin
          disp3 = 8'b10000000; // " "
          disp2 = 8'b10000000; // " "
          case (X)
              2'b00: disp1 = 8'b00000110; // 1
              2'b01: disp1 = 8'b01011011; // 2
              2'b10: disp1 = 8'b01001111; // 3
              2'b11: disp1 = 8'b01100110; // 4
              default: disp1 = 8'b10000000; // " "
          endcase

          case (Y)
              2'b00: disp0 = 8'b00000110; // 1
              2'b01: disp0 = 8'b01011011; // 2
              2'b10: disp0 = 8'b01001111; // 3
              2'b11: disp0 = 8'b01100110; // 4
              default: disp0 = 8'b10000000; // " "
          endcase

          led = {2'b10, A_input_counter, 4'b0000};
      end

      B_IN: begin
          disp3 = 8'b10000000; // " "
          disp2 = 8'b10000000; // " "

          case (X)
              2'b00: disp1 = 8'b00000110; // 1
              2'b01: disp1 = 8'b01011011; // 2
              2'b10: disp1 = 8'b01001111; // 3
              2'b11: disp1 = 8'b01100110; // 4
              default: disp1 = 8'b10000000; // " "
          endcase

          case (Y)
              2'b00: disp0 = 8'b00000110; // 1
              2'b01: disp0 = 8'b01011011; // 2
              2'b10: disp0 = 8'b01001111; // 3
              2'b11: disp0 = 8'b01100110; // 4
              default: disp0 = 8'b10000000; // " "
          endcase

          led = {2'b10, A_input_counter, 4'b0000};
      end

      ERROR_A: begin
          disp3 = 8'b01111001; // E
          disp2 = 8'b01010000; // r
          disp1 = 8'b01010000; // r
          disp0 = 8'b01011100; // o
          led = 8'b10011001;   // 7, 4, 3, 0
      end
      
      ERROR_B: begin
          disp3 = 8'b01111001; // E
          disp2 = 8'b01010000; // r
          disp1 = 8'b01010000; // r
          disp0 = 8'b01011100; // o
          led = 8'b10011001; // 7, 4, 3, 0 lights
      end

      SHOW_SCORE:begin
          disp3 = 8'b10000000; // " "
          disp2 = 8'b00111111; //  0
          disp1 = 8'b01000000; //  -
          disp0 = 8'b00111111; //  0
          led = 8'b10011001; // 7, 4, 3, 0
      end

      A_SHOOT: begin
          disp3 = 8'b10000000; // " "
          disp2 = 8'b10000000; // " "
          case (X)
              2'b00: disp1 = 8'b00000110; // 1
              2'b01: disp1 = 8'b01011011; // 2
              2'b10: disp1 = 8'b01001111; // 3
              2'b11: disp1 = 8'b01100110; // 4
              default: disp1 = 8'b10000000; // " "
          endcase

          case (Y)
              2'b00: disp0 = 8'b00000110; // 1
              2'b01: disp0 = 8'b01011011; // 2
              2'b10: disp0 = 8'b01001111; // 3
              2'b11: disp0 = 8'b01100110; // 4
              default: disp0 = 8'b10000000; // " "
          endcase

          led = {2'b10, sink_count_A, sink_count_B ,2'b00}; 
      end

      B_SHOOT: begin
          disp3 = 8'b10000000; // " "
          disp2 = 8'b10000000; // " "
  
          case (X)
              2'b00: disp1 = 8'b00000110; // 1
              2'b01: disp1 = 8'b01011011; // 2
              2'b10: disp1 = 8'b01001111; // 3
              2'b11: disp1 = 8'b01100110; // 4
              default: disp1 = 8'b10000000; // " "
          endcase

          case (Y)
              2'b00: disp0 = 8'b00000110; // 1
              2'b01: disp0 = 8'b01011011; // 2
              2'b10: disp0 = 8'b01001111; // 3
              2'b11: disp0 = 8'b01100110; // 4
              default: disp0 = 8'b10000000; // " "
          endcase
  
          led = {2'b00, sink_count_A, sink_count_B ,2'b01}; 
      end

      A_SINK: begin
          disp3 = 8'b10000000; // " "
  
          case (Score_A)
          2'b00: disp2 = 8'b00111111; // 1
          2'b01: disp2 = 8'b00000110; // 2
          2'b10: disp2 = 8'b01011011; // 3
          2'b11: disp2 = 8'b01001111; // 4
          default: disp2 = 8'b01100110; // " "
      endcase
      
      disp1 = 8'b01000000; // -
      
      case (Score_B)
          2'b00: disp0 = 8'b00111111; // 1
          2'b01: disp0 = 8'b00000110; // 2
          2'b10: disp0 = 8'b01011011; // 3
          2'b11: disp0 = 8'b01001111; // 4
          default: disp0 = 8'b10000000; // " "
      endcase
      
      if (Z) led = 8'b11111111; 
      else led = 8'b00000000;
      
      end
      A_WIN: begin
          disp3 = 8'b01110111; // A
          disp2 = 8'b01100110; //  4
          disp1 = 8'b01000000; // -
          case (Score_B)
              2'b00: disp0 = 8'b00111111; // 1
              2'b01: disp0 = 8'b00000110; // 2
              2'b10: disp0 = 8'b01011011; // 3
              2'b11: disp0 = 8'b01001111; // 4
              default: disp0 = 8'b10000000; // " "
          endcase

          if (Z) 
              led = 8'b10101010; 
          else 
              led = 8'b01010101;
      end
     
      B_SINK: begin
          disp3 = 8'b10000000; // " "
          
          case (Score_A)
              2'b00: disp2 = 8'b00111111; // 1
              2'b01: disp2 = 8'b00000110; // 2
              2'b10: disp2 = 8'b01011011; // 3
              2'b11: disp2 = 8'b01001111; // 4
              default: disp2 = 8'b10000000; // " "
          endcase

          disp1 = 8'b01000000; // -

          case (Score_B)
              2'b00: disp0 = 8'b00111111; // 1
              2'b01: disp0 = 8'b00000110; // 2
              2'b10: disp0 = 8'b01011011; // 3
              2'b11: disp0 = 8'b01001111; // 4
              default: disp0 = 8'b01100110; // " "
          endcase
              
              if (Z) led = 8'b11111111; 
              else led = 8'b00000000;
      end
      B_WIN: begin
          disp3 = 8'b01111100; // b
          case (Score_A)
              2'b00: disp2 = 8'b00111111; // 1
              2'b01: disp2 = 8'b00000110; // 2
              2'b10: disp2 = 8'b01011011; // 3
              2'b11: disp2 = 8'b01001111; // 4
              default: disp2 = 8'b10000000; // " "
          endcase
          disp1 = 8'b01000000; // -
          disp0 = 8'b01100110; // " "
          if (Z) 
              led = 8'b10101010; 
          else 
              led = 8'b01010101;
      end
      default: begin
          disp3 = 8'b00110000; // I
          disp2 = 8'b01011110; // D
          disp1 = 8'b00111000; // L
          disp0 = 8'b01111001; // E
          led = 8'b10011001; // 7, 4, 3, 0
      end
  endcase
end
endmodule
