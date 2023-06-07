`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    00:30:38 03/19/2013
// Design Name:
// Module Name:    vga640x480
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module vga640x480 (
    input wire dclk,  //pixel clock: 25MHz
    input wire clr,  //asynchronous reset
    input wire [4:0] cursor_x,  //cursor x position
    input wire [4:0] cursor_y,  //cursor y position
    input wire button1,  // draw
    input wire button2,  // erase
    output reg hsync,  //horizontal sync out
    output reg vsync,  //vertical sync out
    output reg [2:0] red,  //red vga output
    output reg [2:0] green,  //green vga output
    output reg [1:0] blue  //blue vga output
);


  // video structure constants
  parameter hpixels = 800;  // horizontal pixels per line
  parameter vlines = 521;  // vertical lines per frame
  parameter hpulse = 96;  // hsync pulse length
  parameter vpulse = 2;  // vsync pulse length
  parameter hbp = 244;  // end of horizontal back porch
  parameter hfp = 884;  // beginning of horizontal front porch
  parameter vbp = 31;  // end of vertical back porch
  parameter vfp = 511;  // beginning of vertical front porch
  // active horizontal video is therefore: 784 - 144 = 640
  // active vertical video is therefore: 511 - 31 = 480


  // registers for storing the horizontal & vertical counters
  reg [9:0] hc;
  reg [9:0] vc;




  parameter NX = 32;
  parameter NY = 24;



  wire [NX*NY-1:0] pixel_values_1d;


   Grid grid (
      .cursor_x(cursor_x),
      .cursor_y(cursor_y),
      .button1(button1),
      .button2(button2),
      .clock(dclk),
      .pixel_values_1d(pixel_values_1d)
  );
  



 /*initial begin

     
     pixel_values_1d[0] = 1;
     pixel_values_1d[12] = 1;
     pixel_values_1d[34] = 1;
     pixel_values_1d[345] = 1;
     pixel_values_1d[318] = 1;
     pixel_values_1d[149] = 1;
     pixel_values_1d[56] = 1;
     pixel_values_1d[95] = 1;
 end*/





  // Horizontal & vertical counters --
  // this is how we keep track of where we are on the screen.
  // ------------------------
  // Sequential "always block", which is a block that is
  // only triggered on signal transitions or "edges".
  // posedge = rising edge  &  negedge = falling edge
  // Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=


  always @(posedge dclk) begin
    hsync <= ~(hc >= 8 && hc < 104);
    vsync <= ~(vc >= 2 && vc < 4);
    hc <= hc == 799 ? 0 : hc + 1;  // vgaX goes 0-799 on clk
    if (hc == 799) vc <= vc == 524 ? 0 : vc + 1;  // vgaY goes 0-524 on ~HSync and clk
  end


  // generate sync pulses (active low)
  // ----------------
  // "assign" statements are a quick way to
  // give values to variables of type: wire




  // display 100% saturation colorbars
  // ------------------------
  // Combinational "always block", which is a block that is
  // triggered when anything in the "sensitivity list" changes.
  // The asterisk implies that everything that is capable of triggering the block
  // is automatically included in the sensitivty list.  In this case, it would be
  // equivalent to the following: always @(hc, vc)
  // Assignment statements can only be used on type "reg" and should be of the "blocking" type: =


  wire is_red;
  wire is_blue;
  wire is_normal;


  wire [4:0] hc_scaled = (hc - hbp) / (20);
  wire [4:0] vc_scaled = (vc - vbp) / (20);
  

  assign is_red = cursor_x == hc_scaled && cursor_y == vc_scaled && !button2;
  assign is_blue = cursor_x == hc_scaled && cursor_y == vc_scaled && !button1 && button2;
  assign is_normal = !is_red && !is_blue;
  
 
  
//assign is_red = 1;

  


  always @(*) begin
    // first check if we're within vertical active video range
    if (vc >= vbp && vc < vfp) begin
      // now display different colors every 80 pixels
      // while we're within the active horizontal range
      // -----------------
      // display white bar
      if (hc >= hbp && hc < (hbp + 640)) begin





        // condition to appear: make the pixel display blue if the cursor is on it and button 1 is pressed, red if the cursor is on it and button 2 is pressed, and the original color if the cursor is not on it. original color shown in pixel_values_1d


        red = is_red ? 3'b111 : is_blue ? 3'b000 : pixel_values_1d[hc_scaled*24+vc_scaled] ? 0 : 3'b111;
        green = is_red ? 3'b000 : is_blue ? 3'b000 : pixel_values_1d[hc_scaled*24+vc_scaled] ? 0 : 3'b111;
        blue = is_red ? 3'b000 : is_blue ? 3'b111 : pixel_values_1d[hc_scaled*24+vc_scaled] ? 0 : 2'b11;

        
		  
      end  // we're outside active horizontal range so display black
      else begin
        red   = 0;
        green = 0;
        blue  = 0;
      end
    end  // we're outside active vertical range so display black
    else begin
      red   = 0;
      green = 0;
      blue  = 0;
    end
  end


endmodule
