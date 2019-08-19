DATA    SEGMENT
MSG     DB 0,0,0,0,0,0,3DH,0DCH,8CH,8CH,0EDH,0,0,0,0,0,0 
DATA    ENDS 

STAC    SEGMENT STACK
        DB 50 DUP(0)
STAC    ENDS      

CODE    SEGMENT
        ASSUME DS:DATA,CS:CODE,SS:STAC 
       
MAIN    PROC    FAR
        mov     AX,DATA
        mov     DS,AX
        mov     ES,AX

        mov     AL,80H      ;复位8255工作状态，方式0，输出，高四位输出，方式0，输出，低四位输出
        mov     DX,0EE03H      
        out     DX,AL 

LBEG:   mov     BX,OFFSET MSG
        mov     CX,0BH  

LOP5:   mov     DX,0EEE0H   ;从SW读入数据 
        in      AL,DX
        inc     AL
        and     AL,07H
        mov     AH,0
        mov     DX,AX       ;DX值设置为外循环次数
LDISP:  call    DISP        ;显示子程序调用
        dec     DX
        jnz     LDISP       ;显示当前状态直至DX=0
        inc     BX          ;BX决定哪个数码管应被点亮
        loop    LOP5        ;重新设置数码管移动速度
        jmp     LBEG        ;当六种状态都结束后重新开始显示“HELLO”过程
MAIN    ENDP

;---------------------------显示子程序
DISP      PROC NEAR 
          push    CX 
          push    DX
          push    AX

          mov     CX,0044H           ;控制显示速度，该次循环44H次，改变可以延长时间。
DISP1:    mov     SI,0
                       
          mov     DX,0EE00H          ;从外部设备读入数据
          mov     AH,01H             ;每次显示一个数码管
          push    CX

          mov     CX,06H             
DISP2:    mov     AL,MSG[BX+SI]
          out     DX,AL
          mov     AL,AH              ;决定显示哪一个数码管
          mov     DX,0EE01H          ;位选
          out     DX,AL              ;控制哪一个LED灯亮
          mov     DX,0EE00H          ;段选
          rol     AH,1               ;左移AH，使得下一个LED灯亮
          inc     SI
          call    DELAY              ;调用延时子程序
          call    KEY                ;检验按键是否有输入
          loop    DISP2  
          pop     CX

          loop    DISP1               ;外层循环，控制显示时间

          pop     AX
          pop     DX
          pop     CX
          ret     
DISP      ENDP

;------------------------------------返回DOS子程序
KEY       PROC NEAR                ;检测键盘输入
          push    AX
          mov     AH,0BH
          int     21H
          or      AL,AL
          jz      NKEY            ;没有键盘输入则跳向GOON
          mov     AH,4CH          ;有任意输入则返回DOS
          int     21H
NKEY:     pop     AX
          ret
KEY       ENDP 

;--------------------------------------------延时子程序
DELAY     PROC                                   
          push    CX
	      mov     CX,100H
DELAY1:   push    CX                          ;外层循环
	      mov     CX,400H
DELAY2:   loop    DELAY2                      ;内层循环
	      pop     CX
	      loop    DELAY1
	      pop     CX         
	      ret
DELAY     ENDP
   
CODE      ENDS
END       MAIN
