// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	control processor's datapath
// 
// Input(s):	1. instr: input is used to determine states
//				2. N: if branches, input is used to determine if
//					  negative condition is true
//				3. Z: if branches, input is used to determine if 
//					  zero condition is true
//
// Output(s):	control signals
//
//				** More detail can be found on the course note under
//				   "Multi-Cycle Implementation: The Control Unit"
//
// ---------------------------------------------------------------------

module FSM
(
reset, instr, clock,
N, Z,
PCwrite, AddrSel, MemRead,
MemWrite, IRload, R1Sel, MDRload,
R1R2Load, R2Sel, ALU1, ALU2, ALUop,
ALUOutWrite, RFWrite, RegIn, FlagWrite, counter,
VRFWrite, X1X2Load, VoutSel, T0Load, T1Load, T2Load, T3Load, MemIn
);
	input	[3:0] instr;
	input	N, Z;
	input	reset, clock;
	output	PCwrite, AddrSel, MemRead, MemWrite, IRload, R1Sel, MDRload;
	output	R1R2Load, R2Sel, ALU1, ALUOutWrite, RFWrite, RegIn, FlagWrite;
	output	[2:0] ALU2, ALUop;
	output	[15:0] counter;
	output VRFWrite, X1X2Load, VoutSel, T0Load, T1Load, T2Load, T3Load;
	output [2:0] MemIn;
	
	reg [4:0]	state;
	reg	PCwrite, AddrSel, MemRead, MemWrite, IRload, R1Sel, MDRload;
	reg	R1R2Load, R2Sel, ALU1, ALUOutWrite, RFWrite, RegIn, FlagWrite;
	reg	[2:0] ALU2, ALUop;
	reg [15:0] counter;
	reg VRFWrite, X1X2Load, VoutSel, T0Load, T1Load, T2Load, T3Load;
	reg [2:0] MemIn;
	
	
	// state constants (note: asn = add/sub/nand, asnsh = add/sub/nand/shift)
	parameter [4:0] reset_s = 0, c1 = 1, c2 = 2, c3_asn = 3,
					c4_asnsh = 4, c3_shift = 5, c3_ori = 6,
					c4_ori = 7, c5_ori = 8, c3_load = 9, c4_load = 10,
					c3_store = 11, c3_bpz = 12, c3_bz = 13, c3_bnz = 14, 
					c3_stop = 15, c3_vload = 16, c4_vload = 17, c5_vload = 18, 
					c6_vload = 19, c7_vload = 20, c3_vstore = 21, c4_vstore = 22,
					c5_vstore = 23, c6_vstore = 24, c3_vadd = 25, c4_vadd = 26;
	
	// determines the next state based upon the current state; supports
	// asynchronous reset
	always @(posedge clock or posedge reset)
	begin
		if (reset)
		begin
			state = reset_s;
			counter = 0;
		end
		else
		begin
			if (state != c3_stop) counter <= counter + 1;
			case(state)
				reset_s:	state = c1; 		// reset state
				c1:			state = c2; 		// cycle 1
				c2:			begin				// cycle 2
								if(instr == 4'b0100 | instr == 4'b0110 | instr == 4'b1000) state = c3_asn;
								else if( instr[2:0] == 3'b011 ) state = c3_shift;
								else if( instr[2:0] == 3'b111 ) state = c3_ori;
								else if( instr == 4'b0000 ) state = c3_load;
								else if( instr == 4'b0010 ) state = c3_store;
								else if( instr == 4'b1101 ) state = c3_bpz;
								else if( instr == 4'b0101 ) state = c3_bz;
								else if( instr == 4'b1001 ) state = c3_bnz;
								else if( instr == 4'b0001 ) state = c3_stop;
								// else if( instr == 4'b1010 ) state = c1; // nop
								else if( instr == 4'b1010 ) state = c3_vload;
								else if( instr == 4'b1100 ) state = c3_vstore;
								else if( instr == 4'b1110 ) state = c3_vadd;
								else state = 0;
							end
				c3_asn:		state = c4_asnsh;	// cycle 3: ADD SUB NAND
				c4_asnsh:	state = c1;			// cycle 4: ADD SUB NAND/SHIFT
				c3_shift:	state = c4_asnsh;	// cycle 3: SHIFT
				c3_ori:		state = c4_ori;		// cycle 3: ORI
				c4_ori:		state = c5_ori;		// cycle 4: ORI
				c5_ori:		state = c1;			// cycle 5: ORI
				c3_load:	state = c4_load;	// cycle 3: LOAD
				c4_load:	state = c1; 		// cycle 4: LOAD
				c3_store:	state = c1; 		// cycle 3: STORE
				c3_bpz:		state = c1; 		// cycle 3: BPZ
				c3_bz:		state = c1; 		// cycle 3: BZ
				c3_bnz:		state = c1; 		// cycle 3: BNZ
				c3_stop:	state = c3_stop;// cycle 3: stop. Continue to be in the stop state
				c3_vload:	state = c4_vload;
				c4_vload: state = c5_vload;
				c5_vload: state = c6_vload;
				c6_vload: state = c7_vload;
				c7_vload: state = c1;
				c3_vstore:	state = c4_vstore;
				c4_vstore:	state = c5_vstore;
				c5_vstore:	state = c6_vstore;
				c6_vstore:	state = c1;
				c3_vadd:	state = c4_vadd;
				c4_vadd:	state = c1;
			endcase
		end
	end

	// sets the control sequences based upon the current state and instruction
	always @(*)
	begin
		case (state)
			reset_s:	//control = 19'b0000000000000000000;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end					
			c1: 		//control = 19'b1110100000010000000;
				begin
					PCwrite = 1;
					AddrSel = 1;
					MemRead = 1;
					MemWrite = 0;
					IRload = 1;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b001;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end	
			c2: 		//control = 19'b0000000100000000000;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 1;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 1;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_asn:		begin
							if ( instr == 4'b0100 ) 		// add
								//control = 19'b0000000010000001001;
							begin
								PCwrite = 0;
								AddrSel = 0;
								MemRead = 0;
								MemWrite = 0;
								IRload = 0;
								R1Sel = 0;
								MDRload = 0;
								R1R2Load = 0;
								ALU1 = 1;
								ALU2 = 3'b000;
								ALUop = 3'b000;
								ALUOutWrite = 1;
								RFWrite = 0;
								RegIn = 0;
								FlagWrite = 1;
								R2Sel = 0;
								VRFWrite = 0;
								X1X2Load = 0;
								VoutSel = 0;
								T0Load = 0;
								T1Load = 0;
								T2Load = 0;
								T3Load = 0;
								MemIn = 3'b000;
							end	
							else if ( instr == 4'b0110 ) 	// sub
								//control = 19'b0000000010000011001;
							begin
								PCwrite = 0;
								AddrSel = 0;
								MemRead = 0;
								MemWrite = 0;
								IRload = 0;
								R1Sel = 0;
								MDRload = 0;
								R1R2Load = 0;
								ALU1 = 1;
								ALU2 = 3'b000;
								ALUop = 3'b001;
								ALUOutWrite = 1;
								RFWrite = 0;
								RegIn = 0;
								FlagWrite = 1;
								R2Sel = 0;
								VRFWrite = 0;
								X1X2Load = 0;
								VoutSel = 0;
								T0Load = 0;
								T1Load = 0;
								T2Load = 0;
								T3Load = 0;
								MemIn = 3'b000;
							end
							else 							// nand
								//control = 19'b0000000010000111001;
							begin
								PCwrite = 0;
								AddrSel = 0;
								MemRead = 0;
								MemWrite = 0;
								IRload = 0;
								R1Sel = 0;
								MDRload = 0;
								R1R2Load = 0;
								ALU1 = 1;
								ALU2 = 3'b000;
								ALUop = 3'b011;
								ALUOutWrite = 1;
								RFWrite = 0;
								RegIn = 0;
								FlagWrite = 1;
								R2Sel = 0;
								VRFWrite = 0;
								X1X2Load = 0;
								VoutSel = 0;
								T0Load = 0;
								T1Load = 0;
								T2Load = 0;
								T3Load = 0;
								MemIn = 3'b000;
							end
				   		end
			c4_asnsh: 	//control = 19'b0000000000000000100;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 1;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_shift: 	//control = 19'b0000000011001001001;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 1;
					ALU2 = 3'b100;
					ALUop = 3'b100;
					ALUOutWrite = 1;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 1;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_ori: 	//control = 19'b0000010100000000000;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 1;
					MDRload = 0;
					R1R2Load = 1;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c4_ori: 	//control = 19'b0000000010110101001;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 1;
					ALU2 = 3'b011;
					ALUop = 3'b010;
					ALUOutWrite = 1;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 1;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c5_ori: 	//control = 19'b0000010000000000100;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 1;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 1;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_load: 	//control = 19'b0010001000000000000;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 1;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 1;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c4_load: 	//control = 19'b0000000000000001110;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 1;
					RFWrite = 1;
					RegIn = 1;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_store: 	//control = 19'b0001000000000000000;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 1;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b100;
				end
			c3_bpz: 	//control = {~N,18'b000000000100000000};
				begin
					PCwrite = ~N;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b010;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_bz: 		//control = {Z,18'b000000000100000000};
				begin
					PCwrite = Z;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b010;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_bnz: 	//control = {~Z,18'b000000000100000000};
				begin
					PCwrite = ~Z;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b010;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_stop: 	//control = {};
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c3_vload:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 1;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 1;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 1;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 1;
					T0Load = 1;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c4_vload:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 1;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 1;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 1;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 1;
					T0Load = 0;
					T1Load = 1;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c5_vload:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 1;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 1;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 1;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 1;
					T0Load = 0;
					T1Load = 0;
					T2Load = 1;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c6_vload:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 1;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 1;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 1;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 1;
					MemIn = 3'b000;
				end
			c7_vload:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 1;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 1;
					MemIn = 3'b000;
				end
			c3_vstore:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 1;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 1;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 1;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			c4_vstore:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 1;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 1;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 1;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b001;
				end
			c5_vstore:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 1;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 1;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 1;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b010;
				end
			c6_vstore:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 1;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b011;
				end
			c3_vadd:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 1;
					T1Load = 1;
					T2Load = 1;
					T3Load = 1;
					MemIn = 3'b000;
				end
			c4_vadd:
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 1;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
			default:	//control = 19'b0000000000000000000;
				begin
					PCwrite = 0;
					AddrSel = 0;
					MemRead = 0;
					MemWrite = 0;
					IRload = 0;
					R1Sel = 0;
					MDRload = 0;
					R1R2Load = 0;
					ALU1 = 0;
					ALU2 = 3'b000;
					ALUop = 3'b000;
					ALUOutWrite = 0;
					RFWrite = 0;
					RegIn = 0;
					FlagWrite = 0;
					R2Sel = 0;
					VRFWrite = 0;
					X1X2Load = 0;
					VoutSel = 0;
					T0Load = 0;
					T1Load = 0;
					T2Load = 0;
					T3Load = 0;
					MemIn = 3'b000;
				end
		endcase
	end
	
endmodule
