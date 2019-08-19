DATA    SEGMENT             ;数据段
NUM     DB          07FH
DATA    ENDS                

STAC    SEGMENT     STACK   ;堆栈段
DB      50          DUP(?)
STAC    ENDS                

CODE    SEGMENT             ;代码段
ASSUME  CS:CODE,DS:DATA,SS:STAC
START   PROC        FAR
        push        DS
        mov         AX,0
        push        AX                  
        mov         AX,DATA
        mov         DS,AX
        mov         DX,0EEE0H           ;设置IO地址

SW:     in          AX,DX
        cmp         AL,01H              ;第一个SW开
        jz          RR
        cmp         AL,00H              ;第一个SW关
        jz          LL
        and         AL,02H              ;只看第二位，相当于“子网掩码”
        cmp         AL,02H              ;第二个SW开
        jz          EXIT
        call        KEY
        jmp         SW

RR:     call        DELAY               ;第一个SW开，右移
        ror         NUM,1
        mov         AL,NUM
        out         DX,AL
        jmp         SW

LL:     call        DELAY               ;第一个SW关，左移
        rol         NUM,1
        mov         AL,NUM
        out         DX,AL
        jmp         SW

EXIT:   mov         AH,4CH              ;第二个SW开，返回DOS
        int         21H

START   ENDP

;-----------------------------------------延时子程序
DELAY   PROC
        push        CX
        mov         CX,00FFFH            ;外循环过程
D1:     push        CX
        mov         CX,00FFFH            ;内循环过程
D2:     loop        D2
        pop         CX
        loop        D1
        pop         CX
        ret

DELAY   ENDP

;------------------------------------返回DOS子程序
KEY       PROC                      ;检测键盘输入
          push    AX
          mov     AH,0BH
          int     21H
          or      AL,AL             ;键盘有输入时，AL=00,；键盘无输入时，AL=FF
          jz      NKEY              ;没有键盘输入则返回主程序
          mov     AH,4CH            ;有任意输入则返回DOS
          int     21H
NKEY:     pop     AX
          ret
KEY       ENDP 

CODE    ENDS
END     START