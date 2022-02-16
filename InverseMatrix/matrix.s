	AREA matrix,CODE,READONLY
		ENTRY
start

	LDR r11,=Matrix_data     ;(R10)
	LDR r10,tempaddr
	LDR sp,tempaddr2
	LDR r0,[r11],#4 ; size   (R0)
	MOV r1,r0
	MOV lr,pc
	B calculate_size
	MOV r12,r0
	MOV lr,pc
	B get_line_byte
	MOV r1,r0
	MOV r3,#0
	MOV r4,#0
	LDR r11,=Matrix_data
	LDR r0,[r11],#4 ; size   (R0)
	MOV lr,pc
	B store_data
	MOV r1,r0
	LDR r10,tempaddr
	MOV r3,r0
	ADD r10,r10,r9
	ADD r6,r9,r9
initialize_inverse_matrix
	LDR r5,=0x3f800000
	STR r5,[r10],r6
	ADD r10,r10,#4
	SUB r3,r3,#1
	CMP r3,#0
	BNE initialize_inverse_matrix
	
	;initialize
	LDR r12,tempaddr    ;;;;;;;;;;;;;;(R12) current line
	LDR r11,tempaddr    ;;;;;;;;;;;; (R11) matrix address
	MOV r10,r0          ;;;;;;;;;;;; (R10) size-1
	SUB r10,r10,#1
	ADD r8,r9,r9           ;;;;;;;;;;;; (R9)  size*2-1
	SUB r9,r9,#1
	ADD r9,r0,r0          ;;;;;;;;;;;; (R8)  line byte*2
	SUB r9,r9,#1
	MOV r7,#0 ;;;;;;;;;;;;;;;; (R7=i) big loop
	MOV r4,#0
	 STMFA sp!,{r4-r12}
big_loop
	LDMFA sp!,{r4-r12}
	MOV r6,#0 ;;;;;;;;;;;;;;;;;j
	MOV r5,#0 ;;;;;;;;;;;      k
	LDR r11,tempaddr
	ADD r1,r10,#1
	MOV r3,#0	
set_t CMP r3,r7
	  ADDNE r11,r11,r8
	  ADDNE r11,r11,#4
	  ADDNE r3,r3,#1
	  BNE set_t
	  LDR r4,[r11]
	  LDR r11,tempaddr
	  MOV r6,#0          ;j=i
set_i_j 
	  CMP r6,r7
	  ADDNE r6,r6,#1
	  ADDNE r11,r11,r8
	  ADDNE r11,r11,#4
	  BNE set_i_j
	  STMFA sp!,{r4-r12}
	  
	  CMP r4,#0
	  BNE loop1
	  MOV lr,pc
	  B line_exchange 
	  LDMFA sp!,{r4-r12}
	  MOV r4,r0
	  STMFA sp!,{r4-r12}
	  B loop1
	  
line_exchange 
	MOV r0,#0
	LDR r1,tempaddr
	MOV r3,r7
go_n_i 
	 CMP r3,#0
	 ADDNE r1,r1,#4
	 BNE go_n_i
	 
go_k_i
	 ADD r1,r1,r8  ;changed t=r1
	 LDR r2,[r1]
	 ADD r0,r0,#1
	 CMP r2,#0
	 MOVNE r0,r2
	 BEQ go_k_i
	 
	LDR r4,tempaddr
	MOV r5,#0
	MOV r3,#0
go_i_0 CMP r5,r7         ;r4=i address
	   ADDNE r4,r4,r8
	   BNE go_i_0
	 MOV r6,r1 ;;;;;;;;;r6=k address
go_k_0 CMP r3,r7
	   SUBNE r6,r6,#4
	   BNE go_k_0
	   MOV r3,r9
change LDR r2,[r4]
	   LDR r5,[r6]
	   STR r5,[r4],#4
	   STR r2,[r6],#4
	   CMP r3,#0
	   SUBNE r3,r3,#1
	   BNE change
	   MOV pc,lr
	 
	

loop1 
	 LDMFA sp!,{r4-r12}
	 LDR r2,[r11]
	 MOV r1,r4
	 STMFA sp!,{r4-r12}
	 CMP r2,#0
	 MOVNE lr,pc
	 BNE divi
	 LDMFA sp!,{r4-r12}
	 STR r2,[r11],#4
	 CMP r6,r9
	 ADDNE r6,r6,#1
	 STMNEFA sp!,{r4-r12}
	 BNE loop1
	 MOVEQ r6,#0
	 
	 B loop2
	 
	 
	  
