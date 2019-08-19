DAT     SEGMENT
NUM     DB          0EFH
DAT     ENDS                ;定义数据段

STA     SEGMENT     STACK
DB      100         DUP(?)
STA     ENDS                ;定义堆栈段

COD     SEGMENT
ASSUME  CS:COD,DS:DAT,SS:STA
START   PROC        FAR
        PUSH        DS
        MOV         AX,0
        PUSH        AX                  ;使用第一种返回DOS的方式
        MOV         AX,DAT
        MOV         DS,AX
        MOV         DX,0EE00H           ;输出端口设置
LOOP0:  IN          AL,DX
        MOV         AH,AL
        TEST        AL,01H
        JZ          GG                  ;低位为1则程序结束
        TEST        AL,02H              ;检测中间位
        JZ          LOOP0               ;若输入端为0则继续等待
        TEST        AL,04H；
        JZ          RR                  ;跑马灯向右运动
        ROL         NUM,1               ;跑马灯向左运动
        JMP         LOOP2
RR:     ROR         NUM,1               ;原数据循环右移，使得跑马灯向右跳转
LOOP2:  AND         AH,1FH
        MOV         CL,AH               ;设置子程序调用的次数，间接控制延迟时间
        MOV         CH,0； 
        MOV         AL,NUM
        OUT         DX,AL
        INC         CX
LOOP1:  CALL        DELAY               ;调用延时子程序
        LOOP        LOOP1
        JMP         LOOP0               ;返回等待输入过程
GG:     RETF
START   ENDP

;-----------------------------------------延时子程序
DELAY   PROC
        PUSH        CX
        MOV         CX,008FFH            ;外循环过程
D1:     PUSH        CX
        MOV         CX,004FFH            ;内循环过程
D2:     LOOP        D2
        POP         CX
        LOOP        D1
        POP         CX
        RET
DELAY   ENDP
COD     ENDS
END     START
