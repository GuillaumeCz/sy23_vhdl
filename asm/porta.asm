;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.equ IFLAG, 7
.equ TFLAG, 6
.equ HFLAG, 5
.equ SFLAG, 4
.equ VFLAG, 3
.equ NFLAG, 2
.equ ZFLAG, 1
.equ CFLAG, 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.equ IO_SREG,	0x3F
.equ IO_SPH,	0x3E
.equ IO_SPL,	0x3D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.equ IO_PORTA,	0x1B ; PORTA


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	rjmp setup ; vecteur reset en 0x0000
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption		
	rjmp noirq ; pas d'interruption		
	rjmp noirq ; pas d'interruption	
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption		
	rjmp noirq ; pas d'interruption		
	rjmp noirq ; pas d'interruption	
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption
	rjmp noirq ; pas d'interruption		
	rjmp noirq ; pas d'interruption		
	rjmp noirq ; pas d'interruption		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup defaults
setup:
	ldi R16,0x5f
	out IO_SPL,R16
	ldi R16,0x02
	out IO_SPH,R16
	clr R0
	out IO_SREG,R0
	ldi R17,0
loop:
	out	IO_PORTA,R17
	rcall d1
	inc R17
	rjmp loop
	
d1:
	ldi R21,0x20
s1:	rcall d2
	dec R21
	brne s1
	ret
	
d2:
	ldi R22,0xff
s2:	rcall d3
	dec R22
	brne s2
	ret	
	
d3:
	ldi R23,0xff
s3:	dec R23
	brne s3
	ret	

noirq:
	reti

.end
