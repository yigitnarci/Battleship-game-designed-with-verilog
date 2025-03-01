
module clk_divider (
  input      clk_in     ,
  output reg divided_clk
);

  parameter  toggle_value = 270000;
  reg [24:0] cnt                 ;

  initial begin
    cnt = 0;
    divided_clk = 0;
  end

  always@(posedge clk_in)
    begin
      if (cnt==toggle_value) begin
        cnt         <= 0;
        divided_clk <= ~divided_clk;
      end
      else begin
        cnt         <= cnt +1;
        divided_clk <= divided_clk;
      end
    end

endmodule
