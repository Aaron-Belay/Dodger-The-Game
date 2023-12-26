module DE1_SoC_Audio_Example (
	// Inputs
	CLOCK_50,
	KEY,

	AUD_ADCDAT,
	playsound,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	gameoversounddone
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

input				AUD_ADCDAT;
input           playsound;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;
output reg gameoversounddone;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;
// Internal Registers

reg [18:0] delay_cnt;
wire [18:0] delay;
reg snd;


reg [15:0] address;



initial begin
	address <= 100;
	delay_cnt <= 0;
	snd <= 0;
	gameoversounddone <= 0;
end


newestgosound (.address(address), .clock(CLOCK_50), .q(delay));


// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

reg [27:0] DelayCounter;

   // 26-bit counter for 50,000,000 cycles (1 second)

always @(posedge CLOCK_50) begin
if(gameoversounddone == 1) begin
gameoversounddone <=0;
end
if (playsound == 1 && gameoversounddone == 0)begin
	  DelayCounter <= DelayCounter + 1;
	  if (DelayCounter >= 400000) 
		begin  // 50,000,000 cycles for 1 Hz frequency
				 DelayCounter <= 0;
				 address <= address + 1; // Increment the address
				 if (address >= 400) 
						begin
						gameoversounddone <= 1; 
						address <= 0;
						DelayCounter <= 0;
						end
			  end
	 end
	 else begin
		 DelayCounter <=0;
		 address <= 0;
	 end
 
end


always @(posedge CLOCK_50)
	begin
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;
	end


/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

wire [31:0] sound =  (playsound == 0) ? 0 : snd ? 32'd10000000 : -32'd10000000;


assign read_audio_in			= audio_in_available & audio_out_allowed;
assign left_channel_audio_out	= left_channel_audio_in + sound;
assign right_channel_audio_out	= right_channel_audio_in + sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);
 
 
endmodule 