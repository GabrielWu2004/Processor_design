// ---------------------------------------------------------------------
// Copyright (c) 2007 by University of Toronto ECE 243 development team 
// ---------------------------------------------------------------------
//
// Major Functions:	a simple processor which operates basic mathematical
//					operations as follow:
//					(1)loading, (2)storing, (3)adding, (4)subtracting,
//					(5)shifting, (6)oring, (7)branch if zero,
//					(8)branch if not zero, (9)branch if positive zero
//					 
// Input(s):		1. KEY0(reset): clear all values from registers,
//									reset flags condition, and reset
//									control FSM
//					2. KEY1(clock): manual clock controls FSM and all
//									synchronous components at every
//									positive clock edge
//
//
// Output(s):		1. HEX Display: display registers value K3 to K1
//									in hexadecimal format
//
//					** For more details, please refer to the document
//					   provided with this implementation
//
// ---------------------------------------------------------------------

module multicycle
(
SW, KEY, HEX0, HEX1, HEX2, HEX3,
HEX4, HEX5, LEDR
);

// ------------------------ PORT declaration ------------------------ //
input	[1:0] KEY;
input [4:0] SW;
output	[6:0] HEX0, HEX1, HEX2, HEX3;
output	[6:0] HEX4, HEX5;
output reg [17:0] LEDR;

// ------------------------- Registers/Wires ------------------------ //
wire	clock, reset;
wire	IRLoad, MDRLoad, MemRead, MemWrite, PCWrite, RegIn, AddrSel;
wire	ALU1, ALUOutWrite, FlagWrite, R1R2Load, R1Sel, R2Sel, RFWrite;
wire 	VRFWrite, X1X2Load, VoutSel, T0Load, T1Load, T2Load, T3Load;
wire	[31:0] VRFout1wire, VRFout2wire, VDataInWire;
wire	[31:0] vreg0, vreg1, vreg2, vreg3, X1Wire, X2Wire;
wire	[7:0] R2wire, PCwire, R1wire, RFout1wire, RFout2wire;
wire	[7:0] ALU1wire, ALU2wire, ALUwire, ALUOut, MDRwire, MEMwire;
wire	[7:0] IR, SE4wire, ZE5wire, ZE3wire, AddrWire, RegWire;
wire	[7:0] reg0, reg1, reg2, reg3;
wire	[7:0] disp0, disp1, disp2, disp3;
wire	[7:0] constant;
wire	[7:0] VA0wire, VA1wire, VA2wire, VA3wire;
wire	[7:0] VMux0wire, VMux1wire, VMux2wire, VMux3wire;
wire	[7:0] VDataInWire0, VDataInWire1, VDataInWire2, VDataInWire3;
wire	[7:0] MEMIn_wire;
wire	[2:0] ALUOp, ALU2;
wire	[2:0] MemIn;
wire	[1:0] R1_in;
wire	[15:0] counter;
wire	[7:0] counter_upper, counter_lower;
wire	Nwire, Zwire;
reg		N, Z;

// ------------------------ Input Assignment ------------------------ //
assign	clock = KEY[1];
assign	reset =  ~KEY[0]; // KEY is active high


// ------------------- DE2 compatible HEX display ------------------- //

assign counter_upper = counter[15:8];
assign counter_lower = counter[7:0];

HEXs	HEX_display(
	.in0(IR),.in1(IR),.in2(counter_upper),.in3(counter_lower),.selH(SW[2]),
	.out0(HEX0),.out1(HEX1),.out2(HEX2),.out3(HEX3),
	.out4(HEX4),.out5(HEX5)
);
// ----------------- END DE2 compatible HEX display ----------------- //

/*
// ------------------- DE1 compatible HEX display ------------------- //
chooseHEXs	HEX_display(
	.in0(reg0),.in1(reg1),.in2(reg2),.in3(reg3),
	.out0(HEX0),.out1(HEX1),.select(SW[1:0])
);
// turn other HEX display off
assign HEX2 = 7'b1111111;
assign HEX3 = 7'b1111111;
assign HEX4 = 7'b1111111;
assign HEX5 = 7'b1111111;
assign HEX6 = 7'b1111111;
assign HEX7 = 7'b1111111;
// ----------------- END DE1 compatible HEX display ----------------- //
*/

