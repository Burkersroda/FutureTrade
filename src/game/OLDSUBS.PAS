{$S-,N+,E+,I-,G+,F-}
{$A+,B-,P-,Q-,R-,T-,V+,X+}

UNIT Subs;
{  Main-Unit for FutureTrade        }
{  (c)1996-99 by Ronny Burkersroda  }

INTERFACE

USES crtn,dos,normfont,smallfnt,fontunit,vesa,sb_vars,effects,memory,vars,
     sound_sb,modexlib{,spx_clk};

PROCEDURE Intro;
PROCEDURE Outro;
PROCEDURE GameOver(typ:BYTE);
FUNCTION Mouse_Exist:BOOLEAN;
PROCEDURE Sort(nr:WORD);
FUNCTION TypeName(nr:BYTE):STRING;
PROCEDURE MapPal;
FUNCTION ClickedField:WORD;
FUNCTION Click(x1,y1,x2,y2:INTEGER;but:BYTE):BOOLEAN;
FUNCTION Dec2Hex(w:WORD):STRING;
PROCEDURE Dot2Comma(VAR st0:STRING);
PROCEDURE ClearKeyboardBuffer;
PROCEDURE OutPut(x,y:BYTE;st:STRING;col:WORD);
PROCEDURE GotoXY(x,y:BYTE);
PROCEDURE MouseReset;
FUNCTION Entfernung(x1,y1,x2,y2:INTEGER):LONGINT;
FUNCTION Schnitt(x11,y11,x12,y12,x21,y21,x22,y22:INTEGER):BOOLEAN;
PROCEDURE GetCFOriginals(darker:BOOLEAN);
PROCEDURE Mouse(dt:BYTE);
PROCEDURE GrBar(x1,y1,x2,y2:INTEGER;st0:STRING);
PROCEDURE ClickField(felder:WORD);
FUNCTION TimeString:STRING;
PROCEDURE OutText(xp,yp:INTEGER;st:STRING;col,aus:BYTE;di:SINGLE);
PROCEDURE OutBTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
PROCEDURE OutSTxt(xp,yp:INTEGER;st:STRING;col:BYTE);
PROCEDURE PlayCD(f,u:WORD);
PROCEDURE TextMode;
PROCEDURE BlackPal;
FUNCTION LoadMMLtrack(ssx,ssy:WORD;coeff:WORD;labl:STRING;palend:BYTE):BOOLEAN;
PROCEDURE ID(VAR st:STRING;byt:BYTE);
PROCEDURE Wait(ttw:WORD);
FUNCTION UpString(st:STRING):STRING;
FUNCTION CreateMap:BOOLEAN;

IMPLEMENTATION

FUNCTION UpString(st:STRING):STRING;
VAR cnt:BYTE;
BEGIN
  FOR cnt:=1TO LENGTH(st)DO BEGIN
    CASE st[cnt]OF 'a'..'z':st[cnt]:=UPCASE(st[cnt]);
      'Ñ':st[cnt]:='é';
      'î':st[cnt]:='ô';
      'Å':st[cnt]:='ö';
    END;
  END;
  UpString:=st;
END;
(*PROCEDURE Intro;
VAR s1:STRING[1];
PROCEDURE ShowIntro;
BEGIN
  esc:=TRUE;
  Keys;IF key[1]=#27 THEN EXIT;
  IF InitSoundFile('INTRO')THEN PlaySound;
  LoadMMLtrack(32768,0,0,'ani.GWS Logo',255);IF key[1]=#27 THEN EXIT;
  OutPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
  CLEARDEVICE;LoadMMLtrack(0,0,0,'ani.Intro-Text',255);
  IF key[1]=#27 THEN EXIT;
  IF InitSoundFile('SIM')THEN PlaySound;
  Wait(6);IF key[1]=#27 THEN EXIT;
  LoadMMLtrack(160,140,0,'ani.SIM',255);IF key[1]=#27 THEN EXIT;
  Wait(4);OutPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
  IF InitSoundFile('TITEL')THEN PlaySound;
  LoadMMLtrack(65535,65535,0,'ani.Titel',255);IF key[1]=#27 THEN EXIT;
  Wait(27);IF key[1]=#27 THEN EXIT;
  OutPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
  FOR b1:=1 TO 4 DO  BEGIN STR(b1,s1);
    IF InitSoundFile('STORY'+s1)THEN PlaySound;
    CLEARDEVICE;LoadMMLtrack(0,1,0,'ani.Intro '+s1,255);
    IF key[1]=#27 THEN EXIT;
  END;
  {IF InitSoundFile('STORY2')THEN PlaySound;
  CLEARDEVICE;LoadMMLtrack(0,0,0,'ani.Intro 2',255);
  IF key[1]=#27 THEN EXIT;
  FOR b1:=3 TO 3 DO BEGIN STR(b1,s1);
    CLEARDEVICE;LoadMMLtrack(0,0,0,'scr.I'+s1,0);
    InPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
    Wait(32);IF key[1]=#27 THEN EXIT;
    FILLCHAR(pal,768,63);SetPal(pal);
    LoadMMLtrack(0,0,0,'scr.I'+s1+'t',0);
    IF InitSoundFile('STORY'+s1)THEN PlaySound;
    WhitePic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
    IF sound_ready THEN Wait(364) ELSE Wait(0);IF key[1]=#27 THEN EXIT;
    OutPic(pal,2,0,255);IF key[1]=#27 THEN EXIT;
  END;
  IF InitSoundFile('STORY4')THEN PlaySound;
  CLEARDEVICE;LoadMMLtrack(0,0,0,'ani.Intro 4',255);}
END;
BEGIN
  OutPic(pal,4,0,255);
  ShowIntro;
  FILLCHAR(pal,765,0);
  FOR b1:=236 TO 251 DO pal[b1,1]:=(b1-236)*4+3;
  FILLCHAR(pal[252],9,32);
  pal[252,0]:=63;pal[253,1]:=63;pal[254,2]:=63;
  FILLCHAR(pal[255],3,9);
  IF NOT sound_ready THEN SoundDone;
  CLEARDEVICE;LoadMMLtrack(0,0,0,'scr.HauptmenÅ',235);
  InPic(pal,4,0,255);
  GetCFOriginals;
END;*)
PROCEDURE OpenMML(st0:STRING);
VAR w0:WORD;
BEGIN
  CLOSE(pf);ASSIGN(pf,st0);RESET(pf,1);
  IF IORESULT=0 THEN BEGIN
    BLOCKREAD(pf,page^[1],8,w0);st0:='';
    FOR w0:=1 TO w0 DO st0:=st0+CHR(page^[w0]);
    IF st0<>mml_kopf THEN BEGIN CLOSE(pf);OpenMML(mml_main);EXIT;END;
    BLOCKREAD(pf,page^[1],80,w0);st0:='';
    FOR w0:=1 TO w0 DO st0:=st0+CHR(page^[w0]);
    mml_spos:=POS(mml_tend,st0);
    IF mml_spos=0 THEN BEGIN CLOSE(pf);OpenMML(mml_main);EXIT;END;
    INC(mml_spos,10);
  END;
