{$O+,F+,G+,S-,N+,E+}
UNIT SUB_TEXT;
INTERFACE USES normfont,smallfnt,fontunit,VESA,EFFECTS,VARS;
PROCEDURE OutText(xp,yp:INTEGER;st:STRING;col,aus:BYTE;di:SINGLE);
PROCEDURE OutBTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
PROCEDURE OutSTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
IMPLEMENTATION
PROCEDURE OutText(xp,yp:INTEGER;st:STRING;col,aus:BYTE;di:SINGLE);
VAR pos:BYTE;lv:ltr;xv,yv:WORD;ye:SHORTINT;
BEGIN
  IF aus AND 1=1 THEN FOR pos:=1 TO LENGTH(st) DO BEGIN lletter(st[pos],lv);
    IF st[pos]=#32 THEN DEC(xp,lv.w+8) ELSE DEC(xp,lv.w+2);END;
  IF aus AND 2=2 THEN BEGIN xv:=0;
    FOR pos:=1 TO LENGTH(st) DO BEGIN lletter(st[pos],lv);
      IF st[pos]=#32 THEN INC(xv,lv.w+8) ELSE INC(xv,lv.w+2);
    END;
    DEC(xp,xv DIV 2);
  END;
  FOR pos:=1 TO LENGTH(st) DO BEGIN
    lletter(st[pos],lv);
    IF lv.w>0 THEN FOR xv:=0 TO lv.w-1 DO
     IF (xp+xv>=0) AND (xp+xv<=GETMAXX) THEN BEGIN
      FOR yv:=1 TO 16 DO BEGIN CASE st[pos] OF 'Q':ye:=2;'-','%':ye:=-7;
          '+',':':ye:=-5;'*':ye:=-4;'#','=':ye:=-6;'"':ye:=-11;ELSE ye:=0;END;
        IF(yp+yv+ye>=0)AND(yp+yv+ye<=GETMAXY)AND(lv.b[xv,yv]>0)AND NOT
        ((aus AND 4=4)AND(GETPIXEL(xv+xp,yv+yp+ye)>=col+TRUNC(lv.b[xv,yv]/di)))THEN
         IF di<=16 THEN PUTPIXEL(xv+xp,yv+yp+ye,col+TRUNC(lv.b[xv,yv]/di))
         ELSE PUTPIXEL(xv+xp,yv+yp+ye,zpal[GETPIXEL(xv+xp,yv+yp+ye)]);
      END;
    END;IF st[pos]=#32 THEN INC(xp,lv.w+8) ELSE INC(xp,lv.w+2);
  END;x_p:=xp;
END;
PROCEDURE OutBTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
VAR pos:BYTE;lv:fd;xv,yv,xq:WORD;yon:BOOLEAN;
BEGIN
  IF xp>16000 THEN BEGIN yon:=TRUE;DEC(xp,16384);END ELSE yon:=FALSE;
  FOR pos:=1 TO LENGTH(st) DO BEGIN fontdata(st[pos],lv);
    FOR xv:=0 TO 7 DO IF(xp+xv>=0)AND(xp+xv<=GETMAXX)THEN BEGIN xq:=TRUNC((xv+xp)/4);
      FOR yv:=0 TO 8 DO IF(yp+yv>=0)AND(yp+yv<=GETMAXY)AND(lv[xv,yv]>0)THEN
       IF NOT yon THEN PUTPIXEL(xv+xp,yv+yp,col) ELSE PUTPIXEL(xv+xp,yv+yp,zpal[GETPIXEL(xv+xp,yv+yp)]);
    END;INC(xp,9);
  END;
END;
PROCEDURE OutSTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
VAR pos:BYTE;lv:sfd;xv,yv,xq:WORD;
BEGIN
  FOR pos:=1 TO LENGTH(st) DO BEGIN sfntdata(st[pos],lv);
    FOR xv:=0 TO 4 DO IF (xp+xv>=0) AND (xp+xv<=GETMAXX) THEN BEGIN xq:=TRUNC((xv+xp)/4);
      FOR yv:=0 TO 4 DO BEGIN IF (yp+yv>=0) AND (yp+yv<=GETMAXY) AND (lv[xv+2,yv]>0) THEN
        PUTPIXEL(xv+xp,yv+yp,col);
      END;
    END;INC(xp,6);
  END;
END;

END.