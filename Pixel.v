module Pixel (
    input [4:0] cursor_x,
    input [4:0] cursor_y,
    input [4:0] pixel_x,
    input [4:0] pixel_y,
    input button1,
    input button2,
    input clock,
    output reg pixel_value
);


  parameter NX = 32;
  parameter NY = 24;








  always @(posedge clock) begin
    if (cursor_x == pixel_x && cursor_y == pixel_y) begin
      // display pixel x and y
      //   $display("pixel_x = %d, pixel_y = %d", pixel_x, pixel_y);
      if (button1) pixel_value <= 1;
      else if (button2) pixel_value <= 0;


      //    display pixel value
      //   $display("pixel_value = %d", pixel_value);
    end
  end


  initial begin
    pixel_value <= 0;
  end


endmodule


module Grid (
    input [4:0] cursor_x,
    input [4:0] cursor_y,
    input button1,
    input button2,
    input clock,
    output [NX*NY-1:0] pixel_values_1d
);
  parameter NX = 32;
  parameter NY = 24;
  genvar i, j;
  generate
    for (i = 0; i < NX; i = i + 1) begin
      for (j = 0; j < NY; j = j + 1) begin
        Pixel pixel (
            .cursor_x(cursor_x),
            .cursor_y(cursor_y),
            .pixel_x(i),
            .pixel_y(j),
            .button1(button1),
            .button2(button2),
            .clock(clock),
            .pixel_value(pixel_values_1d[i*NY+j])
        );
      end
    end
  endgenerate


endmodule

