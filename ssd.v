

module ssd (
    input clk,
    input [7:0] disp0,
    input [7:0] disp1,
    input [7:0] disp2,
    input [7:0] disp3,
    output reg [7:0] seven,
    output reg [3:0] segment
);
    reg [15:0] dispCounter = 0; // Display timeout counter
    reg [1:0] index;
    
    always @(posedge clk) begin
        dispCounter <= dispCounter + 1;
        if (dispCounter == 0) begin
            case (index)
                0: begin
                    seven <= disp0;
                end 
                1: begin
                    seven <= disp1;
                end 
                2: begin
                    seven <= disp2;
                end 
                3: begin
                    seven <= disp3;
                end 
                default: begin
                    seven <= 0;
                end
            endcase
            segment <= 1 << index;
            index <= index + 1;
        end
    end
endmodule