FSM		Control(
	.reset(reset),.clock(clock),.N(N),.Z(Z),.instr(IR[3:0]),
	.PCwrite(PCWrite),.AddrSel(AddrSel),.MemRead(MemRead),.MemWrite(MemWrite),
	.IRload(IRLoad),.R1Sel(R1Sel),.MDRload(MDRLoad),.R1R2Load(R1R2Load), .R2Sel(R2Sel),
	.ALU1(ALU1),.ALUOutWrite(ALUOutWrite),.RFWrite(RFWrite),.RegIn(RegIn),
	.FlagWrite(FlagWrite),.ALU2(ALU2),.ALUop(ALUOp), .counter(counter), 
	.VRFWrite(VRFWrite), .X1X2Load(X1X2Load), .VoutSel(VoutSel), 
	.T0Load(T0Load), .T1Load(T1Load), .T2Load(T2Load), .T3Load(T3Load), .MemIn(MemIn)
);

memory	DataMem(
	.MemRead(MemRead),.wren(MemWrite),.clock(clock),
	.address(AddrWire),.data(MEMIn_wire),.q(MEMwire)
);

ALU		ALU(
	.in1(ALU1wire),.in2(ALU2wire),.out(ALUwire),
	.ALUOp(ALUOp),.N(Nwire),.Z(Zwire)
);