loop2 CMP r7,r6
	  ADDEQ r6,r6,#1
	  BEQ loop2
	  MOV r1,#0
	  ADD r0,r10,r10
	  ADD r0,r0,#1
	  ADD r1,r7,r6
	  CMP r0,r1 ;;;finish
	  BEQ finish_matrix
	  LDR r11,tempaddr
	  MOV r0,r11
	  MOV r1,r6
	  
	  
set_t_row 
	CMP r1,#0
	SUBNE r1,r1,#1
    ADDNE r0,r0,r8
	BNE set_t_row
	MOV r1,r7
set_t_col 
	CMP r1,#0
	SUBNE r1,r1,#1
	ADDNE r0,r0,#4
	BNE set_t_col
	LDR r4,[r0]              ;;;;;;;;;;;;;;;r4=t
	STMFA sp!,{r4-r12}
	MOV r0,r11
	MOV r1,r7   ;;;;  i 
set_i_k   
	CMP r1,#0
	SUBNE r1,r1,#1
	ADDNE r0,r0,r8
	BNE set_i_k	
	MOV r3,r0          ;;;;;;;;;;;;;;; i_k address     r3
	MOV r0,r11
	MOV r1,r6   ;;;;  i 
set_j_k  
	CMP r1,#0
	SUBNE r1,r1,#1
	ADDNE r0,r0,r8
	BNE set_j_k
	
	MOV r12,r0               ;;;;;;;;;;;;;; j_k address  r12
	STMFA sp!,{r3-r12}

loop3
	LDMFA sp!,{r3-r12}
	MOV r1,r4
	LDR r2,[r3],#4
	STMFA sp!,{r3-r12}
	CMP r2,#0
	MOVNE lr,pc
	BNE mult
	LDMFA sp!,{r3-r12}
	LDR r1,[r12]
	STMFA sp!,{r3-r12}
	EOR r2,#0x80000000
	MOV lr,pc
	B add_sub
	LDMFA sp!,{r3-r12}
	STR r2,[r12],#4
	STMFA sp!,{r3-r12}
	CMP r5,r9
	ADDNE r5,r5,#1
	STMNEFA sp!,{r3-r12}
	BNE loop3
	CMP r6,r10
	ADDNE r6,r6,#1
	MOVNE r5,#0
	STMNEFA sp!,{r4-r12}
	BNE loop2
	CMP r7,r10
	ADDNE r7,r7,#1
	MOVNE r5,#0
	MOVNE r6,#0
	STMNEFA sp!,{r4-r12}
	BNE big_loop
	
	
	
get_line_byte
	ADD r9,r9,#4  ;(r11)
	SUB r12,r12,#1
	CMP r12,#0
	BNE get_line_byte
	MOVEQ pc,lr
	
	
calculate_size
	ADD r2,r2,r0  ;                 n*n=(R2)
	SUB r1,r1,#1
	CMP r1,#0
	BNE calculate_size
	MOVEQ pc,lr


store_data
	CMP r1,#0
	MOVEQ r1,r0
	ADDEQ r10,r9,r10
	LDRNE r4,[r11],#4
	STRNE r4,[r10],#4
	SUBNE r1,r1,#1
	ADDNE r3,r3,#1
	CMP r3,r2
	BNE store_data
	MOVEQ pc,lr
	

finish_matrix LDR r0,Result_data
			  LDR r1,tempaddr
			  MOV r12,r10
			  MOV r9,#0
			  MOV lr,pc
			  B get_line_byte
			  ADD r9,r9,#4
			  ADD r1,r1,r9
			  MOV r4,r10
			  MOV r3,#0

			  
store_result  LDR r2,[r1],#4
			  STR r2,[r0],#4
			  CMP r3,r10
			  ADDNE r3,r3,#1
			  BNE store_result
			  BEQ next_line
			  
next_line	  ADD r1,r1,r9
			  CMP r4,#0
			  SUBNE r4,r4,#1
			  MOVNE r3,#0
			  BNE store_result
			  BEQ program_end