END;
PROCEDURE Intro;
VAR s1:STRING[1];
PROCEDURE ShowIntro;
BEGIN
  esc:=TRUE;
  Keys;IF key[1]=#27 THEN EXIT;
  CLEARDEVICE;
  IF InitSoundFile('GWS_LOGO')THEN PlaySound;
  LoadMMLtrack(32768,0,0,'ani.GWS Logo',255);IF key[1]=#27 THEN EXIT;
  IF key[1]=' 'THEN IF NOT sound_ready THEN SoundDone;
  CLEARDEVICE;
  REPEAT Keys;UNTIL(sound_ready)OR(key[1]=' ')OR(key[1]=#27);
  IF key[1]=#27 THEN EXIT;
  IF key[1]=' 'THEN IF NOT sound_ready THEN SoundDone;
  IF InitSoundFile('M_INTRO1')THEN PlaySound;
  LoadMMLtrack(32768,0,0,'ani.Vorspann',255);IF key[1]=#27 THEN EXIT;
  FOR b1:=1 TO 4 DO  BEGIN STR(b1,s1);
    IF InitSoundFile('STORY'+s1)THEN PlaySound;
    CLEARDEVICE;LoadMMLtrack(0,1,0,'ani.Intro '+s1,255);
    IF key[1]=#27 THEN EXIT;
  END;
END;
BEGIN
  OutPic(pal,4,0,255);
  OpenMML(mml_anim);
  ShowIntro;
  FILLCHAR(pal,765,0);
  FOR b1:=236 TO 251 DO pal[b1,1]:=(b1-236)*4+3;
  FILLCHAR(pal[252],9,32);
  pal[252,0]:=63;pal[253,1]:=63;pal[254,2]:=63;
  FILLCHAR(pal[255],3,9);
  IF NOT sound_ready THEN SoundDone;
  OpenMML(mml_main);
  CLEARDEVICE;LoadMMLtrack(0,0,0,'scr.HauptmenÅ',235);
  InPic(pal,4,0,255);
  GetCFOriginals(TRUE);
END;
PROCEDURE Outro;
PROCEDURE ShowOutro;
VAR st0:STRING[2];
BEGIN
  esc:=TRUE;
  Keys;IF key[1]=#27 THEN EXIT;
  FOR b1:=1TO 10DO BEGIN
    ClearDevice;BlackPal;STR(b1,st0);
    LoadMMLtrack(32768,0,0,'ani.Outro '+st0,255);IF key[1]=#27 THEN EXIT;
  END;
END;
BEGIN
  OpenMML(mml_anim);
  ShowOutro;
  FILLCHAR(pal,765,0);
  FOR b1:=236 TO 251 DO pal[b1,1]:=(b1-236)*4+3;
  FILLCHAR(pal[252],9,32);
  pal[252,0]:=63;pal[253,1]:=63;pal[254,2]:=63;
  FILLCHAR(pal[255],3,9);
  OpenMML(mml_main);
  CLEARDEVICE;LoadMMLtrack(0,0,0,'scr.HauptmenÅ',235);
  InPic(pal,4,0,255);active:=active AND NOT 5;
  GetCFOriginals(TRUE);
END;
PROCEDURE GameOver(typ:BYTE);
PROCEDURE ShowOutro;
BEGIN
  esc:=TRUE;
  Keys;IF key[1]=#27 THEN EXIT;
  IF typ=1 THEN BEGIN
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 1',255);IF key[1]=#27 THEN EXIT;
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 2',255);IF key[1]=#27 THEN EXIT;
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 3',255);IF key[1]=#27 THEN EXIT;
    ClearDevice;BlackPal;
    LoadMMLtrack(32769,00,0,'ani.Game Over 4',255);
    InPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
    LoadMMLtrack(32768,0,0,'ani.Game Over 4',255);IF key[1]=#27 THEN EXIT;
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 5',255);IF key[1]=#27 THEN EXIT;
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 6',255);IF key[1]=#27 THEN EXIT;
    OutPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
  END ELSE BEGIN
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 7',255);IF key[1]=#27 THEN EXIT;
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 8',255);IF key[1]=#27 THEN EXIT;
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 9',255);IF key[1]=#27 THEN EXIT;
    ClearDevice;BlackPal;
    LoadMMLtrack(32768,0,0,'ani.Game Over 10',255);IF key[1]=#27 THEN EXIT;
    OutPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
  END;
END;
BEGIN
  OpenMML(mml_anim);
  ShowOutro;
  FILLCHAR(pal,765,0);
  FOR b1:=236 TO 251 DO pal[b1,1]:=(b1-236)*4+3;
  FILLCHAR(pal[252],9,32);
  pal[252,0]:=63;pal[253,1]:=63;pal[254,2]:=63;
  FILLCHAR(pal[255],3,9);
  OpenMML(mml_main);
  CLEARDEVICE;LoadMMLtrack(0,0,0,'scr.HauptmenÅ',235);
  InPic(pal,4,0,255);active:=active AND NOT 5;
  GetCFOriginals(TRUE);
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
PROCEDURE Sort(nr:WORD);
VAR tn:STRING[20];tt:BYTE;tx,ty,ti:WORD;
BEGIN
  tn:=mapx^.tn[nr];mapx^.tn[nr]:=mapx^.tn[nr+1];mapx^.tn[nr+1]:=tn;
  tt:=mapx^.tt[nr];mapx^.tt[nr]:=mapx^.tt[nr+1];mapx^.tt[nr+1]:=tt;
  tx:=mapx^.tx[nr];mapx^.tx[nr]:=mapx^.tx[nr+1];mapx^.tx[nr+1]:=tx;
  ty:=mapx^.ty[nr];mapx^.ty[nr]:=mapx^.ty[nr+1];mapx^.ty[nr+1]:=ty;
  ti:=mapx^.ti[nr];mapx^.ti[nr]:=mapx^.ti[nr+1];mapx^.ti[nr+1]:=ti;
END;
FUNCTION TypeName(nr:BYTE):STRING;
VAR st,s1:STRING[20];
BEGIN
  IF nr<21 THEN BEGIN
    IF mapx^.tt[nr]AND 2=0THEN BEGIN st:='RAUMHAFEN';
      IF mapx^.it=nr THEN st:='FREIE STADT' ELSE
       IF mapx^.tt[nr]AND 1=0THEN st:='STADT';
    END ELSE st:='HAUPTSTADT';
  END ELSE BEGIN
    STR(ORD(mapx^.tn[1,2])+ORD(mapx^.tn[2,1])-128,s1);
    STR(nr-20,st);
    IF st[0]=#1 THEN st:='0'+st;
    IF s1[0]=#1 THEN s1:='0'+s1;
    st:='ID-NR. '+s1+'-'+st;
  END;
  TypeName:=st;
END;
PROCEDURE Wait(ttw:WORD);
VAR reg0:REGISTERS;
BEGIN
  IF key[1]=#32 THEN EXIT;
  time:=0;REPEAT Keys;reg0.ax:=3;INTR($33,reg0);
    IF reg0.bx=1 THEN key[1]:=#32 ELSE IF reg0.bx=2 THEN key[1]:=#27;
  UNTIL(key[1]=#27)OR(key[1]=#32)OR((ttw<>0)AND(time>=ttw))OR((ttw=0)AND(sound_ready));
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
FUNCTION Entfernung(x1,y1,x2,y2:INTEGER):LONGINT;
VAR lo0,lo1:LONGINT;sgl:SINGLE;
BEGIN
  lo0:=x2-x1;
  lo1:=y2-y1;
  sgl:=SQRT(SQR(lo0)+SQR(lo1));
  Entfernung:=ROUND(sgl);
END;
FUNCTION Schnitt(x11,y11,x12,y12,x21,y21,x22,y22:INTEGER):BOOLEAN;
VAR x0,y0,m1,m2,n1,n2:DOUBLE;
    x3,y3:INTEGER;
BEGIN
  Schnitt:=TRUE;
  IF y11>y12 THEN BEGIN x3:=x11;y3:=y11;x11:=x12;y11:=y12;x12:=x3;y12:=y3;END;
  IF y21>y22 THEN BEGIN x3:=x21;y3:=y21;x21:=x22;y21:=y22;x22:=x3;y22:=y3;END;
  IF(x11-x12=0)OR(x21-x22=0)THEN EXIT;
  m1:=(y11-y12)/(x11-x12);
  m2:=(y21-y22)/(x21-x22);
  n1:=y11-m1*x11;
  n2:=y21-m2*x21;
  IF m1=m2 THEN BEGIN IF n1<>n2 THEN Schnitt:=FALSE;EXIT;END;
  x0:=(n2-n1)/(m1-m2);
  y0:=m1*x0+n1;
  IF(y0<=y11+0.005)OR(y0>=y12-0.005)
   OR(y0<=y21+0.005)OR(y0>=y22-0.005)
   THEN Schnitt:=FALSE;
END;
{FUNCTION OpenMPA(name:STRING;VAR mpaf:mpa_file):BYTE;
TYPE ch12=ARRAY[1..12]OF CHAR;
CONST kennung:ch12=('M','P','A',' ','1','.','0','0',#13,#10,#26,#26);
VAR b0:BYTE;w0:WORD;erk:ch12;
BEGIN
  ASSIGN(mpaf.af,name);RESET(mpaf.af,1);
  IF IORESULT<>0 THEN BEGIN OpenMPA:=1;EXIT;END;
  BLOCKREAD(mpaf.af,erk,12,w0);
  IF erk<>kennung THEN BEGIN CLOSE(mpaf.af);OpenMPA:=2;EXIT;END;
  BLOCKREAD(mpaf.af,mpaf.anz,2,w0);
  mpaf.pos:=0;
  BLOCKREAD(mpaf.af,b0,1,w0);
  mpaf.bez[0]:=CHR(b0);
  BLOCKREAD(mpaf.af,mpaf.bez[1],b0,w0);
  OpenMPA:=0;
END;
FUNCTION LoadMPA(x1,y1:INTEGER;VAR mpaf:mpa_file;col:INTEGER):BYTE;
VAR b0,ho,pln:BYTE;br,w0:WORD;bp:Pal256;
BEGIN
  IF mpaf.pos=mpaf.anz THEN BEGIN
    SEEK(mpaf.af,15+LENGTH(mpaf.bez));mpaf.pos:=1;END ELSE INC(mpaf.pos);
  BLOCKREAD(mpaf.af,b0,1,w0);
  CASE b0 OF
    1:BEGIN FILLCHAR(bp[0,0],3,0);BLOCKREAD(mpaf.af,bp[1,0],765,w0);
      MOVE(bp[0,0],pal[col,0],(256-col)*3);END;
    2:BEGIN BLOCKREAD(mpaf.af,br,2,w0);BLOCKREAD(mpaf.af,ho,1,w0);
      br:=(br-1)DIV 4+1;
      FOR pln:=0 TO 3 DO FOR ho:=1 TO ho DO
       BLOCKREAD(mpaf.af,page[0]^[pln*16000+x1 DIV 4+(ho+y1-1)*80+1],br,w0);
      IF col<>0 THEN FOR pln:=0 TO 3 DO FOR ho:=1 TO ho DO FOR br:=1 TO br DO
       INC(page[0]^[pln*16000+x1 DIV 4+(ho+y1-1)*80+br],col);
    END;
  END;
  LoadMPA:=b0;
END;
PROCEDURE ShowPic(pa1,pa:BYTE);
VAR i,oldMode:BYTE;splane:WORD;pnt1,pnt2:POINTER;
    msback:array[1..15,1..16]of byte;
PROCEDURE DrawBack;
VAR xs,ys:INTEGER;wx,xp:BYTE;
BEGIN
  FOR xs:=ms.x TO ms.x+14 DO BEGIN wx:=xs DIV 4;xp:=xs-ms.x+1;
    IF xs<320 THEN CASE xs-integer(wx)*4+1 OF 1:FOR ys:=ms.y TO ms.y+14 DO
       IF ys<200 THEN page[pa1]^[wx+ys*80+1]:=msback[ys-ms.y+1,xs-ms.x+1];
      2:FOR ys:=ms.y TO ms.y+14 DO IF ys<200 THEN page[pa1]^[wx+ys*80+16001]:=msback[ys-ms.y+1,xs-ms.x+1];
      3:FOR ys:=ms.y TO ms.y+14 DO IF ys<200 THEN page[pa1]^[wx+ys*80+32001]:=msback[ys-ms.y+1,xs-ms.x+1];
      4:FOR ys:=ms.y TO ms.y+14 DO IF ys<200 THEN page[pa1]^[wx+ys*80+48001]:=msback[ys-ms.y+1,xs-ms.x+1];END;END;
END;
PROCEDURE GetBack;
VAR xs,ys:INTEGER;wx,xp:BYTE;
BEGIN
  FOR xs:=ms.x TO ms.x+14 DO begin wx:=xs DIV 4;xp:=xs-ms.x+1;
    IF xs<320 THEN CASE xs-integer(wx)*4+1 OF 1:FOR ys:=ms.y TO ms.y+14 DO
       IF ys<200 THEN msback[ys-ms.y+1,xs-ms.x+1]:=page[pa1]^[wx+ys*80+1];
      2:FOR ys:=ms.y TO ms.y+14 DO IF ys<200 THEN msback[ys-ms.y+1,xs-ms.x+1]:=page[pa1]^[wx+ys*80+16001];
      3:FOR ys:=ms.y TO ms.y+14 DO IF ys<200 THEN msback[ys-ms.y+1,xs-ms.x+1]:=page[pa1]^[wx+ys*80+32001];
      4:FOR ys:=ms.y TO ms.y+14 DO IF ys<200 THEN msback[ys-ms.y+1,xs-ms.x+1]:=page[pa1]^[wx+ys*80+48001];END;END;
END;
PROCEDURE DrawArrow;
CONST mspfeil:ARRAY[0..1,1..15,1..15]OF BYTE =
      ( ( (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
          (0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
          (0, 1, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
          (0, 0, 1, 2, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0),
          (0, 0, 1, 2, 2, 2, 2, 1, 1, 0, 0, 0, 0, 0, 0),
          (0, 0, 0, 1, 2, 2, 2, 2, 2, 1, 1, 0, 0, 0, 0),
          (0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 0, 0),
          (0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1),
          (0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 0),
          (0, 0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 1, 0, 0),
          (0, 0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 1, 0, 0),
          (0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 1, 0),
          (0, 0, 0, 0, 0, 0, 1, 2, 2, 1, 1, 2, 2, 2, 1),
          (0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 2, 2, 1),
          (0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1) ),
        ( (2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
          (2, 1, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
          (0, 1, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
          (2, 0, 1, 0, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0),
          (2, 2, 1, 2, 2, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0),
          (0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0),
          (0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0),
          (0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1),
          (0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0),
          (0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0),
          (0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0),
          (0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0),
          (0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1),
          (0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1),
          (0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 1) ) );
VAR xs,ys:INTEGER;wx,xp:BYTE;
BEGIN
  FOR xs:=ms.x TO ms.x+14 DO begin wx:=xs DIV 4;xp:=xs-ms.x+1;
    IF xs<320 THEN CASE xs-integer(wx)*4+1 OF 1:FOR ys:=ms.y TO ms.y+14 DO
       IF (mspfeil[ms.n,ys-ms.y+1,xs-ms.x+1]>0) AND (ys<200) THEN
        page[pa1]^[wx+ys*80+1]:=ms.c[mspfeil[ms.n,ys-ms.y+1,xs-ms.x+1]];
      2:FOR ys:=ms.y TO ms.y+14 DO IF (mspfeil[ms.n,ys-ms.y+1,xs-ms.x+1]>0) AND
        (ys<200) THEN page[pa1]^[wx+ys*80+16001]:=ms.c[mspfeil[ms.n,ys-ms.y+1,xs-ms.x+1]];
      3:FOR ys:=ms.y TO ms.y+14 DO IF (mspfeil[ms.n,ys-ms.y+1,xs-ms.x+1]>0) AND
        (ys<200) THEN page[pa1]^[wx+ys*80+32001]:=ms.c[mspfeil[ms.n,ys-ms.y+1,xs-ms.x+1]];
      4:FOR ys:=ms.y TO ms.y+14 DO IF (mspfeil[ms.n,ys-ms.y+1,xs-ms.x+1]>0) AND
        (ys<200) THEN page[pa1]^[wx+ys*80+48001]:=ms.c[mspfeil[ms.n,ys-ms.y+1,xs-ms.x+1]];END;END;
END;
BEGIN
  IF ms.on THEN BEGIN GetBack;DrawArrow;END;
  ASM CLI END;
  port[$3ce]:=5;
  oldMode:=port[$3cf];
  ASM STI END;
  FOR i:=0 TO 3 DO BEGIN
    splane:=2+(TranslateTab[i] SHL 8);
    CASE i OF 0:pnt1:=@page[pa1]^[1];1:pnt1:=@page[pa1]^[16001];
     2:pnt1:=@page[pa1]^[32001];3:pnt1:=@page[pa1]^[48001];END;
    pnt2:=ptr(Segment_Adr[pa],0);
    ASM
      CLI
      MOV DX,3CEh
      MOV AX,4005h
      OUT DX,AX
      MOV AX,splane
      MOV DX,3C4h
      OUT DX,AX
      LES DI,pnt2
      LDS SI,pnt1
      MOV CX,16000 SHR 1
      REP movsw
      MOV AX,SEG @DATA
      MOV DS,AX
      STI
    END;
  END;
  portw[$3ce]:=oldMode SHL 8 + 5;
  IF ms.on THEN DrawBack;
END;}
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
  IF(CheckMouse<2)AND(dt=3)THEN EXIT;
  IF dt AND 2=2 THEN PUTIMAGE(ms.ox,ms.oy,ms.bg[0],0);
  IF dt AND 1=1 THEN BEGIN ms.ox:=ms.x;ms.oy:=ms.y;
    ex:=ms.x+14;ey:=ms.y+14;
    IF ex>GETMAXX THEN ex:=GETMAXX;
    IF ey>GETMAXY THEN ey:=GETMAXY;
    GETIMAGE(ms.x,ms.y,ex,ey,ms.bg[0]);
    FOR ex:=0 TO 14 DO FOR ey:=0 TO 14 DO
     IF(ex>ey DIV 2)AND(ey>ex DIV 2)AND(ex+ey<21)THEN
     PUTPIXEL(ms.x+ex,ms.y+ey,zpal[GETPIXEL(ms.x+ex,ms.y+ey)]);
    SETCOLOR(250);
    LINE(ms.x,ms.y,ms.x+14,ms.y+7);
    LINE(ms.x,ms.y,ms.x+7,ms.y+14);
    LINE(ms.x+14,ms.y+7,ms.x+7,ms.y+14);
  END;
END;
PROCEDURE GrBar(x1,y1,x2,y2:INTEGER;st0:STRING);
VAR xbr,xz,yz:WORD;wo:WORD;
BEGIN
  NEW(tpage);
  wo:=IMAGESIZE(x1,y1,x2,y2);
  IF wo=0 THEN EXIT;
  GETIMAGE(x1,y1,x2,y2,tpage^);
  xbr:=x2-x1+1;
  FOR xz:=1 TO xbr DO BEGIN
    FOR yz:=0 TO y2-y1 DO BEGIN wo:=yz*xbr+xz+3;
      tpage^[wo]:=zpal[tpage^[wo]];
    END;
  END;
  PUTIMAGE(x1,y1,tpage^,0);
  SETCOLOR(247);RECTANGLE(x1+1,y1+1,x2-1,y2-1);
  OutText((x1+x2+3)DIV 2,(y1+y2-1)DIV 2-9,st0,240,6,1.5);
  DISPOSE(tpage);
END;
FUNCTION TimeString:STRING;
VAR s5:STRING[5];s2:STRING[2];
BEGIN
  STR((stime.gt+4760)/100:0:2,s5);
  STR(stime.ev,s2);IF s2[0]=#1 THEN s2:='0'+s2;
  TimeString:=s5+':'+s2+' ST';
END;
FUNCTION Click(x1,y1,x2,y2:INTEGER;but:BYTE):BOOLEAN;
VAR act:BOOLEAN;
BEGIN
  IF(((ms.b AND but=0)OR(ms.f AND 1=0))AND(key[1]<>#13))OR(ms.x<x1)
   OR(ms.x>x2)OR(ms.y<y1)OR(ms.y>y2)THEN BEGIN Click:=FALSE;EXIT;END;
  act:=TRUE;IF sound_ready AND InitSoundFile('BEEP')THEN PlaySound;
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
  act:=TRUE;IF sound_ready AND InitSoundFile('BEEP')THEN PlaySound;
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
VAR b0:BYTE;
BEGIN
  FILLCHAR(pal,576,0);
  FOR b0:=1 TO 31 DO BEGIN
    pal[b0,0]:=TRUNC(b0/0.6);pal[b0,1]:=TRUNC(b0/0.75);pal[b0,2]:=TRUNC(b0/1.5);
    pal[b0+32,1]:=b0*2;pal[b0+32,2]:=TRUNC(b0/1.5);
    pal[b0+64,0]:=b0*2;pal[b0+64,1]:=TRUNC(b0/0.6);pal[b0+64,2]:=b0;
    FILLCHAR(pal[b0+96,0],3,TRUNC(b0*1.66));
  END;
  FOR b2:=0 TO 2 DO FOR b0:=0 TO 7 DO FOR b1:=0 TO 2 DO
   pal[b0+b2*8+128,b1]:=(pal[b0*4+b2*32+2,b1]+pal[b0*4+(b2+1)*32+2,b1])DIV 2;
  MOVE(tilpal,pal[160,0],192);
  SetPal(pal);
END;
FUNCTION DiskOp(op:BYTE):BOOLEAN;
VAR sr:SEARCHREC;s1:STRING;s2:STRING[3];st:STRING[24];cp,cnt,iws:BYTE;
    names:ARRAY[1..100]OF STRING[12];bez:ARRAY[1..100]OF STRING[24];f0:FILE;
    x1,y1,x2,x3:WORD;
FUNCTION PackMap:BOOLEAN;
VAR bb0,col,lng,bst:BYTE;hoe,bre,tst,sst:WORD;
BEGIN
  PackMap:=FALSE;
  IF DISKFREE(0)<SQR(1024)THEN EXIT;
  FOR bb0:=1 TO 15 DO BEGIN
    XMS_2_RAM(map[0],xms[bb0],64000);
    FOR hoe:=0 TO 63 DO BEGIN
      MOVE(map[0]^[0,hoe],page^[16000],maxfieldx+1);
      FILLCHAR(page^[0],2048,0);
      col:=page^[16000];lng:=0;bst:=0;tst:=0;sst:=0;
      FOR bre:=1 TO 1000 DO BEGIN
        IF(page^[bre+16000]=col)AND(lng<255)AND(bre<1000)THEN INC(lng) ELSE BEGIN
          IF lng>0 THEN page^[sst]:=page^[sst]OR(1 SHL bst);
          INC(bst);INC(tst);
          IF lng>0 THEN BEGIN page^[tst]:=col;INC(tst);page^[tst]:=lng;END
           ELSE page^[tst]:=col;lng:=0;
          IF bst=8 THEN BEGIN INC(tst);sst:=tst;bst:=0;END;
          col:=page^[bre+16000];
        END;
      END;
      IF bst<>0 THEN INC(tst);
      page^[2048]:=LO(tst);page^[2049]:=HI(tst);
      BLOCKWRITE(f0,page^[2048],2,x1);
      BLOCKWRITE(f0,page^[0],tst,x1);
    END;
  END;
  PackMap:=TRUE;
END;
FUNCTION UnpackMap:BOOLEAN;
VAR bb0,col,bst,act:BYTE;lng,hoe,bre,tst,sst:WORD;
BEGIN
  UnpackMap:=FALSE;
  FOR bb0:=1 TO 15 DO BEGIN
    FILLCHAR(map[0]^,64000,0);
    FOR hoe:=0 TO 63 DO BEGIN
      BLOCKREAD(f0,page^,2,x1);
      lng:=page^[0]+page^[1]*256;
      BLOCKREAD(f0,page^,lng,x1);
      bre:=0;tst:=0;
      WHILE tst<lng-1 DO BEGIN act:=page^[tst];
        FOR bst:=0 TO 7 DO IF tst<lng-1 THEN BEGIN INC(tst);
          IF act AND(1 SHL bst)=0THEN BEGIN
            map[0]^[bre,hoe]:=page^[tst];INC(bre);END
           ELSE BEGIN FILLCHAR(map[0]^[bre],page^[tst+1]+1,page^[tst]);
            INC(tst);INC(bre,page^[tst]+1);END;
        END;
        INC(tst);
      END;
    END;
    RAM_2_XMS(map[0],xms[bb0],64000);
  END;
  UnpackMap:=TRUE;
END;
PROCEDURE InPut;
VAR pos:BYTE;
FUNCTION Gross:CHAR;
BEGIN
  CASE key[1] OF 'Ñ':Gross:='é';
    'î':Gross:='ô';
    'Å':Gross:='ö';
    ELSE Gross:=UPCASE(key[1]);
  END;
END;
BEGIN
  ClearKeyboardBuffer;
  IF cp=0 THEN st:='' ELSE st:=bez[cp];
  pos:=LENGTH(st)+1;time:=0;
  Mouse(1);
  REPEAT
    IF(ms.x>=GETMAXX DIV 2-134)AND(ms.x<=GETMAXX DIV 2+113)
     AND(ms.y>=219)AND(ms.y<=250)THEN Mouse(2);
    BAR(GETMAXX DIV 2-114,239,GETMAXX DIV 2+113,250);
    OutBTxt(GETMAXX DIV 2-113,240,st,247);
    IF(ms.x>=GETMAXX DIV 2-134)AND(ms.x<=GETMAXX DIV 2+113)
     AND(ms.y>=219)AND(ms.y<=250)THEN Mouse(1);
    REPEAT Keys;Mouse(3);
      IF Click(GETMAXX DIV 2,259,GETMAXX DIV 2+119,299,7) THEN key[1]:=#27;
      IF Click(GETMAXX DIV 2-120,259,GETMAXX DIV 2-1,299,7) THEN key[1]:=#13;
      IF(iws=7)AND(cp<>0)AND Click(GETMAXX DIV 2-120,301,GETMAXX DIV 2+119,341,7) THEN key[1]:=#1;
      IF(time<4)OR(key[2]<>#0)THEN SETCOLOR(238) ELSE SETCOLOR(249);
      IF time>7 THEN time:=0;
      IF(time=0)OR(time=4)OR(key[2]<>#0)THEN BEGIN
        IF(ms.x>=GETMAXX DIV 2-142+pos*9)AND(ms.x<=GETMAXX DIV 2-115+pos*9)
         AND(ms.y>=229)AND(ms.y<=250)THEN Mouse(2);
        RECTANGLE(GETMAXX DIV 2-122+pos*9,249,GETMAXX DIV 2-115+pos*9,250);
        IF(ms.x>=GETMAXX DIV 2-142+pos*9)AND(ms.x<=GETMAXX DIV 2-115+pos*9)
         AND(ms.y>=229)AND(ms.y<=250)THEN Mouse(1);
      END;
      CASE key[2] OF #75:IF pos>1 THEN DEC(pos);
        #77:IF pos<LENGTH(st)+1 THEN INC(pos);
        #71:pos:=1;
        #79:pos:=LENGTH(st)+1;
      END;
      IF key[2]<>#83 THEN key[2]:=#0;
      IF(key[1]<#32)AND(key[1]<>#8)AND(key[1]<>#27)AND(key[1]<>#13)AND(key[1]<>#1)THEN key[1]:=#0;
    UNTIL(key[1]<>#0)OR(key[2]<>#0);
    IF(key[1]>#31)AND(key[1]<#155)AND(LENGTH(st)<24)THEN BEGIN
     st:=COPY(st,1,pos-1)+Gross+COPY(st,pos,LENGTH(st)-pos+1);INC(pos);END;
    IF(key[1]=#8)AND(pos>1)THEN BEGIN
     st:=COPY(st,1,pos-2)+COPY(st,pos,LENGTH(st)-pos+1);DEC(pos);END;
    IF(key[2]=#83)AND(pos<=LENGTH(st))AND(LENGTH(st)>0)THEN st:=COPY(st,1,pos-1)+COPY(st,pos+1,LENGTH(st)-pos);
  UNTIL(key[1]=#27)OR((key[1]=#13)AND(st<>''))OR((key[1]=#1)AND(iws=7));
  IF key[1]=#13 THEN s1:=st ELSE IF key[1]=#1 THEN INC(cp,100) ELSE cp:=245;
  Mouse(2);
END;
PROCEDURE BubbleSort;
PROCEDURE Sort(nr:WORD);
VAR s0:STRING[24];s1:STRING[12];
BEGIN
  s0:=bez[nr];bez[nr]:=bez[nr+1];bez[nr+1]:=s0;
  s1:=names[nr];names[nr]:=names[nr+1];names[nr+1]:=s1;
END;
VAR sorted:BOOLEAN;cpos,result:BYTE;snr:WORD;
begin
  IF cnt<2 THEN EXIT;
  REPEAT sorted:=FALSE;
    FOR snr:=1TO cnt-1DO BEGIN cpos:=0;result:=0;
      REPEAT INC(cpos);
        IF ORD(bez[snr,cpos])<ORD(bez[snr+1,cpos])THEN result:=1 ELSE
        IF ORD(bez[snr,cpos])>ORD(bez[snr+1,cpos])THEN result:=2;
      UNTIL(result>0)OR(cpos=24);
      IF result>1THEN BEGIN sort(snr);sorted:=TRUE;END;
    END;
  UNTIL NOT sorted;
END;
PROCEDURE DrawIt;
VAR z0:BYTE;ya:BYTE;col:BYTE;
BEGIN
  ya:=138;IF(x2=255)AND(cnt<100)THEN BEGIN z0:=0;INC(ya,12);END ELSE z0:=1;
  INC(cp,z0);
  IF cp<>y1 THEN BEGIN y1:=cp;
    MOUSE(2);
    FOR z0:=z0 TO cnt DO BEGIN s1:='';
      IF z0=0 THEN st:='[NEUE DATEI ERSTELLEN]' ELSE st:=bez[z0];
      IF cp=z0 THEN col:=253 ELSE col:=247;
      IF(st<>'')AND(z0*12+ya<300)THEN OutBTxt(GETMAXX DIV 2-TRUNC(4.5*LENGTH(st)),z0*12+ya,st,col);
    END;
    MOUSE(1);
  END;
END;
BEGIN
  DiskOp:=FALSE;
  IF op=1 THEN s2:='SZN' ELSE s2:='SAV';
  FINDFIRST('FT???.'+s2,$3F,sr);cnt:=0;
  WHILE(DOSERROR=0)AND(cnt<100)DO BEGIN INC(cnt);
    IF sr.attr AND 16=0 THEN BEGIN names[cnt]:=sr.name;
      ASSIGN(f0,sr.name);RESET(f0,1);
      BLOCKREAD(f0,s1[1],40,x1);s1[0]:=CHR(x1);
      bez[cnt]:=COPY(s1,POS(': ',s1)+2,POS(mml_tend,s1)-POS(': ',s1)-2);
      CLOSE(f0);
      IF COPY(s1,1,3)<>'FT-' THEN DEC(cnt);
    END;
    FINDNEXT(sr);
  END;
  BubbleSort;
  GETIMAGE(GETMAXX DIV 2-120,120,GETMAXX DIV 2+119,359,page^);
  FOR x1:=0 TO 239 DO BEGIN
    y1:=120;x2:=x1+GETMAXX DIV 2-120;x3:=119+GETMAXX DIV 2-x1;
    REPEAT
      PUTPIXEL(x2,y1,zpal[GETPIXEL(x2,y1)]);
      PUTPIXEL(x3,y1+1,zpal[GETPIXEL(x3,y1+1)]);
      INC(y1,2);
    UNTIL y1=318;
  END;
  GrBar(GETMAXX DIV 2-120,319,GETMAXX DIV 2+119,359,abbruch);
  IF op=1 THEN s1:='SZENE' ELSE s1:='SPIELSTAND';
  s1:=s1+' LADEN';
  IF((op=1)AND(active AND 5=1))OR((op=2)AND(active AND 4=4))THEN BEGIN x2:=255;s1:=s1+'/SPEICHERN';END ELSE x2:=0;
  OutText(GETMAXX DIV 2,125,s1,240,6,1.5);
  SETFILLSTYLE(1,238);
  FOR y1:=0 TO 12 DO BAR(GETMAXX DIV 2-109,y1*12+149,GETMAXX DIV 2+108,y1*12+159);
  Mouse(1);iws:=0;
  REPEAT IF(ms.y>148)AND(ms.y<304)THEN cp:=(ms.y-149)DIV 12 ELSE cp:=254;
    DrawIt;
    REPEAT Mouse(3);UNTIL ms.f<>0;
    IF Click(GETMAXX DIV 2-120,319,GETMAXX DIV 2+119,359,7)THEN iws:=255;
    IF ms.b=1 THEN iws:=1 ELSE IF ms.b=2 THEN iws:=2;
    IF(ms.f=1)AND(ms.b=0)AND(cp<=cnt)THEN INC(iws,5);
  UNTIL iws>5;
  Mouse(2);
  PUTIMAGE(GETMAXX DIV 2-120,120,page^,0);
  IF iws>5 THEN BEGIN
    IF(x2=255)AND((cp=0)OR(iws=7))THEN BEGIN
      FOR x1:=0 TO 239 DO BEGIN
        y1:=200;x2:=x1+GETMAXX DIV 2-120;x3:=119+GETMAXX DIV 2-x1;
        REPEAT
          PUTPIXEL(x2,y1,zpal[GETPIXEL(x2,y1)]);
          PUTPIXEL(x3,y1+1,zpal[GETPIXEL(x3,y1+1)]);
          INC(y1,2);
        UNTIL y1=258;
      END;
      OutText(GETMAXX DIV 2,210,'BEZEICHNUNG:',240,6,1.5);
      GrBar(GETMAXX DIV 2-120,259,GETMAXX DIV 2-1,299,ok);
      GrBar(GETMAXX DIV 2,259,GETMAXX DIV 2+119,299,abbruch);
      IF(iws=7)AND(cp<>0)THEN GrBar(GETMAXX DIV 2-120,301,GETMAXX DIV 2+119,341,'LôSCHEN');
      InPut;
      PUTIMAGE(GETMAXX DIV 2-120,120,page^,0);
      IF(cp>100)AND(cp<201)THEN BEGIN ASSIGN(f0,names[cp-100]);RESET(f0,1);
        IF IORESULT=0 THEN BEGIN CLOSE(f0);ERASE(f0);END;
      END;
      IF cp<101 THEN BEGIN
        CASE op OF 1:BEGIN
            IF cp=0 THEN BEGIN x1:=0;
              REPEAT INC(x1);STR(x1,st);
                FOR x2:=1 TO 3-LENGTH(st) DO st:='0'+st;
                st:='FT'+st+'.'+s2;
                FINDFIRST(st,$3F,sr);
              UNTIL DOSERROR<>0;
            END ELSE st:=names[cp];
            ASSIGN(f0,st);REWRITE(f0,1);
            s1:='FT-SCENERY: '+s1+mml_tend;
            BLOCKWRITE(f0,s1[1],LENGTH(s1),x1);
            BLOCKWRITE(f0,mapx^,SIZEOF(map_xtra),x1);
            BLOCKWRITE(f0,road^,SIZEOF(streets),x1);
            IF PackMap THEN BEGIN
              BLOCKWRITE(f0,stime,SIZEOF(startime),x1);
              CLOSE(f0);
            END ELSE BEGIN CLOSE(f0);ERASE(f0);END;
          END;
        END;
      END;
    END ELSE IF iws=6 THEN BEGIN
      IF cp<101 THEN BEGIN
        CASE op OF 1:BEGIN
            ASSIGN(f0,names[cp]);RESET(f0,1);
            BLOCKREAD(f0,s1,40,x1);
            SEEK(f0,POS(mml_tend,s1)+3);
            BLOCKREAD(f0,mapx^,SIZEOF(map_xtra),x1);
            BLOCKREAD(f0,road^,SIZEOF(streets),x1);
            UnpackMap;
            BLOCKREAD(f0,stime,SIZEOF(startime),x1);
            CLOSE(f0);
            trk.p:=255;
          END;
        END;
        FILLCHAR(vertr^,SIZEOF(contract),0);
        active:=active OR 1;active:=active AND NOT 6;
        OutPic(pal,4,0,255);CLEARDEVICE;
        MapPal;
        DiskOp:=TRUE;
      END;
    END ELSE IF(cp<101)AND(iws=7)THEN BEGIN
      FOR x1:=0 TO 239 DO BEGIN
        y1:=200;x2:=x1+GETMAXX DIV 2-120;x3:=119+GETMAXX DIV 2-x1;
        REPEAT
          PUTPIXEL(x2,y1,zpal[GETPIXEL(x2,y1)]);
          PUTPIXEL(x3,y1+1,zpal[GETPIXEL(x3,y1+1)]);
          INC(y1,2);
        UNTIL y1=258;
      END;
      OutText(GETMAXX DIV 2,210,'BEZEICHNUNG:',240,6,1.5);
      GrBar(GETMAXX DIV 2-120,259,GETMAXX DIV 2-1,299,'LôSCHEN');
      GrBar(GETMAXX DIV 2,259,GETMAXX DIV 2+119,299,abbruch);
      OutBTxt(GETMAXX DIV 2-TRUNC(LENGTH(st)*4.5),240,st,250);iws:=0;
      Mouse(1);
      REPEAT REPEAT Mouse(3);UNTIL ms.f<>0;
        IF Click(GETMAXX DIV 2-120,259,GETMAXX DIV 2-1,299,7)THEN iws:=1;
        IF Click(GETMAXX DIV 2,259,GETMAXX DIV 2+119,299,7)THEN iws:=2;
      UNTIL iws>0;
      Mouse(2);
      IF iws=1 THEN BEGIN
        ASSIGN(f0,names[cp]);RESET(f0,1);
        IF IORESULT<>0 THEN BEGIN CLOSE(f0);ERASE(f0);END;
      END;
      PUTIMAGE(GETMAXX DIV 2-120,120,page^,0);
    END;
  END;
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
    IF darker THEN FOR x1:=GETMAXX DIV 2-50 TO GETMAXX DIV 2+51 DO
     FOR y1:=GETMAXY-16 TO GETMAXY-4 DO IF((y1<>GETMAXY-16)AND(y1<>GETMAXY-4))OR
      ((x1<>GETMAXX DIV 2-50)AND(x1<>GETMAXX DIV 2+51))THEN PUTPIXEL(x1,y1,zpal[GETPIXEL(x1,y1)]);
    GETIMAGE(GETMAXX DIV 2-21,GETMAXY-14,GETMAXX DIV 2-5,GETMAXY-6,tbkgr^[0]);
    GETIMAGE(GETMAXX DIV 2+6,GETMAXY-14,GETMAXX DIV 2+22,GETMAXY-6,tbkgr^[1]);
    OutBTxt(GETMAXX DIV 2-48,GETMAXY-14,TimeString,248);
  END;
END;
PROCEDURE ClickField(felder:WORD);
VAR field,x1,y1,z0:BYTE;x2,y2,fields:WORD;ico:ARRAY[0..19,0..19]OF BYTE;
    buf:ARRAY[0..16,0..903]OF BYTE;
BEGIN
  IF felder=cfeld THEN EXIT;
  felder:=felder AND NOT 6;
  fields:=(cfeld OR felder) AND NOT cfeld;
  REPEAT
    FOR field:=0 TO 16 DO IF fields AND(WORD(1)SHL field)>0 THEN BREAK;
    IF field=16 THEN BREAK;
    DEC(fields,(WORD(1)SHL field));
    IF field=0 THEN MOVE(icon^[0],ico,400) ELSE
     IF field=15 THEN IF active AND 1=1 THEN MOVE(icon^[14],ico,400)
     ELSE MOVE(icon^[13],ico,400) ELSE MOVE(icon^[field-2],ico,400);
    IF field<8 THEN BEGIN
      GETIMAGE(0,15+60*field,29,44+60*field,buf[field]);
      FOR x1:=0 TO 29 DO FOR y1:=0 TO 29 DO
       IF(x1<29)OR((y1>0)AND(y1<29))THEN buf[field,x1+y1*30+4]:=zpal[buf[field,x1+y1*30+4]];
      FOR x2:=0 TO 27 DO BEGIN buf[field,x2+34]:=247;buf[field,x2+844]:=247;END;
      FOR y2:=2 TO 27 DO buf[field,y2*30+32]:=247;
      buf[field,62]:=244;buf[field,872]:=244;buf[field,91]:=243;buf[field,841]:=243;
      FOR x1:=0 TO 19 DO FOR y1:=0 TO 19 DO BEGIN x2:=x1+2;y2:=y1+4;
        IF(ico[x1,y1]<>0)AND(ico[x1,y1]>buf[field,x2+y2*30+4])THEN buf[field,x2+y2*30+4]:=ico[x1,y1];
      END;
    END ELSE BEGIN
      GETIMAGE(GETMAXX-29,15+60*(field-8),GETMAXX,44+60*(field-8),buf[field]);
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
  FOR field:=0 TO 15DO IF(cfeld AND(WORD(1)SHL field)>0)
   AND(felder AND(WORD(1)SHL field)=0)THEN BEGIN
    IF field=0THEN PUTIMAGE(0,15,cfo^[0],0)ELSE
     IF field<8THEN PUTIMAGE(0,15+60*field,cfo^[field-2],0)
     ELSE PUTIMAGE(GETMAXX-29,15+60*(field-8),cfo^[field-2],0);
  END;
  time:=0;
  FOR z0:=0 TO 14 DO BEGIN fields:=(cfeld OR felder) AND NOT cfeld;
    REPEAT
      FOR field:=0 TO 16 DO IF fields AND(WORD(1)SHL field)>0 THEN BREAK;
      IF field=16 THEN BREAK;
      DEC(fields,(WORD(1)SHL field));
      x2:=z0*2+1;MOVE(x2,buf[16,0],2);MOVE(buf[field,2],buf[16,2],2);INC(x2);
      IF field<8 THEN BEGIN
        FOR y2:=0 TO 29 DO MOVE(buf[field,y2*30+32-z0*2],buf[16,y2*x2+4],x2);
        PUTIMAGE(0,15+60*field,buf[16],0);
      END ELSE BEGIN
        FOR y2:=0 TO 29 DO MOVE(buf[field,y2*30+4],buf[16,y2*x2+4],x2);
        PUTIMAGE(GETMAXX-z0*2-1,15+60*(field-8),buf[16],0);
      END;
    UNTIL fields=0;
    IF z0/3=z0 DIV 3 THEN BEGIN REPEAT UNTIL time>0;time:=0;END;
  END;
  cfeld:=felder;
END;
{PROCEDURE IPage;
BEGIN
  ap:=1-ap;
END;
PROCEDURE Show;
BEGIN
  IPage;WaitRetrace;ShowPic(0,ap);SetScr(ap);
END;
PROCEDURE Pixel(x1,y1:INTEGER;col:BYTE);
VAR xe:BYTE;pln:WORD;
BEGIN
  IF (x1<0) OR (x1>319) OR (y1<0) OR (y1>199) THEN EXIT;
  xe:=x1 DIV 4;pln:=(x1-INTEGER(xe)*4)*16000+1;
  page[0]^[y1*80+xe+pln]:=col;
END;
FUNCTION GetPix(x1,y1:INTEGER):BYTE;
VAR xe:BYTE;pln:WORD;
BEGIN
  IF (x1<0) OR (x1>319) OR (y1<0) OR (y1>199) THEN BEGIN GetPix:=0;EXIT;END;
  xe:=x1 DIV 4;pln:=(x1-INTEGER(xe)*4)*16000+1;
  GetPix:=page[0]^[y1*80+xe+pln];
END;
PROCEDURE SLine(x1,y1,x2,y2:INTEGER;col:BYTE);
VAR xz,yz:LONGINT;xe:BYTE;pln:WORD;
BEGIN
  IF x1>x2 THEN BEGIN xz:=x1;x1:=x2;x2:=xz;END;
  IF y1>y2 THEN BEGIN yz:=y1;y1:=y2;y2:=yz;END;
  IF x1<0 THEN x1:=0;IF x2>319 THEN x2:=319;
  IF y1<0 THEN y1:=0;IF y2>199 THEN y2:=199;
  IF x1<>x2 THEN FOR xz:=x1 TO x2 DO BEGIN
    xe:=xz DIV 4;pln:=(xz-INTEGER(xe)*4)*16000+1;
    page[0]^[y1*80+xe+pln]:=col;END
   ELSE BEGIN xe:=TRUNC(x1/4);pln:=(x1-INTEGER(xe)*4)*16000+1;
    FOR yz:=y1 TO y2 DO page[0]^[yz*80+xe+pln]:=col;END;
END;
PROCEDURE Line(x1,y1,x2,y2:INTEGER;col:BYTE);
VAR xz,yz,wx,p:INTEGER;xe:BYTE;pln:WORD;m:SINGLE;
BEGIN
  xz:=x2-x1;yz:=y2-y1;
  IF ABS(xz)<ABS(yz) THEN BEGIN
    m:=xz/yz;
    IF y1>y2 THEN BEGIN yz:=y1;y1:=y2;y2:=yz;xz:=x1;x1:=x2;x2:=xz;END;
    FOR yz:=y1 TO y2 DO IF (yz>=0) AND (yz<200) THEN BEGIN
      xz:=ROUND(m*(yz-y1))+x1;
      xe:=xz DIV 4;pln:=(xz-INTEGER(xe)*4)*16000+1;
      IF (xz>=0) AND (xz<320) THEN page[0]^[xe+pln+yz*80]:=col;
    END;
  END ELSE BEGIN
    IF xz=0 THEN m:=1000 ELSE m:=yz/xz;
    IF x1>x2 THEN BEGIN yz:=y1;y1:=y2;y2:=yz;xz:=x1;x1:=x2;x2:=xz;END;
    FOR xz:=x1 TO x2 DO IF (xz>=0) AND (xz<320) THEN BEGIN
      xe:=xz DIV 4;pln:=(xz-INTEGER(xe)*4)*16000+1;yz:=ROUND(m*(xz-x1))+y1;
      IF (yz>=0) AND (yz<200) THEN page[0]^[xe+pln+yz*80]:=col;
    END;
  END;
END;
PROCEDURE FBox(x1,y1,x2,y2:INTEGER;col:BYTE);
VAR xz,yz:LONGINT;xe:BYTE;pln:WORD;
BEGIN
  IF x1>x2 THEN BEGIN xz:=x1;x1:=x2;x2:=xz;END;
  IF y1>y2 THEN BEGIN yz:=y1;y1:=y2;y2:=yz;END;
  IF x1<0 THEN x1:=0;IF x2>319 THEN x2:=319;
  IF y1<0 THEN y1:=0;IF y2>199 THEN y2:=199;
  FOR xz:=x1 TO x2 DO BEGIN
    xe:=xz DIV 4;pln:=(xz-INTEGER(xe)*4)*16000+1;
    FOR yz:=y1 TO y2 DO page[0]^[yz*80+xe+pln]:=col;END;
END;
PROCEDURE Box(x1,y1,x2,y2:INTEGER;col:BYTE);
VAR xz,yz:LONGINT;xe1,xe2:BYTE;pln1,pln2:WORD;
BEGIN
  IF x1>x2 THEN BEGIN xz:=x1;x1:=x2;x2:=xz;END;
  IF y1>y2 THEN BEGIN yz:=y1;y1:=y2;y2:=yz;END;
  IF x1<0 THEN x1:=0;IF x2>319 THEN x2:=319;
  IF y1<0 THEN y1:=0;IF y2>199 THEN y2:=199;
  FOR xz:=x1 TO x2 DO BEGIN
    xe1:=xz DIV 4;pln1:=(xz-INTEGER(xe1)*4)*16000+1;
    page[0]^[y1*80+xe1+pln1]:=col;page[0]^[y2*80+xe1+pln1]:=col;END;
  xe1:=x1 DIV 4;pln1:=(x1-INTEGER(xe1)*4)*16000+1;
  xe2:=x2 DIV 4;pln2:=(x2-INTEGER(xe2)*4)*16000+1;
  FOR yz:=y1+1 TO y2-1 DO BEGIN
    page[0]^[yz*80+xe1+pln1]:=col;page[0]^[yz*80+xe2+pln2]:=col;END;
END;}
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
      FOR yv:=1 TO 16 DO BEGIN CASE st[pos] OF 'Q':ye:=1;'-','%':ye:=-7;
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
        {page[0]^[(xv+xp-xq*4)*16000+xq+(yv+yp)*80+1]:=col;}
        PUTPIXEL(xv+xp,yv+yp,col);
      END;
    END;INC(xp,6);
  END;
END;
{PROCEDURE Block(x1,y1,x2,y2:INTEGER;txt:STRING);
BEGIN
  FBox(x1+2,y1+2,x2-2,y2-2,253);
  SLine(x1+3,y1+1,x2-1,y1+1,253);SLine(x1+1,y1+3,x1+1,y2-1,253);
  SLine(x1+1,y2-1,x2-3,y2-1,253);SLine(x2-1,y1+1,x2-1,y2-3,253);
  Pixel(x1+1,y1+2,255);Pixel(x1+2,y1+1,255);
  SLine(x1+3,y1,x2-1,y1,254);SLine(x1,y1+3,x1,y2-1,254);
  Pixel(x2,y1,253);Pixel(x1,y2,253);
  SLine(x1+1,y2,x2-3,y2,252);SLine(x2,y1+1,x2,y2-3,252);
  Pixel(x2-1,y2-2,251);Pixel(x2-2,y2-1,251);
  OutBTxt((x1+x2) DIV 2-4*LENGTH(txt)+1,(y1+y2) DIV 2-3,txt,252);
  OutBTxt((x1+x2) DIV 2-4*LENGTH(txt)+1,(y1+y2) DIV 2-1,txt,252);
  OutBTxt((x1+x2) DIV 2-4*LENGTH(txt),(y1+y2) DIV 2-2,txt,252);
  OutBTxt((x1+x2) DIV 2-4*LENGTH(txt)+2,(y1+y2) DIV 2-2,txt,252);
  OutBTxt((x1+x2) DIV 2-4*LENGTH(txt)+1,(y1+y2) DIV 2-2,txt,249);
END;
PROCEDURE Invert(x1,y1,x2,y2:INTEGER;cl6,co6,cl7,co7:BYTE);
VAR co1,co2,co4,co5:BYTE;xz,yz:INTEGER;xe:BYTE;pln:WORD;
BEGIN
  co1:=GetPix(x2-2,y2-1);
  co2:=GetPix(x2-3,y2);
  co4:=GetPix(x1+3,y1);
  co5:=GetPix(x1+2,y1+1);
  Pixel(x1+1,y1+2,co1);Pixel(x1+2,y1+1,co1);
  SLine(x1+3,y1,x2-1,y1,co2);SLine(x1,y1+3,x1,y2-1,co2);
  SLine(x1+1,y2,x2-3,y2,co4);SLine(x2,y1+1,x2,y2-3,co4);
  Pixel(x2-1,y2-2,co5);Pixel(x2-2,y2-1,co5);
  FOR xz:=x1+3 TO x2-3 DO BEGIN xe:=xz DIV 4;pln:=(xz-xe*4)*16000+1;
    FOR yz:=y1+1 TO y2-1 DO
     IF cl6=page[0]^[yz*80+xe+pln] THEN page[0]^[yz*80+xe+pln]:=co6 ELSE
     IF cl7=page[0]^[yz*80+xe+pln] THEN page[0]^[yz*80+xe+pln]:=co7;END;
END;}
PROCEDURE ID(VAR st:STRING;byt:BYTE);
BEGIN
  CASE mapx^.ft[byt] OF 0:st:=st+'URAN-BERGWERK';
    1:st:=st+'SILICIUM-BERGWERK';
    2:st:=st+'DIAMANDENMINE';
    3:st:=st+'ERZ-BERGWERK';
    4:st:=st+'WASSER-PUMPSTATION';
    5:st:=st+'GENUSSMITTELFABRIK';
    6:st:=st+'HANFPLANTAGE';
    7:st:=st+'FARM';
    8:st:=st+'RANCH';
    9:st:=st+'GöTERFABRIK';
    10:st:=st+'SCHMELZWERK';END;
END;
PROCEDURE PlayCD(f,u:WORD);
TYPE k=array[0..6]OF WORD;
     r=RECORD
       l,s,m,f:BYTE;END;
VAR x:RECORD
        c,f,l:BYTE;a:r;END;
    y:RECORD
        c,t:BYTE;a:r;i:BYTE;END;
    g:RECORD
        c:k;v,a:LONGINT;END;
    s,o,v:WORD;
    n:^k;
    t:ARRAY[1..100]OF LONGINT;
    z:REGISTERS;
FUNCTION a(r:r):LONGINT;
VAR m,s,f:LONGINT;
BEGIN m:=r.m;s:=r.s;f:=r.f;a:=m*4500+s*75+f-150;END;
PROCEDURE i(VAR b);
BEGIN z.dx:=ofs(b);z.ds:=seg(b);z.bx:=s;z.ax:=$4402;z.cx:=7;msdos(z);END;
BEGIN
  IF f=0 THEN g.c[1]:=$85 ELSE g.c[1]:=$84;
  z.ax:=$1500;z.bx:=0;INTR($2f,z);v:=z.cx;
  GETMEM(n,z.bx*5+1);z.ax:=$1501;z.es:=seg(n^);z.bx:=ofs(n^)+1;INTR($2f,z);
  n:=PTR(n^[2],n^[1]);z.ax:=$3d00;z.ds:=seg(n^[5]);z.dx:=ofs(n^[5]);
  MSDOS(z);s:=z.ax;IF z.flags AND 1>0 THEN EXIT;x.c:=10;i(x);
  t[x.l+1]:=a(x.a);FOR o:=x.f TO x.l DO BEGIN y.c:=11;y.t:=o;i(y);
    t[o]:=a(y.a);END;IF f<x.f THEN f:=x.f;
  IF (u=0) OR (u>x.l) THEN u:=x.l;IF f>u THEN exit;
  g.c[0]:=21;g.c[6]:=0;g.v:=t[f];g.a:=t[u+1]-g.v;z.ax:=$1510;z.cx:=v;
  z.es:=SEG(g);z.bx:=OFS(g);INTR($2f,z);z.ah:=$3f;z.bx:=s;MSDOS(z);
  FREEMEM(n,z.bx*5+1);
END;
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
FUNCTION CreateMap:BOOLEAN;
VAR panz,xm,ym,hoh,rad,bt,mp,mr:BYTE;xp,yp,bb,cc,dd,ee,ff,gg,hh,ii:WORD;
    lo0:LONGINT;abr:BOOLEAN;
    txt:TEXT;st:STRING;anz:ARRAY[0..2]OF BYTE;
PROCEDURE DrawC;
VAR ax,ay:WORD;cp:SINGLE;wert:INTEGER;
BEGIN
  cp:=0;
  IF bt=0 THEN wert:=128-INTEGER(ROUND(hoh*(1-rad/mr)))
   ELSE wert:=INTEGER(ROUND(hoh*(1-rad/mr)))+128;
  REPEAT ax:=(maxfieldx+1)DIV 2+ROUND(sin(cp)*rad);
    ay:=(maxfieldy+1)DIV 2-ROUND(cos(cp)*rad);
    IF(ax>=0)AND(ax<=maxfieldx)AND(ay>=0)AND(ay<=maxfieldy)THEN map[1]^[ax,ay]:=wert;
    cp:=cp+1/rad;
  UNTIL cp>=2*Pi;
END;
PROCEDURE FillC;
VAR ax,ay:WORD;w1,w2,w3,w4:BYTE;
BEGIN
  FOR ax:=(maxfieldx+1)DIV 2-rad TO (maxfieldx+1)DIV 2+rad DO
   FOR ay:=(maxfieldy+1)DIV 2-rad TO (maxfieldy+1)DIV 2+rad DO BEGIN
    w1:=map[1]^[ax-1,ay];w2:=map[1]^[ax+1,ay];w3:=map[1]^[ax,ay-1];w4:=map[1]^[ax,ay+1];
    IF(map[1]^[ax,ay]=0)AND(w1<>0)AND(w2<>0)AND(w3<>0)AND(w4<>0)THEN
     map[1]^[ax,ay]:=WORD(w1+w2+w3+w4)DIV 4;
  END;
END;
PROCEDURE CopyC;
VAR ax,ay,ox,oy,wert:INTEGER;
BEGIN
  FOR ay:=(maxfieldy+1)DIV 2-rad TO (maxfieldy+1)DIV 2+rad DO BEGIN
    oy:=ay+yp-(maxfieldy+1)DIV 2;
    IF(oy>=0)AND(oy<=maxfieldy)THEN
     FOR ax:=(maxfieldx+1)DIV 2-rad TO (maxfieldx+1)DIV 2+rad DO BEGIN
      ox:=ax+xp-(maxfieldx+1)DIV 2;
      IF(ox>=0)AND(ox<=maxfieldx)AND(map[1]^[ax,ay]>0)THEN BEGIN
        wert:=map[0]^[ox,oy]+INTEGER(map[1]^[ax,ay]-128);
        IF wert<0 THEN wert:=0 ELSE IF wert>255 THEN wert:=255;
        map[0]^[ox,oy]:=wert;
      END;
    END;
  END;
END;
PROCEDURE PutTrees(treex,treey,treetyp:BYTE);
BEGIN
  IF(treex<1)OR(treex>maxfieldx-1)OR(treey<1)OR(treey>maxfieldy-1)
   OR(map[0]^[treex,treey]<66)OR(map[0]^[treex,treey]>178)OR(RANDOM(2)=1)
   OR(map[2]^[treex,treey]<>255)THEN EXIT;
  map[2]^[treex,treey]:=treetyp;
  PutTrees(treex+RANDOM(5)-2,treey+RANDOM(5)-2,treetyp);
  PutTrees(treex+RANDOM(5)-2,treey+RANDOM(5)-2,treetyp);
  PutTrees(treex+RANDOM(3)-1,treey+RANDOM(3)-1,treetyp);
  PutTrees(treex+RANDOM(3)-1,treey+RANDOM(3)-1,treetyp);
END;
VAR sorted:BOOLEAN;cpos,result:BYTE;snr:WORD;
    xz,yz:BYTE;col:SINGLE;ncol:INTEGER;
    triacol:ARRAY[0..1]OF ^undergroundtype;
    rawfile:FILE;
    flag:BOOLEAN;
    lo1:LONGINT;
BEGIN
  CreateMap:=FALSE;
  GETIMAGE(190,130,315,240,page^[0]);
  FOR b1:=0 TO 2 DO BEGIN GETIMAGE(320,120+b1*41,429,159+b1*41,page^[16000+WORD(b1)*8000]);
    CASE b1 OF 0:st:='LANDSCHAFT';1:st:='STéDTEANZAHL';2:st:='INDUSTRIEDICHTE';END;
    OutText(315,130+b1*41,st+':',244,1,2);
  END;
  GETIMAGE(209,300,318,339,page^[48000]);
  GrBar(209,300,318,339,ok);
  GETIMAGE(320,300,429,339,page^[56000]);
  GrBar(320,300,429,339,abbruch);
  b2:=255;FILLCHAR(anz[0],3,6);
  REPEAT
    FOR b1:=0 TO 2 DO IF(1 SHL b1)AND b2>0 THEN BEGIN
      CASE anz[b1] OF 6:st:='ZUFALL';
        1:CASE b1 OF 0:st:='FLACH';1,2:st:='MINIMUM';END;
        2:CASE b1 OF 0:st:='HöGELIG';1:st:='EINIGE';2:st:='GERING';END;
        3:CASE b1 OF 0:st:='AUSGEGLICHEN';1:st:='MEHRERE';2:st:='MITTEL';END;
        4:CASE b1 OF 0:st:='BERGIG';1:st:='VIELE';2:st:='HOCH';END;
        5:CASE b1 OF 0:st:='STARK BERGIG';1,2:st:='MAXIUMUM';END;
        7..11:BEGIN STR(anz[b1]-6,st);st:='SATELIT '+st;END;
      END;
      GrBar(320,120+b1*41,429,159+b1*41,st);
    END;
    Mouse(1);b2:=0;
    REPEAT Mouse(3);Keys;
      FOR b1:=0 TO 2 DO IF Click(320,120+b1*41,429,159+b1*41,1)THEN BEGIN
        INC(b2,1 SHL b1);INC(anz[b1]);
        IF((anz[b1]=7)AND(b1<>0))OR((anz[b1]=12)AND(b1=0))THEN anz[b1]:=1;
       END ELSE IF Click(320,120+b1*41,429,159+b1*41,2)THEN BEGIN
        INC(b2,1 SHL b1);DEC(anz[b1]);
        IF anz[b1]=0 THEN CASE b1 OF 0:anz[b1]:=11;1..2:anz[b1]:=6;END;
       END;
      IF Click(209,300,318,339,7)THEN b2:=127;
      IF Click(320,300,429,339,7)THEN b2:=255;
    UNTIL b2>0;
    Mouse(2);
    FOR b1:=0 TO 2 DO IF(1 SHL b1)AND b2>0 THEN
     PUTIMAGE(320,120+b1*41,page^[16000+WORD(b1)*8000],0);
  UNTIL b2>126;
  PUTIMAGE(190,130,page^[0],0);
  PUTIMAGE(209,300,page^[48000],0);
  PUTIMAGE(320,300,page^[56000],0);
  IF b2=255 THEN EXIT;
  GETIMAGE(40,440,179,459,page^[0]);GETIMAGE(180,440,209,459,page^[16000]);
  GETIMAGE(0,435,29,464,page^[32000]);
  OutText(40,440,'GENERIERE KARTE...',244,0,2);
  ClickField(128);
  mp:=0;stime.gt:=0;stime.ev:=RANDOM(90);
  FILLCHAR(trk.c,26,0);
  IF anz[0]=6 THEN mp:=RANDOM(100)+50 ELSE mp:=RANDOM(25)+50*(anz[0]-1)+26;
  CASE anz[1]OF 6:mapx^.tc:=RANDOM(16)+5;
    1:mapx^.tc:=3;
    5:mapx^.tc:=20;
    ELSE mapx^.tc:=RANDOM(4)+4*(anz[1]-1)+1;
  END;
  CASE anz[2]OF 6:mapx^.fc:=RANDOM(16)+5;
    1:mapx^.fc:=2;
    5:mapx^.fc:=20;
    ELSE mapx^.fc:=RANDOM(4)+4*(anz[2]-1)+1;
  END;
  IF anz[0]<7 THEN BEGIN
    IF mp<150 THEN
     FOR xp:=0 TO maxfieldx DO FOR yp:=0 TO maxfieldy DO map[0]^[xp,yp]:=RANDOM(5)+126
     ELSE FILLCHAR(map[0]^,62500,128);
    FOR panz:=1 TO mp DO BEGIN
      xp:=RANDOM(maxfieldx+1);
      yp:=RANDOM(maxfieldy+1);
      bt:=RANDOM(2);
      hoh:=RANDOM(54)+10;
      mr:=TRUNC(RANDOM(hoh-10)/1.5)+10;
      FILLCHAR(map[1]^,62500,0);
      FOR rad:=1 TO mr DO BEGIN DrawC;IF rad=1 THEN Mouse(1) ELSE Mouse(3);
        IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
          ClickField(0);
          PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
          EXIT;
        END;
      END;
      FillC;CopyC;
      STR(ROUND(panz/mp*90),st);
      Mouse(2);PUTIMAGE(180,440,page^[16000],0);
      OutText(195,440,st+'%',244,2,2);
    END;
  {FOR ym:=0 TO 14 DO BEGIN
    XMS_2_RAM(map,xms[ym+1],64000);
    STR(TRUNC(ym/1.5)+91,st);
    PUTIMAGE(180,440,page^[16000],0);
    OutText(195,440,st+'%',244,2,2);
    Mouse(1);
    FOR xp:=0 TO 499 DO FOR yp:=0 TO 31 DO BEGIN Mouse(3);
      IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
        ClickField(0);
        PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
        DISPOSE(map2);map2:=NIL;
        EXIT;
      END;
      hoh:=map^[yp*2000+xp*2];rad:=map^[yp*2000+xp*2+1];
      bt:=map^[yp*2000+xp*2+1000];mr:=map^[yp*2000+xp*2+1001];
      map^[yp*2000+xp*2]:=(hoh*3+rad+bt+mr)DIV 6;
      map^[yp*2000+xp*2+1]:=(rad*3+hoh+bt+mr)DIV 6;
      map^[yp*2000+xp*2+1000]:=(bt*3+rad+hoh+mr)DIV 6;
      map^[yp*2000+xp*2+1001]:=(mr*3+rad+bt+hoh)DIV 6;
    END;
    RAM_2_XMS(map,xms[ym+1],64000);
    Mouse(2);
  END;}
  {RandSeed:=1234567890;
  FOR xm:=0 TO 2 DO FOR ym:=0 TO 4 DO BEGIN
    XMS_2_RAM(map,xms[ym*3+xm+1],64000);
    STR(ym+xm*5+86,st);
    MOVE(page[1]^,page[0]^,64000);
    OutBTxt(156-LENGTH(st)*4,110,st+'%',215);
    Show;
    FOR xp:=0 TO 319 DO FOR yp:=0 TO 199 DO BEGIN
      hoh:=RANDOM(4);
      CASE RANDOM(2) OF 1:IF map^[yp*320+xp+1]<255-hoh THEN INC(map^[yp*320+xp+1],hoh);
        0:IF map^[yp*320+xp+1]>hoh THEN DEC(map^[yp*320+xp+1],hoh);END;
    END;
    RAM_2_XMS(map,xms[ym*3+xm+1],64000);
  END;}
  END ELSE BEGIN
    STR(anz[0]-7,st);
    ASSIGN(rawfile,'MAP00'+st+'.RAW');
    RESET(rawfile,1);
    IF IORESULT<>0 THEN BEGIN Mouse(2);
      ClickField(0);
      PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
      EXIT;
    END;
    BLOCKREAD(rawfile,map[0]^,62500);
    CLOSE(rawfile);
  END;
  RAM_2_XMS(map[0],xms[1],62500);
  DISPOSE(map[1]);map[1]:=NIL;
  NEW(triacol[0]);NEW(triacol[1]);
  FOR xz:=0 TO maxfieldx-1 DO FOR yz:=0 TO maxfieldy-1 DO BEGIN
    col:=(map[0]^[xz,yz]+map[0]^[xz+1,yz+1])/2;
    triacol[0]^[xz,yz]:=TRUNC((map[0]^[xz,yz+1]-col)*0.75)+16;
    triacol[1]^[xz,yz]:=TRUNC((col-map[0]^[xz+1,yz])*0.75)+16;
  END;
  DISPOSE(map[0]);map[0]:=NIL;
  NEW(map[1]);
  FOR xz:=0 TO maxfieldx DO FOR yz:=0 TO maxfieldy DO BEGIN
    IF(xz=0)OR(yz=0)OR(xz=maxfieldx)OR(yz=maxfieldy)THEN map[1]^[xz,yz]:=32
     ELSE BEGIN ncol:=(WORD(triacol[0]^[xz-1,yz-1])+WORD(triacol[1]^[xz-1,yz-1])+
      WORD(triacol[0]^[xz,yz])+WORD(triacol[1]^[xz,yz])+
      WORD(triacol[0]^[xz-1,yz])+WORD(triacol[1]^[xz,yz-1]))DIV 3-16;
      IF ncol<0 THEN map[1]^[xz,yz]:=0 ELSE
       IF ncol>29 THEN map[1]^[xz,yz]:=29 ELSE
       map[1]^[xz,yz]:=ncol;
    END;
  END;
  RAM_2_XMS(map[1],xms[2],62500);
  DISPOSE(triacol[1]);DISPOSE(triacol[0]);
  NEW(map[0]);
  XMS_2_RAM(map[0],xms[1],62500);
  RANDOMIZE;
  PUTIMAGE(180,440,page^[16000],0);PUTIMAGE(40,440,page^[0],0);
  OutText(40,440,'GENERIERE STéDTE...',244,0,2);
  bb:=0;Mouse(1);
  FOR panz:=1 TO mapx^.tc DO REPEAT Mouse(3);
    IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
      ClickField(0);
      PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
      EXIT;
    END;
    mapx^.tx[panz]:=RANDOM(maxfieldx-19)+10;mapx^.ty[panz]:=RANDOM(maxfieldy-19)+10;
    mapx^.ti[panz]:=RANDOM(59800)+200;mapx^.tt[panz]:=RANDOM(256)AND NOT 3;
    IF(RANDOM(4)=1)AND(bb<mapx^.tc DIV 5+1)THEN
     BEGIN mapx^.tt[panz]:=mapx^.tt[panz]OR 1;INC(bb);END;
    FOR b3:=0 TO 25 DO mapx^.pr[panz,b3]:=
     GetPrice[b3]+(SHORTINT(RANDOM(2)*2)-1)*RANDOM(ROUND(GetPrice[b3]))/10
     +RANDOM(ROUND(GetPrice[b3]))/18;
    mapx^.gs[panz]:=RANDOM(256);
    xp:=mapx^.tx[panz];yp:=mapx^.ty[panz];
    flag:=TRUE;
    FOR b3:=1 TO panz-1 DO IF Entfernung(xp,yp,mapx^.tx[b3],mapx^.ty[b3])<10 THEN flag:=FALSE;
  UNTIL(map[0]^[xp,yp]>68)AND(map[0]^[xp,yp]<178)AND flag;
  ASSIGN(txt,'NAMES.TXL');RESET(txt);
  WHILE IORESULT<>0 DO BEGIN CLOSE(txt);RESET(txt);END;
  xp:=0;FILLCHAR(map[1]^,62500,0);
  IF IORESULT=0 THEN WHILE NOT EOF(txt)AND(xp<=maxfieldx) DO BEGIN
    READLN(txt,st);
    IF st='.' THEN INC(xp) ELSE
     IF (st[1]<>'#') AND (st[1]<>'~') THEN INC(map[1]^[xp,0]) ELSE
     IF st[1]='~' THEN INC(map[1]^[xp,1]);
  END ELSE BEGIN xp:=0;yp:=0;END;
  FOR panz:=1 TO mapx^.tc DO REPEAT mapx^.tn[panz]:='';ym:=0;
    IF xp<>0 THEN BEGIN RESET(txt);
      FOR yp:=1 TO RANDOM(xp)+1 DO REPEAT READLN(txt,st);UNTIL st='.';
      FOR xm:=1 TO RANDOM(map[1]^[yp,0])+1 DO
       REPEAT READLN(txt,st);UNTIL (st[1]<>'~') AND (st[1]<>'#');
      mapx^.tn[panz]:=st;
      Mouse(3);
      IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
        ClickField(0);
        PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
        EXIT;
      END;
      IF st[LENGTH(st)]='~' THEN BEGIN RESET(txt);
        FOR yp:=1 TO yp DO REPEAT READLN(txt,st);UNTIL st='.';
        FOR xm:=1 TO RANDOM(map[1]^[yp,1])+1 DO
         REPEAT READLN(txt,st);UNTIL st[1]='~';
        mapx^.tn[panz]:=COPY(mapx^.tn[panz],1,LENGTH(mapx^.tn[panz])-1)+
         COPY(st,2,LENGTH(st)-1);
      END;
      FOR xm:=1 TO panz-1 DO IF mapx^.tn[xm]=mapx^.tn[panz] THEN INC(ym);
    END;
  UNTIL ym=0;
  CLOSE(txt);
  FOR panz:=1 TO mapx^.tc DO FOR xm:=1 TO LENGTH(mapx^.tn[panz]) DO
   CASE mapx^.tn[panz,xm] OF 'Ñ':mapx^.tn[panz,xm]:='é';
    'î':mapx^.tn[panz,xm]:='ô';
    'Å':mapx^.tn[panz,xm]:='ö';
    ELSE mapx^.tn[panz,xm]:=UPCASE(mapx^.tn[panz,xm]);END;
  REPEAT sorted:=FALSE;
    FOR snr:=1TO mapx^.tc-1DO BEGIN cpos:=0;result:=0;
      REPEAT INC(cpos);
        Mouse(3);
        IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
          ClickField(0);
          PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
          EXIT;
        END;
        IF cpos>LENGTH(mapx^.tn[snr]) THEN result:=1 ELSE
         IF cpos>LENGTH(mapx^.tn[snr+1]) THEN result:=2 ELSE
         IF ORD(mapx^.tn[snr,cpos])<ORD(mapx^.tn[snr+1,cpos])THEN result:=1 ELSE
         IF ORD(mapx^.tn[snr,cpos])>ORD(mapx^.tn[snr+1,cpos])THEN result:=2;
      UNTIL(result<>0)OR(cpos=20);
      IF result=2THEN BEGIN sort(snr);sorted:=TRUE;END;
    END;
  UNTIL NOT sorted;
  Mouse(2);
  PUTIMAGE(40,440,page^[0],0);
  OutText(40,440,'GENERIERE INDUSTRIE...',244,0,2);
  bb:=0;Mouse(1);
  FOR panz:=1 TO mapx^.fc DO BEGIN
    REPEAT
      Mouse(3);
      IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
        ClickField(0);
        PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
        EXIT;
      END;
      mapx^.fx[panz]:=RANDOM(maxfieldx-19)+10;mapx^.fy[panz]:=RANDOM(maxfieldy-19)+10;
      xp:=mapx^.fx[panz];yp:=mapx^.fy[panz];
      IF map[0]^[xp,yp]<111 THEN mapx^.ft[panz]:=RANDOM(3) ELSE
      IF map[0]^[xp,yp]>143 THEN mapx^.ft[panz]:=RANDOM(5)+2
       ELSE BEGIN mapx^.ft[panz]:=RANDOM(6)+5;xm:=RANDOM(500 DIV mp);END;
      flag:=TRUE;
      FOR b3:=1 TO mapx^.tc DO IF Entfernung(xp,yp,mapx^.tx[b3],mapx^.ty[b3])<10 THEN flag:=FALSE;
      FOR b3:=1 TO panz-1 DO IF Entfernung(xp,yp,mapx^.fx[b3],mapx^.fy[b3])<10 THEN flag:=FALSE;
    UNTIL(xm=1)AND(bb AND(WORD(1)SHL mapx^.ft[panz])=0)AND flag;
    INC(bb,WORD(1)SHL mapx^.ft[panz]);
    IF bb=2047 THEN bb:=0;
  END;
  Mouse(2);
  PUTIMAGE(40,440,page^[0],0);
  OutText(40,440,'GENERIERE STRASSEN...',244,0,2);
  Mouse(1);
  panz:=0;
  xp:=0;
  yp:=0;
  REPEAT
    lo1:=10000;
    xm:=0;
    ym:=0;
    FOR xz:=1 TO 40 DO
     IF((xz<21)AND(xz<=mapx^.tc))OR((xz>20)AND(xz-20<=mapx^.fc))THEN BEGIN
      IF xz<21 THEN BEGIN ff:=mapx^.tx[xz];gg:=mapx^.ty[xz];END
       ELSE BEGIN ff:=mapx^.fx[xz-20];gg:=mapx^.fy[xz-20];END;
      FOR yz:=1 TO 40 DO IF(xz<>yz)AND
       (((yz<21)AND(yz<=mapx^.tc))OR((yz>20)AND(yz-20<=mapx^.fc)))THEN BEGIN
        IF yz<21 THEN BEGIN hh:=mapx^.tx[yz];ii:=mapx^.ty[yz];END
         ELSE BEGIN hh:=mapx^.fx[yz-20];ii:=mapx^.fy[yz-20];END;
        lo0:=Entfernung(ff,gg,hh,ii);
        IF(lo0>=xp)AND(lo0<lo1)THEN BEGIN flag:=TRUE;
          FOR b3:=1 TO panz DO IF((road^.p1[b3]=xz)AND(road^.p2[b3]=yz))
           OR((road^.p1[b3]=yz)AND(road^.p2[b3]=xz))THEN flag:=FALSE;
          FOR b3:=1 TO panz DO BEGIN
            b1:=road^.p1[b3];b2:=road^.p2[b3];
            IF b1<21 THEN BEGIN bb:=mapx^.tx[b1];cc:=mapx^.ty[b1];END
             ELSE BEGIN bb:=mapx^.fx[b1-20];cc:=mapx^.fy[b1-20];END;
            IF b2<21 THEN BEGIN dd:=mapx^.tx[b2];ee:=mapx^.ty[b2];END
             ELSE BEGIN dd:=mapx^.fx[b2-20];ee:=mapx^.fy[b2-20];END;
            IF Schnitt(bb,cc,dd,ee,ff,gg,hh,ii)THEN flag:=FALSE;
          END;
          IF flag THEN BEGIN lo1:=lo0;xm:=xz;ym:=yz;END;
        END;
        IF(lo0>yp)THEN yp:=lo0;
      END;
    END;
    Mouse(3);
    IF(ms.f=1)AND(ClickedField=23)THEN BEGIN Mouse(2);
      ClickField(0);
      PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
      EXIT;
    END;
    IF xm<>0 THEN BEGIN
      INC(panz);
      road^.p1[panz]:=xm;
      road^.p2[panz]:=ym;
    END;
    xp:=lo1;
  UNTIL(xm=0)OR(xp=yp)OR(panz=100);
  road^.sc:=panz;
  {panz:=1;road^.p1[1]:=1;road^.p2[1]:=21;
  REPEAT INC(panz);yp:=0;
    FOR cc:=2 TO mapx^.tc DO BEGIN hoh:=cc;
      FOR bb:=1 TO panz-1 DO IF(road^.p1[bb]=cc)OR(road^.p2[bb]=cc)THEN hoh:=0;
      IF hoh=cc THEN BREAK;
    END;
    IF hoh=0 THEN FOR cc:=2 TO mapx^.fc DO BEGIN hoh:=cc+20;
      FOR bb:=1 TO panz-1 DO IF(road^.p1[bb]=cc+20)OR(road^.p2[bb]=cc+20)THEN hoh:=0;
      IF hoh=cc+20 THEN BREAK;
    END;
    IF hoh<>0 THEN BEGIN
      road^.p1[panz]:=hoh;
      IF road^.p1[panz]<21 THEN BEGIN
        bb:=mapx^.tx[road^.p1[panz]];cc:=mapx^.ty[road^.p1[panz]]
      END ELSE BEGIN
        bb:=mapx^.fx[road^.p1[panz]-20];cc:=mapx^.fy[road^.p1[panz]-20]
      END;
      REPEAT xp:=2500;
        Mouse(3);
        IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
          ClickField(0);
          PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
          EXIT;
        END;
        FOR xm:=1 TO mapx^.tc DO IF xm<>road^.p1[panz]THEN BEGIN
          lo0:=Entfernung(mapx^.tx[xm],mapx^.ty[xm],bb,cc);
          IF(lo0>yp)AND(lo0<xp)THEN BEGIN road^.p2[panz]:=xm;xp:=lo0;END;
        END;
        FOR xm:=1 TO mapx^.fc DO IF xm+20<>road^.p1[panz]THEN BEGIN
          lo0:=Entfernung(mapx^.fx[xm],mapx^.fy[xm],bb,cc);
          IF(lo0>yp)AND(lo0<xp)THEN BEGIN road^.p2[panz]:=xm+20;xp:=lo0;END;
        END;
        b3:=0;
        FOR xm:=1 TO panz-1 DO
         IF((road^.p1[panz]=road^.p1[xm])AND(road^.p2[panz]=road^.p2[xm]))
         OR((road^.p1[panz]=road^.p2[xm])AND(road^.p2[panz]=road^.p1[xm]))
         THEN b3:=1;
        IF b3=0 THEN FOR xm:=1 TO panz-1 DO
         IF(road^.p2[panz]=road^.p1[xm])OR(road^.p2[panz]=road^.p2[xm])
         THEN b3:=2;
        IF b3=2 THEN BEGIN
          IF road^.p1[panz]<21 THEN BEGIN bb:=mapx^.tx[road^.p1[panz]];cc:=mapx^.ty[road^.p1[panz]];
           END ELSE BEGIN bb:=mapx^.fx[road^.p1[panz]-20];cc:=mapx^.fy[road^.p1[panz]-20];END;
          IF road^.p2[panz]<21 THEN BEGIN dd:=mapx^.tx[road^.p2[panz]];ee:=mapx^.ty[road^.p2[panz]];
           END ELSE BEGIN dd:=mapx^.fx[road^.p2[panz]-20];ee:=mapx^.fy[road^.p2[panz]-20];END;
          FOR xm:=1 TO panz-1 DO BEGIN
            IF road^.p1[xm]<21 THEN BEGIN ff:=mapx^.tx[road^.p1[xm]];gg:=mapx^.ty[road^.p1[xm]];
             END ELSE BEGIN ff:=mapx^.fx[road^.p1[xm]-20];gg:=mapx^.fy[road^.p1[xm]-20];END;
            IF road^.p2[xm]<21 THEN BEGIN hh:=mapx^.tx[road^.p2[xm]];ii:=mapx^.ty[road^.p2[xm]];
             END ELSE BEGIN hh:=mapx^.fx[road^.p2[xm]-20];ii:=mapx^.fy[road^.p2[xm]-20];END;
            IF Schnitt(bb,cc,dd,ee,ff,gg,hh,ii) THEN BEGIN b3:=0;BREAK;END;
          END;
        END;
        IF b3<2 THEN yp:=xp;
      UNTIL(road^.p1[panz]<>road^.p2[panz])AND(b3=2);
    END;
  UNTIL(panz=100)OR(hoh=0);
  hoh:=(mapx^.tc+mapx^.fc)DIV 4;
  IF panz<100 THEN FOR hoh:=panz TO hoh+RANDOM(hoh)+panz DO BEGIN
    IF RANDOM(2)=0 THEN road^.p1[hoh]:=RANDOM(mapx^.tc)+1 ELSE road^.p1[hoh]:=RANDOM(mapx^.fc)+21;
    REPEAT b3:=1;
      Mouse(3);
      IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
        ClickField(0);
        PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
        EXIT;
      END;
      IF RANDOM(2)=0 THEN road^.p2[hoh]:=RANDOM(mapx^.tc)+1 ELSE road^.p2[hoh]:=RANDOM(mapx^.fc)+21;
      IF road^.p1[hoh]=road^.p2[hoh] THEN b3:=0;
      IF b3=1 THEN FOR xm:=1 TO hoh-1 DO
       IF((road^.p1[hoh]=road^.p1[xm])AND(road^.p2[hoh]=road^.p2[xm]))
       OR((road^.p1[hoh]=road^.p2[xm])AND(road^.p2[hoh]=road^.p1[xm]))
       THEN b3:=0;
      IF b3=1 THEN BEGIN
        IF road^.p1[hoh]<21 THEN BEGIN bb:=mapx^.tx[road^.p1[hoh]];cc:=mapx^.ty[road^.p1[hoh]];
         END ELSE BEGIN bb:=mapx^.fx[road^.p1[hoh]-20];cc:=mapx^.fy[road^.p1[hoh]-20];END;
        IF road^.p2[hoh]<21 THEN BEGIN dd:=mapx^.tx[road^.p2[hoh]];ee:=mapx^.ty[road^.p2[hoh]];
         END ELSE BEGIN dd:=mapx^.fx[road^.p2[hoh]-20];ee:=mapx^.fy[road^.p2[hoh]-20];END;
        FOR xm:=1 TO hoh-1 DO BEGIN
          IF road^.p1[xm]<21 THEN BEGIN ff:=mapx^.tx[road^.p1[xm]];gg:=mapx^.ty[road^.p1[xm]];
           END ELSE BEGIN ff:=mapx^.fx[road^.p1[xm]-20];gg:=mapx^.fy[road^.p1[xm]-20];END;
          IF road^.p2[xm]<21 THEN BEGIN hh:=mapx^.tx[road^.p2[xm]];ii:=mapx^.ty[road^.p2[xm]];
           END ELSE BEGIN hh:=mapx^.fx[road^.p2[xm]-20];ii:=mapx^.fy[road^.p2[xm]-20];END;
          IF Schnitt(bb,cc,dd,ee,ff,gg,hh,ii) THEN BEGIN b3:=0;BREAK;END;
        END;
      END;
    UNTIL b3=1;
  END;
  road^.sc:=hoh;}
  Mouse(2);
  FILLCHAR(map[0]^,41,0);
  FOR panz:=1 TO road^.sc DO FOR ym:=1 TO 2 DO BEGIN
    IF ym=1 THEN xm:=road^.p1[panz] ELSE xm:=road^.p2[panz];
    IF xm<21 THEN INC(map[0]^[xm,0]);
  END;
  ym:=0;
  FOR panz:=mapx^.tc DOWNTO 1 DO IF map[0]^[panz,0]>ym THEN BEGIN xm:=panz;ym:=map[0]^[panz,0];END;
  mapx^.tt[xm]:=mapx^.tt[xm]OR 2;trk.p:=255;
  IF ym>5 THEN mapx^.tt[xm]:=mapx^.tt[xm]OR 128 ELSE mapx^.tt[xm]:=mapx^.tt[xm]AND NOT 128;
  FOR panz:=1 TO mapx^.tc DO IF(map[0]^[panz,0]<=ym)AND(mapx^.tt[panz]AND 3<>3)THEN BEGIN xm:=panz;ym:=map[0]^[panz,0];END;
  NEW(map[2]);FILLCHAR(map[2]^,62500,255);
  XMS_2_RAM(map[0],xms[1],62500);
  FOR ym:=1 TO maxfieldy-1 DO FOR xm:=1 TO maxfieldx-1 DO
   IF(RANDOM(15)=1)AND(map[0]^[xm,ym]>=66)AND(map[0]^[xm,ym]<=179)THEN map[2]^[xm,ym]:=16+RANDOM(4);
  FOR ym:=1 TO 10 DO PutTrees(RANDOM(maxfieldx-1)+1,RANDOM(maxfieldy-1)+1,16+RANDOM(4));
  FOR panz:=1 TO mapx^.tc DO BEGIN
    IF mapx^.tt[panz] AND 2=2 THEN BEGIN
      IF mapx^.tt[panz] AND 128=128 THEN map[2]^[mapx^.tx[panz],mapx^.ty[panz]]:=3
       ELSE map[2]^[mapx^.tx[panz],mapx^.ty[panz]]:=2;
    END ELSE IF mapx^.tt[panz] AND 1=1 THEN BEGIN
      map[2]^[mapx^.tx[panz],mapx^.ty[panz]]:=4;
      map[2]^[mapx^.tx[panz]-1,mapx^.ty[panz]+1]:=6;
      map[2]^[mapx^.tx[panz]+1,mapx^.ty[panz]-1]:=5;
    END ELSE BEGIN
      map[2]^[mapx^.tx[panz],mapx^.ty[panz]]:=1;
      map[2]^[mapx^.tx[panz]-1,mapx^.ty[panz]]:=0;
      map[2]^[mapx^.tx[panz]+1,mapx^.ty[panz]]:=0;
      map[2]^[mapx^.tx[panz],mapx^.ty[panz]-1]:=0;
      map[2]^[mapx^.tx[panz],mapx^.ty[panz]+1]:=0;
    END;
  END;
  FOR panz:=1 TO mapx^.fc DO BEGIN
    CASE mapx^.ft[panz] OF
      4:map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=13;
      6:map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=11;
      8:map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=8;
      7:BEGIN
        map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=9;
        map[2]^[mapx^.fx[panz]-1,mapx^.fy[panz]-1]:=10;
        map[2]^[mapx^.fx[panz]-1,mapx^.fy[panz]]:=10;
        map[2]^[mapx^.fx[panz]-1,mapx^.fy[panz]+1]:=10;
        map[2]^[mapx^.fx[panz],mapx^.fy[panz]-1]:=10;
      END;
      10:map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=12;
      ELSE map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=7;
    END;
  END;
  RAM_2_XMS(map[2],xms[3],62500);
  DISPOSE(map[2]);map[2]:=NIL;
  mapx^.it:=xm;mapx^.itst:=0;
  FILLCHAR(vertr^,SIZEOF(contract),0);
  active:=active OR 1;active:=active AND NOT 6;
  CreateMap:=TRUE;
  OutPic(pal,4,0,255);CLEARDEVICE;
  MapPal;
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
         ELSE BEGIN INC(tst);
          IF(ssx<>65534)OR((hoe>ssy-16)AND(hoe<ssy+15))THEN
           PutHorizontalLine(sx+bre,sx+bre+temp[tst],sy+hoe,temp[tst-1]);
          INC(bre,temp[tst]+1);END;
      END;
      INC(tst);
    END;
  END;
  IF(palend<>0)AND(palend<>235)THEN SetPal(pal);
  Bild8Bit:=TRUE;
END;
FUNCTION GCAni:BOOLEAN;
TYPE halfScrArray=ARRAY[0..38399]OF BYTE;
VAR mode,apos,b,dau:BYTE;
    br,ho,anz,pst:WORD;
    palcng:BOOLEAN;
    bre,hoe,lng,tst,acx,acy,acx2:WORD;
    col,act,bst,bufnr,bufho:BYTE;
    l00:LONGINT;
    linebuf:ARRAY[0..643]OF BYTE;
    scrbuf:ARRAY[0..1]OF ^halfScrArray;
BEGIN
  GCAni:=FALSE;
  SEEK(pf,sp);pst:=0;
  BLOCKREAD(pf,temp,4,w0);
  BLOCKREAD(pf,anz,2,w0);
  BLOCKREAD(pf,mode,1,w0);
  SEEK(pf,sp+7);apos:=0;time:=0;palcng:=FALSE;
  DISPOSE(map[1]);map[1]:=NIL;
  DISPOSE(map[0]);map[0]:=NIL;
  NEW(scrbuf[0]);NEW(scrbuf[1]);
  GETIMAGE(0,0,639,0,linebuf);
  REPEAT INC(pst);
    Keys;IF key[1]=#27 THEN BREAK;
    BLOCKREAD(pf,b,1,w0);
    CASE b OF
      1:BEGIN FILLCHAR(pal[0,0],WORD(palend)*3,0);
        IF(ssx<>32768)OR(pst<>1)THEN SetPal(pal);
        br:=0;ho:=0;palcng:=TRUE;
        BLOCKREAD(pf,temp,765,w0);
        MOVE(temp,pal[1,0],WORD(palend)*3);
      END;
      2:BEGIN
        BLOCKREAD(pf,temp,5,w0);
        in0:=br;in1:=ho;
        br:=temp[0]+temp[1]*256;ho:=temp[2]+temp[3]*256;dau:=temp[4];
        SetActivePage(1-GetActivePage);
        IF(br<>in0)OR(ho<>in1)THEN INC(apos);
        IF ssx=65535 THEN BEGIN sx:=AniPos[apos,0];
          IF ssy=65535 THEN sy:=AniPos[apos,1] ELSE sy:=ssy;
        END ELSE BEGIN sx:=ssx;sy:=ssy;END;
        FOR hoe:=0 TO ho-1 DO BEGIN bufnr:=hoe DIV 120;bufho:=hoe MOD 120;
          IF(ssx=32768)OR(ssx=32769)THEN BEGIN
            BLOCKREAD(pf,temp,2,w0);
            lng:=temp[0]+temp[1]*256;
            BLOCKREAD(pf,temp,lng,w0);
            bre:=0;tst:=0;acy:=bufho*br;
            WHILE tst<lng-1 DO BEGIN act:=temp[tst];
              FOR bst:=0 TO 7 DO IF tst<lng-1 THEN BEGIN INC(tst);
                IF act AND (1 SHL bst)=0THEN BEGIN
                  IF temp[tst]<>0 THEN scrbuf[bufnr]^[acy+bre]:=temp[tst];
                  INC(bre);
                END ELSE BEGIN
                  acx:=temp[tst+1]+1;
                  IF temp[tst]<>0 THEN FILLCHAR(scrbuf[bufnr]^[acy+bre],acx,temp[tst]);
                  INC(tst);INC(bre,acx);
                END;
              END;
              INC(tst);
            END;
          END ELSE BEGIN
            BLOCKREAD(pf,temp,2,w0);
            lng:=temp[0]+temp[1]*256;
            BLOCKREAD(pf,temp,lng,w0);
            bre:=0;tst:=0;acy:=sy+hoe;
            {ASM
              MOV ax,acy
              ADD ax,hoe
              MOV acy,ax
            END;}
            WHILE tst<lng-1 DO BEGIN act:=temp[tst];
              FOR bst:=0 TO 7 DO IF tst<lng-1 THEN BEGIN INC(tst);
                IF act AND (1 SHL bst)=0THEN BEGIN
                  IF temp[tst]<>0 THEN BEGIN acx:=bre+sx;
                    {ASM
                      MOV ax,bre
                      ADD ax,acx
                      MOV acx,ax
                    END;}
                    PUTPIXEL(acx,acy,temp[tst]);
                  END;
                  INC(bre);
                END ELSE BEGIN
                  IF temp[tst]<>0 THEN BEGIN
                    acx:=sx;acx2:=temp[tst+1];
                    ASM
                      MOV ax,bre
                      ADD ax,acx
                      MOV acx,ax
                      ADD ax,acx2
                      MOV acx2,ax
                    END;
                    PutHorizontalLine(acx,acx2,acy,temp[tst]);
                  END;
                  INC(tst);INC(bre,temp[tst]+1);
                END;
              END;
              INC(tst);
            END;
          END;
        END;
        IF(ssx=32768)OR(ssx=32769)THEN BEGIN
          FOR bufnr:=0 TO 1 DO FOR bufho:=0 TO bufho DO BEGIN
            FOR bre:=0 TO br-1 DO FILLCHAR(linebuf[bre*2+4],2,scrbuf[bufnr]^[bufho*br+bre]);
            PUTIMAGE(0,WORD(bufho+bufnr*120)*2,linebuf,0);
          END;
        END;
        IF(ssx<>32769)AND palcng THEN BEGIN SetPal(pal);palcng:=FALSE;END;
        {IF(ssx=32768)OR(ssx=32769)THEN }SetVisualPage(GetActivePage);
        REPEAT UNTIL time>dau;
        DEC(time,dau+1);
        IF KEYPRESSED THEN key[1]:=CHAR(LO(READKEY));
        IF(key[1]=#27)OR(key[1]=#32)OR(ssx=32769)THEN BREAK;
      END;
    END;
  UNTIL pst=anz;
  SetVisualPage(0);
  SetActivePage(0);
  DISPOSE(scrbuf[1]);DISPOSE(scrbuf[0]);
  NEW(map[0]);NEW(map[1]);
END;
BEGIN
  CASE typ OF
    1:LiesTrack:=Entpacken;
    2:LiesTrack:=BlockEntpacken;
    3:LiesTrack:=Bild8Bit;
    5:LiesTrack:=GCAni;
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