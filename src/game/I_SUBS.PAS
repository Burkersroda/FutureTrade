{$S-,N+,E+,I-,G+,F-}
{$A+,B-,P-,Q-,R-,T-,V+,X+}

UNIT I_Subs;
{  Main-Unit for Install            }
{  (c)1996-97 by Ronny Burkersroda  }

INTERFACE

USES crt,dos,i_font,vesa,effects,memory,i_vars;

FUNCTION Mouse_Exist:BOOLEAN;
PROCEDURE MapPal;
FUNCTION Click(x1,y1,x2,y2:INTEGER;but:BYTE):BOOLEAN;
FUNCTION Dec2Hex(w:WORD):STRING;
PROCEDURE Dot2Comma(VAR st0:STRING);
PROCEDURE ClearKeyboardBuffer;
PROCEDURE OutPut(x,y:BYTE;st:STRING;col:WORD);
PROCEDURE GotoXY(x,y:BYTE);
PROCEDURE MouseReset;
PROCEDURE Mouse(dt:BYTE);
PROCEDURE OutBTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
PROCEDURE TextMode;
PROCEDURE BlackPal;
PROCEDURE BlBar(x1,y1,x2,y2:INTEGER);
FUNCTION LoadMMLtrack(ssx,ssy:WORD;coeff:WORD;labl:STRING;palend:BYTE):BOOLEAN;
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
PROCEDURE Dot2Comma(VAR st0:STRING);
VAR by0:BYTE;
BEGIN
  FOR by0:=1 TO LENGTH(st0) DO IF st0[by0]='.' THEN st0[by0]:=',';
END;
FUNCTION Dec2Hex(w:WORD):STRING;
VAR w2:WORD;b4:ARRAY[1..4]OF BYTE;b:BYTE;st,s2:STRING;
BEGIN
  IF w=0 THEN BEGIN dec2hex:='0000';exit;END;
  b4[1]:=TRUNC(w/4096);b4[2]:=TRUNC((w-LONGINT(b4[1])*4096)/256);
  b4[3]:=TRUNC((w-LONGINT(b4[2])*256-LONGINT(b4[1])*4096)/16);
  b4[4]:=W-LONGINT(b4[3])*16-LONGINT(b4[2])*256-LONGINT(b4[1])*4096;
  s2:='';FOR b:=1 TO 4 DO BEGIN
    IF b4[b]>9 THEN BEGIN CASE b4[b] OF 10:st:='A';11:st:='B';12:st:='C';
        13:st:='D';14:st:='E';15:st:='F';END;
    END ELSE STR(b4[b],st);s2:=s2+st;END;
  WHILE s2[1]='0' DO s2:=copy(s2,2,length(s2)-1);
  FOR w2:=1 TO 4-LENGTH(s2) DO s2:='0'+s2;Dec2Hex:=s2;
END;
PROCEDURE ClearKeyboardBuffer;
BEGIN
  WHILE KEYPRESSED DO READKEY;
END;
PROCEDURE OutPut(x,y:BYTE;st:STRING;col:WORD);
VAR reg:REGISTERS;
BEGIN
  reg.cx:=ORD(st[0]);reg.es:=SEG(st[1]);reg.bp:=OFS(st[1]);
  reg.ax:=$1300;reg.bx:=col;reg.dh:=y;reg.dl:=x;INTR($10,reg);
END;
PROCEDURE GotoXY(x,y:BYTE);ASSEMBLER;
ASM
  MOV AH,2
  MOV BH,0
  MOV DH,y
  MOV DL,x
  INT 10h
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
    ms.y:=ms.y+y1-240;If ms.y<0 THEN ms.y:=0;IF ms.y>GETMAXY THEN ms.y:=GETMAXY;END;
  CheckMouse:=fec;IF dt=3 THEN ms.f:=fec;
END;
VAR ex,ey:INTEGER;
BEGIN
  IF(CheckMouse=0)AND(dt=3)THEN EXIT;
  IF(ms.f<>1)AND(dt AND 2=2)THEN PUTIMAGE(ms.ox,ms.oy,ms.bg[0],0);
  IF dt AND 1=1 THEN BEGIN
    IF(ms.f<>1)OR(dt<>3)THEN BEGIN
      ms.ox:=ms.x;ms.oy:=ms.y;
      ex:=ms.x+14;ey:=ms.y+14;
      IF ex>GETMAXX THEN ex:=GETMAXX;
      IF ey>GETMAXY THEN ey:=GETMAXY;
      GETIMAGE(ms.x,ms.y,ex,ey,ms.bg[0]);
      FOR ex:=0 TO 14 DO FOR ey:=0 TO 14 DO
       IF(ex>ey DIV 2)AND(ey>ex DIV 2)AND(ex+ey<21)THEN
       PUTPIXEL(ms.x+ex,ms.y+ey,zpal[GETPIXEL(ms.x+ex,ms.y+ey)]);
    END;
    IF ms.b=0THEN SETCOLOR(220)ELSE SETCOLOR(223);
    LINE(ms.x,ms.y,ms.x+14,ms.y+7);
    LINE(ms.x,ms.y,ms.x+7,ms.y+14);
    LINE(ms.x+14,ms.y+7,ms.x+7,ms.y+14);
  END;