program_end
	MOV pc,#0 ;Program end
			  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mult
	MOV r11,#0
	CMP r1,#0
	MOVEQ r2,#0
	MOVEQ pc,lr
	CMP r2,#0
	MOVEQ pc,lr
	LDR r9,=0x80000000
	AND r3,r1,r9 ;extract sign bit 1  
	AND r4,r2,r9 ;extract sign bit 2  
	LDR r9,=0x7F800000
	AND r5,r1,r9 ;extract exponent bit 1  
	AND r6,r2,r9 ;extract exponent bit 2   
	
	EOR r3,r3,r4 ; result's sign bit (r3)
	
	MOV r5,r5,LSR #23
	MOV r6,r6,LSR #23
	ADD r10,r5,r6
	SUB r4,r10,#254 ;result's exponent bit (r4)
	LDR r9,=0x007FFFFF
	AND r1,r1,r9 ; extract mantissa bit 1 	(r1)
	ORR r1,r1,#0x00800000
	MVN r0,r1;
	ADD r0,r0,#1 ; ~multiplicand
	AND r8,r2,r9 ; extract mantissa bit 2   (R2)
	ORR r8,r8,#0x00800000 ; 
	MOV r8,r8,LSL #1;for compare (r2)
	MOV r5,r8 ; for RSC multiplier
	

booth   ;U=r7  V=r8
	MOV r6, r5 ; for xi & xi-1
	AND r6,#0x00000007;
	CMP r6,#1  ; +1X 
	ADDEQ r7,r7,r1
	CMP r6,#2 ; +1X
	ADDEQ r7,r7,r1
	CMP r6,#3 ; +2X
	ADDEQ r7,r7,r1, LSL #1
	CMP r6, #4; -2X
	ADDEQ r7,r7,r0, LSL #1
	CMP r6, #5; -X
	ADDEQ r7,r7,r0
	CMP r6,#6 ;-X
	ADDEQ r7,r0
	
	MOV r11,r11,LSR #2
	AND r9,r7,#3  ;calculate overflow
	MOV r9,r9,LSL #30
	ADD r11,r11,r9
	
	MOV r7, r7, ASR #2 ; lsr U
	MOV r5, r5, ROR #2; lsr X
	CMP r8,r5
	BNE booth 
	
	MOV r1,#0
make_fraction	
	MOV r8,r7
	AND r8,#0x80000000
	MOV r7,r7,LSL #1
	MOV r12,r11
	MOV r12,r12,LSR #31
	MOV r11,r11,LSL #1
	ADD r7,r12
	CMP r8,#0x80000000
	ADD r1,r1,#1
	BNE make_fraction
	
;nomalize	
	CMP r1,#0x11
	ADDEQ r4,r4,#1
	MOV r7,r7,LSR #9
	ADD r4,r4,#127
	MOV r4,r4,LSL #23
	ADD r7,r7,r4
	ADD r7,r7,r3
	MOV r2,r7
	MOV pc,lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

divi
	LDR r9,=0x80000000
	AND r3,r1,r9 ;extract sign bit 1  
	AND r4,r2,r9 ;extract sign bit 2  
	LDR r9,=0x7F800000
	AND r5,r1,r9 ;extract exponent bit 1  
	AND r6,r2,r9 ;extract exponent bit 2   
	
	EOR r3,r3,r4 ; result's sign bit (r3)
	
	MOV r5,r5,LSR #23
	MOV r6,r6,LSR #23
	SUB r4,r6,r5 ;result's exponent bit (r4)
	LDR r9,=0x007FFFFF
	AND r1,r1,r9 ; extract mantissa bit 1 	(r1)
	ORR r1,r1,#0x00800000
	AND r2,r2,r9 ; extract mantissa bit 2   (R2)
	ORR r2,r2,#0x00800000 ; 
	MOV r9,#24
	MOV r10,#0
;result=r12 
division 
	MOV r6,#1 ; for operand div ;23->1
	CMP r2,r1
	SUBGE r2,r2,r1
	MOVGE r6,r6,LSL r9
	ADDGE r10,r10,r6
	MOV r2,r2,LSL #1
	SUB r9,r9,#1
	CMP r9,#0
	BEQ result
	BNE division
	
	
result
	AND r5,r10, #0x01000000
	CMP r5,#0x01000000
	SUBEQ r10,r10,#0x01000000
	MOVEQ r10,r10,LSR #1
	SUBNE r4,r4,#1
	SUBNE r10,r10,#0x00800000
	ADD r4,r4,#127
	MOV r4,r4,LSL #23
	ADD r10,r10,r4
	ADD r10,r10, r3
	MOV r2,r10;;;;;;;;;;;;;;;;;;result=r2
	MOV pc,lr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
