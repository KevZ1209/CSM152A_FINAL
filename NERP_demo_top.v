`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Na          me:    NERP_demo_top 
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
module NERP_demo_top(
	input wire clk,			//master clock = 100MHz
	input wire clr,			//right-most pushbutton for reset
	output wire [6:0] seg,	//7-segment display LEDs
	output wire [3:0] an,	//7-segment display anode enable
	output wire dp,			//7-segment display decimal point
	output wire [2:0] red,	//red vga output - 3 bits
	output wire [2:0] green,//green vga output - 3 bits
	output wire [1:0] blue,	//blue vga output - 2 bits
	output wire hsync,		//horizontal sync out
	output wire vsync,			//vertical sync out
    
    
 input    RST,     // Button D
 input    MISO,    // Master In Slave Out, Pin 3, Port JA
 input  [2:0] SW,  // Switches 2, 1, and 0
 output   SS,      // Slave Select, Pin 1, Port JA
 output   MOSI,    // Master Out Slave In, Pin 2, Port JA 
 output   SCLK,    // Serial Clock, Pin 4, Port JA 
 output [2:0] LED,  // LEDs 2, 1, and 0,   
 output	[3:0] AN,  // Anodes for Seven Segment Display  
 output	[6:0] SEG,  // Cathodes for Seven Segment Display  
 
 
		// draw and erase buttons 
		input draw,
		input erase
     
	);
    
    
	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
		        

			wire SS;						// Active low
			wire MOSI;					// Data transfer from master to slave
			wire SCLK;					// Serial clock that controls communication
			reg [2:0] LED;				// Status of PmodJSTK buttons displayed on LEDs
			//wire [3:0] AN;				// Anodes for Seven Segment Display
			//wire [6:0] SEG;			// Cathodes for Seven Segment Display



			// Holds data to be sent to PmodJSTK
			wire [7:0] sndData;

			// Signal to send/receive data to/from PmodJSTK
			wire sndRec;
            
            wire faster;

			// Data read from PmodJSTK
			wire [39:0] jstkData;

			// Signal carrying output data that user selected
			wire [9:0] posData;

			

	// ===========================================================================
	// 										Implementation
	// ===========================================================================


			//-----------------------------------------------
			//  	  			PmodJSTK Interface
			//-----------------------------------------------
			PmodJSTK PmodJSTK_Int(
					.CLK(clk),
					.RST(RST),
					.sndRec(sndRec),
					.DIN(sndData),
					.MISO(MISO),
					.SS(SS),
					.SCLK(SCLK),
					.MOSI(MOSI),
					.DOUT(jstkData)
			);
			


			//-----------------------------------------------
			//  		Seven Segment Display Controller
			//-----------------------------------------------
			ssdCtrl DispCtrl(
					.CLK(clk),
					.RST(RST),
					.DIN(posData),
					.AN(AN),
					.SEG(SEG)
			);
			
			

			//-----------------------------------------------
			//  			 Send Receive Generator
			//-----------------------------------------------
			ClkDiv_5Hz genSndRec(
					.CLK(clk),
					.RST(RST),
					.CLKOUT(sndRec)
			);
            
            			ClkDiv_FASTER cdf(
					.CLK(clk),
					.RST(RST),
					.CLKOUT(faster)
			);
			
           
            wire [3:0] directions; // cursor movements
            wire [9:0] joystick_y, joystick_x;
            assign joystick_y = {jstkData[9:8], jstkData[23:16]};
            assign joystick_x = {jstkData[25:24], jstkData[39:32]};
            wire [4:0] cursor_x, cursor_y;
				
            joystick_to_movement jtm(
                    .clk(faster),
                    .directions(directions),
                    .x(joystick_x),
                    .y(joystick_y)
            ); 
				cursor_move cm(
					.clk(faster),
					.directions(directions),
					.cx(cursor_x),
					.cy(cursor_y)
				); 
				
				
           


			// Use state of switch 0 to select output of X position or Y position data to SSD
			assign posData = (SW[0] == 1'b1) ? joystick_x : joystick_y;
            // assign posData = dx;

			// Data to be sent to PmodJSTK, lower two bits will turn on leds on PmodJSTK
			assign sndData = {8'b100000, {SW[1], SW[2]}};

			// Assign PmodJSTK button status to LED[2:0]
			/* always @(sndRec or RST or jstkData) begin
					if(RST == 1'b1) begin
							LED <= 3'b000;
					end
					else begin
							LED <= {jstkData[1], {jstkData[2], jstkData[0]}};
					end
			end */


// 7-segment clock interconnect
wire segclk;

// VGA display clock interconnect
wire dclk;

// disable the 7-segment decimal points
assign dp = 1;

// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.clr(clr),
	.segclk(segclk),
	.dclk(dclk)
	);
segdisplay U2(
	.segclk(segclk),
	.clr(clr),
	.seg(seg),
	.an(an)
	);

// VGA controller
 vga640x480 U3(
	.dclk(dclk),
	.clr(clr),
	
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue),
	.button1(draw),
	.button2(erase),
	.cursor_x(cursor_x),  //cursor x position
   .cursor_y(cursor_y)  //cursor y position
	); 

endmodule