END;
FUNCTION Click(x1,y1,x2,y2:INTEGER;but:BYTE):BOOLEAN;
VAR act:BOOLEAN;
BEGIN
  IF(((ms.b AND but=0)OR(ms.f AND 1=0))AND(key[1]<>#13))OR(ms.x<x1)
   OR(ms.x>x2)OR(ms.y<y1)OR(ms.y>y2)THEN BEGIN Click:=FALSE;EXIT;END;
  act:=TRUE;{IF sound_ready AND InitSoundFile('BEEP')THEN PlaySound;}
  IF key[1]=#13 THEN BEGIN Click:=TRUE;EXIT;END;
  Mouse(2);SETCOLOR(251);RECTANGLE(x1+1,y1+1,x2-1,y2-1);Mouse(1);
  REPEAT REPEAT Mouse(3);UNTIL ms.f>0;
    IF((ms.b AND but=0)OR(ms.x<x1)OR(ms.x>x2)OR(ms.y<y1)OR(ms.y>y2))
     AND act THEN BEGIN act:=FALSE;
      Mouse(2);SETCOLOR(247);RECTANGLE(x1+1,y1+1,x2-1,y2-1);Mouse(1);END;
    IF((ms.b AND but>0)AND(ms.x>=x1)AND(ms.x<=x2)AND(ms.y>=y1)AND(ms.y<=y2))
     AND NOT act THEN BEGIN act:=TRUE;
      Mouse(2);SETCOLOR(251);RECTANGLE(x1+1,y1+1,x2-1,y2-1);Mouse(1);END;
  UNTIL ms.b AND but=0;
  IF(ms.x>=x1)AND(ms.x<=x2)AND(ms.y>=y1)AND(ms.y<=y2)THEN
   Click:=TRUE ELSE Click:=FALSE;
END;
FUNCTION ClickedField:WORD;
VAR field,but:BYTE;fields:WORD;act:BOOLEAN;
PROCEDURE DrawField;
BEGIN
  IF field<8 THEN BEGIN LINE(28,17+60*field,28,42+60*field);
    LINE(0,16+60*field,27,16+60*field);LINE(0,43+60*field,27,43+60*field);
    PUTPIXEL(28,16+60*field,GETCOLOR-4);PUTPIXEL(28,43+60*field,GETCOLOR-4);
    PUTPIXEL(27,17+60*field,GETCOLOR-4);PUTPIXEL(27,42+60*field,GETCOLOR-4);
  END ELSE BEGIN LINE(GETMAXX-28,17+60*(field-8),GETMAXX-28,42+60*(field-8));
    LINE(GETMAXX-27,16+60*(field-8),GETMAXX,16+60*(field-8));LINE(GETMAXX-27,43+60*(field-8),GETMAXX,43+60*(field-8));
    PUTPIXEL(GETMAXX-28,16+60*field,GETCOLOR-4);PUTPIXEL(GETMAXX-28,43+60*field,GETCOLOR-4);
    PUTPIXEL(GETMAXX-27,17+60*field,GETCOLOR-4);PUTPIXEL(GETMAXX-27,42+60*field,GETCOLOR-4);
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
  IF field=16 THEN EXIT;
  ClickedField:=field;
  IF(ms.b=0)OR(ms.f AND 1=0)THEN EXIT;
  but:=ms.b;
  act:=TRUE;{IF sound_ready AND InitSoundFile('BEEP')THEN PlaySound;}
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
END;
PROCEDURE MapPal;
VAR by1:BYTE;
BEGIN
  FILLCHAR(pal,64*3,0);
  FOR by1:=0 TO 67 DO pal[by1+1,1]:=by1 DIV 3+16;
  FOR by1:=0 TO 31 DO pal[by1+37,0]:=by1*2;
  FOR by1:=0 TO 31 DO pal[by1+1,0]:=16-by1 DIV 2;
  FILLCHAR(pal[255],3,9);
  SetPal(pal);
END;
PROCEDURE OutBTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
VAR pos:BYTE;lv:fd;xv,yv,xq:WORD;yon:BOOLEAN;
BEGIN
  IF xp>16000 THEN BEGIN yon:=TRUE;DEC(xp,16384);END ELSE yon:=FALSE;
  FOR pos:=1 TO LENGTH(st) DO BEGIN fontdata(st[pos],lv);
    FOR xv:=0 TO 7 DO IF(xp+xv>=0)AND(xp+xv<=GETMAXX)THEN BEGIN xq:=TRUNC((xv+xp)/4);
      FOR yv:=0 TO 10 DO IF(yp+yv>=0)AND(yp+yv<=GETMAXY)AND(lv[xv,yv]>0)THEN
       IF NOT yon THEN PUTPIXEL(xv+xp,yv+yp,col) ELSE PUTPIXEL(xv+xp,yv+yp,zpal[GETPIXEL(xv+xp,yv+yp)]);
    END;INC(xp,9);
  END;
END;
{PROCEDURE OutSTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
VAR pos:BYTE;lv:sfd;xv,yv,xq:WORD;
BEGIN
  FOR pos:=1 TO LENGTH(st) DO BEGIN sfntdata(st[pos],lv);
    FOR xv:=0 TO 4 DO IF (xp+xv>=0) AND (xp+xv<=GETMAXX) THEN BEGIN xq:=TRUNC((xv+xp)/4);
      FOR yv:=0 TO 4 DO BEGIN IF (yp+yv>=0) AND (yp+yv<=GETMAXY) AND (lv[xv+2,yv]>0) THEN
        PUTPIXEL(xv+xp,yv+yp,col);
      END;
    END;INC(xp,6);
  END;
END;}
PROCEDURE TextMode;ASSEMBLER;
ASM
  MOV AX,0003h
  INT 10h
END;
PROCEDURE BlackPal;
VAR palbuf:Pal256;
BEGIN
  FILLCHAR(palbuf,768,0);
  SetPal(palbuf);
END;
PROCEDURE BlBar(x1,y1,x2,y2:INTEGER);
VAR xbr,xz,yz:WORD;wo:WORD;map:^ScrArray;
BEGIN
  NEW(map);
  wo:=IMAGESIZE(x1,y1,x2,y2);
  IF wo=0 THEN EXIT;
  GETIMAGE(x1,y1,x2,y2,map^);
  xbr:=x2-x1+1;
  FOR xz:=1 TO xbr DO BEGIN
    FOR yz:=0 TO y2-y1 DO BEGIN wo:=yz*xbr+xz+3;
      map^[wo]:=zpal[map^[wo]];
    END;
  END;
  PUTIMAGE(x1,y1,map^,0);
  DISPOSE(map);
END;
FUNCTION LoadMMLtrack(ssx,ssy:WORD;coeff:WORD;labl:STRING;palend:BYTE):BOOLEAN;
VAR tanz,tco,w0,sx,sy:WORD;temp:m32k;s40:STRING[40];sp:LONGINT;
    typ:BYTE;tf:FILE;
FUNCTION LiesTrack:BOOLEAN;
FUNCTION SchreibBlk(anz:WORD):BOOLEAN;
VAR cc:WORD;
BEGIN
  IF DISKFREE(0)<anz+1024 THEN BEGIN SchreibBlk:=FALSE;EXIT;END;
  BLOCKWRITE(tf,temp[0],anz,cc);
  IF cc<>anz THEN SchreibBlk:=FALSE ELSE SchreibBlk:=TRUE;
END;
FUNCTION Entpacken:BOOLEAN;
VAR s12:STRING[12];sr:SEARCHREC;tl:LONGINT;
BEGIN
  STR(tco,s12);WHILE LENGTH(s12)<5 DO s12:='0'+s12;s12:=s12+'.DAT';
  ASSIGN(tf,s12);REWRITE(tf,1);
  SEEK(pf,sp);
  BLOCKREAD(pf,temp[0],4,w0);
  tl:=LONGINT(temp[0])+LONGINT(temp[1])*256+LONGINT(temp[2])*65536+LONGINT(temp[3])*16777216;
  REPEAT IF tl>32768 THEN w0:=32768 ELSE w0:=tl;
    DEC(tl,w0);
    BLOCKREAD(pf,temp,w0,w0);
    IF NOT SchreibBlk(w0) THEN w0:=65535;
  UNTIL(w0=65535)OR(w0=0)OR(tl=0);
  CLOSE(tf);
  IF w0=65535 THEN Entpacken:=FALSE ELSE Entpacken:=TRUE;
END;
FUNCTION BlockEntpacken:BOOLEAN;
VAR s12:STRING[12];sr:SEARCHREC;fl:LONGINT;cnt,anz:WORD;
BEGIN
  SEEK(pf,sp);
  BLOCKREAD(pf,temp[0],6,w0);
  anz:=temp[4]+temp[5]*256;cnt:=0;
  REPEAT INC(cnt);
    BLOCKREAD(pf,s12[0],1,w0);
    BLOCKREAD(pf,s12[1],ORD(s12[0]),w0);
    FINDFIRST(s12,$3F,sr);w0:=0;
    ASSIGN(tf,s12);REWRITE(tf,1);
    BLOCKREAD(pf,temp[0],4,w0);
    fl:=LONGINT(temp[0])+LONGINT(temp[1])*256+LONGINT(temp[2])*65536+LONGINT(temp[3])*16777216;
    REPEAT IF fl>32768 THEN w0:=32768 ELSE w0:=0;
      DEC(fl,w0);
      BLOCKREAD(pf,temp,w0,w0);
      IF NOT SchreibBlk(w0) THEN w0:=65535;
    UNTIL(w0=65535)OR(w0=0)OR(fl=0);
    CLOSE(tf);
  UNTIL(w0=65535)OR(cnt=anz);
  IF w0=65535 THEN BlockEntpacken:=FALSE ELSE BlockEntpacken:=TRUE;
END;
FUNCTION Bild8Bit:BOOLEAN;
VAR br,ho,bre,hoe,lng,tst:WORD;col,act,bst:BYTE;
    gd,gm:INTEGER;
BEGIN
  SEEK(pf,sp);Bild8Bit:=FALSE;
  BLOCKREAD(pf,temp,776,w0);
  br:=temp[4]+temp[5]*256;
  ho:=temp[6]+temp[7]*256;
  IF ssx=65535 THEN sx:=(GETMAXX-br)DIV 2 ELSE sx:=ssx;
  IF ssy=65535 THEN sy:=(GETMAXY-ho)DIV 2 ELSE sy:=ssy;
  IF ssx=65534 THEN BEGIN sx:=0;sy:=0;END;
  FILLCHAR(pal[0],WORD(palend+1)*3,0);
  IF palend>0 THEN BEGIN SetPal(pal);MOVE(temp[8],pal[0],WORD(palend+1)*3);
  END ELSE MOVE(temp[8],pal[0],768);
  FOR hoe:=0 TO ho-1 DO BEGIN
    BLOCKREAD(pf,temp,2,w0);
    lng:=temp[0]+temp[1]*256;
    BLOCKREAD(pf,temp,lng,w0);
    bre:=0;tst:=0;
    WHILE tst<lng-1 DO BEGIN act:=temp[tst];
      FOR bst:=0 TO 7 DO IF tst<lng-1 THEN BEGIN INC(tst);
        IF act AND (1 SHL bst)=0THEN BEGIN
          IF(ssx<>65534)OR((hoe>ssy-16)AND(hoe<ssy+15))THEN PUTPIXEL(sx+bre,sy+hoe,temp[tst]);INC(bre);END
         ELSE BEGIN SETCOLOR(temp[tst]);INC(tst);
          IF(ssx<>65534)OR((hoe>ssy-16)AND(hoe<ssy+15))THEN LINE(sx+bre,sy+hoe,sx+bre+temp[tst],sy+hoe);
          INC(bre,temp[tst]+1);END;
      END;
      INC(tst);
    END;
  END;
  IF(palend<>0)AND(palend<>203)THEN SetPal(pal);
  Bild8Bit:=TRUE;
END;
BEGIN
  CASE typ OF
    1:LiesTrack:=Entpacken;
    2:LiesTrack:=BlockEntpacken;
    3:LiesTrack:=Bild8Bit;
  END;
END;
BEGIN
  LoadMMLtrack:=FALSE;SEEK(pf,mml_spos);
  BLOCKREAD(pf,temp,2,w0);tanz:=temp[0]+temp[1]*256;
  FOR tanz:=1 TO tanz DO BEGIN
    BLOCKREAD(pf,temp,3,w0);tco:=temp[0]+temp[1]*256;
    BLOCKREAD(pf,s40[1],temp[2],w0);s40[0]:=CHR(temp[2]);
    BLOCKREAD(pf,temp,5,w0);typ:=temp[0];
    sp:=LONGINT(temp[1])+LONGINT(temp[2])*256+LONGINT(temp[3])*65536+LONGINT(temp[4])*16777216;
    IF((labl='#*')AND(coeff=tco))OR(labl=s40)THEN BEGIN
      LoadMMLtrack:=LiesTrack;BREAK;
    END;
  END;
END;

END.