ALU		VADDER0(
	.in1(X1Wire[7:0]), .in2(X2Wire[7:0]), .out(VA0wire),
	.ALUOp(3'b000), .N(1'bz), .Z(1'bz)
);

ALU		VADDER1(
	.in1(X1Wire[15:8]), .in2(X2Wire[15:8]), .out(VA1wire),
	.ALUOp(3'b000), .N(1'bz), .Z(1'bz)
);

ALU		VADDER2(
	.in1(X1Wire[23:16]), .in2(X2Wire[23:16]), .out(VA2wire),
	.ALUOp(3'b000), .N(1'bz), .Z(1'bz)
);

ALU		VADDER3(
	.in1(X1Wire[31:24]), .in2(X2Wire[31:24]), .out(VA3wire),
	.ALUOp(3'b000), .N(1'bz), .Z(1'bz)
);

RF		RF_block(
	.clock(clock),.reset(reset),.RFWrite(RFWrite),
	.dataw(RegWire),.reg1(R1_in),.reg2(IR[5:4]),
	.regw(R1_in),.data1(RFout1wire),.data2(RFout2wire),
	.r0(reg0),.r1(reg1),.r2(reg2),.r3(reg3)
);

VRF		VRF_block(
	.clock(clock), .reset(reset), .VRFWrite(VRFWrite),
	.vdataw(VDataInWire), .vreg1(IR[7:6]), .vreg2(IR[5:4]),
	.vregw(IR[7:6]), .vdata1(VRFout1wire), .vdata2(VRFout2wire),
	.vr0(vreg0), .vr1(vreg1), .vr2(vreg2), .vr3(vreg3)
);

assign VDataInWire = {VDataInWire0, VDataInWire1, VDataInWire2, VDataInWire3};

register_32bit X1(
	.clock(clock), .aclr(reset), .enable(X1X2Load),
	.data(VRFout1wire), .q(X1Wire)
);

register_32bit X2(
	.clock(clock), .aclr(reset), .enable(X1X2Load),
	.data(VRFout2wire), .q(X2Wire)
);

register_8bit T0(
	.clock(clock), .aclr(reset), .enable(T0Load),
	.data(VMux0wire), .q(VDataInWire0)
);

register_8bit T1(
	.clock(clock), .aclr(reset), .enable(T1Load),
	.data(VMux1wire), .q(VDataInWire1)
);

register_8bit T2(
	.clock(clock), .aclr(reset), .enable(T2Load),
	.data(VMux2wire), .q(VDataInWire2)
);

register_8bit T3(
	.clock(clock), .aclr(reset), .enable(T3Load),
	.data(VMux3wire), .q(VDataInWire3)
);

register_8bit	IR_reg(
	.clock(clock),.aclr(reset),.enable(IRLoad),
	.data(MEMwire),.q(IR)
);

register_8bit	MDR_reg(
	.clock(clock),.aclr(reset),.enable(MDRLoad),
	.data(MEMwire),.q(MDRwire)
);

register_8bit	PC(
	.clock(clock),.aclr(reset),.enable(PCWrite),
	.data(ALUwire),.q(PCwire)
);

register_8bit	R1(
	.clock(clock),.aclr(reset),.enable(R1R2Load),
	.data(RFout1wire),.q(R1wire)
);

register_8bit	R2(
	.clock(clock),.aclr(reset),.enable(R1R2Load),
	.data(RFout2wire),.q(R2wire)
);

register_8bit	ALUOut_reg(
	.clock(clock),.aclr(reset),.enable(ALUOutWrite),
	.data(ALUwire),.q(ALUOut)
);

mux2to1_2bit		R1Sel_mux(
	.data0x(IR[7:6]),.data1x(constant[1:0]),
	.sel(R1Sel),.result(R1_in)
);

mux2to1_8bit 		AddrSel_mux(
	.data0x(R2wire),.data1x(PCwire),
	.sel(AddrSel),.result(AddrWire)
);

mux2to1_8bit 		RegMux(
	.data0x(ALUOut),.data1x(MDRwire),
	.sel(RegIn),.result(RegWire)
);

mux2to1_8bit 		ALU1_mux(
	.data0x(PCwire),.data1x(R1wire),
	.sel(ALU1),.result(ALU1wire)
);

mux2to1_8bit 		VMux0(
	.data0x(VA0wire), .data1x(MEMWire),
	.sel(VoutSel), .result(VMux0wire)
);

mux2to1_8bit 		VMux1(
	.data0x(VA1wire), .data1x(MEMWire),
	.sel(VoutSel), .result(VMux1wire)
);

mux2to1_8bit 		VMux2(
	.data0x(VA2wire), .data1x(MEMWire),
	.sel(VoutSel), .result(VMux2wire)
);

mux2to1_8bit 		VMux3(
	.data0x(VA3wire), .data1x(MEMWire),
	.sel(VoutSel), .result(VMux3wire)
);

mux5to1_8bit 		ALU2_mux(
	.data0x(R2wire),.data1x(constant),.data2x(SE4wire),
	.data3x(ZE5wire),.data4x(ZE3wire),.sel(ALU2),.result(ALU2wire)
);

mux5to1_8bit		MEMIn_mux(
	.data0x(X1Wire[7:0]), .data1x(X1Wire[15:8]), .data2x(X1Wire[23:16]),
	.data3x(X1Wire[31:24]), .data4x(R1wire), .sel(MemIn), .result(MEMIn_wire)
);

sExtend		SE4(.in(IR[7:4]),.out(SE4wire));
zExtend		ZE3(.in(IR[5:3]),.out(ZE3wire));
zExtend		ZE5(.in(IR[7:3]),.out(ZE5wire));
// define parameter for the data size to be extended
defparam	SE4.n = 4;
defparam	ZE3.n = 3;
defparam	ZE5.n = 5;

always@(posedge clock or posedge reset)
begin
if (reset)
	begin
	N <= 0;
	Z <= 0;
	end
else
if (FlagWrite)
	begin
	N <= Nwire;
	Z <= Zwire;
	end
end

// ------------------------ Assign Constant 1 ----------------------- //
assign	constant = 1;

// ------------------------- LEDs Indicator ------------------------- //
always @ (*)
begin

    case({SW[4],SW[3]})
    2'b00:
    begin
      LEDR[9] = 0;
      LEDR[8] = 0;
      LEDR[7] = PCWrite;
      LEDR[6] = AddrSel;
      LEDR[5] = MemRead;
      LEDR[4] = MemWrite;
      LEDR[3] = IRLoad;
      LEDR[2] = R1Sel;
      LEDR[1] = MDRLoad;
      LEDR[0] = R1R2Load;
    end

    2'b01:
    begin
      LEDR[9] = ALU1;
      LEDR[8:6] = ALU2[2:0];
      LEDR[5:3] = ALUOp[2:0];
      LEDR[2] = ALUOutWrite;
      LEDR[1] = RFWrite;
      LEDR[0] = RegIn;
    end

    2'b10:
    begin
      LEDR[9] = 0;
      LEDR[8] = 0;
      LEDR[7] = FlagWrite;
      LEDR[6:2] = constant[7:3];
      LEDR[1] = N;
      LEDR[0] = Z;
    end

    2'b11:
    begin
      LEDR[9:0] = 10'b0;
    end
  endcase
end
endmodule