add_sub
	EOR r12,r1,r2
	CMP r12, 0x80000000
	MOVEQ r2,0x00000000
	MOVEQ pc,lr
    LDR r10, =0x7f800000 
    AND r4, r1, r10  ;exponent1           (R4)
    AND r5, r2, r10  ;exponent2			  (R5)
    CMP r4, r5 
    MOVCC r3, r1 
    MOVCC r1, r2 
    MOVCC r2, r3    ;swap two float  
    ANDCC r4, r1, r10  
    ANDCC r5, r2, r10   
    MOV r4, r4, LSR #23 
    MOV r5, r5, LSR #23         
    SUB r3, r4, r5              ; shift amount (R3)
    LDR r10, =0x007fffff      
    AND r5, r1, r10             ; mantissa1 (R5)
    AND r6, r2, r10             ; mantissa2 (R6)
    LDR r10, =0x00800000 
    ADD r5, r5, r10             
    ADD r6, r6, r10             
    MOV r6, r6, LSR r3          ; shift 
    LDR r10, =0x80000000 
	ANDS r0, r1, r10            ; check msb for negative bit 
    MOVNE r0, r5   
	MVNNE r0, r0                  
    ADDNE r0, r0, #1              ; negative 
    MOVNE r5, r0  
    ANDS r0, r2, r10             ; check msb for negative bit 
    MOVNE r0, r6 
	MVNNE r0, r0                  
    ADDNE r0, r0, #1              ;negative
    MOVNE r6, r0 
    ADD r5, r5, r6              ; result's mantissa
    ANDS r0, r5, r10   ; check msb to see if the result is negative 
    MOVNE r0, r5 
    MVNNE r0, r0           ;negative
    ADDNE r0, r0, #1              
    MOVNE r5, r0 
    LDRNE r0, =0x80000000       ;negative result
    MOVEQ r0, #0                ;positive result
    MOV r3, #0 
    LDR r10, =0x80000000 

normalize
    CMP r10, r5 
    ADDHI r3, r3, #1 
    MOVHI r10, r10, lsr #1 
    BHI normalize  ;exponent 

    CMP r3, #8                  
    SUBHI r3, r3, #8         
    MOVHI r5, r5, lsl r3     
	SUBHI r4, r4, r3       
    MOVCC r10, #8 
    SUBCC r3, r10, r3         
    MOVCC r5, r5, lsr r3   
    ADDCC r4, r4, r3        

 
    MOV r4, r4, lsl #23       
    ORR r0, r0, r4             
    LDR r10, =0x007fffff 
    AND r5, r5, r10          
    ORR r0, r0, r5           
    MOV r2,r0
    MOV pc, lr 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


