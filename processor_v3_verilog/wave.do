onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /multicycle_tb/reset
add wave -noupdate /multicycle_tb/clock
add wave -radix hexadecimal sim:/multicycle_tb/DUT/DataMem/address
add wave -radix hexadecimal sim:/multicycle_tb/DUT/DataMem/data
add wave -radix hexadecimal sim:/multicycle_tb/DUT/DataMem/q
add wave sim:/multicycle_tb/DUT/DataMem/MemRead
add wave sim:/multicycle_tb/DUT/DataMem/wren
add wave -radix hexadecimal sim:/multicycle_tb/DUT/PC/data
add wave -radix hexadecimal sim:/multicycle_tb/DUT/IR_reg/data
add wave -radix unsigned sim:/multicycle_tb/DUT/Control/state
add wave -radix hexadecimal sim:/multicycle_tb/DUT/RF_block/k0
add wave -radix hexadecimal sim:/multicycle_tb/DUT/RF_block/k1
add wave -radix hexadecimal sim:/multicycle_tb/DUT/RF_block/k2
add wave -radix hexadecimal sim:/multicycle_tb/DUT/RF_block/k3
add wave -radix decimal sim:/multicycle_tb/DUT/Control/counter
add wave -radix hexadecimal sim:/multicycle_tb/DUT/R2/q
add wave sim:/multicycle_tb/DUT/R2Sel_mux/sel
add wave -radix hexadecimal sim:/multicycle_tb/DUT/VRF_block/k0
add wave -radix hexadecimal sim:/multicycle_tb/DUT/VRF_block/k1
add wave -radix hexadecimal sim:/multicycle_tb/DUT/VRF_block/k2
add wave -radix hexadecimal sim:/multicycle_tb/DUT/VRF_block/k3
add wave -radix hexadecimal sim:/multicycle_tb/DUT/T0/q
add wave -radix hexadecimal sim:/multicycle_tb/DUT/T1/q
add wave -radix hexadecimal sim:/multicycle_tb/DUT/T2/q
add wave -radix hexadecimal sim:/multicycle_tb/DUT/T3/q
add wave -noupdate -divider {Hex Display}
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in0
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in1
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in2
add wave -noupdate -radix hexadecimal /multicycle_tb/DUT/HEX_display/in3
add wave -noupdate -divider {multicycle.v inputs}
add wave -noupdate /multicycle_tb/KEY
add wave -noupdate /multicycle_tb/SW
add wave -noupdate -divider {multicycle.v outputs}
add wave -noupdate /multicycle_tb/LEDG
add wave -noupdate /multicycle_tb/LEDR
add wave -noupdate /multicycle_tb/HEX0
add wave -noupdate /multicycle_tb/HEX1
add wave -noupdate /multicycle_tb/HEX2
add wave -noupdate /multicycle_tb/HEX3
add wave -noupdate /multicycle_tb/HEX4
add wave -noupdate /multicycle_tb/HEX5
add wave -noupdate /multicycle_tb/HEX6
add wave -noupdate /multicycle_tb/HEX7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2500 ns} 0}
configure wave -namecolwidth 227
configure wave -valuecolwidth 57
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2500 ns}
add wave -position 21  -radix hexadecimal sim:/multicycle_tb/DUT/T0_mux/data1x
add wave -position 22  sim:/multicycle_tb/DUT/T0_mux/sel
add wave -position 23  -radix hexadecimal sim:/multicycle_tb/DUT/T0_mux/result