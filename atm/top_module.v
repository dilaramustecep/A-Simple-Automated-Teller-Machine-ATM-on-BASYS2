`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:44:59 12/19/2019 
// Design Name: 
// Module Name:    top_module 
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
module top_module (clk, rst, 
						BTN3, BTN2, BTN1, 
						SW, LED,
						a,b,c,d,e,f,g,an0,an1,an2,an3); 
						 
	// ----- INPUTS -----					 
	input clk, rst, BTN3, BTN2, BTN1;
	input [3:0] SW;
	
	// ----- OUTPUTS ----
	output [7:0] LED;
	output a,b,c,d,e,f,g,an0,an1,an2,an3;
	
	
	// ----- CLK_DIVIDER -----
	wire divided_clk;
	clk_divider divider(.clk_in(clk),.rst(rst),.divided_clk(divided_clk)); //sikinti yok
	
	
	
	
	// ----- DEBOUNCER -----
	wire debouncer_out_btn3;
	debouncer debouncer_BTN3 (.clk(divided_clk), .rst(rst),.noisy_in(BTN3),.clean_out(debouncer_out_btn3));
	
	wire debouncer_out_btn2;
	debouncer debouncer_BTN2 (.clk(divided_clk),.rst(rst),.noisy_in(BTN2),.clean_out(debouncer_out_btn2));
	
	wire debouncer_out_btn1;
	debouncer debouncer_BTN1 (.clk(divided_clk),.rst(rst),.noisy_in(BTN1),.clean_out(debouncer_out_btn1)); //sikinti yok
	
	
	
	// ----- ATM_CODE ----
	wire [6:0] ssd_digit1, ssd_digit2, ssd_digit3, ssd_digit4;
	atm_code atm (.clk(divided_clk),.rst(rst),
						.BTN1(debouncer_out_btn1),.BTN2(debouncer_out_btn2),.BTN3(debouncer_out_btn3),
						.SW(SW),.LED(LED),
						.digit4(ssd_digit4), .digit3(ssd_digit3),.digit2(ssd_digit2),.digit1(ssd_digit1)
						);
	

	
	
	// ----- SSD -----
	ssd ssd_atm (.clk(clk), .reset(rst),
					.a0(ssd_digit1[6]), .b0(ssd_digit1[5]), .c0(ssd_digit1[4]), .d0(ssd_digit1[3]), .e0(ssd_digit1[2]),.f0(ssd_digit1[1]),.g0(ssd_digit1[0]),
					.a1(ssd_digit2[6]), .b1(ssd_digit2[5]), .c1(ssd_digit2[4]), .d1(ssd_digit2[3]), .e1(ssd_digit2[2]),.f1(ssd_digit2[1]),.g1(ssd_digit2[0]),
					.a2(ssd_digit3[6]), .b2(ssd_digit3[5]), .c2(ssd_digit3[4]), .d2(ssd_digit3[3]), .e2(ssd_digit3[2]),.f2(ssd_digit3[1]),.g2(ssd_digit3[0]),
					.a3(ssd_digit4[6]), .b3(ssd_digit4[5]), .c3(ssd_digit4[4]), .d3(ssd_digit4[3]), .e3(ssd_digit4[2]),.f3(ssd_digit4[1]),.g3(ssd_digit4[0]),
					
					.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
					.an0(an0), .an1(an1), .an2(an2), .an3(an3));


endmodule