tempaddr	& &40000000
tempaddr2	& &20000000
Result_data	& &60000000
Matrix_data
	DCD 20
	DCD 2_01000001101000000000000000000000
	DCD 2_01000011011100000000000000000000
	DCD 2_01000001001001000000000000000000
	DCD 2_01000010010000000000000000000000
	DCD 2_01000001111100000000000000000000
	DCD 2_01000000000001000000000000000000
	DCD 2_01000000010100000000000000000000
	DCD 2_11000001100111000000000000000000
	DCD 2_01000011000110000000000000000000
	DCD 2_11000001101000000000000000000000
	DCD 2_01000011000000100000000000000000
	DCD 2_11000001001010000000000000000000
	DCD 2_01000001100100000000000000000000
	DCD 2_11000000110110000000000000000000
	DCD 2_11000010100101000000000000000000
	DCD 2_01000100010010000000000000000000
	DCD 2_11000000111010000000000000000000
	DCD 2_11000001101100000000000000000000
	DCD 2_11000100000111000000000000000000
	DCD 2_11000001010010000000000000000000
	DCD 2_01000011010001000000000000000000
	DCD 2_01000000001110000000000000000000
	DCD 2_01000011010010000000000000000000
	DCD 2_01000011001000000000000000000000
	DCD 2_11000011010110000000000000000000
	DCD 2_11000000010100000000000000000000
	DCD 2_11000100001101000000000000000000
	DCD 2_01000000111101000000000000000000
	DCD 2_11000011011011000000000000000000
	DCD 2_01000011010110000000000000000000
	DCD 2_01000010111010000000000000000000
	DCD 2_01000001110010000000000000000000
	DCD 2_01000011010111000000000000000000
	DCD 2_11000001101110000000000000000000
	DCD 2_11000100001110000000000000000000
	DCD 2_01000010111110000000000000000000
	DCD 2_01000000000101000000000000000000
	DCD 2_01000010001100000000000000000000
	DCD 2_01000001101000000000000000000000
	DCD 2_11000010000110000000000000000000
	DCD 2_11000001011000000000000000000000
	DCD 2_01000010110101000000000000000000
	DCD 2_11000011010110000000000000000000
	DCD 2_01000011111010000000000000000000
	DCD 2_01000100011010000000000000000000
	DCD 2_11000011111100000000000000000000
	DCD 2_11000000110100000000000000000000
	DCD 2_11000011100011000000000000000000
	DCD 2_01000000101001000000000000000000
	DCD 2_11000011110100000000000000000000
	DCD 2_11000010111110000000000000000000
	DCD 2_11000010101001000000000000000000
	DCD 2_01000011011110000000000000000000
	DCD 2_11000001101100000000000000000000
	DCD 2_11000011000110000000000000000000
	DCD 2_01000011110101000000000000000000
	DCD 2_01000010010101000000000000000000
	DCD 2_11000000100000000000000000000000
	DCD 2_11000000010001000000000000000000
	DCD 2_11000000100001000000000000000000
	DCD 2_01000011000101000000000000000000
	DCD 2_01000011011100000000000000000000
	DCD 2_01000000001110000000000000000000
	DCD 2_01000000010010000000000000000000
	DCD 2_11000010010010000000000000000000
	DCD 2_11000000011110000000000000000000
	DCD 2_11000011111110000000000000000000
	DCD 2_01000001000000100000000000000000
	DCD 2_01000010100111000000000000000000
	DCD 2_01000001000100000000000000000000
	DCD 2_11000000111000000000000000000000
	DCD 2_01000010101010000000000000000000
	DCD 2_11000100000011000000000000000000
	DCD 2_01000010110101000000000000000000
	DCD 2_11000100010100000000000000000000
	DCD 2_01000010000000000000000000000000
	DCD 2_01000010000101000000000000000000
	DCD 2_11000000110000000000000000000000
	DCD 2_01000011001111000000000000000000
	DCD 2_01000000100001000000000000000000
	DCD 2_11000001110100000000000000000000
	DCD 2_11000010001100000000000000000000
	DCD 2_01000000111100000000000000000000
	DCD 2_01000000101000000000000000000000
	DCD 2_01000010000111000000000000000000
	DCD 2_01000000111101000000000000000000
	DCD 2_01000011000101000000000000000000
	DCD 2_11000100010100000000000000000000
	DCD 2_01000010011100000000000000000000
	DCD 2_01000001001000000000000000000000
	DCD 2_11000001000001000000000000000000
	DCD 2_11000011000011000000000000000000
	DCD 2_01000001011101000000000000000000
	DCD 2_11000001110011000000000000000000
	DCD 2_01000001101100000000000000000000
	DCD 2_11000001000111000000000000000000
	DCD 2_01000001000010000000000000000000
	DCD 2_11000000010110000000000000000000
	DCD 2_11000011001000000000000000000000
	DCD 2_11000100001100000000000000000000
	DCD 2_11000011110110000000000000000000
	DCD 2_01000010010110000000000000000000
	DCD 2_01000100001010000000000000000000
	DCD 2_01000011111100000000000000000000
	DCD 2_01000000010111000000000000000000
	DCD 2_01000010111000000000000000000000
	DCD 2_01000001100000000000000000000000
	DCD 2_11000001001011000000000000000000
	DCD 2_11000011101100000000000000000000
	DCD 2_11000100010001000000000000000000
	DCD 2_01000010110110000000000000000000
	DCD 2_01000001101100000000000000000000
	DCD 2_11000001011001000000000000000000
	DCD 2_11000000011100000000000000000000
	DCD 2_11000000000010000000000000000000
	DCD 2_11000000000001000000000000000000
	DCD 2_01000011100100000000000000000000
	DCD 2_01000000010000000000000000000000
	DCD 2_01000010111110000000000000000000
	DCD 2_01000000110001000000000000000000
	DCD 2_01000100010000000000000000000000
	DCD 2_11000100001100000000000000000000
	DCD 2_11000001111100000000000000000000
	DCD 2_01000100010000000000000000000000
	DCD 2_11000011000000000000000000000000
	DCD 2_11000000111100000000000000000000
	DCD 2_11000001111000000000000000000000
	DCD 2_11000000111100000000000000000000
	DCD 2_11000000000001000000000000000000
	DCD 2_01000010111011000000000000000000
	DCD 2_11000001010101000000000000000000
	DCD 2_01000001000000100000000000000000
	DCD 2_01000001000000000000000000000000
	DCD 2_01000001010100000000000000000000
	DCD 2_11000010001110000000000000000000
	DCD 2_11000100011010000000000000000000
	DCD 2_01000001101000000000000000000000
	DCD 2_11000011100000000000000000000000
	DCD 2_01000001000001000000000000000000
	DCD 2_01000100000110000000000000000000
	DCD 2_01000000101110000000000000000000
	DCD 2_01000010001001000000000000000000
	DCD 2_11000011010110000000000000000000
	DCD 2_01000010101000000000000000000000
	DCD 2_11000000110010000000000000000000
	DCD 2_11000100011100000000000000000000
	DCD 2_01000001101101000000000000000000
	DCD 2_11000011000001000000000000000000
	DCD 2_01000011011000000000000000000000
	DCD 2_01000000111100000000000000000000
	DCD 2_01000100000000100000000000000000
	DCD 2_11000100011000000000000000000000
	DCD 2_01000000111011000000000000000000
	DCD 2_11000001011011000000000000000000
	DCD 2_11000001110111000000000000000000
	DCD 2_11000011111010000000000000000000
	DCD 2_11000000000000000000000000000000
	DCD 2_11000001011101000000000000000000
	DCD 2_11000011010110000000000000000000
	DCD 2_01000010111000000000000000000000
	DCD 2_11000000100001000000000000000000
	DCD 2_01000011100010000000000000000000
	DCD 2_01000000110100000000000000000000
	DCD 2_11000001110111000000000000000000
	DCD 2_11000010111000000000000000000000
	DCD 2_01000011101110000000000000000000
	DCD 2_11000000111110000000000000000000
	DCD 2_11000100000101000000000000000000
	DCD 2_01000001010100000000000000000000
	DCD 2_11000000010010000000000000000000
	DCD 2_11000001000000100000000000000000
	DCD 2_01000001000110000000000000000000
	DCD 2_01000000100100000000000000000000
	DCD 2_11000011010111000000000000000000
	DCD 2_01000000011010000000000000000000
	DCD 2_11000100010010000000000000000000
	DCD 2_01000010111110000000000000000000
	DCD 2_11000011001010000000000000000000
	DCD 2_11000100000001000000000000000000
	DCD 2_01000001001100000000000000000000
	DCD 2_01000011111111000000000000000000
	DCD 2_01000000010100000000000000000000
	DCD 2_01000000011011000000000000000000
	DCD 2_11000100010001000000000000000000
	DCD 2_11000010010010000000000000000000
	DCD 2_01000100000000000000000000000000
	DCD 2_11000011000111000000000000000000
	DCD 2_01000010101100000000000000000000
	DCD 2_01000011110000000000000000000000
	DCD 2_11000100010000000000000000000000
	DCD 2_11000001001001000000000000000000
	DCD 2_11000010100010000000000000000000
	DCD 2_01000010111100000000000000000000
	DCD 2_11000000000001000000000000000000
	DCD 2_11000100000011000000000000000000
	DCD 2_01000000011100000000000000000000
	DCD 2_11000001011001000000000000000000
	DCD 2_11000001101110000000000000000000
	DCD 2_01000000011010000000000000000000
	DCD 2_01000010100011000000000000000000
	DCD 2_11000001111100000000000000000000
	DCD 2_11000010100100000000000000000000
	DCD 2_11000011011100000000000000000000
	DCD 2_11000000000000000000000000000000
	DCD 2_01000001010100000000000000000000
	DCD 2_01000011001001000000000000000000
	DCD 2_11000001010110000000000000000000
	DCD 2_01000100000010000000000000000000
	DCD 2_01000000111110000000000000000000
	DCD 2_11000010011010000000000000000000
	DCD 2_01000011110000000000000000000000
	DCD 2_01000100011000000000000000000000
	DCD 2_11000001110000000000000000000000
	DCD 2_01000001001110000000000000000000
	DCD 2_01000001011110000000000000000000
	DCD 2_01000011011001000000000000000000
	DCD 2_01000001100010000000000000000000
	DCD 2_11000100001010000000000000000000
	DCD 2_11000010110001000000000000000000
	DCD 2_11000001010000000000000000000000
	DCD 2_01000000111010000000000000000000
	DCD 2_11000011011011000000000000000000
	DCD 2_01000010001000000000000000000000
	DCD 2_01000001010011000000000000000000
	DCD 2_01000011001000000000000000000000
	DCD 2_01000010100000000000000000000000
	DCD 2_11000010010010000000000000000000
	DCD 2_11000010001000000000000000000000
	DCD 2_11000001011010000000000000000000
	DCD 2_01000000011110000000000000000000
	DCD 2_01000000111000000000000000000000
	DCD 2_01000000001010000000000000000000
	DCD 2_01000001010110000000000000000000
	DCD 2_11000010011100000000000000000000
	DCD 2_01000010011001000000000000000000
	DCD 2_01000001100100000000000000000000
	DCD 2_11000000011111000000000000000000
	DCD 2_11000001100010000000000000000000
	DCD 2_01000100011000000000000000000000
	DCD 2_01000011100011000000000000000000
	DCD 2_01000100010100000000000000000000
	DCD 2_01000001100100000000000000000000
	DCD 2_11000011000100000000000000000000
	DCD 2_11000011001000000000000000000000
	DCD 2_01000100011100000000000000000000
	DCD 2_11000001001111000000000000000000
	DCD 2_11000100001100000000000000000000
	DCD 2_01000000110111000000000000000000
	DCD 2_01000100000011000000000000000000
	DCD 2_11000000101111000000000000000000
	DCD 2_11000001000000000000000000000000
	DCD 2_11000010111011000000000000000000
	DCD 2_01000001100001000000000000000000
	DCD 2_01000011000001000000000000000000
	DCD 2_11000001011100000000000000000000
	DCD 2_11000010001111000000000000000000
	DCD 2_01000010111111000000000000000000
	DCD 2_01000011000000000000000000000000
	DCD 2_11000000000000000000000000000000
	DCD 2_01000001100010000000000000000000
	DCD 2_11000100011000000000000000000000
	DCD 2_01000000100000000000000000000000
	DCD 2_11000001100000000000000000000000
	DCD 2_11000011101111000000000000000000
	DCD 2_11000010110100000000000000000000
	DCD 2_01000000111110000000000000000000
	DCD 2_01000011110011000000000000000000
	DCD 2_01000010100010000000000000000000
	DCD 2_01000100000000000000000000000000
	DCD 2_01000000010010000000000000000000
	DCD 2_11000010011011000000000000000000
	DCD 2_11000011101100000000000000000000
	DCD 2_11000011111101000000000000000000
	DCD 2_01000001101001000000000000000000
	DCD 2_01000011110100000000000000000000
	DCD 2_01000001001101000000000000000000
	DCD 2_01000010100010000000000000000000
	DCD 2_01000000111100000000000000000000
	DCD 2_11000001101000000000000000000000
	DCD 2_11000010001100000000000000000000
	DCD 2_01000010001010000000000000000000
	DCD 2_11000001100010000000000000000000
	DCD 2_01000000110100000000000000000000
	DCD 2_11000001101100000000000000000000
	DCD 2_01000010001110000000000000000000
	DCD 2_01000001001010000000000000000000
	DCD 2_11000001001000000000000000000000
	DCD 2_11000010011010000000000000000000
	DCD 2_11000010111100000000000000000000
	DCD 2_11000001100000000000000000000000
	DCD 2_01000011110011000000000000000000
	DCD 2_01000000000101000000000000000000
	DCD 2_11000000011011000000000000000000
	DCD 2_11000010010111000000000000000000
	DCD 2_11000001011101000000000000000000
	DCD 2_11000000101000000000000000000000
	DCD 2_01000011011000000000000000000000
	DCD 2_01000000100010000000000000000000
	DCD 2_11000001100001000000000000000000
	DCD 2_11000000100001000000000000000000
	DCD 2_11000010110011000000000000000000
	DCD 2_11000010010001000000000000000000
	DCD 2_11000000101000000000000000000000
	DCD 2_11000000101000000000000000000000
	DCD 2_11000011010101000000000000000000
	DCD 2_11000001101000000000000000000000
	DCD 2_01000011100010000000000000000000
	DCD 2_01000001010110000000000000000000
	DCD 2_11000000000100000000000000000000
	DCD 2_11000011111110000000000000000000
	DCD 2_11000000000000000000000000000000
	DCD 2_11000100000010000000000000000000
	DCD 2_11000010111100000000000000000000
	DCD 2_01000001110100000000000000000000
	DCD 2_11000010010001000000000000000000
	DCD 2_11000000011000000000000000000000
	DCD 2_01000000001000000000000000000000
	DCD 2_01000011010110000000000000000000
	DCD 2_01000001100101000000000000000000
	DCD 2_11000000100010000000000000000000
	DCD 2_11000011001000000000000000000000
	DCD 2_01000000001110000000000000000000
	DCD 2_01000000011010000000000000000000
	DCD 2_01000100000000000000000000000000
	DCD 2_01000000011110000000000000000000
	DCD 2_01000011101001000000000000000000
	DCD 2_01000010001100000000000000000000
	DCD 2_01000010100000000000000000000000
	DCD 2_01000010010100000000000000000000
	DCD 2_01000001001010000000000000000000
	DCD 2_11000011110100000000000000000000
	DCD 2_01000001110110000000000000000000
	DCD 2_11000000110011000000000000000000
	DCD 2_01000000001010000000000000000000
	DCD 2_01000011101000000000000000000000
	DCD 2_01000000110010000000000000000000
	DCD 2_01000010101100000000000000000000
	DCD 2_01000010000110000000000000000000
	DCD 2_11000011101000000000000000000000
	DCD 2_01000010010111000000000000000000
	DCD 2_11000001100010000000000000000000
	DCD 2_11000000111000000000000000000000
	DCD 2_01000001110010000000000000000000
	DCD 2_11000011011000000000000000000000
	DCD 2_11000001101100000000000000000000
	DCD 2_11000001110010000000000000000000
	DCD 2_01000010010000000000000000000000
	DCD 2_01000000011111000000000000000000
	DCD 2_11000001000000100000000000000000
	DCD 2_11000001010011000000000000000000
	DCD 2_11000000101110000000000000000000
	DCD 2_11000011011001000000000000000000
	DCD 2_01000001000101000000000000000000
	DCD 2_11000100000000000000000000000000
	DCD 2_01000010101110000000000000000000
	DCD 2_11000010010000000000000000000000
	DCD 2_11000011100101000000000000000000
	DCD 2_01000011000000000000000000000000
	DCD 2_01000010000000000000000000000000
	DCD 2_11000010010100000000000000000000
	DCD 2_11000000111000000000000000000000
	DCD 2_11000100000000000000000000000000
	DCD 2_01000010000000000000000000000000
	DCD 2_11000001100110000000000000000000
	DCD 2_01000011011010000000000000000000
	DCD 2_11000010000010000000000000000000
	DCD 2_11000010010100000000000000000000
	DCD 2_11000000000010000000000000000000
	DCD 2_01000010111110000000000000000000
	DCD 2_11000001111000000000000000000000
	DCD 2_01000001100101000000000000000000
	DCD 2_11000010101010000000000000000000
	DCD 2_11000000000000100000000000000000
	DCD 2_01000000011011000000000000000000
	DCD 2_01000001101000000000000000000000
	DCD 2_11000010100100000000000000000000
	DCD 2_01000000101010000000000000000000
	DCD 2_11000011011110000000000000000000
	DCD 2_11000010000001000000000000000000
	DCD 2_11000001001110000000000000000000
	DCD 2_11000001110001000000000000000000
	DCD 2_11000001110100000000000000000000
	DCD 2_11000001100110000000000000000000
	DCD 2_01000011011001000000000000000000
	DCD 2_01000010010000000000000000000000
	DCD 2_11000001000101000000000000000000
	DCD 2_01000000000000000000000000000000
	DCD 2_11000001110111000000000000000000
	DCD 2_01000010101000000000000000000000
	DCD 2_11000011110101000000000000000000
	DCD 2_01000000111111000000000000000000
	DCD 2_01000001000100000000000000000000
	DCD 2_01000011000100000000000000000000
	DCD 2_01000011001100000000000000000000
	DCD 2_01000100011110000000000000000000
	DCD 2_11000011011001000000000000000000
	DCD 2_01000000110101000000000000000000
	DCD 2_11000000001010000000000000000000
	DCD 2_01000001001100000000000000000000
	DCD 2_01000000110100000000000000000000

	END