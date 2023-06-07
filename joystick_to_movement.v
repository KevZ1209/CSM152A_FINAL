
module joystick_to_movement(x, y, directions, clk);
  input [9:0] x, y; // joystick positions
  output reg [3:0] directions; // cursor movements
  input clk; // clock signal
  
  // assign dx and dy based on x and y values
  always @(posedge clk) begin
    if (x <= 100) directions <= 4'b1000;
    else if (x >= 1000) directions <= 4'b0100;    
    else if (y <= 100) directions <= 4'b0001;
    else if (y >= 1000) directions <= 4'b0010;
    else directions <= 4'b0000; 
    
  end
  
endmodule
