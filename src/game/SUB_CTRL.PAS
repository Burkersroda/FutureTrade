{$O+,F+,G+,S-}
UNIT SUB_CTRL;
INTERFACE USES VESA,DOS,VARS,EFFECTS,SMIX,SUB_DRAW,SUB_TEXT,SPX_CLK,CRTN;
FUNCTION Mouse_Exist:BOOLEAN;
PROCEDURE MouseReset;
PROCEDURE Mouse(dt:BYTE);
FUNCTION Click(x1,y1,x2,y2:INTEGER;but:BYTE):BOOLEAN;
FUNCTION ClickedField:WORD;
PROCEDURE ClickField(felder:WORD);
PROCEDURE ClearKeyboardBuffer;
IMPLEMENTATION
PROCEDURE ClearKeyboardBuffer;
BEGIN
  WHILE KEYPRESSED DO READKEY;
END;
FUNCTION Mouse_Exist:BOOLEAN;
VAR axw:WORD;
BEGIN
  ASM
    MOV AX,0
    INT 33h
    MOV axw,AX
  END;
  IF axw=0 THEN Mouse_Exist:=FALSE ELSE Mouse_Exist:=TRUE;
END;
PROCEDURE MouseReset;ASSEMBLER;
ASM
  MOV AX,4
  MOV CX,320
  MOV DX,240
  INT 33h
END;
PROCEDURE Mouse(dt:BYTE);
FUNCTION CheckMouse:BYTE;
VAR x1,y1,bu:WORD;reg:REGISTERS;fec:BYTE;
BEGIN
  fec:=0;reg.ax:=3;INTR($33,reg);bu:=reg.bx;x1:=reg.cx;y1:=reg.dx;
  reg.ax:=4;reg.cx:=320;reg.dx:=240;INTR($33,reg);
  IF(ms.b<>bu)AND(dt=3)THEN BEGIN ms.b:=bu;fec:=1;END;
  IF x1<>320 THEN BEGIN INC(fec,2);
    ms.x:=ms.x+x1-320;IF ms.x<0 THEN ms.x:=0;IF ms.x>GETMAXX THEN ms.x:=GETMAXX;END;
  IF y1<>240 THEN BEGIN INC(fec,4);
    ms.y:=ms.y+y1-240;IF ms.y<0 THEN ms.y:=0;IF ms.y>GETMAXY THEN ms.y:=GETMAXY;END;
  CheckMouse:=fec;IF dt=3 THEN ms.f:=fec;
