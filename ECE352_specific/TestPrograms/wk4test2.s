; Week 4, Test Program 2
; Andrew House, TA, ECE352
;
; This program simply tests the bz instruction, plus handling of
; control and data hazards.  The branch is taken so long as the difference
; of k3 and k0 is zero. k3 is (sort of) generated by an or with k1, which starts
; at 1 and gets multiplied by 2 every loop iteration, so that on the fifth
; iteration the loop should exit.
;
; Final result should be:
; k0: 0f   k1: c0    k2: 00    k3: 10
;
;
	sub	k1,k1	; clear k0 and k1 and k3
	sub	k0,k0
	sub	k3,k3

	ori	15	; load 15 into k1
	add	k0,k1	; set k0 to 15

	sub	k1,k1	; clear k1
	ori	1	; set k1 to 1
	nand	k1,k1	; prepare k1 for use in OR 

loop1 add	k3,k0 ; copy k0 to k3
	nand	k3,k3 ; invert it
	nand	k3,k1	; nand with previously inverted k1, k3 should now be k1 OR k3
	shiftl	k1,1	; shift value in k1 left by 1
	sub	k3,k0	; subtract k0 from k3
	bz	loop1	; loop while the subtraction results in 0

	nop
	nop
	nop
	stop
	nop
	nop
	nop
	nop
	nop

