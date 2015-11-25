TITLE TSR FOR RTC
COMMENT %
ATTRIBUTE BYTE  BL  R  G  B  I  R  G  B
                BACKGROUND   FOREGROUND

FORMULA TO CALCULATE OFFSET IN VIDEO RAM USING X,Y CO-ORDINATES
        = [(Y * 80)+X]*2
%

.MODEL TINY
.CODE
        ORG 100H                ;START FROM 100H LOCATION
START:  JMP INIT

        TEMPAX DW ?
        TEMPBX DW ?
        TEMPCX DW ?
        TEMPDX DW ?
        TEMPSI DW ?
        TEMPDI DW ?

        TEMPDS DW ?
        TEMPES DW ?

        SAVEINT08 DD ?

MYINT08:
        MOV CS:TEMPAX,AX
        MOV CS:TEMPBX,BX
        MOV CS:TEMPCX,CX
        MOV CS:TEMPDX,DX
        MOV CS:TEMPSI,SI
        MOV CS:TEMPDI,DI
        MOV CS:TEMPDS,DS
        MOV CS:TEMPES,ES


        MOV AH,02H              ;READ CLOCK. RETURNS CH=HH, CL=MM, DH=SS IN BCD
        INT 1AH

        MOV AX,0B800H           ;BASE ADDRESS OF PAGE-0 OF VIDEO RAM
        MOV ES,AX

        MOV DI,3984             ;OFFSET IN VIDEO RAM WHERE WE WANT TO DISPLAY HH:MM:SS

;DISPLAYING HH
        MOV BL,02               ;NUMBER OF DIGITS TO DISPLAY
UP1:    ROL CH,4               ;ROTATE
        

        MOV AL,CH
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H              ;ATTRIBUTE BYTE (BL R G B I R G B) 00010111
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC BL
        JNZ UP1

;DISPLAYING BLINKING ':'
        MOV AL,':'
        MOV AH,94H															
        MOV ES:[DI],AX

        INC DI
        INC DI

;DISPLAYING MM
        MOV BL,02               ;NUMBER OF DIGITS TO DISPLAY
UP2:    ROL CL,4               ;ROTATE
        

        MOV AL,CL
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H              ;ATTRIBUTE BYTE (BL R G B I R G B)
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC BL
        JNZ UP2

;DISPLAYING BLINKING ':'
        MOV AL,':'
        MOV AH,94H
        MOV ES:[DI],AX

        INC DI
        INC DI

;DISPLAYING SS
        MOV BL,02               ;NUMBER OF DIGITS TO DISPLAY
UP3:    ROL DH,4               ;ROTATE
       

        MOV AL,DH
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H              ;ATTRIBUTE BYTE (BL R G B I R G B)
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC BL
        JNZ UP3


        MOV AX,CS:TEMPAX
        MOV BX,CS:TEMPBX
        MOV CX,CS:TEMPCX
        MOV DX,CS:TEMPDX
        MOV SI,CS:TEMPSI
        MOV DI,CS:TEMPDI
        MOV DS,CS:TEMPDS
        MOV ES,CS:TEMPES

        JMP CS:SAVEINT08

INIT:   CLI
        MOV AH,35H              ;GET VECTOR
        MOV AL,08H              ;OF TYPE 08
        INT 21H                 ;WHICH RETURNS VECTOR ADDRESS IN ES:BX

        MOV WORD PTR SAVEINT08,BX
        MOV WORD PTR SAVEINT08+2,ES

        MOV AH,25H              ;SET VECTOR
        MOV AL,08H              ;OF TYPE 08
        LEA DX,MYINT08          ;ENTRY POINT OF MY ISR STORED IN DS:DX
        INT 21H

        MOV AH,31H              ;TERMINATE AND MAKE RESIDENT
        LEA DX,INIT             ;SIZE OF MEMORY BLOCK
        STI                     ;SET IF
        INT 21H
END START
