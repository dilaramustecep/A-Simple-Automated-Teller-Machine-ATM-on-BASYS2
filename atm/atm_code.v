`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:25:32 12/12/2019 
// Design Name: 
// Module Name:    atm_code 
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


 module atm_code(input clk, input rst, input BTN3, BTN2, BTN1,input [3:0] SW,  
                     output reg [7:0] LED, output reg [6:0] digit4, digit3, digit2, digit1); 
	
	/*
	----------------------------------------
		IN THIS MODULE

			3.balance //beacuse of hexadecimal ?????
			4.counter cntr
			FOR TIMING ???
	
	--------------------------------------- 
	*/	
	 reg [3:0] password;
    reg [15:0] balance;	
	 reg [3:0] current_state; 
	 reg [3:0] next_state;	
	 

	 reg [31:0] counter=32'd0; 
 
	 // STATES
	 parameter [3:0] IDLE= 4'b0000;
	 parameter [3:0] PASS_ENT_3= 4'b0001;
	 parameter [3:0] PASS_ENT_2= 4'b0010;
	 parameter [3:0] PASS_ENT_1= 4'b0011;
	 parameter [3:0] LOCK = 4'b0100;
    parameter [3:0] ATM_MENU= 4'b0101;
	 parameter [3:0] MONEY= 4'b0110;
	 parameter [3:0] WARNING= 4'b0111;
	 parameter [3:0] PASS_CHG_3= 4'b1000;
	 parameter [3:0] PASS_CHG_2= 4'b1001;
	 parameter [3:0] PASS_CHG_1= 4'b1010;
	 parameter [3:0] PASS_NEW= 4'b1011;
	 


	 
	 // STATE TRANSITIONS - (sequential part)
	 //--------------------------------------------------------------------------- 
	 always@ (posedge clk or posedge rst)
	 begin
		if(rst==1)
		begin
			current_state<=IDLE;
		end
		else
			current_state<=next_state; 
	 end
	 
	 //---------------------------------------------------------------------------
	 


	//NEXT STATE DEFINITIONS - (combinatorial part)
	//--------------------------------------------------------------------------- 
	always @ (*)
	begin
				case(current_state)
				
					IDLE:
					begin
						if(BTN3==1) next_state=PASS_ENT_3;
						else next_state=IDLE;
					end
					
					
					
					PASS_ENT_3:
					begin
						if (BTN3==1) 
						begin
							if(password==SW) next_state=ATM_MENU;	
							else next_state=PASS_ENT_2;
						end
						else if (BTN1==1) next_state=IDLE;
						else next_state=PASS_ENT_3;
					end
					
					
					PASS_ENT_2:
					begin
						if (BTN1==1) next_state=IDLE; 
						else if (BTN1==0 && BTN3==1)
						begin
							if (SW==password) next_state=ATM_MENU;
							else next_state=PASS_ENT_1;
						end
						else next_state=PASS_ENT_2;
					end
					
					
					PASS_ENT_1:
					begin
						if(BTN1==1) next_state=IDLE; //regardless of SW
						else if (BTN3==1)
						begin
							if (password==SW) next_state=ATM_MENU;
							else next_state=LOCK;	
						end
						else next_state=PASS_ENT_1;
					end
					

					LOCK:
					begin

						if(counter==32'd100) next_state=IDLE;
						else next_state=LOCK;
					end

					
					
					ATM_MENU:
					begin
						if(BTN1==1) next_state=IDLE;
						else if (BTN3==1) next_state=MONEY;
						else if (BTN2==1) next_state=PASS_CHG_3;
						else next_state=ATM_MENU;
					
					end
					
					
					MONEY:
					begin
						if (BTN1==1) next_state=ATM_MENU;
						else if(BTN2==1)
						begin	
							if (balance>SW) next_state=MONEY;		
							else next_state=WARNING;				
						end
						else if (BTN3==1) next_state=MONEY;
						else next_state=MONEY;
					end
					
	
					WARNING:
					begin
						if(counter==32'd50) next_state=MONEY;
						else next_state=WARNING;
					end
	
					
					
					PASS_CHG_3:
					begin
						if (BTN1==1) next_state=ATM_MENU;
						else if (BTN3==1)
						begin
							if (password==SW) next_state=PASS_NEW;
							else next_state=PASS_CHG_2;						
						end
						else next_state=PASS_CHG_3;
					
					end
					
					
					PASS_CHG_2:
					begin
						if(BTN1==1) next_state=ATM_MENU;
						else if(BTN3==1)
						begin
							if(password==SW) next_state=PASS_NEW;
							else next_state=PASS_CHG_1;
						
						end
						else next_state=PASS_CHG_2;
					end
					
					PASS_CHG_1:
					begin
						if (BTN1==1) next_state=ATM_MENU;
						else if (BTN3==1)
						begin
							if (password==SW) next_state=PASS_NEW;
							else next_state=LOCK;
						end	
						else next_state=PASS_CHG_1;						
					end
					
					PASS_NEW:
					begin
						if (BTN3==1) next_state=ATM_MENU;
						else next_state=PASS_NEW;
					end
				endcase
	end
	
	
	


	// COUNTER FOR BLOCKING ATM IN LOCK AND WARNING - (sequential part)
	//--------------------------------------------------------------------------- 
	always @ (posedge clk or posedge rst)
	begin

				if (rst) counter<=0;
				else
				begin
					case (current_state)
						LOCK:
						begin
							if(counter==32'd100) counter<=32'd0;
							else counter<=counter+1;
						 
						end
						
						WARNING:
						begin
							if(counter==32'd50) counter<=32'd0;
							else counter<=counter+1;
						end
					endcase
				end
	end 	




	// OUTPUT PART - (combinatorial part)
	//--------------------------------------------------------------------------- 
	
	always @ (posedge clk or posedge rst)
	begin
			if(rst==1) 
			begin 
				balance<=16'b0000000000000000; // initial balnce 		
				password<=4'b0000;//initial password
				LED<=8'b10101010;
			end
			
			else
			begin
				case(current_state)
					IDLE: 
					begin
						LED <= 8'b00000001; 
						//for CArd
									//abcdefg		
						digit4<=7'b0110001; //C			
						digit3<=7'b0001000; //A	
						digit2<=7'b1111010; //r						
						digit1<=7'b1000010; //d
					
					end
					
					
					PASS_ENT_3:
					begin
						LED <= 8'b10000000; 
						// for PE-3
									//abcdefg		
						digit4<=7'b0011000; //P
						digit3<=7'b0110000; //E
						digit2<=7'b1111110; //-		
						digit1<=7'b0000110; //3
					end
					
					
					PASS_ENT_2: 
					begin
						LED <= 8'b11000000;
						//for PE-2
										//abcdefg					
						digit4<=7'b0011000; //P
						digit3<=7'b0110000; //E
						digit2<=7'b1111110; //-		
						digit1<=7'b0010010; //2	
					end
					
					
					PASS_ENT_1: 
					begin
						LED <= 8'b11100000;
						// for PE-1
									//abcdefg
						digit4<=7'b0011000; //P
						digit3<=7'b0110000; //E
						digit2<=7'b1111110; //-
						digit1<=7'b1001111; //1
					end
					
					
					LOCK:
					begin
						LED <= 8'b11111111; 
						// for FAIL
									//abcdefg
						digit4<=7'b0111000; //F
						digit3<=7'b0001000; //A
						digit2<=7'b1111001; //I	
						digit1<=7'b1110001; //L
					
					end
					
					
					ATM_MENU: 
					begin
						LED <= 8'b00010000; 
						// for OPEn
									//abcdefg
						digit4<=7'b0000001; //O
						digit3<=7'b0011000; //P
						digit2<=7'b0110000; //E
						digit1<=7'b1101010; //n
					
					end
					
					
					MONEY: 
					begin
						if (BTN3==1) balance<=balance+SW; 
						else if (BTN2==1) 
						begin
							if(balance> SW) balance<=balance-SW; //extra check
							else if (balance==SW) balance<=balance-SW;
							else balance<=balance;
						end
						
						LED <= 8'b00001000; 
						// for balance ->v ariable one (?)
									//abcdefg
						// digit4
						if (balance[15:12]==4'b0000) digit4<=7'b0000001; //0
						else if (balance[15:12]==4'b0001) digit4<=7'b1001111; //1	
						else if (balance[15:12]==4'b0010) digit4<=7'b0010010; //2	
						else if (balance[15:12]==4'b0011) digit4<=7'b0000110; //3	
						else if (balance[15:12]==4'b0100) digit4<=7'b1001100; //4 	
						else if (balance[15:12]==4'b0101) digit4<=7'b0100100; //5	
						else if (balance[15:12]==4'b0110) digit4<=7'b0100000; //6
						else if (balance[15:12]==4'b0111) digit4<=7'b0001101; //7
						else if (balance[15:12]==4'b1000) digit4<=7'b0000000; //8
						else if (balance[15:12]==4'b1001) digit4<=7'b0000100; //9
						else if (balance[15:12]==4'b1010) digit4<=7'b0001000; //10 - A
						else if (balance[15:12]==4'b1011) digit4<=7'b1100000; //11 - b
						else if (balance[15:12]==4'b1100) digit4<=7'b0110001; //12 - C	
						else if (balance[15:12]==4'b1101) digit4<=7'b1000010; //13 - d			
						else if (balance[15:12]==4'b1110) digit4<=7'b0110000; //14 - E	
						else if (balance[15:12]==4'b1111) digit4<=7'b0111000; //15 - F
						
						
						// digit3
						if (balance[11:8]==4'b0000) digit3<=7'b0000001; //0
						else if (balance[11:8]==4'b0001) digit3<=7'b1001111; //1
						else if (balance[11:8]==4'b0010) digit3<=7'b0010010; //2		
						else if (balance[11:8]==4'b0011) digit3<=7'b0000110; //3		
						else if (balance[11:8]==4'b0100) digit3<=7'b1001100; //4 	
						else if (balance[11:8]==4'b0101) digit3<=7'b0100100; //5
						
						else if (balance[11:8]==4'b0110) digit3<=7'b0100000; //6 
						else if (balance[11:8]==4'b0111) digit3<=7'b0001101; //7
						else if (balance[11:8]==4'b1000) digit3<=7'b0000000; //8
						else if (balance[11:8]==4'b1001) digit3<=7'b0000100; //9	
						else if (balance[11:8]==4'b1010) digit3<=7'b0001000; //10 - A	
						else if (balance[11:8]==4'b1011) digit3<=7'b1100000; //11 - b	
						else if (balance[11:8]==4'b1100) digit3<=7'b0110001; //12 - C	
						else if (balance[11:8]==4'b1101) digit3<=7'b1000010; //13 - d	
						else if (balance[11:8]==4'b1110) digit3<=7'b0110000; //14 - E	
						else if (balance[11:8]==4'b1111) digit3<=7'b0111000; //15 - F
						
						
						
						// digit2
						if (balance[7:4]==4'b0000) digit2<=7'b0000001; //0
						else if (balance[7:4]==4'b0001) digit2<=7'b1001111; //1
						else if (balance[7:4]==4'b0010) digit2<=7'b0010010; //2	
						else if (balance[7:4]==4'b0011) digit2<=7'b0000110; //3		
						else if (balance[7:4]==4'b0100) digit2<=7'b1001100; //4 
						else if (balance[7:4]==4'b0101) digit2<=7'b0100100; //5
						else if (balance[7:4]==4'b0110) digit2<=7'b0100000; //6	
						else if (balance[7:4]==4'b0111) digit2<=7'b0001101; //7	
						else if (balance[7:4]==4'b1000) digit2<=7'b0000000; //8		
						else if (balance[7:4]==4'b1001) digit2<=7'b0000100; //9	
						else if (balance[7:4]==4'b1010) digit2<=7'b0001000; //10 - A	
						else if (balance[7:4]==4'b1011) digit2<=7'b1100000; //11 - b	
						else if (balance[7:4]==4'b1100) digit2<=7'b0110001; //12 - C		
						else if (balance[7:4]==4'b1101) digit2<=7'b1000010; //13 - d			
						else if (balance[7:4]==4'b1110) digit2<=7'b0110000; //14 - E	
						else if (balance[7:4]==4'b1111) digit2<=7'b0111000; //15 - F
						
						
						// digit1
						if (balance[3:0]==4'b0000) digit1<=7'b0000001; //0
						else if (balance[3:0]==4'b0001) digit1<=7'b1001111; //1	
						else if (balance[3:0]==4'b0010) digit1<=7'b0010010; //2	
						else if (balance[3:0]==4'b0011) digit1<=7'b0000110; //3	
						else if (balance[3:0]==4'b0100) digit1<=7'b1001100; //4			
						else if (balance[3:0]==4'b0101) digit1<=7'b0100100; //5				
						else if (balance[3:0]==4'b0110) digit1<=7'b0100000; //6					
						else if (balance[3:0]==4'b0111) digit1<=7'b0001101; //7			
						else if (balance[3:0]==4'b1000) digit1<=7'b0000000; //8			
						else if (balance[3:0]==4'b1001) digit1<=7'b0000100; //9		
						else if (balance[3:0]==4'b1010) digit1<=7'b0001000; //10 - A		
						else if (balance[3:0]==4'b1011) digit1<=7'b1100000; //11 - b		
						else if (balance[3:0]==4'b1100) digit1<=7'b0110001; //12 - C			
						else if (balance[3:0]==4'b1101) digit1<=7'b1000010; //13 - d		
						else if (balance[3:0]==4'b1110) digit1<=7'b0110000; //14 - E		
						else if (balance[3:0]==4'b1111) digit1<=7'b0111000; //15 - F
						
					end
					
					
					WARNING:
					begin
						LED <= 8'b11111111; 
						// for -NA-
									//abcdefg
						digit4<=7'b1111110; //-
						digit3<=7'b1101010; //n
						digit2<=7'b0001000; //A						
						digit1<=7'b1111110; //-
					end
					
					
					PASS_CHG_3:
					begin
						LED <= 8'b00000100;
						// for PC-3
									//abcdefg
						digit4<=7'b0011000; //P
						digit3<=7'b0110001; //C
						digit2<=7'b1111110; //-		
						digit1<=7'b0000110; //3									
					end
					
					
					PASS_CHG_2:
					begin
						LED <= 8'b00000110; 
						//for PC-2
									//abcdefg
						digit4<=7'b0011000; //P
						digit3<=7'b0110001; //C
						digit2<=7'b1111110; //-		
						digit1<=7'b0010010; //2									
					end
					
					
					PASS_CHG_1: 
					begin
						LED <= 8'b00000111; 
						//for PC-1
									//abcdefg
						digit4<=7'b0011000; //P
						digit3<=7'b0110001; //C
						digit2<=7'b1111110; //-		
						digit1<=7'b1001111; //1	
					end
					
					
					PASS_NEW: 
					begin
					if(BTN3==1)password<=SW;
					LED <= 8'b00000010; 
					// for PASS
								//abcdefg
					digit4<=7'b0011000; //P
					digit3<=7'b0001000; //A
					digit2<=7'b0100100; //S
					digit1<=7'b0100100; //S
					end				
					
				endcase
				
			end
	end
	
endmodule