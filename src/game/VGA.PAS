{$I-,N+,E+,S-,G+,F+}
UNIT vga;
INTERFACE
USES dos;
TYPE ScrArray=ARRAY[1..64000]OF BYTE;
     Pal256=ARRAY[0..255,0..2]OF BYTE;
FUNCTION _VGA:BOOLEAN;
PROCEDURE InitVGA;
{PROCEDURE ShowPic(picbuf:scrarray;pa:BYTE);}
PROCEDURE SetScr(pa:BYTE);
PROCEDURE BlackPal;
PROCEDURE SetPal(palbuf:pal256);
PROCEDURE WaitRetrace;
PROCEDURE TextMode;
CONST TranslateTab:ARRAY[0..3] OF BYTE=(1,2,4,8);
      Segment_Adr:ARRAY[0..3] OF WORD=($A000,$A3E8,$A7D0,$ABB8);
      Offset_Adr:ARRAY[0..3] OF WORD=($0000,$3E80,$7D00,$BB80);
VAR crtaddress,statusreg:word;
IMPLEMENTATION
PROCEDURE WaitRetrace;
BEGIN
  ASM
    MOV   DX,03dAh
@WD_R:
    IN    AL,DX
    TEST  AL,8d
    JZ    @WD_R
@WD_D:
    IN    AL,DX
    TEST  AL,8d
    JNZ   @WD_D
  END;
END;
PROCEDURE SetPal(palbuf:pal256);
VAR reg:REGISTERS;
BEGIN
  reg.ax:=$1012;
  reg.bx:=0;
  reg.cx:=256;
  reg.es:=SEG(palbuf);
  reg.dx:=OFS(palbuf);
  WaitRetrace;
  INTR($10,reg);
END;
PROCEDURE BlackPal;
VAR palbuf:Pal256;
BEGIN
  FILLCHAR(palbuf,768,0);
  SetPal(palbuf);
END;
FUNCTION _VGA:BOOLEAN;
VAR reg:REGISTERS;
BEGIN
  reg.ax:=$1A00;INTR($10,reg);
  IF (reg.al=$1A) AND ((reg.bl=7) OR (reg.bl=8)) THEN
   _VGA:=TRUE ELSE _VGA:=FALSE;
END;
PROCEDURE InitVGA;
BEGIN
 IF NOT _VGA THEN EXIT;
 ASM
   MOV DX,3CCh
   IN AL,DX
   TEST AL,1
   MOV DX,3D4h
   JNZ @L1
   MOV DX,3B4h
  @L1:
   MOV CRTAddress,DX
   ADD DX,6
   MOV StatusReg,DX
 END;
 ASM
    MOV AX,0013h
    INT 10h
    MOV DX,03C4h
    MOV AL,04
    OUT DX,AL
    INC DX
    IN  AL,DX
    AND AL,0F7h
    OR  AL,04
    OUT DX,AL
    MOV DX,03C4h
    MOV AL,02
    OUT DX,AL
    INC DX
    MOV AL,0Fh
    OUT DX,AL
    MOV AX,0A000h
    MOV ES,AX
    SUB DI,DI
    MOV AX,DI
    MOV CX,8000h
    CLD
    REP STOSW
    MOV DX,CRTAddress
    MOV AL,14h
    OUT DX,AL
    INC DX
    IN  AL,DX
    AND AL,0BFh
    OUT DX,AL
    DEC DX
    MOV AL,17h
    OUT DX,AL
    INC DX
    IN  AL,DX
    OR  AL,40h
    OUT DX,AL
 END;
END;
PROCEDURE SetScr(pa:BYTE);ASSEMBLER;
ASM
  MOV DX,CRTAddress
  MOV AL,$0D
  CLI
  OUT DX,AL
  INC DX
  MOV BL,pa
  MOV SI,BX
  AND SI,3
  SHL SI,1
  ADD SI,OFFSET Offset_Adr
  LODSW
  OUT DX,AL
  DEC DX
  MOV AL,$0C
  OUT DX,AL
  INC DX
  MOV AL,AH
  OUT DX,AL
  STI
END;
PROCEDURE TextMode;ASSEMBLER;
ASM
  MOV AX,0003h
  INT 10h
END;
END.