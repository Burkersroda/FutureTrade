{$F+,S-,I-,N+,E+,M 1024,0,0}
UNIT effects;
INTERFACE
USES dos,crtn,vesa;
CONST esc:BOOLEAN=FALSE;
      effect:BOOLEAN=FALSE;
      gamma:BYTE=5;
VAR ppos:BYTE;
    zpal:ARRAY[0..255]OF BYTE;
    pal:Pal256;
    key:ARRAY[1..2]OF CHAR;
PROCEDURE Keys;
PROCEDURE WaitRetrace;
PROCEDURE SetPal(palbuf:pal256);
PROCEDURE InPic(palbuf:Pal256;gr,sf,ef:BYTE);
PROCEDURE WhitePic(palbuf:Pal256;gr,sf,ef:BYTE);
PROCEDURE OutPic(palbuf:Pal256;gr,sf,ef:BYTE);
PROCEDURE BeginInPalEff;
PROCEDURE InPal(palbuf:Pal256;gr,sf,ef:BYTE);
PROCEDURE BeginOutPalEff;
PROCEDURE OutPal(palbuf:Pal256;gr,sf,ef:BYTE);
PROCEDURE XPal;
PROCEDURE BlackPal;
IMPLEMENTATION
PROCEDURE SetPal(palbuf:pal256);
VAR reg:REGISTERS;by0,by1,by2:BYTE;rightgamma:SINGLE;
BEGIN
  IF NOT effect THEN BEGIN
    FOR by0:=0 TO 255 DO zpal[by0]:=ROUND(SQRT(WORD(pal[by0,0]+pal[by0,1]*3+pal[by0,2]*2)DIV 6))+236;
    FOR by0:=0 TO 15 DO zpal[by0+236]:=by0 DIV 2+236;
  END;
  rightgamma:=1-gamma/30;
  IF gamma>1 THEN FOR by0:=0 TO 255 DO FOR by1:=0 TO 2 DO
   palbuf[by0,by1]:=TRUNC(EXP(rightgamma*LN((palbuf[by0,by1]+1)/64))*63);
  WaitRetrace;
  reg.ax:=$1012;
  reg.bx:=0;
  reg.cx:=256;
  reg.es:=SEG(palbuf);
  reg.dx:=OFS(palbuf);
  INTR($10,reg);
END;
PROCEDURE BlackPal;
VAR palbuf:Pal256;
BEGIN
  FILLCHAR(palbuf,768,0);
  SetPal(palbuf);
END;
PROCEDURE XPal;
VAR b1:BYTE;
BEGIN
  FILLCHAR(pal[236],60,0);
  FOR b1:=236 TO 251 DO BEGIN
    pal[b1,1]:=(b1-236)*4+3;
    pal[b1,2]:=(b1-236)*2+19;
  END;
  FILLCHAR(pal[252],9,32);
  pal[252,0]:=63;pal[253,1]:=63;pal[254,2]:=63;
  FILLCHAR(pal[255],3,9);
END;
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
PROCEDURE Keys;
VAR keycode:WORD;
BEGIN
  IF NOT KEYPRESSED THEN BEGIN key[1]:=#0;key[2]:=#0;EXIT;END;
  keycode:=READKEY;
  key[1]:=CHAR(LO(keycode));
  key[2]:=CHAR(HI(keycode));
  IF key[1]=#224 THEN key[1]:=#0;
END;
PROCEDURE BeginInPalEff;
BEGIN
  ppos:=63;
END;
PROCEDURE BeginOutPalEff;
BEGIN
  ppos:=0;
END;
PROCEDURE InPal(palbuf:Pal256;gr,sf,ef:BYTE);
VAR palbf:Pal256;xz,yz:BYTE;
BEGIN
  palbf:=palbuf;FOR yz:=sf TO ef DO FILLCHAR(palbf[yz,0],3,0);
  IF ppos>=gr THEN BEGIN DEC(ppos,gr);FOR yz:=sf TO ef DO BEGIN
    IF palbuf[yz,0]>ppos THEN palbf[yz,0]:=palbuf[yz,0]-ppos ELSE palbf[yz,0]:=0;
    IF palbuf[yz,1]>ppos THEN palbf[yz,1]:=palbuf[yz,1]-ppos ELSE palbf[yz,1]:=0;
    IF palbuf[yz,2]>ppos THEN palbf[yz,2]:=palbuf[yz,2]-ppos ELSE palbf[yz,2]:=0;
  END;SetPal(palbf);END
   ELSE BEGIN SetPal(palbuf);END;