END;
VAR ex,ey:INTEGER;pic:BYTE;
BEGIN
  IF(CheckMouse<2)AND(dt=3)THEN EXIT;
  IF dt AND 2=2 THEN PutImage(ms.ox,ms.oy,ms.bg[0],0);
  IF dt AND 1=1 THEN BEGIN ms.ox:=ms.x;ms.oy:=ms.y;
    ex:=ms.x+14;ey:=ms.y+14;
    IF ex>GETMAXX THEN ex:=GETMAXX;
    IF ey>GETMAXY THEN ey:=GETMAXY;
    GetImage(ms.x,ms.y,ex,ey,ms.bg[0]);
    pic:=0;
    IF ms.arrow THEN BEGIN
      IF(ms.x>=30)AND(ms.x<60)THEN INC(pic)
       ELSE IF(ms.x>GETMAXX-60)AND(ms.x<=GETMAXX-30)THEN INC(pic,2);
      IF(ms.y<20)AND(ms.x>=30)AND(ms.x<=GETMAXX-30)THEN INC(pic,4)
       ELSE IF(ms.y>GETMAXY-20)AND(ms.x>=30)AND(ms.x<=GETMAXX-30)THEN INC(pic,8);
    END;
    CASE pic OF
      0:BEGIN
        FOR ex:=0 TO 14 DO IF ms.x+ex<=GETMAXX THEN FOR ey:=0 TO 14 DO IF ms.y+ey<=GETMAXY THEN
         IF(ex>ey DIV 2)AND(ey>ex DIV 2)AND(ex+ey<21)THEN
         PUTPIXEL(ms.x+ex,ms.y+ey,zpal[GETPIXEL(ms.x+ex,ms.y+ey)]);
        LINE2(ms.x,ms.y,ms.x+14,ms.y+7,250);
        LINE2(ms.x,ms.y,ms.x+7,ms.y+14,250);
        LINE2(ms.x+14,ms.y+7,ms.x+7,ms.y+14,250);
      END;
      1:BEGIN
        Line2(ms.x,ms.y+7,ms.x+7,ms.y,250);
        Line2(ms.x+7,ms.y,ms.x+7,ms.y+14,250);
        Line2(ms.x,ms.y+7,ms.x+7,ms.y+14,250);
      END;
      2:BEGIN
        Line2(ms.x+7,ms.y+7,ms.x,ms.y,250);
        Line2(ms.x,ms.y,ms.x,ms.y+14,250);
        Line2(ms.x+7,ms.y+7,ms.x,ms.y+14,250);
      END;
      4:BEGIN
        Line2(ms.x+7,ms.y,ms.x+14,ms.y+7,250);
        Line2(ms.x,ms.y+7,ms.x+14,ms.y+7,250);
        Line2(ms.x,ms.y+7,ms.x+7,ms.y,250);
      END;
      5:BEGIN
        Line2(ms.x,ms.y,ms.x+9,ms.y,250);
        Line2(ms.x,ms.y,ms.x,ms.y+9,250);
        Line2(ms.x+10,ms.y,ms.x,ms.y+10,250);
      END;
      6:BEGIN
        Line2(ms.x,ms.y,ms.x+9,ms.y,250);
        Line2(ms.x+10,ms.y,ms.x+10,ms.y+9,250);
        Line2(ms.x,ms.y,ms.x+10,ms.y+10,250);
      END;
      8:BEGIN
        Line2(ms.x+7,ms.y+7,ms.x+14,ms.y,250);
        Line2(ms.x,ms.y,ms.x+14,ms.y,250);
        Line2(ms.x,ms.y,ms.x+7,ms.y+7,250);
      END;
      9:BEGIN
        Line2(ms.x,ms.y+10,ms.x+9,ms.y+10,250);
        Line2(ms.x,ms.y,ms.x,ms.y+9,250);
        Line2(ms.x,ms.y,ms.x+10,ms.y+10,250);
      END;
      10:BEGIN
        Line2(ms.x,ms.y+10,ms.x+10,ms.y+10,250);
        Line2(ms.x+10,ms.y,ms.x+10,ms.y+9,250);
        Line2(ms.x+10,ms.y,ms.x,ms.y+10,250);
      END;
    END;
  END;
