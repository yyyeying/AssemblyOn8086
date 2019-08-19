DATA        SEGMENT                                  ;数据段
SHOW        DB          0D9H,0F4H,0F4H,0EDH,0DDH,0EDH ;522060的数码管
;1  21H     00100001
;2  0F4H    11110100
;3  0F1H    11110001
;4  39H     00111001
;5  0D9H    11011001
;6  0DDH    11011101
;7  61H     01100001
;8  0FDH    11111101
;9  0F9H    11111001
;0  0EDH    11101101
COUNT       EQU         $-SHOW              ;$-show是当前地址与show首地址的差，相当于统计了show的长度
SL          DB          ?                   ;数码管位选信号              
DATA        ENDS

STACK       SEGMENT STACK                   ;数据段
DB 50       DUP(?)
STACK       ENDS   
          
CODE        SEGMENT 
ASSUME      CS:CODE, DS:DATA, SS:STACK

;-------------------------------------------主程序
START:  mov     AX,DATA
		mov     DS,AX 
        mov     ES,AX
        
NEXT:   mov     CX,COUNT                    ;数字位数
	    mov     BX,OFFSET SHOW
		mov     SL,01H						;从最高位开始
	
DISPLAY:mov     AL,80H                      ;复位8255工作状态，A方式0，A输出，C高四位输出，B方式0，B输出，C低四位输出
	    mov     DX,0EE03H                   
	    out     DX,AL                  

	    mov     AL,SL
	    mov     DX,0EE01H                   ;SL-位选    
	    out     DX,AL

	    mov     AL,[BX]                     ;show
	    mov     DX,0EE00H                        
	    out     DX,AL                       ;数码管显示数字   

	    mov     AL,00H 
	    mov     DX,0EE00H
	    out     DX,AL                       ;熄灭数码管

	    inc     BX                          ;BX自增，移至show[BX+1]
	    shl     SL,1                        ;SL左移依次向右选通数码管                               
	    loop    DISPLAY

	    mov     AH,0BH                      ;检测键盘状态                         
	    int     21H
	    or      AL,AL                       ;键盘有输入时，AL=00,；键盘无输入时，AL=FF
	    jz      NEXT						;键盘无输入时重新显示

LAST:   mov     AH,4CH						;键盘有输入时返回DOS
	    int     21H

;--------------------------------------------延时子程序
DELAY   PROC                                   
        push    CX
	    mov     CX,800H
DELAY1: push    CX                          ;外层循环
	    mov     CX,400H
DELAY2: loop    DELAY2                      ;内层循环
	    pop     CX
	    loop    DELAY1
	    pop     CX         
	    ret
DELAY   ENDP
CODE    ENDS
END     START