END;
PROCEDURE InPic(palbuf:Pal256;gr,sf,ef:BYTE);
VAR palbf:Pal256;xz,yz:BYTE;
BEGIN
  palbf:=palbuf;xz:=gr;effect:=TRUE;
  WHILE xz<63-gr DO BEGIN INC(xz,gr);
    IF esc THEN BEGIN Keys;IF key[1]=#27 THEN BREAK;END;
    FOR yz:=sf TO ef DO BEGIN
      palbf[yz,0]:=TRUNC(palbuf[yz,0]/63*xz);
      palbf[yz,1]:=TRUNC(palbuf[yz,1]/63*xz);
      palbf[yz,2]:=TRUNC(palbuf[yz,2]/63*xz);
    END;
    SetPal(palbf);
  END;
  effect:=FALSE;SetPal(palbuf);
END;
PROCEDURE WhitePic(palbuf:Pal256;gr,sf,ef:BYTE);
VAR palbf:Pal256;xz,yz:BYTE;
BEGIN
  palbf:=palbuf;xz:=gr;effect:=TRUE;
  WHILE xz<63-gr DO BEGIN INC(xz,gr);
    IF esc THEN BEGIN Keys;IF key[1]=#27 THEN BREAK;END;
    FOR yz:=sf TO ef DO BEGIN
      palbf[yz,0]:=63-TRUNC((63-palbuf[yz,0])/63*xz);
      palbf[yz,1]:=63-TRUNC((63-palbuf[yz,1])/63*xz);
      palbf[yz,2]:=63-TRUNC((63-palbuf[yz,2])/63*xz);
    END;
    SetPal(palbf);
  END;
  effect:=FALSE;SetPal(palbuf);
END;
PROCEDURE OutPic(palbuf:Pal256;gr,sf,ef:BYTE);
VAR palbf:Pal256;xz,yz:BYTE;paldif:ARRAY[0..255,0..2]OF SINGLE;
BEGIN
  palbf:=palbuf;xz:=63-gr;effect:=TRUE;
  WHILE xz>gr DO BEGIN DEC(xz,gr);
    IF esc THEN BEGIN Keys;IF key[1]=#27 THEN BREAK;END;
    FOR yz:=sf TO ef DO BEGIN
      palbf[yz,0]:=TRUNC(palbuf[yz,0]/63*xz);
      palbf[yz,1]:=TRUNC(palbuf[yz,1]/63*xz);
      palbf[yz,2]:=TRUNC(palbuf[yz,2]/63*xz);
    END;
    SetPal(palbf);
  END;
  effect:=FALSE;FILLCHAR(palbf[sf,0],(ef-sf+1)*3,0);SetPal(palbf);
END;
PROCEDURE OutPal(palbuf:Pal256;gr,sf,ef:BYTE);
VAR palbf:Pal256;xz,yz:BYTE;
BEGIN
  palbf:=palbuf;
  IF ppos<=63-gr THEN BEGIN INC(ppos,gr);FOR yz:=sf TO ef DO BEGIN
    IF palbuf[yz,0]>ppos THEN palbf[yz,0]:=palbuf[yz,0]-ppos ELSE palbf[yz,0]:=0;
    IF palbuf[yz,1]>ppos THEN palbf[yz,1]:=palbuf[yz,1]-ppos ELSE palbf[yz,1]:=0;
    IF palbuf[yz,2]>ppos THEN palbf[yz,2]:=palbuf[yz,2]-ppos ELSE palbf[yz,2]:=0;
  END;SetPal(palbf);END ELSE
   BEGIN FILLCHAR(palbf[sf,0],(ef-sf+1)*3,0);SetPal(palbf);END;
END;
END.