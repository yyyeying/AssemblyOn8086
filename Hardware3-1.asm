DATA    SEGMENT             ;数据段                  
VAR_DELAY_SHORT     DW  0FH
VAR_DELAY           DW  01FFFH                    
VAR_DELAY_LONG      DW  02FFFH         ;延时大小

NOTE_DO     DB      7DH ;125 256Hz
NOTE_RE     DB      6FH ;111 288Hz
NOTE_MI     DB      64H ;100 320Hz
NOTE_FA     DB      5EH ;94  341Hz
NOTE_SO     DB      53H ;83  384Hz
NOTE_RA     DB      4BH ;75  427Hz
NOTE_TI     DB      43H ;67  480Hz
NOTE_DO1    DB      3FH ;63  512Hz

NUM_ONE     DB      21H
NUM_TWO     DB      0F4H
NUM_THREE   DB      0F1H
NUM_FOUR    DB      39H
NUM_FIVE    DB      0D9H
NUM_SIX     DB      0DDH
NUM_SEVEN   DB      61H    
DATA    ENDS

STACK   SEGMENT STACK
DB  100H    DUP(?)
STACK   ENDS  

CODE    SEGMENT             ;代码段
ASSUME  CS:CODE, DS:DATA, SS:STACK

;------------------------------------返回DOS子程序
KEY     PROC                      ;检测键盘输入
        push    AX
        mov     AH,0BH
        int     21H
        or      AL,AL             ;键盘有输入时，AL=00,；键盘无输入时，AL=FF
        jz      NKEY              ;没有键盘输入则返回主程序
        mov     AH,4CH            ;有任意输入则返回DOS
        int     21H
NKEY:   pop     AX
        ret
KEY     ENDP 

DELAY   PROC FAR            ;延时子程序
	pushf
	push    CX
	mov     CX,VAR_DELAY
LOOP1:  push    CX
	mov     CX,VAR_DELAY
LOOP2:  loop    LOOP2
	pop     CX
	loop    LOOP1
	pop     CX
	popf
	retf
DELAY   ENDP

SHORT_DELAY  PROC FAR   ;延时子程序
	pushf
	push    CX
	mov     CX,VAR_DELAY
LOOPS1: push    CX
	mov     CX,VAR_DELAY_SHORT
LOOPS2: loop    LOOPS2
	    pop     CX
	    loop    LOOPS1
	    pop     CX
	    popf
	    retf
SHORT_DELAY  ENDP

LONG_DELAY  PROC FAR   ;延时子程序
	pushf
	push    CX
	mov     CX,VAR_DELAY
LOOPL1: push    CX
	mov     CX,VAR_DELAY_LONG
LOOPL2: loop    LOOPL2
	pop     CX
	loop    LOOPL1
	pop     CX
	popf
	retf
LONG_DELAY  ENDP

;播放音符子程序，音符写进BL，数字写进BH
PLAYNOTE PROC FAR
PLAY:
        mov     DX,0EEE0H   ;由拨码SW2决定是否暂停
        in      AL,DX
        cmp     AL,02H      
        jz      PAUSE
        cmp     AL,04H
        jz      EXIT
        call    KEY
        mov     DX,0EE20H   ;设置TMR0
        mov     AL,BL 
        out     DX,AL
        mov     DX,0EE00H   ;数码管
        mov     AL,BH
        out     DX,AL
        retf
PAUSE: 
        mov     DX,0EE20H      ;设置TMR0
        mov     AL,0
        out     DX,AL
        mov     DX,0EE00H   ;数码管依然显示
        mov     AL,BH 
        out     DX,AL
        jmp     PLAY 

EXIT:   
        mov     DX,0EE20H      ;设置TMR0
        mov     AL,0
        out     DX,AL
        mov     DX,0EE00H   ;数码管依然显示
        mov     AL,0
        out     DX,AL
        mov     AH,4CH            ;有任意输入则返回DOS
        int     21H   
        retf
PLAYNOTE ENDP

;主程序--------------------------------------------------------
START   PROC FAR      
	mov     AX,DATA
	mov     DS,AX  
init:   mov     DX,0EE23H           ;8253初始化
        mov     AL,00010110B        ;分频比小于255,mode3,二进制
        out     DX,AL
	;8255初始化
	mov     DX,0EE03H           ;A、B口均为方式0输出
	mov     AL,80H
	out     DX,AL
	                        ;数码管显示的准备工作
	mov     DX,0EE01H           ;设置数码管选通信号
	mov     AL,02H
	out     DX,AL
	mov     DX,0EE00H           ;显示清零
	mov     AL,00H
	out     DX,AL

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_DO
        mov     BH,NUM_ONE
        call    PLAYNOTE
        call    DELAY
        call    DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_FA
        mov     BH,NUM_FOUR
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY
        call    DELAY
        call    DELAY
        call    DELAY

        mov     BL,0
        mov     BH,0
        call    PLAYNOTE
        call    SHORT_DELAY 

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY   

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_DO
        mov     BH,NUM_ONE
        call    PLAYNOTE
        call    DELAY
        call    DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_FA
        mov     BH,NUM_FOUR
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_DO
        mov     BH,NUM_ONE
        call    PLAYNOTE
        
        call    DELAY
        call    DELAY
        call    DELAY 
        call    DELAY   

        mov     BL,0
        mov     BH,0
        call    PLAYNOTE
        call    SHORT_DELAY  
        
        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,0
        mov     BH,0
        call    PLAYNOTE
        call    SHORT_DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,1
        mov     BH,0
        call    PLAYNOTE
        call    SHORT_DELAY

        mov     BL,NOTE_FA
        mov     BH,NUM_FOUR
        call    PLAYNOTE
        call    DELAY

        mov     BL,1
        mov     BH,0
        call    PLAYNOTE
        call    SHORT_DELAY

        mov     BL,NOTE_FA
        mov     BH,NUM_FOUR
        call    PLAYNOTE
        call    DELAY

        mov     BL,1
        mov     BH,0
        call    PLAYNOTE
        call    SHORT_DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY
        call    DELAY

        mov     BL,NOTE_DO
        mov     BH,NUM_ONE
        call    PLAYNOTE
        call    DELAY
        

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY
        call    DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_FA
        mov     BH,NUM_FOUR
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY

        call    DELAY
        call    DELAY
        call    DELAY

        mov     BL,0
        mov     BH,0
        call    PLAYNOTE
        call    SHORT_DELAY 

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_SO
        mov     BH,NUM_FIVE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_DO
        mov     BH,NUM_ONE
        call    PLAYNOTE
        call    DELAY

        call    DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_FA
        mov     BH,NUM_FOUR
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_MI
        mov     BH,NUM_THREE
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_RE
        mov     BH,NUM_TWO
        call    PLAYNOTE
        call    DELAY

        mov     BL,NOTE_DO
        mov     BH,NUM_ONE
        call    PLAYNOTE
        call    DELAY
        
        call    DELAY
        call    DELAY
        call    DELAY  

	mov     AH,0bh                 ;检测键盘缓冲区
	int     21h
	or      AL,AL
	jnz     goon
	jmp     init
goon:   mov     DX,0E823H         ;退出前送出一个控制字，使音乐停止播放
        mov     AL,16H
        out     DX,AL
        mov     AX,4C00h             ;返回DOS
	int     21h
	ret
START   ENDP
CODE    ENDS
END     START
