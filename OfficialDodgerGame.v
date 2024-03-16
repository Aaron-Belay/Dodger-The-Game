module dodgerthegame
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,	
		PS2_CLK,
		PS2_DAT,
		
		
//		//audio stuff
 		AUD_ADCDAT,
 		AUD_BCLK,
 		AUD_ADCLRCK,
 		AUD_DACLRCK,
 
 		FPGA_I2C_SDAT,
 
 		 //audio outputs
 		AUD_XCK,
 		AUD_DACDAT,
 
 		FPGA_I2C_SCLK,
 		
 		
		
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, // On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
    
	input	[3:0]	KEY;	
    input PS2_CLK, PS2_DAT;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	
	input				AUD_ADCDAT;

 	 // Bidirectionals
 	inout				AUD_BCLK;
 	inout				AUD_ADCLRCK;
 	inout				AUD_DACLRCK;
 
 	inout				FPGA_I2C_SDAT;
 
 	 // Outputs
 	output				AUD_XCK;
 	output				AUD_DACDAT;
 
 	output				FPGA_I2C_SCLK;


//	//audio instantiation
	DE1_SoC_Audio_Example D65(
	// Inputs
	.CLOCK_50(CLOCK_50),
	.KEY(KEY),
	.playsound(playsound),

	.AUD_ADCDAT(AUD_ADCDAT),

//	// Bidirectionals
	.AUD_BCLK(AUD_BCLK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
  	.AUD_DACLRCK(AUD_DACLRCK),
  
  	.FPGA_I2C_SDAT(FPGA_I2C_SDAT),
  
  	  // Outputs
  	.AUD_XCK(AUD_XCK),
  	.AUD_DACDAT(AUD_DACDAT),
  
  	.FPGA_I2C_SCLK(FPGA_I2C_SCLK),
	.gameoversounddone(gameoversounddone)
  );

	
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire drawEn;
	wire [11:0] outputScore;
	
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(drawEn),
			.donecounting5(donecounting5),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.

    wire LEFT,RIGHT, titledonesignal, collidesignal, gameoversounddone, playsound;
	 wire donecounting5;
	 wire [11:0] highscorewire, highscore;
	 
	 //instantiate audio

    keyboard U3 (.PS2_CLK(PS2_CLK),.PS2_DAT(PS2_DAT),.LEFT(LEFT),.RIGHT(RIGHT), .SPACE(titledonesignal));

	
	falling U2 (.iReset(resetn),.iClock(CLOCK_50),.oX(x),.oY(y),.oColour(colour),.oPlot(drawEn), .left(LEFT),.right(RIGHT),.titledonesignal(!KEY[2]), .outputScore(outputScore), .donesignal_player(donecounting5), .collidesignal5(collidesignal), .playsound(playsound),.gameoversounddone(gameoversounddone), .highscore (highscore));
	
	
	


	
	
	
	wire [11:0] decHundreds, decTens, decUnits;
		wire [11:0] decHundreds1, decTens1, decUnits1;
	
	hex_decoder decoderHundreds (decHundreds[3:0] , HEX2 [6:0]);
	hex_decoder decoderTens (decTens [3:0], HEX1[6:0]);
	hex_decoder decoderUnits (decUnits [3:0], HEX0[6:0]);
	
		
	hex_decoder decoderHundreds1 (decHundreds1[3:0] , HEX5 [6:0]);
	hex_decoder decoderTens1 (decTens1 [3:0], HEX4[6:0]);
	hex_decoder decoderUnits1 (decUnits1 [3:0], HEX3[6:0]);
	
	
	BinaryToDec decConverter (.binaryInput(outputScore), .decHundreds(decHundreds), .decTens(decTens), .decUnits(decUnits));
	BinaryToDec decConverter1 (.binaryInput(highscore), .decHundreds(decHundreds1), .decTens(decTens1), .decUnits(decUnits1));


	
endmodule


module keyboard(PS2_CLK, PS2_DAT, LEFT, RIGHT, SPACE);
    input PS2_CLK, PS2_DAT;
    output reg LEFT = 0, RIGHT = 0, SPACE = 0;

    reg [7:0] data = 0;
    reg [3:0] q = 0;
    reg done = 0;
	 reg break = 0;
	 reg extended = 0;

	 //key logic
	 always @(posedge done) begin
        if(data == 8'hF0) begin //released
            break <= 1;
        end
        else if(data == 8'hE0) begin
            extended <= 1;
        end
        else begin
				if (data == 8'h06B && extended) 
					begin 
					LEFT <= !break; //left key
					end
            else if(data == 8'h74 && extended) 
					begin
					RIGHT <= !break; //right key
					end
				else if(data == 8'h29 && extended) 
					begin
					SPACE <= !break;
					end					//never used space
            break <= 0;
            extended <= 0;
        end
    end
	 
	 
    // take the key scan code
    always @(negedge PS2_CLK) begin
        case(q)
            4'd0:   ; //do nothing
            4'd1:   data[0] <= PS2_DAT;
            4'd2:   data[1] <= PS2_DAT;
            4'd3:   data[2] <= PS2_DAT;
            4'd4:   data[3] <= PS2_DAT;
            4'd5:   data[4] <= PS2_DAT;
            4'd6:   data[5] <= PS2_DAT;
            4'd7:   data[6] <= PS2_DAT;
            4'd8:   data[7] <= PS2_DAT;
            4'd9:   done <= 1'b1;
            4'd10:  done <= 1'b0;
            default: q <= 0;
        endcase
        if(q == 10) 
			begin
				q <= 0;
			end
        else 
			begin
				q <= q+1;
			end
    end

    
endmodule


module BinaryToDec (
    input wire [11:0] binaryInput,  // 12-bit binary input
    output reg [11:0] decHundreds,    // 4-bit dec output for hundreds place
    output reg [11:0] decTens,        // 4-bit dec output for tens place
    output reg [11:0] decUnits        // 4-bit dec output for units place
);

always @(*) begin
    decHundreds <= binaryInput[11:0] / 12'd100;
    decTens <= (binaryInput[11:0] / 12'd10) - (decHundreds*12'd10);
    decUnits <= binaryInput[11:0] - (decHundreds*12'd100) - (decTens*12'd10);
end

endmodule

module hex_decoder(c, display);

	input [3:0] c;
	output [6:0] display;


	assign display[0] = (!c[3] & !c[2] & !c[1] & c[0]) | (!c[3] & c[2] & !c[1] & !c[0]) | (c[3] & !c[2] & c[1] & c[0]) | (c[3] & c[2] & !c[1] & c[0]);

	assign display[1] = (!c[3] & c[2] & !c[1] & c[0]) | (!c[3] & c[2] & c[1] & !c[0]) | (c[3] & !c[2] & c[1] & c[0]) | (c[3] & c[2] & !c[1] & !c[0]) | (c[3] & c[2] & c[1] & !c[0]) | (c[3] & c[2] & c[1] & c[0])  ;

	assign display[2] = (!c[3] & !c[2] & c[1] & !c[0]) | (c[3] & c[2] & !c[1] & !c[0]) | (c[3] & c[2] & c[1] & !c[0]) | (c[3] & c[2] & c[1] & c[0]);

	assign display[3] = (!c[3] &! c[2] & !c[1] & c[0]) | (!c[3] & c[2] & !c[1] & !c[0]) | (!c[3] & c[2] & c[1] & c[0]) | (c[3] & !c[2] & c[1] & !c[0]) | (c[3] & c[2] & c[1] & c[0]);

	assign display[4] = (!c[3] & !c[2] & !c[1] & c[0]) | (!c[3] & !c[2] & c[1] & c[0]) | (!c[3] & c[2] & !c[1] & !c[0]) | (!c[3] & c[2] & !c[1] & c[0]) | (!c[3] & c[2] & c[1] & c[0]) | (c[3] & !c[2] & !c[1] & c[0]);

	assign display[5] =  (!c[3] & !c[2] & !c[1] & c[0]) | (!c[3] & !c[2] & c[1] & !c[0]) | (!c[3] & !c[2] & c[1] & c[0]) | (!c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & !c[1] & c[0]);

	assign display[6] = (!c[3] & !c[2] & !c[1] & !c[0]) | (!c[3] & !c[2] & !c[1] & c[0]) | (!c[3] & c[2] & c[1] & c[0]) | (c[3] & c[2] & !c[1] & !c[0]);

endmodule




module falling(iReset,iClock,oX,oY,oColour,oPlot, left, right, titledonesignal, outputScore, highscore, donesignal_player, collidesignal5, gameoversounddone, playsound);
   input wire 	    iReset;
   input wire 	    iClock;
   input wire titledonesignal;
   input wire left;
   input wire right;
	input wire gameoversounddone;
   
   output reg [8:0] oX;         // VGA pixel coordinates
   output reg [7:0] oY;

   output reg [2:0] oColour;     // VGA pixel colour (0-7)
   output reg 	     oPlot;       // Pixel drawn enable
   output wire [11:0] outputScore;
	output wire [11:0] highscore;
	output wire donesignal_player;
	output wire collidesignal5;
	output wire playsound;

   parameter
     X_BOXSIZE = 8'd4,   // Box X dimension
     Y_BOXSIZE = 7'd4,   // Box Y dimension
     X_SCREEN_PIXELS = 9,  // X screen width for starting resolution and fake_fpga
     Y_SCREEN_PIXELS = 7,  // Y screen height for starting resolution and fake_fpga
     X_MAX = X_SCREEN_PIXELS - 1 - X_BOXSIZE, // 0-based and account for box width
     Y_MAX = Y_SCREEN_PIXELS - 1 - Y_BOXSIZE//,
		//CLOCKS_PER_SECOND = 12000,
     //FRAMES_PER_UPDATE = 15,
     //PULSES_PER_SIXTIETH_SECOND = CLOCKS_PER_SECOND / 60
	  ;
	
	wire iResetn;
	assign iResetn = iReset & !titledonesignal;
	
	wire blackclr1, donecounting1, updatedone1, startcounting1, updatepos1, load1,
	blackclr2, donecounting2, updatedone2, startcounting2, updatepos2, load2,
    blackclr3, donecounting3, updatedone3, startcounting3, updatepos3, load3,
    blackclr4, donecounting4, updatedone4, startcounting4, updatepos4, load4,
    blackclr5, updatedone5, startcounting5, updatepos5, load5,
    blackclrplayer, donecounting5, updatedoneplayer, startcountingplayer, updateposplayer, loadplayer,
	collidesignal1, collidesignal2, collidesignal3, collidesignal4, screendonesignal;
	wire [8:0] xcord1, ycord1, xcord2, ycord2, xcord3, ycord3, xcord4, ycord4, xcord5, ycord5, xcordplayer, ycordplayer;
	
  
    wire [8:0] outputY1, outputY2, outputY3, outputY4, outputY5, outputYplayer, outputYsc;

	wire [8:0] outputX1, outputX2, outputX3, outputX4, outputX5, outputXplayer, outputXsc;

	wire [2:0] outputColour1, outputColour2, outputColour3, outputColour4, outputColour5, outputColourplayer, outputClrsc;
	
	
	wire outputPlot1, outputPlot2, outputPlot3, outputPlot4, outputPlot5, outputPlotplayer, outputPlotsc;
	
	wire [2:0] screentype;
    wire collidesignal;

	
		
	always@(posedge iClock)begin
	if (outputPlot1 == 1'b1) begin
		 oY <= outputY1[7:0];
		 oX <= outputX1[8:0];
		 oPlot <= outputPlot1;
		 oColour <= outputColour1;
		end
	else if (outputPlot2 == 1'b1) begin
		 oY <= outputY2[7:0];
		 oX <= outputX2[8:0];
		 oPlot <= outputPlot2;
		 oColour <= outputColour2;
		end
    else if (outputPlot3 == 1'b1) begin
		 oY <= outputY3[7:0];
		 oX <= outputX3[8:0];
		 oPlot <= outputPlot3;
		 oColour <= outputColour3;
		end
    else if (outputPlot4 == 1'b1) begin
		 oY <= outputY4[7:0];
		 oX <= outputX4[8:0];
		 oPlot <= outputPlot4;
		 oColour <= outputColour4;
		end
    else if (outputPlot5 == 1'b1) begin
		 oY <= outputY5[7:0];
		 oX <= outputX5[8:0];
		 oPlot <= outputPlot5;
		 oColour <= outputColour5;
		end  
    else if (outputPlotplayer == 1'b1) begin
		 oY <= outputYplayer[7:0];
		 oX <= outputXplayer[8:0];
		 oPlot <= outputPlotplayer;
		 oColour <= outputColourplayer;
		end 
	 else if (outputPlotsc == 1'b1) begin
		 oY <= outputYsc[7:0];
		 oX <= outputXsc[8:0];
		 oPlot <= outputPlotsc;
		 oColour <= outputClrsc;
		end 
	else begin
		oPlot <= 1'b0;
		oY <= outputYplayer[7:0];
		oX <= outputXplayer[8:0];
		oColour <= 3'b0;
	end
	end
	
	highscoreachieved itsgiving(.iClock(iClock), .finalscore(outputScore), .highscore(highscore), .iResetn(iReset));

 
	control C0(
	//inputs
        .iClock(iClock),
        .iResetn(iReset),
		.donesignal_box1(oDone1), //when done plotting
		.donesignal_box2(oDone2),
        .donesignal_box3(oDone3), //when done plotting
		.donesignal_box4(oDone4),
        .donesignal_box5(oDone5), //when done plotting
		.donesignal_player(oDoneplayer),
		.donecounting(donecounting5),
		.updatedone_box1(updatedone1),
		.updatedone_box2(updatedone2),
        .updatedone_box3(updatedone3),
		.updatedone_box4(updatedone4),
        .updatedone_box5(updatedone5),
        .right(RIGHT),
        .left(LEFT),
		.updatedone_player(updatedoneplayer),
        .titledonesignal(titledonesignal),
        .collidesignal(collidesignal5),
		.screendonesignal(screendonesignal),
		.gameoversounddone(gameoversounddone),
		
	//outputs
		.blackclr_box1(blackclr1),
		.blackclr_box2(blackclr2),
        .blackclr_box3(blackclr3),
		.blackclr_box4(blackclr4),
        .blackclr_box5(blackclr5),
		.blackclr_player(blackclrplayer),
		.drawobject_box1(outputPlot1),
		.drawobject_box2(outputPlot2),
        .drawobject_box3(outputPlot3),
		.drawobject_box4(outputPlot4),
        .drawobject_box5(outputPlot5),
		.drawobject_player(outputPlotplayer),
		.updatepos_box1(updatepos1),
		.updatepos_box2(updatepos2),
        .updatepos_box3(updatepos3),
		.updatepos_box4(updatepos4),
        .updatepos_box5(updatepos5),
		.updatepos_player(updateposplayer),
		.startcounting(startcounting5),
		.load_box1(load1),
        .load_box2(load2),
		.load_box3(load3),
        .load_box4(load4),
		.load_box5(load5),
        .load_player(loadplayer),
		.pointsearned(pointsearned),
		.screentype(screentype),
		.drawscreen(outputPlotsc),
		.playsound(playsound)
    );

	datapath C1_1(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		
		.xcord(xcord1),
		.ycord(ycord1),
		.blackclr(blackclr1),
		.drawobject(outputPlot1),
		.load(load1),


	//outputs	
		.outputX(outputX1),	
		.outputY(outputY1),
		.outputClr(outputColour1),
		.donesignal(oDone1)
		
    );
	
	counters C2_1(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		.startcounting(startcounting1),
		.updatepos(updatepos1),
		.initx(9'd23),
		
	//outputs	
		.updatedone(updatedone1),
		.donecounting(donecounting1),
		.xcord(xcord1),
		.ycord(ycord1)
    );
	
	
	
	datapath C1_2(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		
		.xcord(xcord2),
		.ycord(ycord2),
		.blackclr(blackclr2),
		.drawobject(outputPlot2),
		.load(load2),


	//outputs	
		.outputX(outputX2),	
		.outputY(outputY2),
		.outputClr(outputColour2),
		.donesignal(oDone2)
		
    );
	
	counters C2_2(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		.startcounting(startcounting2),
		.updatepos(updatepos2),
		.initx(9'd57),
		
	//outputs	
		.updatedone(updatedone2),
		.donecounting(donecounting2),
		.xcord(xcord2),
		.ycord(ycord2)
    );

datapath C1_3(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		
		.xcord(xcord3),
		.ycord(ycord3),
		.blackclr(blackclr3),
		.drawobject(outputPlot3),
		.load(load3),


	//outputs	
		.outputX(outputX3),	
		.outputY(outputY3),
		.outputClr(outputColour3),
		.donesignal(oDone3)
		
    );
	
	counters C2_3(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		.startcounting(startcounting3),
		.updatepos(updatepos3),
		.initx(9'd100),
		
	//outputs	
		.updatedone(updatedone3),
		.donecounting(donecounting3),
		.xcord(xcord3),
		.ycord(ycord3)
    );


    datapath C1_4(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		
		.xcord(xcord4),
		.ycord(ycord4),
		.blackclr(blackclr4),
		.drawobject(outputPlot4),
		.load(load4),


	//outputs	
		.outputX(outputX4),	
		.outputY(outputY4),
		.outputClr(outputColour4),
		.donesignal(oDone4)
		
    );
	
	counters C2_4(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		.startcounting(startcounting4),
		.updatepos(updatepos4),
		.initx(9'd300),
		
	//outputs	
		.updatedone(updatedone4),
		.donecounting(donecounting4),
		.xcord(xcord4),
		.ycord(ycord4)
    );



    datapath C1_5(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		
		.xcord(xcord5),
		.ycord(ycord5),
		.blackclr(blackclr5),
		.drawobject(outputPlot5),
		.load(load5),


	//outputs	
		.outputX(outputX5),	
		.outputY(outputY5),
		.outputClr(outputColour5),
		.donesignal(oDone5)
		
    );
	
	counters C2_5(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		.startcounting(startcounting5),
		.updatepos(updatepos5),
		.initx(9'd200),
		
	//outputs	
		.updatedone(updatedone5),
		.donecounting(donecounting5),
		.xcord(xcord5),
		.ycord(ycord5)
    );

    
    datapath_player C1_player(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		
		.xcord(xcordplayer),
		.ycord(ycordplayer),
		.blackclr(blackclrplayer),
		.drawobject(outputPlotplayer),
		.load(loadplayer),


	//outputs	
		.outputX(outputXplayer),	
		.outputY(outputYplayer),
		.outputClr(outputColourplayer),
		.donesignal(oDoneplayer)
		
    );
	

    counters_player C2_player(
	//inputs
        .iClock(iClock),
        .iResetn(iResetn),
		.startcounting(startcountingplayer),
		.updatepos(updateposplayer),
		.left(left),
		.right(right),
		
	//outputs	
		.updatedone(updatedoneplayer),
		.donecounting(donesignal_player),
		.xcord(xcordplayer),
		.ycord(ycordplayer)
    );



    collide oops1(
        .iClock(iClock),
        .iResetn(iResetn),
        .oX(outputX1),
        .oX_player(outputXplayer),
        .oY(outputY1),
        .oY_player(outputYplayer),
		.oldcollidesignal(1'b0),
        .collidesignal(collidesignal1), 
		  .outputPlot(outputPlot1)
        
    );
	
	    collide oops2(
        .iClock(iClock),
        .iResetn(iResetn),
        .oX(outputX2),
        .oX_player(outputXplayer),
        .oY(outputY2),
        .oY_player(outputYplayer),
		.oldcollidesignal(collidesignal1),
        .collidesignal(collidesignal2), 
		  .outputPlot(outputPlot2)
        
    );
	
	    collide oops3(
        .iClock(iClock),
        .iResetn(iResetn),
        .oX(outputX3),
        .oX_player(outputXplayer),
        .oY(outputY3),
        .oY_player(outputYplayer),
		.oldcollidesignal(collidesignal2),
        .collidesignal(collidesignal3), 
		  .outputPlot(outputPlot3)
        
    );
	
	    collide oops4(
        .iClock(iClock),
        .iResetn(iResetn),
        .oX(outputX4),
        .oX_player(outputXplayer),
        .oY(outputY4),
        .oY_player(outputYplayer),
		.oldcollidesignal(collidesignal3),
        .collidesignal(collidesignal4), 
		  .outputPlot(outputPlot4)
        
    );
	
	    collide oops5(
        .iClock(iClock),
        .iResetn(iResetn),
        .oX(outputX5),
        .oX_player(outputXplayer),
        .oY(outputY5),
        .oY_player(outputYplayer),
		.oldcollidesignal(collidesignal4),
        .collidesignal(collidesignal5),
		  .outputPlot(outputPlot5)
        
    );
	 
	 
	 score yay(.iClock(iClock), .iResetn(iResetn), .ipointsignal(pointsearned), .oScore(outputScore), .oY(outputY5), .donecounting5(donecounting5));
	 
	datapath_screen zoooom (.iClock(iClock), .iResetn(iReset), 
	.screentype (screentype), .drawscreen(outputPlotsc), .outputX(outputXsc), .outputY(outputYsc), .outputClr(outputClrsc),
	.screendonesignal(screendonesignal)
    );
	
 


endmodule 


module control(
	input iClock,
	input iResetn,
	input donesignal_box1,
	input donesignal_box2,
    input donesignal_box3,
    input donesignal_box4,
    input donesignal_box5,
    input donesignal_player,
	input screendonesignal,
	input donecounting,
	input updatedone_box1,
	input updatedone_box2,
    input updatedone_box3,
    input updatedone_box4,
    input updatedone_box5,
    input updatedone_player,
	input titledonesignal,
    input right,
    input left,
    input collidesignal,
	 input gameoversounddone,
	
	output reg blackclr_box1,
	output reg blackclr_box2,
    output reg blackclr_box3,
    output reg blackclr_box4,
    output reg blackclr_box5,
    output reg blackclr_player,
	output reg drawobject_box1,
	output reg drawobject_box2,
    output reg drawobject_box3,
    output reg drawobject_box4,
    output reg drawobject_box5,
    output reg drawobject_player,
	output reg drawscreen,
	output reg updatepos_box1,
	output reg updatepos_box2,
    output reg updatepos_box3,
    output reg updatepos_box4,
    output reg updatepos_box5,
    output reg updatepos_player,
	output reg startcounting,
	output reg load_box1,
	output reg load_box2,
    output reg load_box3,
    output reg load_box4,
    output reg load_box5,
    output reg load_player,
	output reg pointsearned,
	output reg [2:0] screentype,
	output reg playsound

    );

    reg [5:0] current_state, next_state;
	reg loaddone_1, loaddone_2, loaddone_3, loaddone_4, loaddone_5, loaddone_player;
	reg titlewentoff;

    localparam 
				DRAW_1      = 6'd0, //constants for states
                DRAW_DONE   = 6'd1,
                ERASE_1        = 6'd2, 
				UPDATE_1   = 6'd3,
				LOAD_1 = 6'd4,
				LOAD_DONE_1 = 6'd5,

				DRAW_2      = 6'd6, //constants for states
                ERASE_2        = 6'd7, 
				UPDATE_2   = 6'd8,
				LOAD_2 = 6'd9,
				LOAD_DONE_2 = 6'd10,

                DRAW_3      = 6'd11, //constants for states
                ERASE_3        = 6'd12, 
				UPDATE_3   = 6'd13,
				LOAD_3 = 6'd14,
				LOAD_DONE_3 = 6'd15,

                DRAW_4      = 6'd16, //constants for states
                ERASE_4        = 6'd17, 
				UPDATE_4   = 6'd18,
				LOAD_4 = 6'd19,
				LOAD_DONE_4 = 6'd20,

                DRAW_5      = 6'd21, //constants for states
                ERASE_5        = 6'd22, 
				UPDATE_5  = 6'd23,
				LOAD_5 = 6'd24,
				LOAD_DONE_5 = 6'd25,

                DRAW_PLAYER      = 6'd26, //constants for states
                ERASE_PLAYER        = 6'd27, 
				UPDATE_PLAYER  = 6'd28,
				LOAD_PLAYER = 6'd29,
				LOAD_DONE_PLAYER = 6'd30,

                TITLE = 6'd31,
                WAIT_TITLE = 6'd32,
				COLLIDE = 6'd33,
				GAMEOVER = 6'd34,
				CLR_SCREEN = 6'd35,
				WAIT_GO = 6'd37,
				CLR_SCREEN_GO = 6'd38,
				GAMEOVER_SOUND = 6'd39
				;
				
	// Next state logic aka our state table
    always@(*)
    begin: state_table //name
            case (current_state)
            TITLE: 
						begin //0
							if (screendonesignal == 1'b1) //when done drawing object, go to wait
								next_state = WAIT_TITLE;
							else 	
								next_state = TITLE;
						end
			WAIT_TITLE: begin
				if (titledonesignal == 1'b1) next_state = CLR_SCREEN;
				else next_state = WAIT_TITLE;
				end
				
				CLR_SCREEN: begin
					if (screendonesignal == 1'b1) next_state = ERASE_PLAYER;
					else 
						next_state = CLR_SCREEN;
						end

				DRAW_1: 	begin
							if (donesignal_box1 == 1'b1) //when done drawing object, go to wait
								next_state = DRAW_2;
							else 	
								next_state = DRAW_1;
						end

				DRAW_2: 	begin
							if (donesignal_box2 == 1'b1) //when done drawing object, go to wait
								next_state = DRAW_3;
							else 	
								next_state = DRAW_2;
						end
				
                DRAW_3: 	begin
							if (donesignal_box3 == 1'b1) //when done drawing object, go to wait
								next_state = DRAW_4;
							else 	
								next_state = DRAW_3;
						end
                
                DRAW_4: 	begin
							if (donesignal_box4 == 1'b1) //when done drawing object, go to wait
								next_state = DRAW_5;
							else 	
								next_state = DRAW_4;
						end

                DRAW_5: 	begin
							if (donesignal_box5 == 1'b1) //when done drawing object, go to wait
								next_state = DRAW_PLAYER;
							else 	
								next_state = DRAW_5;
						end

                DRAW_PLAYER: 	begin
							if (donesignal_player == 1'b1) //when done drawing object, go to wait
								next_state = DRAW_DONE;
							else 	
								next_state = DRAW_PLAYER;
						end


				
				DRAW_DONE: begin
							if (donecounting == 1'b1 & !(collidesignal == 1'b1)) //wait 15 frames
								next_state = ERASE_1;
                            else if (donecounting == 1'b1 & collidesignal == 1'b1)
                                next_state = COLLIDE;
							else 	
								next_state = DRAW_DONE;
						end
				
				ERASE_1: begin
							if (donesignal_box1 == 1'b1)
								next_state = ERASE_2;
							else 	
								next_state = ERASE_1;
						end
				ERASE_2: begin
							if (donesignal_box2 == 1'b1)
								next_state = ERASE_3;
							else 	
								next_state = ERASE_2;
						end
				ERASE_3: begin
							if (donesignal_box3 == 1'b1)
								next_state = ERASE_4;
							else 	
								next_state = ERASE_3;
						end
                ERASE_4: begin
							if (donesignal_box4 == 1'b1)
								next_state = ERASE_5;
							else 	
								next_state = ERASE_4;
						end
                ERASE_5: begin
							if (donesignal_box5 == 1'b1)
								next_state = ERASE_PLAYER;
							//else if (donesignal_box5 == 1'b1)
								//next_state = ERASE_PLAYER;
							else
								next_state = ERASE_5;
						end

                ERASE_PLAYER: begin
							if (donesignal_player == 1'b1)
								next_state = UPDATE_1;
							else 	
								next_state = ERASE_PLAYER;
						end

				
				UPDATE_1: begin
							if ((updatedone_box1 == 1'b1))
								next_state = UPDATE_2;
							else 	
								next_state = UPDATE_1;
						end	
						
				UPDATE_2: begin
							if ((updatedone_box2 == 1'b1))
								next_state = UPDATE_3;
							else 	
								next_state = UPDATE_2;
						end	

                UPDATE_3: begin
							if ((updatedone_box3 == 1'b1))
								next_state = UPDATE_4;
							else 	
								next_state = UPDATE_3;
						end		
                UPDATE_4: begin
							if ((updatedone_box4 == 1'b1))
								next_state = UPDATE_5;
							else 	
								next_state = UPDATE_4;
						end		
                UPDATE_5: begin
							if ((updatedone_box5 == 1'b1))
								next_state = UPDATE_PLAYER;
							else 	
								next_state = UPDATE_5;
						end		

                 UPDATE_PLAYER: begin
							if ((updatedone_player == 1'b1))
								next_state = LOAD_1;
							else 	
								next_state = UPDATE_PLAYER;
						end	

				
				LOAD_1: next_state = LOAD_DONE_1;
				
				LOAD_2: next_state = LOAD_DONE_2;
				
				LOAD_DONE_1: next_state = LOAD_2;

				LOAD_DONE_2: next_state = LOAD_3;

                LOAD_3: next_state = LOAD_DONE_3;

                LOAD_DONE_3: next_state = LOAD_4;

                LOAD_4: next_state = LOAD_DONE_4;

                LOAD_DONE_4: next_state = LOAD_5;

                LOAD_5: next_state = LOAD_DONE_5;

                LOAD_DONE_5: next_state = LOAD_PLAYER;

                LOAD_PLAYER: next_state = LOAD_DONE_PLAYER;

                LOAD_DONE_PLAYER: next_state = DRAW_1;
					 
				COLLIDE: next_state = GAMEOVER_SOUND;
				
				GAMEOVER_SOUND: begin
					if (gameoversounddone == 1)begin
						next_state = GAMEOVER;		
					end
					else begin
						next_state = GAMEOVER_SOUND;
						end
					 end
				GAMEOVER: begin 
							if (screendonesignal == 1'b1) next_state = WAIT_GO;
							else next_state = GAMEOVER;
						end
				
				WAIT_GO: begin
					if (titledonesignal == 1'b1) next_state = CLR_SCREEN_GO;
					else next_state = WAIT_GO;
					end
				
				CLR_SCREEN_GO: begin
					if (screendonesignal == 1'b1) next_state = TITLE;
					else 
						next_state = CLR_SCREEN_GO;
						end
							
				default: next_state = TITLE;
			endcase
	end
	
	// Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		drawobject_box1 = 1'b0;
		blackclr_box1 = 1'b0;
		startcounting = 1'b0;
		updatepos_box1 = 1'b0;
		load_box1 = 1'b0;
		loaddone_1 = 1'b0;

		drawobject_box2 = 1'b0;
		blackclr_box2 = 1'b0;
		updatepos_box2 = 1'b0;
		load_box2 = 1'b0;
		loaddone_2 = 1'b0;

        drawobject_box3 = 1'b0;
		blackclr_box3 = 1'b0;
		updatepos_box3 = 1'b0;
		load_box3 = 1'b0;
		loaddone_3 = 1'b0;

        drawobject_box4 = 1'b0;
		blackclr_box4 = 1'b0;
		updatepos_box4 = 1'b0;
		load_box4 = 1'b0;
		loaddone_4 = 1'b0;

        drawobject_box5 = 1'b0;
		blackclr_box5 = 1'b0;
		updatepos_box5 = 1'b0;
		load_box5 = 1'b0;
		loaddone_5 = 1'b0;
		
		drawobject_player = 1'b0;
		blackclr_player = 1'b0;
		updatepos_player = 1'b0;
		load_player = 1'b0;
		loaddone_player = 1'b0;
		
		drawscreen = 1'b0;
		screentype = 3'd2;
		playsound = 1'b0;
    
		
		case (current_state) //have case for when done ex done = 0 then done = 1
    
			DRAW_1: begin
					drawscreen = 1'b0;
					drawobject_box1 = 1'b1;
					load_box1 = 1'b0;
				end
			
			DRAW_2: begin
					drawobject_box2 = 1'b1;
					load_box2 = 1'b0;
				end

            DRAW_3: begin
					drawobject_box3 = 1'b1;
					load_box3 = 1'b0;
				end
            
            DRAW_4: begin
					drawobject_box4 = 1'b1;
					load_box4 = 1'b0;
				end
            
            DRAW_5: begin
					drawobject_box5 = 1'b1;
					load_box5 = 1'b0;
				end
			DRAW_PLAYER: begin
				drawobject_player = 1'b1;
				load_player = 1'b0;
			end
			
			DRAW_DONE: begin
							startcounting = 1'b1;
							blackclr_box1 = 1'b1;
							blackclr_box2 = 1'b1;
                            blackclr_box3 = 1'b1;
							blackclr_box4 = 1'b1;
                            blackclr_box5 = 1'b1;
							blackclr_player = 1'b1;
						end

			ERASE_1:begin
					drawobject_box1 = 1'b1;
					blackclr_box1 = 1'b1;
					blackclr_box2 = 1'b1;
                    blackclr_box3 = 1'b1;
					blackclr_box4 = 1'b1;
                    blackclr_box5 = 1'b1;
					blackclr_player = 1'b1;
					
	
					end
					
			ERASE_2:begin
					drawobject_box2 = 1'b1;
					blackclr_box1 = 1'b1;
					blackclr_box2 = 1'b1;
                    blackclr_box3 = 1'b1;
					blackclr_box4 = 1'b1;
                    blackclr_box5 = 1'b1;
					blackclr_player = 1'b1;
					end

			ERASE_3:begin
					drawobject_box3 = 1'b1;
					blackclr_box1 = 1'b1;
					blackclr_box2 = 1'b1;
                    blackclr_box3 = 1'b1;
					blackclr_box4 = 1'b1;
                    blackclr_box5 = 1'b1;
					blackclr_player = 1'b1;
					end

            ERASE_4:begin
					drawobject_box4 = 1'b1;
					blackclr_box1 = 1'b1;
					blackclr_box2 = 1'b1;
                    blackclr_box3 = 1'b1;
					blackclr_box4 = 1'b1;
                    blackclr_box5 = 1'b1;
					blackclr_player = 1'b1;
					end

            ERASE_5:begin
					drawobject_box5 = 1'b1;
					blackclr_box1 = 1'b1;
					blackclr_box2 = 1'b1;
                    blackclr_box3 = 1'b1;
					blackclr_box4 = 1'b1;
                    blackclr_box5 = 1'b1;
					blackclr_player = 1'b1;
					end


			ERASE_PLAYER: begin
					drawobject_player = 1'b1;
					pointsearned = 1'b1;
					blackclr_box1 = 1'b1;
					blackclr_box2 = 1'b1;
                    blackclr_box3 = 1'b1;
					blackclr_box4 = 1'b1;
                    blackclr_box5 = 1'b1;
					blackclr_player = 1'b1;
					end
			
			
			UPDATE_1: begin
						pointsearned = 1'b0;
						drawscreen = 1'b0;
						updatepos_box1 = 1'b1;
						blackclr_box1 = 1'b0;
					end
					
			UPDATE_2: begin
						updatepos_box2 = 1'b1;
						blackclr_box2 = 1'b0;
					end

            UPDATE_3: begin
						updatepos_box3 = 1'b1;
						blackclr_box3 = 1'b0;
					end
					
			UPDATE_4: begin
						updatepos_box4 = 1'b1;
						blackclr_box4 = 1'b0;
					end

            UPDATE_5: begin
						updatepos_box5 = 1'b1;
						blackclr_box5 = 1'b0;
					end

			UPDATE_PLAYER: begin
						updatepos_player = 1'b1;
						blackclr_player = 1'b0;
					end

	
					
			LOAD_1: begin
						load_box1 = 1'b1;
						drawobject_box1 = 1'b0;	
				end
				
			LOAD_2: begin
						load_box2 = 1'b1;
						drawobject_box2 = 1'b0;	
				end

            LOAD_3: begin
						load_box3 = 1'b1;
						drawobject_box3 = 1'b0;	
				end
				
			LOAD_4: begin
						load_box4 = 1'b1;
						drawobject_box4 = 1'b0;	
				end

            LOAD_5: begin
						load_box5 = 1'b1;
						drawobject_box5 = 1'b0;	
				end
			
            LOAD_PLAYER: begin
						load_player = 1'b1;
						drawobject_player = 1'b0;	
				end
			
			
			LOAD_DONE_1:begin
						drawobject_box1 = 1'b0;
						load_box1 = 1'b1;
					end
			
			
			LOAD_DONE_2:begin
						drawobject_box2 = 1'b0;
						load_box2 = 1'b1;
					end
			
            LOAD_DONE_3:begin
						drawobject_box3 = 1'b0;
						load_box3 = 1'b1;
					end
			
			
			LOAD_DONE_4:begin
						drawobject_box4 = 1'b0;
						load_box4 = 1'b1;
					end

            LOAD_DONE_5:begin
						drawobject_box5 = 1'b0;
						load_box5 = 1'b1;
					end
			
			
			LOAD_DONE_PLAYER:begin
						drawobject_player = 1'b0;
						load_player = 1'b1;
					end
			
			TITLE: begin
				screentype = 3'd0;
				drawscreen = 1'b1;
						load_box1 = 1'b1;
						drawobject_box1 = 1'b0;
						load_box2 = 1'b1;
						drawobject_box2 = 1'b0;	
						load_box3 = 1'b1;
						drawobject_box3 = 1'b0;	
						load_box4 = 1'b1;
						drawobject_box4 = 1'b0;	
						load_box5 = 1'b1;
						drawobject_box5 = 1'b0;	
						load_player = 1'b1;
						drawobject_player = 1'b0;
				end
			
			WAIT_GO: begin
				drawscreen = 1'b0;
				
				end
			
				WAIT_TITLE: begin
				drawscreen = 1'b0;
				end
				
				GAMEOVER_SOUND: begin
				playsound = 1'b1;
				end
				
			GAMEOVER: begin
				screentype = 3'd2;
				drawscreen = 1'b1;
				end
			
			CLR_SCREEN: begin
				screentype = 3'd1;
				drawscreen = 1'b1;
				end
				
			CLR_SCREEN_GO: begin
				screentype = 3'd1;
				drawscreen = 1'b1;
				end
		endcase
	end
	
    // current_state registers
    always@(posedge iClock)
    begin: state_FF
        if(!iResetn) //ACTIVE LOW
		  begin
            current_state <= TITLE;
				end
        else
            current_state <= next_state;
    end // state_FFS
endmodule



module datapath(
    input iClock,
    input iResetn,
    input [8:0] xcord,
	input [8:0] ycord,
	
	input blackclr, 
	input drawobject,
	input load,
	
	
	//output x,y and colour
	output reg [8:0] outputX,	
	output reg [8:0] outputY,
	output reg [2:0] outputClr,
	
	output reg donesignal
    );
	
	parameter
		maxi = 9'd15,   // Box X dimension
		maxj = 9'd15   // Box Y dimension
	;
    // input registers
    reg [8:0] xreg, yreg, xcount, ycount;
	reg innerdonesignal;
	reg [2:0] clrreg;

	// Registers xreg, yreg, and clr with respective input logic
    always@(posedge iClock) 
	begin
        if(!iResetn)
			begin
				xcount <= 9'b0;
				ycount <= 9'b0;
				clrreg <= 3'd4;
				
				xreg <= xcord;
				yreg <= ycord;
				outputX <= 9'd5;	
				outputY <= 9'b0;
				outputClr <= 3'b0;
				
				innerdonesignal <= 1'b0;
				donesignal <= 1'b0;
			end
		else
			begin 
				if (drawobject == 1'b0)
					begin
						xreg <= xcord;
						yreg <= ycord;
						clrreg <= 3'd0;
					end
				if (drawobject == 1'b1)
					begin
						outputX <= xreg;
						outputY <= yreg + ycount;
						outputClr <= clrreg;
					end
				if (blackclr == 1'b1)
					begin
						clrreg <= 3'd0;
						outputClr <= clrreg;
					end
				else	
					begin
						clrreg <= 3'd4;
					end
					
				if (innerdonesignal) 
					begin
						donesignal <= innerdonesignal;
					end
				

				//draw the object:
				
				if (drawobject == 1'b1 & load == 1'b0 & ~donesignal)
					begin
					
						// Calculate output coordinates
						if ((xcount == maxi))
							begin 
								xcount <= 9'b0;
								ycount <= ycount + 1;
							end
						else
							begin
								xcount <= xcount + 1;
							end
							
						if ((ycount == maxj) & (xcount == maxi))
							begin
								xcount <= 9'b0;
								ycount <= 9'b0;
						
								innerdonesignal <= 1'b1;
							end

						outputX <= xreg + xcount;
						outputY <= yreg + ycount;
						outputClr <= clrreg;
						

					end
				else
					begin
						donesignal <= 1'b0;
						innerdonesignal <= 1'b0;
					end
					
					
			end
	end
				
endmodule


module counters(
    input iClock,
    input iResetn,
    input startcounting,
	input updatepos,
	input [8:0] initx,
	
	
    output reg donecounting,
	output reg updatedone,
	output reg [8:0] xcord,
	output reg [8:0] ycord
);

	reg [23:0] CLOCKS_PER_SECOND;
    // input registers
	
	
	// Clock divider for 1/60th of a second pulse
    reg [23:0] DelayCounter;
    reg [23:0] FrameCounter;

    // Registers xreg, yreg, and clr with respective input logic
    always @(posedge iClock)
    begin
        if (!iResetn)
			begin
				DelayCounter <= 0;
				FrameCounter <= 0;
				xcord <= initx;
				ycord <= 0;
				donecounting <= 0;
				CLOCKS_PER_SECOND <= 2300000;
				
			end
		
        else
			if(startcounting)
				begin
					// Increment DelayCounter every clock cycle
					DelayCounter <= DelayCounter + 1;

					// Generate a 1/60th of a second pulse
					if (DelayCounter == CLOCKS_PER_SECOND / 60 - 1)
						begin
							DelayCounter <= 0;

							// Increment FrameCounter on each 1/60th of a second
							FrameCounter <= FrameCounter + 1;

							// Check if 15 frames have elapsed
							if (FrameCounter == 15)
								begin
									FrameCounter <= 0;
									donecounting <= 1; // Signal that counting is done
								end
							else
								begin
									donecounting <= 0;
								end
						end
				end
			else
				begin
					donecounting <= 1'b0;
				end
			
			
		if ((updatepos == 1'b1) && (updatedone == 1'b0))
			begin
				if (ycord == 9'd223) //change this back
					begin
						ycord <= 9'd0;
						if (CLOCKS_PER_SECOND > 880000)
							begin
								CLOCKS_PER_SECOND <= (CLOCKS_PER_SECOND * 100) / 105;
							end
						xcord <= {xcord[3],xcord[0],xcord[4]-xcord[5],xcord[7],xcord[1]^xcord[3],xcord[2],xcord[6]^xcord[1],xcord[4]};
						updatedone <= 1;
					end
				else 
					begin
						ycord <= ycord + 1;
						updatedone <= 1;
					end

			end
		else
			begin
				updatedone <= 1'b0;
			end	
		
    end

endmodule

module datapath_player(
    input iClock,
    input iResetn,
    input [8:0] xcord,
	input [8:0] ycord,
	
	input blackclr, 
	input drawobject,
	input load,
	
	//output x,y and colour
	output reg [8:0] outputX,	
	output reg [8:0] outputY,
	output reg [2:0] outputClr,
	
	output reg donesignal
    );
	
	parameter
		maxi = 9'd34,   // Box X dimension
		maxj = 9'd12   // Box Y dimension
	;
    // input registers
    reg [8:0] xreg, yreg, xcount, ycount;
	reg innerdonesignal;
	reg [2:0] clrreg;

	// Registers xreg, yreg, and clr with respective input logic
    always@(posedge iClock) 
	begin
        if(!iResetn)
			begin
				xcount <= 9'b0;
				ycount <= 9'b0;
				clrreg <= 3'd1;
				xreg <= xcord;
				yreg <= ycord;
				outputX <= 9'd153;	
				outputY <= 9'd230;
				outputClr <= 3'b0;
				
				innerdonesignal <= 1'b0;
				donesignal <= 1'b0;
			end
		else
			begin 
				if (drawobject == 1'b0)
					begin
						xreg <= xcord;
						yreg <= ycord;
						clrreg <= 3'd1;
					end
				if (drawobject == 1'b1)
					begin
						outputX <= xreg;
						outputY <= yreg + ycount;
						outputClr <= clrreg;
					end
				if (blackclr == 1'b1)
					begin
						clrreg <= 3'd0;
						outputClr <= clrreg;
					end
				else	
					begin
						clrreg <= 3'd1;
					end
					
				if (innerdonesignal) 
					begin
						donesignal <= innerdonesignal;
					end
				

				//draw the object:
				
				if (drawobject == 1'b1 & load == 1'b0 & ~donesignal)
					begin
					
						// Calculate output coordinates
						if ((xcount == maxi))
							begin 
								xcount <= 9'b0;
								ycount <= ycount + 1;
							end
						else
							begin
								xcount <= xcount + 1;
							end
							
						if ((ycount == maxj) & (xcount == maxi))
							begin
								xcount <= 9'b0;
								ycount <= 9'b0;
						
								innerdonesignal <= 1'b1;
							end

						outputX <= xreg + xcount;
						outputY <= yreg + ycount;
						outputClr <= clrreg;
						

					end
				else
					begin
						donesignal <= 1'b0;
						innerdonesignal <= 1'b0;
					end
					
					
			end
	end
				
endmodule

	

module counters_player(
    input iClock,
    input iResetn,
    input startcounting,
	input updatepos,
	input left,
	input right,
	
	
	
	
    output reg donecounting,
	output reg updatedone,
	output reg [8:0] xcord,
	output reg [8:0] ycord
);

	parameter CLOCKS_PER_SECOND = 5000000;
    // input registers
	
    reg [23:0] DelayCounter;
    reg [23:0] FrameCounter;

    // Clock divider for 1/60th of a second pulse
    reg [23:0] clockDivider;

    // Registers xreg, yreg, and clr with respective input logic
    always @(posedge iClock)
    begin
        if (!iResetn)
			begin
				DelayCounter <= 0;
				FrameCounter <= 0;
				xcord <= 9'd153;
				ycord <= 9'd230;
				clockDivider <= 0;
				donecounting <= 0;
			end
		
        else
			if(startcounting)
				begin
					// Increment DelayCounter every clock cycle
					DelayCounter <= DelayCounter + 1;

					// Generate a 1/60th of a second pulse
					if (DelayCounter == CLOCKS_PER_SECOND / 60 - 1)
						begin
							DelayCounter <= 0;

							// Increment FrameCounter on each 1/60th of a second
							FrameCounter <= FrameCounter + 1;

							// Check if 15 frames have elapsed
							if (FrameCounter == 15)
								begin
									FrameCounter <= 0;
									donecounting <= 1; // Signal that counting is done
								end
							else
								begin
									donecounting <= 0;
								end
						end
				end
			else
				begin
					donecounting <= 1'b0;
				end
			
			
		if ((updatepos == 1'b1) && (updatedone == 1'b0))
			begin
				if (xcord == 9'd0) 
					begin
						if (left == 1)
							begin
								ycord <= 9'd230;
								xcord <= xcord;
								updatedone <= 1;
							end
						else if (right == 1 & left == 0)
							begin
								ycord <= 9'd230;
								xcord <= xcord + 1;
								updatedone <= 1;
							end	
						else begin
							xcord <=xcord;
							ycord <= 9'd230;
							updatedone <=1;
						end
					end
				else if	(xcord == 9'd286)
					begin
						if (left == 1 & right == 0)
							begin	
								ycord <= 9'd230;
								xcord <= xcord - 1;
								updatedone <= 1;
							end
						else if (right == 1)
							begin	
								ycord <= 9'd230;
								xcord <= xcord;
								updatedone <= 1;
							end	
						else begin
							xcord <=xcord;
							ycord <= 9'd230;
							updatedone <=1;
						end	
					end		
				else 
					begin
						if (left == 1 & right == 0)
							xcord <= xcord - 1;
						else if(right == 1 & left == 0)
							xcord <= xcord + 1;
						else 
							begin
								xcord <= xcord;
							end
						ycord <= 9'd230;
						updatedone <= 1;
					end

			end
		else
			begin
				updatedone <= 1'b0;
			end	
		
    end

endmodule



module collide (iClock, iResetn, oX, oY, oX_player, oY_player, collidesignal, oldcollidesignal, outputPlot);
    input iClock, iResetn, oldcollidesignal, outputPlot;
    input [8:0] oX, oY;
    input [8:0] oX_player, oY_player; // you probably just need the height of the box
    output reg collidesignal;
	reg signalreg;

    always @(posedge iClock) begin
		if (oldcollidesignal == 1'b1) 
			begin
			collidesignal = 1'b1;
			end
        else if ( ( ((oX == oX_player) && (oY >= 9'd214)) || ((oX + 9'd15 == oX_player) && (oY >= 9'd214)) ) && outputPlot == 1'b0) begin
            signalreg <= 1'b1;
			collidesignal <= signalreg;
            end
        else if (!iResetn) begin
            collidesignal <= 1'b0;
			signalreg <= 1'b0;
            end
		else collidesignal <= signalreg;
		end

	endmodule
	
	
	
	
	
	
module score (iClock, iResetn, ipointsignal, oScore, oY, donecounting5);
        input iClock, iResetn, ipointsignal;
		input donecounting5;
		input [8:0] oY;
        output reg [11:0] oScore;
		reg [11:0] count, regscore;
		  
            always@(posedge iClock) begin
                if (oY == 9'd216 && donecounting5 == 1'b1) begin
                    count <= count + 12'd1;
                    end
                else if (!iResetn) begin
                    oScore <= 12'd0;
					count <= 12'd0;
					regscore <= 12'd0;
                    end
                else if (count == 12'd2) begin 
					count <= 12'd0;
					regscore <= regscore + 12'd1;
					end
				else begin
					oScore <= regscore;
					end
                end

        endmodule


module datapath_screen(
    input iClock,
    input iResetn,
	
	input [2:0] screentype, 
	input drawscreen,
	//input load,
	
	
	//output x,y and colour
	output reg [8:0] outputX,	
	output reg [8:0] outputY,
	output reg [2:0] outputClr,
	
	output reg screendonesignal
    );
	
	parameter
		maxi = 9'd319,   // screen X dimension
		maxj = 9'd239   // screen Y dimension
	;
    // input registers
    reg [8:0] xreg, yreg, xcount, ycount;
	reg screeninnerdonesignal;
	reg [2:0] clrreg;
	
	
	localparam TITLESCREEN = 3'd0,
				BACKGROUND = 3'd1,
				GAMEOVERSCREEN = 3'd2;
	
	
	wire [2:0] titlecolour;
	reg [16:0] titleaddress;
	
	officialtitlescreen U7 (.address(titleaddress), .clock(iClock), .q(titlecolour));
	
	wire [2:0] gameovercolour;
	reg [16:0] gameoveraddress;
	
	officialgameover U8 (.address(gameoveraddress), .clock(iClock), .q(gameovercolour));
	
	wire [2:0] backgroundcolour;
	reg [16:0] backgroundaddress;
	
	gameover U9 (.address(backgroundaddress), .clock(iClock), .q(backgroundcolour));


	// Registers xreg, yreg, and clr with respective input logic
    always@(posedge iClock) 
	begin
        if(!iResetn)
			begin
				xcount <= 9'b0;
				ycount <= 9'b0;
				clrreg <= 3'd0;
				
				xreg <= 9'd0;
				yreg <= 9'd0;
				outputX <= 9'd0;	
				outputY <= 9'b0;
				outputClr <= 3'b0;
				
				screeninnerdonesignal <= 1'b0;
				screendonesignal <= 1'b0;
			end
		else
			begin 
				if (drawscreen == 1'b0)
					begin
						xreg <= 9'd0;
						yreg <= 9'd0;
						clrreg <= 3'd0;
					end
				if (drawscreen == 1'b1)
					begin
						outputX <= xreg;
						outputY <= yreg + ycount;
						outputClr <= clrreg;
					end
				if (screentype == TITLESCREEN)
					begin
						
						clrreg <= titlecolour;
						outputClr <= clrreg;
					end
				else if (screentype == BACKGROUND)
					begin
						clrreg <= backgroundcolour;
						outputClr <= clrreg;
					end
				else if (screentype == GAMEOVERSCREEN)
					begin
					clrreg <= gameovercolour;
					outputClr <= clrreg;
					
					end
				else clrreg <= 3'd0;
					
				if (screeninnerdonesignal) 
					begin
						screendonesignal <= screeninnerdonesignal;
					end
				

				//draw the object:
				
				if (drawscreen == 1'b1 & ~screendonesignal)
					begin
					
						// Calculate output coordinates
						if ((xcount == maxi))
							begin 
								xcount <= 9'b0;
								ycount <= ycount + 1;
								titleaddress <= titleaddress  + 17'b1;
								gameoveraddress <= gameoveraddress + 17'b1;
								backgroundaddress  <= backgroundaddress  + 17'b1;
							end
						else
							begin
								xcount <= xcount + 1;
								titleaddress <= titleaddress  + 17'b1;
								gameoveraddress <= gameoveraddress + 17'b1;
								backgroundaddress  <= backgroundaddress  + 17'b1;
							end
							
						if ((ycount == maxj) & (xcount == maxi))
							begin
								xcount <= 9'b0;
								ycount <= 9'b0;
								titleaddress <= titleaddress  + 17'b0;
								gameoveraddress <= 17'b0;
								backgroundaddress  <= 17'b0;
								screeninnerdonesignal <= 1'b1;
							end

						outputX <= xreg + xcount;
						outputY <= yreg + ycount;
						outputClr <= clrreg;
						

					end
				else
					begin
						screendonesignal <= 1'b0;
						screeninnerdonesignal <= 1'b0;
					end
					
					
			end
	end
				
endmodule


module highscoreachieved (iClock, finalscore, highscore, iResetn);
input[11: 0]finalscore;
	input iClock, iResetn; 
	output reg[11: 0]highscore;
	
	reg wren;
	wire[11: 0]newscore;
	
	always @(posedge iClock) begin
if (!iResetn) begin
highscore <= 12'b0;
end
		
		else if (finalscore > highscore) begin
wren <= 1'b1;
highscore <= finalscore;

end
		
		else begin
wren <= 1'b0;
end

end
			
	assign newscore = highscore;

	//assign wren = (finalscore > newscore)? 1'b1: 1'b0;
	
	assign wwren = wren;
	
	wire [11:0] scorewire;
	
	highscore yay(6'b0,
	iClock,
    finalscore,
    wren,
   scorewire);

endmodule
