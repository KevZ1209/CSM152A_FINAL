module cursor_move(directions, cx, cy, clk);
  input clk; // input clk signal
  input [3:0] directions; // cursor movements
  output reg [4:0] cx, cy; // cursor positions
  parameter XMAX = 31; // maximum x coordinate
  parameter YMAX = 23; // maximum y coordinate

  // initialize cursor positions
  initial begin
	cx = 15;
	cy = 15; 
  end
  
  always @(posedge clk) begin
    if (directions == 4'b1000) begin
        cx <= cx + 1;
    end
    else if (directions == 4'b0100) begin
        cx <= cx - 1;
    end
    else if (directions == 4'b0010) begin
        cy <= cy + 1;
    end
    else if (directions == 4'b0001) begin
        cy <= cy - 1;
    end    
    if (cx > XMAX) cx <= XMAX; // check x boundary
    if (cy > YMAX) cy <= YMAX; // check y boundary
  end
  
endmodule