DATA   SEGMENT
NUM    DB   '1','2','3','4','5','6','7','8'   ;欲发送和显示的字符数据
DATA   ENDS

STACK  SEGMENT STACK
       DB 50 DUP(?)
STACK  ENDS

CODE   SEGMENT
       ASSUME CS:CODE,DS:DATA,SS:STACK
START:  mov     AX,DATA
	    mov     DS,AX

	    mov     DX,0E023H       ;8253初始化命令
	    mov     AL,16H          ;00010110H，即选择计数器0，只读低8位，方式3，二进制计数
	    out     DX,AL
	    mov     DX,0E020H       ;8255
	    mov     AL,11111010B    ;设置计数器初值使输出频率为1KHz
	    out     DX,AL	
	    mov     DX,0E041H       ;8251初始化
	    mov     AL,40H          ;首先写入控制字01000000H进行内部软复位
	    out     DX,AL
	    call    DELAY
	    mov     AL,5EH          ;写入方式控制字，选择异步方式，奇校验，一个校验位，8位数据，波特率因子是16
	    out     DX,AL
	    call    DELAY
	    mov     AL,37H          ;写入命令控制字
	    out     DX,AL
	    call    DELAY
	    mov     CX,10           ;设置循环变量是10
	    mov     SI,0
	    lea     BX,NUM              
REPLY:  mov     DX,0E041H
	    in      AL,DX           ;查询8251状态
        test    AL,38H          ;检查是否出错
        jz      OVER            ;出错则返回DOS
	    test    AL,02H          ;检查是否接收到新数据
	    jnz     RECEIVE         ;转到接收新数据的程序
	    test    AL,01H          ;检查是否可以发送字符
	    jz      REPLY           ;否则继续检测
	    mov     DX,0E040H       ;是则发送字符
	    mov     AL,[BX+SI]
	    out     DX,AL           ;发送数据
	    call    DELAY
	    call    DELAY
	    inc     SI              ;SI自加
	    loop    REPLY           ;继续检测
	    jmp     OVER
RECEIVE:
        mov     DX,0E040H
	    in      AL,DX;接收字符
	    mov     AH,02H   
	    mov     DL,AL;DOS功能调用02H，将放入DL寄存器的字符在屏幕上显示输出
	    int     21H
	    jmp     REPLY
OVER:   mov     AH,4CH ;返回DOS系统
	    int     21H

DELAY   PROC  NEAR;延时子程序
	    push    CX
	    mov     CX,0FFFH
LOOP1:  loop    LOOP1
	    pop     CX
	    ret
DELAY   ENDP
CODE    ENDS
END     START
