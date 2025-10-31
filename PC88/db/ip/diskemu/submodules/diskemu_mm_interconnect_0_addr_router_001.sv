// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/13.1/ip/merlin/altera_merlin_router/altera_merlin_router.sv.terp#5 $
// $Revision: #5 $
// $Date: 2013/09/30 $
// $Author: perforce $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// either (a) the address or (b) the dest id. The DECODER_TYPE
// parameter controls this behaviour. 0 means address decoder,
// 1 means dest id decoder.
//
// In the case of (a), it also sets the destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module diskemu_mm_interconnect_0_addr_router_001_default_decode
  #(
     parameter DEFAULT_CHANNEL = 1,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 18 
   )
  (output [87 - 82 : 0] default_destination_id,
   output [59-1 : 0] default_wr_channel,
   output [59-1 : 0] default_rd_channel,
   output [59-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[87 - 82 : 0];

  generate begin : default_decode
    if (DEFAULT_CHANNEL == -1) begin
      assign default_src_channel = '0;
    end
    else begin
      assign default_src_channel = 59'b1 << DEFAULT_CHANNEL;
    end
  end
  endgenerate

  generate begin : default_decode_rw
    if (DEFAULT_RD_CHANNEL == -1) begin
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin
      assign default_wr_channel = 59'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 59'b1 << DEFAULT_RD_CHANNEL;
    end
  end
  endgenerate

endmodule


module diskemu_mm_interconnect_0_addr_router_001
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [101-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [101-1    : 0] src_data,
    output reg [59-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 54;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 87;
    localparam PKT_DEST_ID_L = 82;
    localparam PKT_PROTECTION_H = 91;
    localparam PKT_PROTECTION_L = 89;
    localparam ST_DATA_W = 101;
    localparam ST_CHANNEL_W = 59;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 57;
    localparam PKT_TRANS_READ  = 58;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    localparam PAD0 = log2ceil(64'h40000 - 64'h20000); 
    localparam PAD1 = log2ceil(64'h44000 - 64'h40000); 
    localparam PAD2 = log2ceil(64'h46000 - 64'h44000); 
    localparam PAD3 = log2ceil(64'h47000 - 64'h46800); 
    localparam PAD4 = log2ceil(64'h47200 - 64'h47000); 
    localparam PAD5 = log2ceil(64'h47220 - 64'h47200); 
    localparam PAD6 = log2ceil(64'h47240 - 64'h47220); 
    localparam PAD7 = log2ceil(64'h47260 - 64'h47240); 
    localparam PAD8 = log2ceil(64'h47270 - 64'h47260); 
    localparam PAD9 = log2ceil(64'h47280 - 64'h47270); 
    localparam PAD10 = log2ceil(64'h47290 - 64'h47280); 
    localparam PAD11 = log2ceil(64'h472a0 - 64'h47290); 
    localparam PAD12 = log2ceil(64'h472b0 - 64'h472a0); 
    localparam PAD13 = log2ceil(64'h472c0 - 64'h472b0); 
    localparam PAD14 = log2ceil(64'h472d0 - 64'h472c0); 
    localparam PAD15 = log2ceil(64'h472e0 - 64'h472d0); 
    localparam PAD16 = log2ceil(64'h472f0 - 64'h472e0); 
    localparam PAD17 = log2ceil(64'h47300 - 64'h472f0); 
    localparam PAD18 = log2ceil(64'h47310 - 64'h47300); 
    localparam PAD19 = log2ceil(64'h47320 - 64'h47310); 
    localparam PAD20 = log2ceil(64'h47330 - 64'h47320); 
    localparam PAD21 = log2ceil(64'h47340 - 64'h47330); 
    localparam PAD22 = log2ceil(64'h47350 - 64'h47340); 
    localparam PAD23 = log2ceil(64'h47360 - 64'h47350); 
    localparam PAD24 = log2ceil(64'h47370 - 64'h47360); 
    localparam PAD25 = log2ceil(64'h47380 - 64'h47370); 
    localparam PAD26 = log2ceil(64'h47390 - 64'h47380); 
    localparam PAD27 = log2ceil(64'h473a0 - 64'h47390); 
    localparam PAD28 = log2ceil(64'h473b0 - 64'h473a0); 
    localparam PAD29 = log2ceil(64'h473c0 - 64'h473b0); 
    localparam PAD30 = log2ceil(64'h473d0 - 64'h473c0); 
    localparam PAD31 = log2ceil(64'h473e0 - 64'h473d0); 
    localparam PAD32 = log2ceil(64'h473f0 - 64'h473e0); 
    localparam PAD33 = log2ceil(64'h47400 - 64'h473f0); 
    localparam PAD34 = log2ceil(64'h47410 - 64'h47400); 
    localparam PAD35 = log2ceil(64'h47420 - 64'h47410); 
    localparam PAD36 = log2ceil(64'h47430 - 64'h47420); 
    localparam PAD37 = log2ceil(64'h47440 - 64'h47430); 
    localparam PAD38 = log2ceil(64'h47450 - 64'h47440); 
    localparam PAD39 = log2ceil(64'h47460 - 64'h47450); 
    localparam PAD40 = log2ceil(64'h47470 - 64'h47460); 
    localparam PAD41 = log2ceil(64'h47480 - 64'h47470); 
    localparam PAD42 = log2ceil(64'h47490 - 64'h47480); 
    localparam PAD43 = log2ceil(64'h474a0 - 64'h47490); 
    localparam PAD44 = log2ceil(64'h474b0 - 64'h474a0); 
    localparam PAD45 = log2ceil(64'h474c0 - 64'h474b0); 
    localparam PAD46 = log2ceil(64'h474d0 - 64'h474c0); 
    localparam PAD47 = log2ceil(64'h474e0 - 64'h474d0); 
    localparam PAD48 = log2ceil(64'h474f0 - 64'h474e0); 
    localparam PAD49 = log2ceil(64'h47500 - 64'h474f0); 
    localparam PAD50 = log2ceil(64'h47510 - 64'h47500); 
    localparam PAD51 = log2ceil(64'h47520 - 64'h47510); 
    localparam PAD52 = log2ceil(64'h47530 - 64'h47520); 
    localparam PAD53 = log2ceil(64'h47540 - 64'h47530); 
    localparam PAD54 = log2ceil(64'h47550 - 64'h47540); 
    localparam PAD55 = log2ceil(64'h47560 - 64'h47550); 
    localparam PAD56 = log2ceil(64'h47568 - 64'h47560); 
    localparam PAD57 = log2ceil(64'h47570 - 64'h47568); 
    localparam PAD58 = log2ceil(64'h47574 - 64'h47570); 
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'h47574;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam RG = RANGE_ADDR_WIDTH-1;
    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [59-1 : 0] default_src_channel;




    // -------------------------------------------------------
    // Write and read transaction signals
    // -------------------------------------------------------
    wire read_transaction;
    assign read_transaction  = sink_data[PKT_TRANS_READ];


    diskemu_mm_interconnect_0_addr_router_001_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

    // ( 0x20000 .. 0x40000 )
    if ( {address[RG:PAD0],{PAD0{1'b0}}} == 19'h20000   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 18;
    end

    // ( 0x40000 .. 0x44000 )
    if ( {address[RG:PAD1],{PAD1{1'b0}}} == 19'h40000   ) begin
            src_channel = 59'b00000000000000000000000000000000000000100000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 21;
    end

    // ( 0x44000 .. 0x46000 )
    if ( {address[RG:PAD2],{PAD2{1'b0}}} == 19'h44000   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000100000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 58;
    end

    // ( 0x46800 .. 0x47000 )
    if ( {address[RG:PAD3],{PAD3{1'b0}}} == 19'h46800   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 20;
    end

    // ( 0x47000 .. 0x47200 )
    if ( {address[RG:PAD4],{PAD4{1'b0}}} == 19'h47000   ) begin
            src_channel = 59'b00000000000000000000010000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
    end

    // ( 0x47200 .. 0x47220 )
    if ( {address[RG:PAD5],{PAD5{1'b0}}} == 19'h47200   ) begin
            src_channel = 59'b00000000000000000000100000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 16;
    end

    // ( 0x47220 .. 0x47240 )
    if ( {address[RG:PAD6],{PAD6{1'b0}}} == 19'h47220   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 52;
    end

    // ( 0x47240 .. 0x47260 )
    if ( {address[RG:PAD7],{PAD7{1'b0}}} == 19'h47240   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 53;
    end

    // ( 0x47260 .. 0x47270 )
    if ( {address[RG:PAD8],{PAD8{1'b0}}} == 19'h47260   ) begin
            src_channel = 59'b10000000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 14;
    end

    // ( 0x47270 .. 0x47280 )
    if ( {address[RG:PAD9],{PAD9{1'b0}}} == 19'h47270   ) begin
            src_channel = 59'b01000000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 13;
    end

    // ( 0x47280 .. 0x47290 )
    if ( {address[RG:PAD10],{PAD10{1'b0}}} == 19'h47280   ) begin
            src_channel = 59'b00100000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
    end

    // ( 0x47290 .. 0x472a0 )
    if ( {address[RG:PAD11],{PAD11{1'b0}}} == 19'h47290   ) begin
            src_channel = 59'b00010000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
    end

    // ( 0x472a0 .. 0x472b0 )
    if ( {address[RG:PAD12],{PAD12{1'b0}}} == 19'h472a0   ) begin
            src_channel = 59'b00001000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
    end

    // ( 0x472b0 .. 0x472c0 )
    if ( {address[RG:PAD13],{PAD13{1'b0}}} == 19'h472b0   ) begin
            src_channel = 59'b00000100000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 12;
    end

    // ( 0x472c0 .. 0x472d0 )
    if ( {address[RG:PAD14],{PAD14{1'b0}}} == 19'h472c0   ) begin
            src_channel = 59'b00000010000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
    end

    // ( 0x472d0 .. 0x472e0 )
    if ( {address[RG:PAD15],{PAD15{1'b0}}} == 19'h472d0   ) begin
            src_channel = 59'b00000001000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 8;
    end

    // ( 0x472e0 .. 0x472f0 )
    if ( {address[RG:PAD16],{PAD16{1'b0}}} == 19'h472e0   ) begin
            src_channel = 59'b00000000100000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
    end

    // ( 0x472f0 .. 0x47300 )
    if ( {address[RG:PAD17],{PAD17{1'b0}}} == 19'h472f0   ) begin
            src_channel = 59'b00000000010000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
    end

    // ( 0x47300 .. 0x47310 )
    if ( {address[RG:PAD18],{PAD18{1'b0}}} == 19'h47300   ) begin
            src_channel = 59'b00000000001000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
    end

    // ( 0x47310 .. 0x47320 )
    if ( {address[RG:PAD19],{PAD19{1'b0}}} == 19'h47310   ) begin
            src_channel = 59'b00000000000100000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 11;
    end

    // ( 0x47320 .. 0x47330 )
    if ( {address[RG:PAD20],{PAD20{1'b0}}} == 19'h47320   ) begin
            src_channel = 59'b00000000000010000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
    end

    // ( 0x47330 .. 0x47340 )
    if ( {address[RG:PAD21],{PAD21{1'b0}}} == 19'h47330   ) begin
            src_channel = 59'b00000000000001000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
    end

    // ( 0x47340 .. 0x47350 )
    if ( {address[RG:PAD22],{PAD22{1'b0}}} == 19'h47340   ) begin
            src_channel = 59'b00000000000000100000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 29;
    end

    // ( 0x47350 .. 0x47360 )
    if ( {address[RG:PAD23],{PAD23{1'b0}}} == 19'h47350   ) begin
            src_channel = 59'b00000000000000010000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 28;
    end

    // ( 0x47360 .. 0x47370 )
    if ( {address[RG:PAD24],{PAD24{1'b0}}} == 19'h47360  && read_transaction  ) begin
            src_channel = 59'b00000000000000001000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 31;
    end

    // ( 0x47370 .. 0x47380 )
    if ( {address[RG:PAD25],{PAD25{1'b0}}} == 19'h47370   ) begin
            src_channel = 59'b00000000000000000100000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 22;
    end

    // ( 0x47380 .. 0x47390 )
    if ( {address[RG:PAD26],{PAD26{1'b0}}} == 19'h47380   ) begin
            src_channel = 59'b00000000000000000010000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 33;
    end

    // ( 0x47390 .. 0x473a0 )
    if ( {address[RG:PAD27],{PAD27{1'b0}}} == 19'h47390   ) begin
            src_channel = 59'b00000000000000000000001000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 32;
    end

    // ( 0x473a0 .. 0x473b0 )
    if ( {address[RG:PAD28],{PAD28{1'b0}}} == 19'h473a0   ) begin
            src_channel = 59'b00000000000000000000000100000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 24;
    end

    // ( 0x473b0 .. 0x473c0 )
    if ( {address[RG:PAD29],{PAD29{1'b0}}} == 19'h473b0   ) begin
            src_channel = 59'b00000000000000000000000010000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 57;
    end

    // ( 0x473c0 .. 0x473d0 )
    if ( {address[RG:PAD30],{PAD30{1'b0}}} == 19'h473c0   ) begin
            src_channel = 59'b00000000000000000000000001000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 56;
    end

    // ( 0x473d0 .. 0x473e0 )
    if ( {address[RG:PAD31],{PAD31{1'b0}}} == 19'h473d0   ) begin
            src_channel = 59'b00000000000000000000000000100000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 55;
    end

    // ( 0x473e0 .. 0x473f0 )
    if ( {address[RG:PAD32],{PAD32{1'b0}}} == 19'h473e0   ) begin
            src_channel = 59'b00000000000000000000000000010000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 36;
    end

    // ( 0x473f0 .. 0x47400 )
    if ( {address[RG:PAD33],{PAD33{1'b0}}} == 19'h473f0   ) begin
            src_channel = 59'b00000000000000000000000000001000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 27;
    end

    // ( 0x47400 .. 0x47410 )
    if ( {address[RG:PAD34],{PAD34{1'b0}}} == 19'h47400   ) begin
            src_channel = 59'b00000000000000000000000000000100000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 25;
    end

    // ( 0x47410 .. 0x47420 )
    if ( {address[RG:PAD35],{PAD35{1'b0}}} == 19'h47410   ) begin
            src_channel = 59'b00000000000000000000000000000010000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 23;
    end

    // ( 0x47420 .. 0x47430 )
    if ( {address[RG:PAD36],{PAD36{1'b0}}} == 19'h47420   ) begin
            src_channel = 59'b00000000000000000000000000000001000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 35;
    end

    // ( 0x47430 .. 0x47440 )
    if ( {address[RG:PAD37],{PAD37{1'b0}}} == 19'h47430   ) begin
            src_channel = 59'b00000000000000000000000000000000100000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 34;
    end

    // ( 0x47440 .. 0x47450 )
    if ( {address[RG:PAD38],{PAD38{1'b0}}} == 19'h47440   ) begin
            src_channel = 59'b00000000000000000000000000000000010000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 37;
    end

    // ( 0x47450 .. 0x47460 )
    if ( {address[RG:PAD39],{PAD39{1'b0}}} == 19'h47450  && read_transaction  ) begin
            src_channel = 59'b00000000000000000000000000000000001000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 26;
    end

    // ( 0x47460 .. 0x47470 )
    if ( {address[RG:PAD40],{PAD40{1'b0}}} == 19'h47460   ) begin
            src_channel = 59'b00000000000000000000000000000000000100000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 30;
    end

    // ( 0x47470 .. 0x47480 )
    if ( {address[RG:PAD41],{PAD41{1'b0}}} == 19'h47470   ) begin
            src_channel = 59'b00000000000000000000000000000000000010000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 38;
    end

    // ( 0x47480 .. 0x47490 )
    if ( {address[RG:PAD42],{PAD42{1'b0}}} == 19'h47480   ) begin
            src_channel = 59'b00000000000000000000000000000000000001000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 39;
    end

    // ( 0x47490 .. 0x474a0 )
    if ( {address[RG:PAD43],{PAD43{1'b0}}} == 19'h47490   ) begin
            src_channel = 59'b00000000000000000000000000000000000000010000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 50;
    end

    // ( 0x474a0 .. 0x474b0 )
    if ( {address[RG:PAD44],{PAD44{1'b0}}} == 19'h474a0  && read_transaction  ) begin
            src_channel = 59'b00000000000000000000000000000000000000001000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 19;
    end

    // ( 0x474b0 .. 0x474c0 )
    if ( {address[RG:PAD45],{PAD45{1'b0}}} == 19'h474b0   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000010000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 51;
    end

    // ( 0x474c0 .. 0x474d0 )
    if ( {address[RG:PAD46],{PAD46{1'b0}}} == 19'h474c0   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000001000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 48;
    end

    // ( 0x474d0 .. 0x474e0 )
    if ( {address[RG:PAD47],{PAD47{1'b0}}} == 19'h474d0   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000100000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 45;
    end

    // ( 0x474e0 .. 0x474f0 )
    if ( {address[RG:PAD48],{PAD48{1'b0}}} == 19'h474e0   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000010000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 42;
    end

    // ( 0x474f0 .. 0x47500 )
    if ( {address[RG:PAD49],{PAD49{1'b0}}} == 19'h474f0   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000001000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 44;
    end

    // ( 0x47500 .. 0x47510 )
    if ( {address[RG:PAD50],{PAD50{1'b0}}} == 19'h47500   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000100000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 40;
    end

    // ( 0x47510 .. 0x47520 )
    if ( {address[RG:PAD51],{PAD51{1'b0}}} == 19'h47510   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000010000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 47;
    end

    // ( 0x47520 .. 0x47530 )
    if ( {address[RG:PAD52],{PAD52{1'b0}}} == 19'h47520   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000001000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 41;
    end

    // ( 0x47530 .. 0x47540 )
    if ( {address[RG:PAD53],{PAD53{1'b0}}} == 19'h47530   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 49;
    end

    // ( 0x47540 .. 0x47550 )
    if ( {address[RG:PAD54],{PAD54{1'b0}}} == 19'h47540   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 46;
    end

    // ( 0x47550 .. 0x47560 )
    if ( {address[RG:PAD55],{PAD55{1'b0}}} == 19'h47550   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 43;
    end

    // ( 0x47560 .. 0x47568 )
    if ( {address[RG:PAD56],{PAD56{1'b0}}} == 19'h47560  && read_transaction  ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 54;
    end

    // ( 0x47568 .. 0x47570 )
    if ( {address[RG:PAD57],{PAD57{1'b0}}} == 19'h47568   ) begin
            src_channel = 59'b00000000000000000000000000000000000000000000000000000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 15;
    end

    // ( 0x47570 .. 0x47574 )
    if ( {address[RG:PAD58],{PAD58{1'b0}}} == 19'h47570  && read_transaction  ) begin
            src_channel = 59'b00000000000000000001000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 17;
    end

end


    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