END;
FUNCTION Click(x1,y1,x2,y2:INTEGER;but:BYTE):BOOLEAN;
VAR act:BOOLEAN;
BEGIN
  IF(((ms.b AND but=0)OR(ms.f AND 1=0))AND(key[1]<>#13))OR(ms.x<x1)
   OR(ms.x>x2)OR(ms.y<y1)OR(ms.y>y2)THEN BEGIN Click:=FALSE;EXIT;END;
  act:=TRUE;
  IF exist_SB THEN StartSound(sounds[1],1,FALSE);
  IF key[1]=#13 THEN BEGIN Click:=TRUE;EXIT;END;
  Mouse(2);SETCOLOR(251);
  Line(x1+2,y1+1,x2-2,y1+1);Line(x1+2,y2-1,x2-2,y2-1);
  Line(x1+1,y1+2,x1+1,y2-2);Line(x2-1,y1+2,x2-1,y2-2);
  Mouse(1);
  REPEAT REPEAT Mouse(3);UNTIL ms.f>0;
    IF((ms.b AND but=0)OR(ms.x<x1)OR(ms.x>x2)OR(ms.y<y1)OR(ms.y>y2))
     AND act THEN BEGIN act:=FALSE;
      Mouse(2);SETCOLOR(247);
      Line(x1+2,y1+1,x2-2,y1+1);Line(x1+2,y2-1,x2-2,y2-1);
      Line(x1+1,y1+2,x1+1,y2-2);Line(x2-1,y1+2,x2-1,y2-2);
      Mouse(1);
    END;
    IF((ms.b AND but>0)AND(ms.x>=x1)AND(ms.x<=x2)AND(ms.y>=y1)AND(ms.y<=y2))
     AND NOT act THEN BEGIN act:=TRUE;
      Mouse(2);SETCOLOR(251);
      Line(x1+2,y1+1,x2-2,y1+1);Line(x1+2,y2-1,x2-2,y2-1);
      Line(x1+1,y1+2,x1+1,y2-2);Line(x2-1,y1+2,x2-1,y2-2);
      Mouse(1);
     END;
  UNTIL ms.b AND but=0;
  IF(ms.x>=x1)AND(ms.x<=x2)AND(ms.y>=y1)AND(ms.y<=y2)THEN
   Click:=TRUE ELSE Click:=FALSE;
END;
FUNCTION ClickedField:WORD;
VAR field,but:BYTE;fields:WORD;act:BOOLEAN;
PROCEDURE DrawField;
VAR field2:BYTE;
BEGIN
  IF field<8 THEN BEGIN
    LINE(28,17+60*field,28,42+60*field);
    LINE(0,16+60*field,27,16+60*field);
    LINE(0,43+60*field,27,43+60*field);
  END ELSE BEGIN field2:=field-8;
    LINE(GETMAXX-28,17+60*field2,GETMAXX-28,42+60*field2);
    LINE(GETMAXX-27,16+60*field2,GETMAXX,16+60*field2);
    LINE(GETMAXX-27,43+60*field2,GETMAXX,43+60*field2);
  END;
END;
BEGIN
  ClickedField:=255;
  fields:=cfeld;
  REPEAT
    FOR field:=0 TO 16 DO IF fields AND(WORD(1) SHL field)>0 THEN BREAK;
    IF field=16 THEN BREAK;
    DEC(fields,WORD(1)SHL field);
    IF field<8 THEN BEGIN
      IF(ms.x<30)AND(ms.y>14+60*field)AND(ms.y<45+60*field)AND NOT
       ((ms.x=29)AND((ms.y=15+60*field)OR(ms.y=44+60*field)))THEN BREAK
    END ELSE BEGIN
      IF(ms.x>GETMAXX-30)AND(ms.y>14+60*(field-8))AND(ms.y<45+60*(field-8))AND NOT
       ((ms.x=GETMAXX-29)AND((ms.y=15+60*(field-8))OR(ms.y=44+60*(field-8))))THEN BREAK;
    END;
  UNTIL field=16;
  IF field=16 THEN BEGIN
    IF(tip.xpos<>-1)AND(quicktips)THEN WITH tip DO BEGIN
      Mouse(2);
      PutImage(xpos,ypos,backgr[0],0);
      PutImage(xpos,ypos+9,backgr[1],0);
      Mouse(1);
      xpos:=-1;
    END;
    tip.time:=0;
    EXIT;
  END;
  IF(tip.time>=18)AND(tip.xpos=-1)AND(quicktips)THEN BEGIN
    IF field<8 THEN WITH tip DO BEGIN
      xpos:=32;ypos:=22+60*field;
      IF QuickTip[field,1]='' THEN INC(ypos,5);
      Mouse(2);
      GetImage(xpos,ypos,xpos+79,ypos+6,backgr[0]);
      GetImage(xpos,ypos+9,xpos+79,ypos+15,backgr[1]);
      GreenBar(xpos,ypos,xpos+LENGTH(QuickTip[field,0])*6,ypos+6);
      IF QuickTip[field,1]<>'' THEN GreenBar(xpos,ypos+9,xpos+LENGTH(QuickTip[field,1])*6,ypos+15);
      OutSTxt(xpos+1,ypos+1,QuickTip[field,0],250);
      OutSTxt(xpos+1,ypos+10,QuickTip[field,1],250);
      Mouse(1);
    END ELSE WITH tip DO BEGIN
      xpos:=GETMAXX-118;ypos:=22+60*(field-8);
      IF QuickTip[field,1]='' THEN INC(ypos,5);
      Mouse(2);
      GetImage(xpos,ypos,xpos+79,ypos+6,backgr[0]);
      GetImage(xpos,ypos+9,xpos+79,ypos+15,backgr[1]);
      GreenBar(xpos+79-LENGTH(QuickTip[field,0])*6,ypos,xpos+79,ypos+6);
      IF QuickTip[field,1]<>'' THEN GreenBar(xpos+79-LENGTH(QuickTip[field,1])*6,ypos+9,xpos+79,ypos+15);
      OutSTxt(xpos+80-LENGTH(QuickTip[field,0])*6,ypos+1,QuickTip[field,0],250);
      OutSTxt(xpos+80-LENGTH(QuickTip[field,1])*6,ypos+10,QuickTip[field,1],250);
      Mouse(1);
    END;
  END;
  ClickedField:=field;
  IF(ms.b=0)OR(ms.f AND 1=0)THEN EXIT;
  IF(tip.xpos<>-1)AND(quicktips)THEN WITH tip DO BEGIN
    Mouse(2);
    PutImage(xpos,ypos,backgr[0],0);
    PutImage(xpos,ypos+9,backgr[1],0);
    Mouse(1);
    xpos:=-1;
  END;
  but:=ms.b;
  act:=TRUE;
  IF exist_SB THEN StartSound(sounds[1],1,FALSE);
  Mouse(2);SETCOLOR(251);DrawField;Mouse(1);
  REPEAT REPEAT Mouse(3);UNTIL ms.f>0;
    IF field<8 THEN BEGIN
      IF((ms.b=0)OR(ms.x>29)OR(ms.y<15+60*field)OR(ms.y>44+60*field)OR
       ((ms.x=29)AND((ms.y=15+60*field)OR(ms.y=44+60*field))))AND act THEN BEGIN
        act:=FALSE;Mouse(2);SETCOLOR(247);DrawField;Mouse(1);
      END ELSE IF((ms.b<>0)AND(ms.x<30)AND(ms.y>14+60*field)AND(ms.y<45+60*field)AND NOT
       ((ms.x=29)AND((ms.y=15+60*field)OR(ms.y=44+60*field))))AND NOT act THEN BEGIN
        act:=TRUE;Mouse(2);SETCOLOR(251);DrawField;Mouse(1);
    END;END ELSE BEGIN
      IF((ms.b=0)OR(ms.x<GETMAXX-29)OR(ms.y<15+60*(field-8))OR(ms.y>44+60*(field-8))OR
       ((ms.x=GETMAXX-29)AND((ms.y=15+60*(field-8))OR(ms.y=44+60*(field-8)))))AND act THEN BEGIN
        act:=FALSE;Mouse(2);SETCOLOR(247);DrawField;Mouse(1);
      END ELSE IF((ms.b<>0)AND(ms.x>GETMAXX-30)AND(ms.y>14+60*(field-8))AND(ms.y<45+60*(field-8))AND NOT
       ((ms.x=GETMAXX-29)AND((ms.y=15+60*(field-8))OR(ms.y=44+60*(field-8)))))AND NOT act THEN BEGIN
        act:=TRUE;Mouse(2);SETCOLOR(251);DrawField;Mouse(1);
      END;
    END;
  UNTIL ms.b=0;
  IF field<8 THEN BEGIN
    IF(ms.x<30)AND(ms.y>14+60*field)AND(ms.y<45+60*field)AND NOT
     ((ms.x=29)AND((ms.y=15+60*field)OR(ms.y=44+60*field)))THEN act:=TRUE ELSE act:=FALSE;
  END ELSE BEGIN DEC(field,8);
    IF(ms.x>GETMAXX-30)AND(ms.y>14+60*field)AND(ms.y<45+60*field)AND NOT
     ((ms.x=GETMAXX-29)AND((ms.y=15+60*field)OR(ms.y=44+60*field)))THEN act:=TRUE ELSE act:=FALSE;
    INC(field,8);
  END;
  IF act=FALSE THEN ClickedField:=255 ELSE BEGIN ClickedField:=field+but*16;ms.b:=0;ms.f:=2;END;
  tip.time:=0;
END;
PROCEDURE ClickField(felder:WORD);
VAR field,x1,y1,z0:BYTE;x2,y2,fields,fields2:WORD;
    ico:ARRAY[0..19,0..19]OF BYTE;
    buf:ARRAY[0..16,0..903]OF BYTE;
    time1,time2:LONGINT;
BEGIN
  IF felder=cfeld THEN EXIT;
  felder:=felder AND NOT 6;
  fields:=cfeld OR felder;
  REPEAT
    FOR field:=0 TO 16 DO IF fields AND(WORD(1)SHL field)>0 THEN BREAK;
    IF field=16 THEN BREAK;
    DEC(fields,(WORD(1)SHL field));
    IF field=0 THEN MOVE(icon^[0],ico,400) ELSE
     IF field=15 THEN IF active AND 1=1 THEN MOVE(icon^[14],ico,400)
     ELSE MOVE(icon^[13],ico,400) ELSE MOVE(icon^[field-2],ico,400);
    IF field<8 THEN BEGIN
      IF(cfeld AND(WORD(1)SHL field)>0)AND(felder AND(WORD(1)SHL field)=0)THEN BEGIN
        IF field=0 THEN x1:=0 ELSE x1:=field-2;
        MOVE(cfo^[x1],buf[field,0],904);
      END ELSE GETIMAGE(0,15+60*field,29,44+60*field,buf[field]);
      FOR x1:=0 TO 29 DO FOR y1:=0 TO 29 DO
       IF(x1<29)OR((y1>0)AND(y1<29))THEN buf[field,x1+y1*30+4]:=zpal[buf[field,x1+y1*30+4]];
      FOR x2:=0 TO 27 DO BEGIN buf[field,x2+34]:=247;buf[field,x2+844]:=247;END;
      FOR y2:=2 TO 27 DO buf[field,y2*30+32]:=247;
      buf[field,62]:=244;buf[field,872]:=244;buf[field,91]:=243;buf[field,841]:=243;
      FOR x1:=0 TO 19 DO FOR y1:=0 TO 19 DO BEGIN x2:=x1+2;y2:=y1+4;
        IF(ico[x1,y1]<>0)AND(ico[x1,y1]>buf[field,x2+y2*30+4])THEN buf[field,x2+y2*30+4]:=ico[x1,y1];
      END;
    END ELSE BEGIN
      IF(cfeld AND(WORD(1)SHL field)>0)AND(felder AND(WORD(1)SHL field)=0)THEN
       MOVE(cfo^[field-2],buf[field,0],904)
      ELSE GETIMAGE(GETMAXX-29,15+60*(field-8),GETMAXX,44+60*(field-8),buf[field]);
      FOR x1:=0 TO 29 DO FOR y1:=0 TO 29 DO
       IF(x1>0)OR((y1>0)AND(y1<29))THEN buf[field,x1+y1*30+4]:=zpal[buf[field,x1+y1*30+4]];
      FOR x2:=2 TO 29 DO BEGIN buf[field,x2+34]:=247;buf[field,x2+844]:=247;END;
      FOR y2:=2 TO 27 DO buf[field,y2*30+5]:=247;
      buf[field,35]:=244;buf[field,845]:=244;buf[field,66]:=243;buf[field,816]:=243;
      FOR x1:=0 TO 19 DO FOR y1:=0 TO 19 DO BEGIN x2:=x1+6;y2:=y1+4;
        IF(ico[x1,y1]<>0)AND(ico[x1,y1]>buf[field,x2+y2*30+4])THEN buf[field,x2+y2*30+4]:=ico[x1,y1];
      END;
    END;
  UNTIL fields=0;
  time1:=GetClock;
  FOR z0:=0 TO 14 DO BEGIN
    fields:=(cfeld OR felder) AND NOT cfeld;
    fields2:=cfeld AND NOT felder;
    REPEAT
      FOR field:=0 TO 16 DO IF fields AND(WORD(1)SHL field)>0 THEN BREAK;
      IF field=16 THEN BEGIN
        FOR field:=0 TO 16 DO IF fields2 AND(WORD(1)SHL field)>0 THEN BREAK;
        IF field=16 THEN BREAK;
        DEC(fields2,(WORD(1)SHL field));
        x2:=28-z0*2;
        IF field=0 THEN x1:=0 ELSE x1:=field-2;
        MOVE(cfo^[x1],buf[16,0],904);
        IF field<8 THEN BEGIN
          FOR y2:=0 TO 29 DO MOVE(buf[field,y2*30+6+z0*2],buf[16,y2*30+4],x2);
          PUTIMAGE(0,15+60*field,buf[16],0);
        END ELSE BEGIN
          FOR y2:=0 TO 29 DO MOVE(buf[field,y2*30+4],buf[16,y2*30+z0*2+6],x2);
          PUTIMAGE(GETMAXX-29,15+60*(field-8),buf[16],0);
        END;
      END ELSE BEGIN
        DEC(fields,(WORD(1)SHL field));
        x2:=z0*2+1;
        MOVE(x2,buf[16,0],2);
        MOVE(buf[field,2],buf[16,2],2);
        INC(x2);
        IF field<8 THEN BEGIN
          FOR y2:=0 TO 29 DO MOVE(buf[field,y2*30+32-z0*2],buf[16,y2*x2+4],x2);
          PUTIMAGE(0,15+60*field,buf[16],0);
        END ELSE BEGIN
          FOR y2:=0 TO 29 DO MOVE(buf[field,y2*30+4],buf[16,y2*x2+4],x2);
          PUTIMAGE(GETMAXX-z0*2-1,15+60*(field-8),buf[16],0);
        END;
      END;
    UNTIL(fields=0)AND(fields2=0);
    REPEAT time2:=GetClock;UNTIL time2-time1>=62;
    time1:=time2;
  END;
  cfeld:=felder;
END;

END.