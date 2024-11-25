; my own test case
; store 4 values into consecutive addresses in memory
; load them into v1

; clear all regular registers (k0, k1, k2, k3)
  sub k0,k0   ; clear k0
  sub k1,k1   ; clear k1
  sub k2,k2   ; clear k2
  sub k3,k3   ; clear k3

; store 1 into k3 to use as increment value
  ori 1        ; set k1 to 1
  add k3,k1   ; store the result in k3

; store the values 2, 5, 6, 9 into memory starting at address 120 (we dont want to collide with instruction memory)
  sub k1,k1   ; clear k1
  ori 30      ; set k1 to 30 first (base address)
  shiftl k1,2 ; multiply it by 4 to 120 
  add k0,k1   ; move base address into k0

  sub k1,k1   ; clear k1
  sub k2,k2   ; clear k2
  ori 2        ; set k1 to 2
  add k2,k1   ; move 2 into k2 (value to store)
  store k2,(k0) ; store 2 into address 30

  sub k1,k1   ; clear k1
  sub k2,k2   ; clear k2
  ori 5        ; set k1 to 5
  add k2,k1   ; move 5 into k2
  add k0,k3   ; increment k0 by 1 (k3 is set to 1)
  store k2,(k0) ; store 5 into address 31

  sub k1,k1   ; clear k1
  sub k2,k2   ; clear k2
  ori 6        ; set k1 to 6
  add k2,k1   ; move 6 into k2
  add k0,k3   ; increment k0 by 1
  store k2,(k0) ; store 6 into address 32

  sub k1,k1   ; clear k1
  sub k2,k2   ; clear k2
  ori 9        ; set k1 to 9
  add k2,k1   ; move 9 into k2
  add k0,k3   ; increment k0 by 1
  store k2,(k0) ; store 9 into address 33

; stop ; at this point, k0 = 123, k1 = 9, k2 = 9, k3 = 1

; load vector of 4 elements starting with address 120 into vector register v0 and v1
  sub k0,k0     ; clear k0
  sub k1,k1     ; clear k1
  ori 30        ; set k1 to 30 first (base address)
  shiftl k1,2   ; multiply it by 4 to 120 
  vload v0,(k1) ; load vector from address 120 into v0
  vload v1,(k1) ; load vector from address 120 into v1

; perform two vector additions
  vadd v0,v1  ; the result will be in v0
  vadd v0,v1  ; perform addition again

; store result back to memory
  vstore v0,(k1)

; load the same memory content back to the regular register files so we can check its content
  load k0,(k1)
  add k1,k3
  load k2,(k1)
  add k1,k3
  load k0,(k1)
  add k1,k3
  load k2,(k1)

; stop (program termination)
  stop