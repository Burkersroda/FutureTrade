{$O+,F+,S-,G+}
UNIT SUB_DRAW;
INTERFACE USES VESA,EFFECTS,VARS,SUB_TEXT;
PROCEDURE GreenBar(x1,y1,x2,y2:INTEGER);
PROCEDURE GrBar(x1,y1,x2,y2:INTEGER;st0:STRING);
PROCEDURE GetCFOriginals(darker:BOOLEAN);
FUNCTION TimeString:STRING;
FUNCTION Dec2Hex(w0:WORD):STRING;
FUNCTION Hex2Dec(s:STRING):WORD;
FUNCTION UpString(st:STRING):STRING;
IMPLEMENTATION
FUNCTION UpString(st:STRING):STRING;
VAR cnt:BYTE;
BEGIN
  FOR cnt:=1TO LENGTH(st)DO BEGIN
    CASE st[cnt]OF 'a'..'z':st[cnt]:=UPCASE(st[cnt]);
      '„':st[cnt]:='Ž';
      '”':st[cnt]:='™';
      '':st[cnt]:='š';
    END;
  END;
  UpString:=st;
END;
FUNCTION Dec2Hex(w0:WORD):STRING;
CONST HexChars:ARRAY[0..$F]OF CHAR='0123456789ABCDEF';
VAR st0:STRING[4];
BEGIN
  st0:=HexChars[(w0 AND $F000)SHR 12]+HexChars[(w0 AND $0F00)SHR 8]
   +HexChars[(w0 AND $00F0)SHR 4]+HexChars[(w0 AND $000F)];
  WHILE(st0[1]='0')AND(LENGTH(st0)>1)DO st0:=COPY(st0,2,LENGTH(st0)-1);
  Dec2Hex:=st0;
END;
FUNCTION Hex2Dec(s:STRING):WORD;
VAR position,value:BYTE;w00,w01:WORD;
BEGIN
  w00:=0;
  w01:=1;
  FOR position:=LENGTH(s) DOWNTO 1 DO BEGIN
    IF(s[position]>='0')AND(s[position]<='9')THEN value:=ORD(s[position])-48
    ELSE IF(s[position]>='A')AND(s[position]<='F')THEN value:=ORD(s[position])-55
    ELSE value:=0;
    INC(w00,WORD(value)*w01);
    w01:=w01*16;
  END;
  Hex2Dec:=w00;
END;
PROCEDURE GreenBar(x1,y1,x2,y2:INTEGER);
VAR xbr,xz,yz:WORD;wo:WORD;
BEGIN
  IF LONGINT(ABS(x2-x1))*LONGINT(ABS(y2-y1))>64000 THEN BEGIN
    FOR xz:=x1 TO x2 DO
     FOR yz:=y1 TO y2 DO IF((xz<>x1)AND(xz<>x2))OR((yz<>y1)AND(yz<>y2))THEN BEGIN
      PutPixel(xz,yz,zpal[GetPixel(xz,yz)]);
    END;
  END ELSE BEGIN
    NEW(tpage);
    GETIMAGE(x1,y1,x2,y2,tpage^);
    xbr:=x2-x1+1;
    FOR xz:=1 TO xbr DO
     FOR yz:=0 TO y2-y1 DO IF((xz<>1)AND(xz<>xbr))OR((yz<>0)AND(yz<>y2-y1))THEN BEGIN
      wo:=yz*xbr+xz+3;
      tpage^[wo]:=zpal[tpage^[wo]];
    END;
    PUTIMAGE(x1,y1,tpage^,0);
    DISPOSE(tpage);
  END;
END;
PROCEDURE GrBar(x1,y1,x2,y2:INTEGER;st0:STRING);
VAR xbr,xz,yz:WORD;wo:WORD;
BEGIN
  GreenBar(x1,y1,x2,y2);
  SETCOLOR(247);RECTANGLE(x1+1,y1+1,x2-1,y2-1);
  OutText((x1+x2+3)DIV 2,(y1+y2-1)DIV 2-9,st0,240,6,1.5);
  PutPixel(x1+1,y1+1,244);PutPixel(x2-1,y1+1,244);
  PutPixel(x1+1,y2-1,244);PutPixel(x2-1,y2-1,244);
  PutPixel(x1+2,y1+2,243);PutPixel(x2-2,y1+2,243);
  PutPixel(x1+2,y2-2,243);PutPixel(x2-2,y2-2,243);
END;
FUNCTION TimeString:STRING;
VAR s5:STRING[5];s2:STRING[2];
BEGIN
  STR((stime.gt+4760)/100:0:2,s5);
  STR(stime.ev,s2);IF s2[0]=#1 THEN s2:='0'+s2;
  TimeString:=s5+':'+s2+' ST';
END;
PROCEDURE GetCFOriginals(darker:BOOLEAN);
VAR field,by0:BYTE;x1,y1:WORD;
BEGIN
  by0:=0;
  FOR field:=0 TO 7 DO IF(field=0)OR(field>2)THEN BEGIN
    GETIMAGE(0,15+60*field,29,44+60*field,cfo^[by0]);
    INC(by0);
  END;
  FOR field:=0 TO 7 DO BEGIN
    GETIMAGE(GETMAXX-29,15+60*field,GETMAXX,44+60*field,cfo^[by0]);
    INC(by0);
  END;
  cfeld:=0;
  IF active AND 5>0 THEN BEGIN
    GETIMAGE(269,463,370,475,tbkgr^);
    GreenBar(269,463,370,475);
    OutBTxt((GETMAXX+1) DIV 2-49,GETMAXY-14,TimeString,248);
  END;
END;

END.