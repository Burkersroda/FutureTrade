{$S-,N+,E+,I-,G+,F-,M 65520,100000,330000}
{$A+,B-,P-,Q-,R-,T-,V+,X+}

PROGRAM Installation;
{  (c)1997 by Ronny Burkersroda  }
{  status: alpha                 }

USES crt,dos,vesa,i_subs,errors,memory,effects,normfont,i_vars;

CONST path:STRING[80]='C:';
VAR pal2:Pal256;
{$F+}
PROCEDURE ExitProcedure;
BEGIN
  TextMode;
  OutPut(0,0,prg_info,7);
  IF ErrorAddr<>NIL THEN BEGIN
    STR(EXITCODE,prm);prg_info:='Error '+prm;
    prm:=GetError(EXITCODE);
    IF prm<>'' THEN prg_info:=prg_info+': '+prm;
    prg_info:=prg_info+' (at ';
    prg_info:=prg_info+Dec2Hex(SEG(ErrorAddr^))+':';
    prg_info:=prg_info+Dec2Hex(OFS(ErrorAddr^))+').';
    OutPut(0,5,prg_info,7);
    GotoXY(0,7);ErrorAddr:=NIL;
  END ELSE GotoXY(0,5);
  SETINTVEC($1C,ecpnt);
  SETINTVEC($5,oldprnt);
  SETINTVEC($9,@TasInt);
  FOR hixms:=1 TO hixms DO Freemem_XMS(xms[hixms]);
  IF page<>NIL THEN DISPOSE(page);
  IF fields<>NIL THEN DISPOSE(fields);
  IF mml_main='' THEN CLOSE(pf);
  ClearKeyboardBuffer;
  EXITPROC:=oldexitproc;
END;
FUNCTION DetectSVGA256:INTEGER;
BEGIN
  DetectSVGA256:=videomode;
END;
{PROCEDURE KeyInt;INTERRUPT;
BEGIN
  IF(PORT[$60]=83)AND(stat AND 12=12)THEN BEGIN
    stat:=stat AND NOT 8;
    INLINE($9C);
    TasInt;
    HALT(1024);
  END;
  INLINE($9C);
  TasInt;
END;}
PROCEDURE PrntInt;INTERRUPT;
BEGIN
END;
PROCEDURE Timer;INTERRUPT;
BEGIN
  INLINE($9C);INLINE($FF/$1E/ecpnt);INC(time);
END;
{$F-}

PROCEDURE SetPal(palbuf:pal256);
VAR reg:REGISTERS;by0,by1,by2:BYTE;
BEGIN
  IF NOT effect THEN BEGIN
    FOR by0:=0 TO 255 DO zpal[by0]:=ROUND(SQRT(WORD(pal[by0,0]+pal[by0,1]*3+pal[by0,2]*2)DIV 6))+208;
    zpal[208]:=0;
    FOR by0:=1 TO 15 DO zpal[by0+208]:=by0 DIV 2+208;
  END;
  WaitRetrace;
  reg.ax:=$1012;
  reg.bx:=0;
  reg.cx:=256;
  reg.es:=SEG(palbuf);
  reg.dx:=OFS(palbuf);
  INTR($10,reg);
END;
PROCEDURE Init_System;
CONST s0:ARRAY[1..2] OF CHAR=(':',' ');
      nicht:ARRAY[1..6] OF CHAR=('N','I','C','H','T',' ');
      inipos:BYTE=0;
VAR zeile:BYTE;txf:TEXT;w:WORD;reg:REGISTERS;
    s1:STRING[3];s2:STRING[80];s3:STRING[10];
PROCEDURE OutT(st:STRING);
BEGIN
  OutBTxt(10,100+zeile*12,st,245);INC(zeile);
END;
FUNCTION DetectWin95:BOOLEAN;
FUNCTION Ff(filter:PCHAR;attr:WORD;VAR sr:nsr):WORD;ASSEMBLER;
ASM
  PUSH DS
  LDS DX,filter
  LES DI,SR
  MOV CX,attr
  XOR SI,SI
  MOV AX,714Eh
  INT 21h
  POP DS
  SBB BX,BX
  MOV ES:[DI].nsr.handle,AX
  AND AX,BX
  MOV [DOSERROR],AX
END;
FUNCTION Fs(VAR sr:nsr):WORD;ASSEMBLER;
ASM
  MOV AX,71A1h
  MOV BX,ES:[DI].nsr.handle
  INT 21h
  SBB BX,BX
  AND AX,BX
  MOV [DOSERROR],AX
END;
CONST filter:ARRAY[0..6]OF CHAR='C:\*.*'#0;
VAR sr:nsr;
BEGIN
  DetectWin95:=FALSE;
  Ff(@filter,16,sr);
  IF DOSERROR=0 THEN DetectWin95:=TRUE;
  Fs(sr);
END;
PROCEDURE Stop(st1:STRING);
BEGIN
  OutT('');
  OutT(st1);
  OutT('<ENTER>');
  ClearKeyboardBuffer;
  REPEAT Keys;
  UNTIL key[1]=#13;
  HALT(128);
END;
CONST ini_open:BOOLEAN=FALSE;
      eSB:BOOLEAN=FALSE;
VAR palb:Pal256;
BEGIN
  RANDOMIZE;
  exist_SB:=FALSE;
  FILLCHAR(pal,768,0);
  SetPal(pal);
  zeile:=0;
  ms.on:=FALSE;
  NEW(page);NEW(fields);
  FOR b1:=236 TO 251 DO pal[b1,1]:=(b1-236)*4+3;
  OutBTxt(0,0,'INITIALISIERUNG',251);
  OutBTxt(442,0,'[GWS-GAME-SYSTEM V1.2]',251);
  InPic(pal,4,236,251);
  s1:='INI';OutT(s1+s0+'VIDEOMODUS '+GETMODENAME(videomode)+' AKTIVIERT');
  s1:='REQ';
  IF Test8086<2 THEN BEGIN
    CASE Test8086 OF 0:OutT(s1+s0+'XT-COMPUTER');1:OutT(s1+s0+'80286-PROZESSOR');END;
    Stop('ZUM AUSFöHREN WIRD EIN 80386 ODER HôHERER PROZESSOR BENôTIGT!');
  END ELSE OutT(s1+s0+'32-BIT-PROZESSOR VORHANDEN');
  SWAPVECTORS;
  EXEC(GETENV('COMSPEC'),'/C');
  SWAPVECTORS;
  IF DOSERROR<>0 THEN s2:=nicht ELSE s2:='';
  OutT(s1+s0+'COMMAND.COM '+s2+'AUSFöHRBAR');
  IF s2<>'' THEN
   Stop('FEHLER BEIM VERSUCH, DIE "COMMAND.COM"-DATEI AUSZUFöHREN, AUFGETRETEN!');
  s1:='MEM';
  IF MEMAVAIL<240000 THEN BEGIN OutT(s1+s0+'SPEICHERBEREICH ZU KLEIN');
    Stop('ES WERDEN MINDESTENS 550 KB KONVENTIONELLER SPEICHER BENôTIGT!');
  END ELSE OutT(s1+s0+'SPEICHER IN ORDNUNG');
  IF NOT XMS_vorhanden THEN BEGIN OutT(s1+s0+'XMS '+nicht+'INSTALLIERT');
    Stop('ES MUSS EIN XMS-TREIBER INSTALLIERT SEIN!');END;
  IF XMS_free<1280080 THEN BEGIN OutT(s1+s0+'XMS-SPEICHER ZU GERING');
    Stop('ES MUSS 1250 KB FREIER XMS-SPEICHER VORHANDEN SEIN!');END;
  hixms:=0;
  WHILE(hixms<64)AND(Getmem_XMS(xms[hixms+1],64004)=0)DO INC(hixms);
  STR(hixms,s2);OutT(s1+s0+'XMS-RESERVIERUNG: '+s2+'*64kB');
  IF hixms<0 THEN Stop('ES SIND MINDESTENS 0 FREIE XMS-SEITEN NOTWENDIG!');
  IF DISKFREE(0)<1485760 THEN s2:=nicht ELSE s2:='';
  OutT(s1+s0+'HD-SPEICHER '+s2+'IN ORDNUNG');
  s1:='VBL';
  IF Test8087=0 THEN s2:=nicht ELSE s2:='';
  OutT(s1+s0+'CO-PROZESSOR '+s2+'ERKANNT');
  win95:=DetectWin95;
  IF win95 THEN s2:='ODER HôHER ' ELSE s2:=nicht;
  OutT(s1+s0+'WINDOWS 95 '+s2+'ERKANNT');
  s1:='MML';
  ASSIGN(pf,mml_main);RESET(pf,1);
  IF IORESULT=0 THEN BEGIN mml_main:='';
    BLOCKREAD(pf,page^[1],8,w);s2:='';
    FOR w:=1 TO w DO s2:=s2+CHR(page^[w]);
    IF s2<>mml_kopf THEN BEGIN OutT(s1+s0+s1+'-FEHLER');
      Stop('DER DATEIKOPF ENTSPRICHT NICHT DER '+s1+'-NORM!');END;
    BLOCKREAD(pf,page^[1],80,w);s2:='';
    FOR w:=1 TO w DO s2:=s2+CHR(page^[w]);
    mml_spos:=POS(mml_tend,s2);
    IF mml_spos=0 THEN BEGIN OutT(s1+s0+s1+'-FEHLER');
      Stop('DIE '+s1+'-DATEI KONNTE NICHT RICHTIG GELESEN WERDEN!');END;
    INC(mml_spos,10);
  END;
  OutT(s1+s0+s1+'-DATEI GEôFFNET');
  IF NOT LoadMMLtrack(436,20,0,'til.GWS',234) THEN BEGIN
    OutT(s1+s0+'TEST-BILD '+nicht+'GELADEN');
    Stop('TEST-BILD KANN NICHT AUS DER '+s1+'-DATEI GELESEN WERDEN!');
  END;
  OutT(s1+s0+'BILD '+'GELADEN');
  s1:='IRQ';
  SETINTVEC($5,@PrntInt);
  OutT(s1+s0+'PRINTSCREEN DEAKTIVIERT');
  OutT(s1+s0+'STRG+ALT+ENTF DEAKTIVIERT');
  SETCBREAK(TRUE);CHECKBREAK:=TRUE;
  OutT(s1+s0+'STRG+C DEAKTIVIERT');
  SETINTVEC($1C,@Timer);
  OutT(s1+s0+'TIMER AKTIVIERT');
  s1:='I/O';exist_M:=Mouse_Exist;
  MouseReset;ms.b:=0;ms.x:=320;ms.y:=240;ms.ox:=320;ms.oy:=240;
  IF exist_M THEN s2:='' ELSE s2:=nicht;
  OutT(s1+s0+'MOUSE-TREIBER '+s2+'ERKANNT');
  reg.ax:=$1500;reg.bx:=$0;INTR($2F,reg);
  IF reg.bx=0 THEN CDRom:=FALSE ELSE CDRom:=TRUE;
  IF CDRom THEN s2:='' ELSE s2:=nicht;
  OutT(s1+s0+'CD-ROM-TREIBER '+s2+'ERKANNT');
  OutPic(pal,4,0,255);
  CLEARDEVICE;
END;
FUNCTION MainMenu:BYTE;
VAR menutext:STRING[40];
BEGIN
  GETIMAGE(220,100,419,303,page^[0]);
  FOR b1:=0 TO 4 DO BEGIN
    CASE b1 OF 0:menutext:='SZENE ERSTELLEN';
      1:BEGIN menutext:='SZENE LADEN';
        IF active AND 5=1 THEN menutext:=menutext+'/SPEICHERN';END;
      2:BEGIN menutext:='SPIELSTAND';
        IF active AND 4=0 THEN menutext:=menutext+' LADEN';END;
      3:IF active AND 5>0 THEN menutext:='ZURöCK' ELSE
       IF cheats AND 1=0 THEN menutext:='EINLEITUNG' ELSE menutext:='ENDSEQUENZ';
      4:menutext:='SPIEL BEENDEN';
    END;
  END;Mouse(1);
  REPEAT Keys;
    IF(key[2]=#72)OR(key[2]=#80)THEN BEGIN ms.x:=320;IF ms.y<120 THEN ms.y:=120;
      ms.y:=(ms.y-100)DIV 41*41+120;IF ms.y>284 THEN ms.y:=284;
      IF key[2]=#72 THEN DEC(ms.y,41) ELSE INC(ms.y,41);
      IF ms.y<120 THEN ms.y:=284 ELSE IF ms.y>284 THEN ms.y:=120;
    END ELSE key[2]:=#0;
    IF key[2]=#0 THEN Mouse(3) ELSE Mouse(7);
    b2:=255;FOR b1:=0 TO 4 DO IF Click(220,100+b1*41,419,139+b1*41,7)THEN b2:=b1;
  UNTIL b2<>255;
  MainMenu:=b2;
  Mouse(2);
  PUTIMAGE(220,100,page^[0],0);
END;
{PROCEDURE InPut;
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
END;}
PROCEDURE Field(x0,y0,x1:INTEGER;tit:STRING;no:BYTE);
BEGIN
  fields^.x0[no]:=x0;fields^.x1[no]:=x1;
  fields^.y0[no]:=y0;fields^.tit[no]:=tit;
END;
PROCEDURE Hi2Lo(no:BYTE);
VAR x0,y0:INTEGER;pnt:^m16k;
BEGIN
  NEW(pnt);
  GETIMAGE(fields^.x0[no],fields^.y0[no],fields^.x1[no],fields^.y0[no]+22,pnt^);
  FOR x0:=5TO(fields^.x1[no]-fields^.x0[no]+1)*23+4DO BEGIN
    IF pnt^[x0]>239THEN DEC(pnt^[x0],16);
  END;
  PUTIMAGE(fields^.x0[no],fields^.y0[no],pnt^,0);
  DISPOSE(pnt);
END;
PROCEDURE Lo2Hi(no:BYTE);
VAR x0,y0:INTEGER;pnt:^m16k;
BEGIN
  NEW(pnt);
  GETIMAGE(fields^.x0[no],fields^.y0[no],fields^.x1[no],fields^.y0[no]+22,pnt^);
  FOR x0:=5TO(fields^.x1[no]-fields^.x0[no]+1)*23+4DO BEGIN
    IF pnt^[x0]>223THEN INC(pnt^[x0],16);
  END;
  PUTIMAGE(fields^.x0[no],fields^.y0[no],pnt^,0);
  DISPOSE(pnt);
END;
PROCEDURE DrawFields;
VAR cnt2,y1:BYTE;x2:INTEGER;palbuf:pal256;
BEGIN
  FOR cnt2:=1 TO fields^.cnt DO FOR y1:=0 TO 11 DO
   WITH fields^ DO BEGIN GETMEM(bkgr[cnt2,y1],x1[cnt2]-x0[cnt2]+5);
    GETIMAGE(x0[cnt2],y0[cnt2]+y1,x1[cnt2],y0[cnt2]+y1,bkgr[cnt2,y1]^);
    IF y1<11 THEN BEGIN GETMEM(bkgr[cnt2,22-y1],x1[cnt2]-x0[cnt2]+5);
      GETIMAGE(x0[cnt2],y0[cnt2]+22-y1,x1[cnt2],y0[cnt2]+22-y1,bkgr[cnt2,22-y1]^);
    END;
  END;
  SETFILLSTYLE(1,245);
  MOVE(pal,palbuf,768);
  FILLCHAR(palbuf[245,0],33,0);
  SetPal(palbuf);
  FOR y1:=0 TO 11 DO BEGIN time:=0;
    FOR cnt2:=1 TO fields^.cnt DO WITH fields^ DO
     BAR(x0[cnt2],y0[cnt2]+11-y1,x1[cnt2],y0[cnt2]+11+y1);
    REPEAT UNTIL time>0;
  END;
  FOR cnt2:=1 TO fields^.cnt DO WITH fields^ DO BEGIN
    FOR y1:=1 TO 11 DO BEGIN
      IF y1>7 THEN SETCOLOR(255)ELSE SETCOLOR(y1+248);
      LINE(x0[cnt2]+1,y0[cnt2]+y1,x1[cnt2]-1,y0[cnt2]+y1);
      LINE(x0[cnt2]+1,22+y0[cnt2]-y1,x1[cnt2]-1,22+y0[cnt2]-y1);
    END;
    x2:=ROUND((x0[cnt2]+x1[cnt2])/2-LENGTH(tit[cnt2])*4.5);
    OutBTxt(x2,y0[cnt2]+6,tit[cnt2],246);
    OutBTxt(x2-1,y0[cnt2]+7,tit[cnt2],246);
    OutBTxt(x2+1,y0[cnt2]+7,tit[cnt2],246);
    OutBTxt(x2,y0[cnt2]+8,tit[cnt2],246);
    OutBTxt(x2,y0[cnt2]+7,tit[cnt2],247);
  END;
  InPic(pal,2,248,255);SetPal(pal);
  FOR cnt2:=1 TO fields^.cnt DO Hi2Lo(cnt2);
END;
PROCEDURE FreeFields;
VAR cnt2,y1:BYTE;palbuf:pal256;
BEGIN
  FOR cnt2:=1 TO fields^.cnt DO Lo2Hi(cnt2);
  MOVE(pal,palbuf,768);
  FILLCHAR(palbuf[245,0],33,0);
  OutPic(pal,2,248,255);
  SetPal(palbuf);
  FOR y1:=0 TO 11 DO BEGIN time:=0;
   FOR cnt2:=1 TO fields^.cnt DO WITH fields^ DO BEGIN
      PUTIMAGE(x0[cnt2],y0[cnt2]+y1,bkgr[cnt2,y1]^,0);
      FREEMEM(bkgr[cnt2,y1],x1[cnt2]-x0[cnt2]+5);
      IF y1<11 THEN BEGIN
        PUTIMAGE(x0[cnt2],y0[cnt2]+22-y1,bkgr[cnt2,22-y1]^,0);
        FREEMEM(bkgr[cnt2,22-y1],x1[cnt2]-x0[cnt2]+5);
      END;
    END;
    REPEAT UNTIL time>0;
  END;
END;
FUNCTION Click:BYTE;
VAR cnt2,cnt3,cnt4:BYTE;
BEGIN
  Click:=0;
  IF ms.b=0 THEN EXIT;
  cnt3:=0;cnt4:=1;
  FOR cnt2:=1 TO fields^.cnt DO
   WITH fields^ DO IF(ms.x>=x0[cnt2])AND(ms.x<=x1[cnt2])AND(ms.y>=y0[cnt2])AND(ms.y<y0[cnt2]+23)THEN cnt3:=cnt2;
  IF cnt3=0 THEN EXIT;
  ms.f:=0;Mouse(2);
  Lo2Hi(cnt3);
  SetPal(pal2);
  Mouse(1);
  REPEAT Mouse(3);
    WITH fields^ DO
     IF(cnt4=0)AND((ms.x>=x0[cnt3])AND(ms.x<=x1[cnt3])AND(ms.y>=y0[cnt3])AND(ms.y<y0[cnt3]+23))THEN cnt4:=3
      ELSE IF(cnt4=1)AND(((ms.x<x0[cnt3])OR(ms.x>x1[cnt3])OR(ms.y<y0[cnt3])OR(ms.y>y0[cnt3]+22)))THEN cnt4:=2;
    IF(cnt4>1)OR(ms.f=1)THEN BEGIN
      IF(cnt4=3)OR(ms.b<>0)THEN SetPal(pal2);
      IF(cnt4=2)OR(ms.b=0)THEN SetPal(pal);
      IF cnt4>1 THEN DEC(cnt4,2);
    END;
  UNTIL ms.b=0;
  ms.f:=0;Mouse(2);
  Hi2Lo(cnt3);
  Mouse(1);
  IF cnt4=1 THEN Click:=cnt3;
END;
PROCEDURE Install;
TYPE midline=ARRAY[0..443]OF BYTE;
     strfield=ARRAY[0..3963]OF BYTE;
VAR clicked,back,chosen,nchosen,modus:BYTE;w1,w2:WORD;save:ARRAY[100..380]OF ^midline;
    f0:FILE;t0:TEXT;save2:ARRAY[0..19]OF ^strfield;origdir,path2:STRING;li1:LONGINT;
    eintrag:BOOLEAN;
    dir:RECORD
          name:ARRAY[1..20]OF STRING[40];
          path:ARRAY[1..20]OF STRING[12];
          cnt:BYTE;
        END;
PROCEDURE ReadDir(npth:STRING);
FUNCTION Ff(filter:PCHAR;attr:WORD;VAR sr:nsr):WORD;ASSEMBLER;
ASM
  PUSH DS
  LDS DX,filter
  LES DI,SR
  MOV CX,attr
  XOR SI,SI
  MOV AX,714Eh
  INT 21h
  POP DS
  SBB BX,BX
  MOV ES:[DI].nsr.handle,AX
  AND AX,BX
  MOV [DOSERROR],AX
END;
FUNCTION Fn(VAR sr:nsr):WORD;ASSEMBLER;
ASM
  MOV AX,714Fh
  XOR SI,SI
  LES DI,SR
  MOV BX,ES:[DI].nsr.handle
  INT 21h
  SBB BX,BX
  AND AX,BX
  MOV [DOSERROR],AX
END;
FUNCTION Fs(VAR sr:nsr):WORD;ASSEMBLER;
ASM
  MOV AX,71A1h
  MOV BX,ES:[DI].nsr.handle
  INT 21h
  SBB BX,BX
  AND AX,BX
  MOV [DOSERROR],AX
END;
PROCEDURE BubbleSort;
PROCEDURE Sort(nr:WORD);
VAR s0:STRING[40];s1:STRING[12];
BEGIN
  s0:=dir.name[nr];dir.name[nr]:=dir.name[nr+1];dir.name[nr+1]:=s0;
  s1:=dir.path[nr];dir.path[nr]:=dir.path[nr+1];dir.path[nr+1]:=s1;
END;
VAR sorted:BOOLEAN;cpos,result:BYTE;snr:WORD;
FUNCTION UC(ch:CHAR):CHAR;
BEGIN
  CASE ch OF 'Ñ':uc:='é';'î':uc:='ô';'Å':uc:='ö';ELSE uc:=UPCASE(ch);END;
END;
BEGIN
  IF dir.cnt<2THEN EXIT;
  REPEAT sorted:=FALSE;
    FOR snr:=1TO dir.cnt-1DO BEGIN cpos:=0;result:=0;
      REPEAT INC(cpos);
        IF UC(dir.name[snr,cpos])<UC(dir.name[snr+1,cpos])THEN result:=1 ELSE
        IF UC(dir.name[snr,cpos])>UC(dir.name[snr+1,cpos])THEN result:=2;
      UNTIL(result>0)OR(cpos=40);
      IF result>1THEN BEGIN sort(snr);sorted:=TRUE;END;
    END;
  UNTIL NOT sorted;
END;
VAR sr:SEARCHREC;filter:STRING;sr2:nsr;kurz:STRING[12];by0,by1:BYTE;
BEGIN
  dir.cnt:=0;
  FILLCHAR(dir.name,820,0);
  FILLCHAR(filter,256,0);
  filter:=npth+'\*.*';
  FINDFIRST(filter,$3F,sr);
  WHILE DOSERROR=0 DO BEGIN
    IF(sr.attr AND $12=$10)AND(dir.cnt<19)AND(sr.name<>'.')THEN BEGIN INC(dir.cnt);
      dir.path[dir.cnt]:=sr.name;dir.name[dir.cnt]:=sr.name;
    END;
    FINDNEXT(sr);
  END;
  Ff(@filter[1],16,sr2);
  WHILE DOSERROR=0 DO BEGIN
    IF sr2.sname[0]<>#0 THEN BEGIN kurz:='';
      FOR by0:=0 TO 13 DO IF sr2.sname[by0]<>#0 THEN kurz:=kurz+sr2.sname[by0]
       ELSE BREAK;
      FOR by0:=1 TO dir.cnt DO IF kurz=dir.path[by0] THEN BEGIN dir.name[by0]:='';
        FOR by1:=0 TO 39 DO IF sr2.name[by1]<>#0 THEN dir.name[by0]:=dir.name[by0]+sr2.name[by1]
         ELSE BREAK;
      END;
    END;
    Fn(sr2);
  END;
  Fs(sr2);
  BubbleSort;
END;
BEGIN
  GETDIR(0,origdir);
  CHDIR(COPY(path,1,2));
  CHDIR('\');
  CHDIR(path);
  ms.f:=0;Mouse(2);
  FreeFields;
  OutPic(pal,2,0,255);
  LoadMMLtrack(0,0,0,'scr.Hi-Eco-Le',203);
  InPic(pal,2,0,255);SetPal(pal);
  MOVE(pal,pal2,612);
  NEW(save[380]);
  FOR b1:=0 TO 139 DO FOR b2:=0 TO 1 DO BEGIN
    IF b2=0 THEN w1:=b1*2+100 ELSE w1:=379-b1*2;
    NEW(save[w1]);
    GETIMAGE(100,w1,539,w1,save[w1]^);
    MOVE(save[w1]^[0],save[380]^[0],4);
    FOR w2:=4 TO 443 DO save[380]^[w2]:=zpal[save[w1]^[w2]];
    PUTIMAGE(100,w1,save[380]^,1);
  END;
  REPEAT
    Field(100,400,319,'< ZurÅck',1);
    Field(320,400,539,'Weiter >',2);
    fields^.cnt:=2;
    FOR b1:=3 TO 26 DO IF fields^.cnt<10 THEN BEGIN
      ASSIGN(f0,CHR(b1+64)+':\~FT~.TMP');
      REWRITE(f0,1);
      IF IORESULT=0 THEN BEGIN
        INC(fields^.cnt);
        Field(110,fields^.cnt*30+40,149,CHR(b1+64)+':\',fields^.cnt);
        CLOSE(f0);
        ERASE(f0);
      END;
    END;
    ReadDir(path);
    FOR w1:=0 TO 19 DO BEGIN
      NEW(save2[w1]);
      GETIMAGE(160,w1*12+130,519,w1*12+140,save2[w1]^);
    END;
    OutBTxt(252,110,'Zielpfad wÑhlen',244);
    OutBTxt(160,130,COPY(path+direx,1,40),243);
    IF fields^.cnt=2 THEN BEGIN
      OutBTxt(203,236,'Keine Laufwerke verfÅgbar!',244);
      DEC(fields^.cnt);fields^.x1[1]:=539;
    END;
    FOR b1:=1 TO dir.cnt DO OutBTxt(160,130+b1*12,dir.name[b1],244);
    FOR b1:=1 TO 32 DO BEGIN
      FOR b2:=0 TO 2 DO BEGIN
        INC(pal[244,b2]);IF pal[244,b2]>63 THEN pal[244,b2]:=63;
      END;
      SetPal(pal);
    END;
    DrawFields;
    back:=0;
    Mouse(1);chosen:=0;nchosen:=0;
    REPEAT
      IF(ms.x>159)AND(ms.x<520)AND(ms.y>141)AND(ms.y<142+dir.cnt*12)THEN nchosen:=(ms.y-130)DIV 12 ELSE nchosen:=0;
      IF nchosen<>chosen THEN BEGIN ms.f:=0;Mouse(2);
        IF chosen<>0 THEN OutBTxt(160,130+chosen*12,dir.name[chosen],244);
        chosen:=nchosen;
        IF chosen<>0 THEN OutBTxt(160,130+chosen*12,dir.name[chosen],243);
        Mouse(1);
      END;
      REPEAT Mouse(3);UNTIL ms.f<>0;
      clicked:=Click;
      IF((clicked=0)AND(ms.b=0)AND(ms.f=1)AND(chosen<>0))OR(clicked>2)THEN BEGIN
        IF clicked=0 THEN CHDIR(dir.path[chosen])ELSE
         CHDIR(COPY(fields^.tit[clicked],1,2));
        GETDIR(0,path);
        IF path[LENGTH(path)]='\'THEN path:=COPY(path,1,LENGTH(path)-1);
        ReadDir(path);ms.f:=0;Mouse(2);
        FOR w1:=0 TO 19 DO PUTIMAGE(160,w1*12+130,save2[w1]^,0);
        OutBTxt(160,130,COPY(path+direx,1,40),243);
        FOR b1:=1 TO dir.cnt DO OutBTxt(160,130+b1*12,dir.name[b1],244);
        Mouse(1);chosen:=0;nchosen:=0;
      END;
    UNTIL(clicked=1)OR(clicked=2);
    ms.f:=0;Mouse(2);
    IF clicked=1 THEN back:=1;
    FreeFields;
    FOR b1:=32 DOWNTO 0 DO BEGIN
      FOR b2:=0 TO 2 DO BEGIN
        IF pal[228,b2]+b1>63 THEN pal[244,b2]:=63 ELSE pal[244,b2]:=pal[228,b2]+b1;
      END;
      SetPal(pal);
    END;
    FOR b1:=0 TO 19 DO DISPOSE(save2[b1]);
    IF back=0 THEN REPEAT
      FOR b1:=0 TO 139 DO FOR b2:=0 TO 1 DO BEGIN
        IF b2=0 THEN w1:=b1*2+100 ELSE w1:=379-b1*2;
        FOR w2:=4 TO 443 DO save[380]^[w2]:=zpal[save[w1]^[w2]];
        PUTIMAGE(100,w1,save[380]^,1);
      END;
      li1:=LONGINT(DISKFREE(0))DIV 1024;
      IF li1<100THEN modus:=0 ELSE IF li1<2048THEN modus:=1 ELSE
       IF li1<15360 THEN modus:=2 ELSE modus:=3;
      Field(100,400,539,'< ZurÅck',1);
      IF modus>0 THEN BEGIN Field(120,140,519,'Minimale Installation',2);
        OutBTxt(149,170,'Kopiert Start- und Konfigurationsdatei',244);
        OutBTxt(149,182,'auf die Festplatte.           (0,1 MB)',244);
        IF modus>1 THEN BEGIN Field(120,220,519,'Standartinstallation',3);
          OutBTxt(203,250,'Liest nur die Medien-Datei',244);
          OutBTxt(203,262,'von der CD.         (2 MB)',244);
          IF modus>2 THEN BEGIN Field(120,300,519,'Komplette Installation',4);
            OutBTxt(203,330,'Kopiert gesamtes Spiel auf',244);
            OutBTxt(203,342,'die Festplatte.    (15 MB)',244);
          END;
        END;
      END;
      fields^.cnt:=modus+1;
      OutBTxt(212,110,'Installationmodus wÑhlen',244);
      FOR b1:=1 TO 32 DO BEGIN
        FOR b2:=0 TO 2 DO BEGIN
          INC(pal[244,b2]);IF pal[244,b2]>63 THEN pal[244,b2]:=63;
        END;
        SetPal(pal);
      END;
      DrawFields;
      back:=0;
      Mouse(1);
      REPEAT Mouse(3);
        clicked:=Click;
      UNTIL clicked<>0;
      ms.f:=0;Mouse(2);
      IF clicked=1 THEN back:=2;
      modus:=clicked-1;
      FreeFields;
      FOR b1:=32 DOWNTO 0 DO BEGIN
        FOR b2:=0 TO 2 DO BEGIN
          IF pal[228,b2]+b1>63 THEN pal[244,b2]:=63 ELSE pal[244,b2]:=pal[228,b2]+b1;
        END;
        SetPal(pal);
      END;
      FOR b1:=0 TO 139 DO FOR b2:=0 TO 1 DO BEGIN
        IF b2=0 THEN w1:=b1*2+100 ELSE w1:=379-b1*2;
        FOR w2:=4 TO 443 DO save[380]^[w2]:=zpal[save[w1]^[w2]];
        PUTIMAGE(100,w1,save[380]^,1);
      END;
      IF win95 THEN BEGIN
        eintrag:=FALSE;
        ASSIGN(t0,'C:\MSDOS.SYS');
        RESET(t0);
        IF IORESULT=0 THEN BEGIN
          REPEAT
            READLN(t0,prm);
            FOR w1:=0TO LENGTH(prm)DO prm[w1]:=UPCASE(prm[w1]);
            w1:=POS('WINDIR=',prm);
            IF w1<>0 THEN BEGIN
              prm:=COPY(prm,w1+7,LENGTH(prm)-w1-6);
              IF prm[LENGTH(prm)]='\'THEN prm:=COPY(prm,1,LENGTH(prm)-1);
              CHDIR(COPY(prm,1,2));
              CHDIR(prm);
              IF IORESULT=0 THEN BEGIN
                ReadDir(prm);
                w1:=0;
                FOR w2:=1 TO dir.cnt DO IF COPY(dir.path[w2],1,7)='STARTM~'THEN w1:=w2;
                IF w1<>0 THEN BEGIN
                  FOR w2:=1 TO dir.cnt DO IF dir.path[w2]='STARTM~1'THEN w1:=w2;
                  CHDIR(dir.path[w1]);
                  IF IORESULT=0 THEN eintrag:=TRUE;
                  GETDIR(0,prm);
                END;
              END;
            END;
          UNTIL eintrag OR EOF(t0);
          CLOSE(t0);
        END;
        IF(back=0)AND eintrag THEN REPEAT
          GETDIR(0,path2);
          prm:=path2;
          Field(100,400,219,'< ZurÅck',1);
          Field(220,400,419,'Ohne Eintrag >',2);
          Field(420,400,539,'Weiter >',3);
          fields^.cnt:=3;
          ReadDir(path2);
          MOVE(dir.name[2],dir.name[1],779);
          MOVE(dir.path[2],dir.path[1],247);
          DEC(dir.cnt);
          FOR w1:=0 TO 19 DO BEGIN
            NEW(save2[w1]);
            GETIMAGE(140,w1*12+130,499,w1*12+140,save2[w1]^);
          END;
          OutBTxt(218,110,'StartmenÅ-Eintrag wÑhlen',244);
          OutBTxt(140,130,COPY(path2+'\FutureTrade',LENGTH(prm)+2,LENGTH(prm)+41),243);
          FOR b1:=1 TO dir.cnt DO OutBTxt(140,130+b1*12,dir.name[b1],244);
          FOR b1:=1 TO 32 DO BEGIN
            FOR b2:=0 TO 2 DO BEGIN
              INC(pal[244,b2]);IF pal[244,b2]>63 THEN pal[244,b2]:=63;
            END;
            SetPal(pal);
          END;
          DrawFields;
          back:=0;
          Mouse(1);chosen:=0;nchosen:=0;
          REPEAT
            IF(ms.x>139)AND(ms.x<500)AND(ms.y>141)AND(ms.y<142+dir.cnt*12)THEN nchosen:=(ms.y-130)DIV 12 ELSE nchosen:=0;
            IF nchosen<>chosen THEN BEGIN ms.f:=0;Mouse(2);
              IF chosen<>0 THEN OutBTxt(140,130+chosen*12,dir.name[chosen],244);
              chosen:=nchosen;
              IF chosen<>0 THEN OutBTxt(140,130+chosen*12,dir.name[chosen],243);
              Mouse(1);
            END;
            REPEAT Mouse(3);UNTIL ms.f<>0;
            clicked:=Click;
            IF(clicked=0)AND(ms.b=0)AND(ms.f=1)AND(chosen<>0)THEN BEGIN
              CHDIR(dir.path[chosen]);
              GETDIR(0,path2);
              IF path2[LENGTH(path2)]='\'THEN path2:=COPY(path2,1,LENGTH(path2)-1);
              ReadDir(path2);ms.f:=0;Mouse(2);
              IF path2=prm THEN BEGIN
                MOVE(dir.name[2],dir.name[1],779);
                MOVE(dir.path[2],dir.path[1],247);
                DEC(dir.cnt);
              END;
              FOR w1:=0 TO 19 DO PUTIMAGE(140,w1*12+130,save2[w1]^,0);
              OutBTxt(140,130,COPY(path2+'\FutureTrade',LENGTH(prm)+2,LENGTH(prm)+41),243);
              FOR b1:=1 TO dir.cnt DO OutBTxt(140,130+b1*12,dir.name[b1],244);
              Mouse(1);chosen:=0;nchosen:=0;
            END;
          UNTIL clicked<>0;
          ms.f:=0;Mouse(2);
          IF clicked=1 THEN back:=3;
          FreeFields;
          FOR b1:=32 DOWNTO 0 DO BEGIN
            FOR b2:=0 TO 2 DO BEGIN
              IF pal[228,b2]+b1>63 THEN pal[244,b2]:=63 ELSE pal[244,b2]:=pal[228,b2]+b1;
            END;
            SetPal(pal);
          END;
          FOR b1:=0 TO 19 DO DISPOSE(save2[b1]);
        UNTIL back<4;
      END;
    UNTIL back<3;
  UNTIL back<2;
  FOR b1:=0 TO 139 DO BEGIN FOR b2:=0 TO 1 DO BEGIN
      IF b2=0 THEN w1:=b1*2+100 ELSE w1:=379-b1*2;
      PUTIMAGE(100,w1,save[w1]^,1);
      DISPOSE(save[w1]);
    END;
  END;
  DISPOSE(save[380]);
  OutPic(pal,2,0,255);CLEARDEVICE;
  CHDIR(COPY(origdir,1,2));
  CHDIR(origdir);
END;
PROCEDURE Programm;
VAR clicked:BYTE;
BEGIN
  FOR b1:=0 TO 7 DO BEGIN
    FILLCHAR(pal[248+b1,0],2,TRUNC(EXP(LN(b1+1)*1.3))+10);
    pal[248+b1,2]:=b1*2+21;
  END;
  FILLCHAR(pal[247,0],2,42);pal[247,2]:=55;
  FILLCHAR(pal[246,0],2,8);pal[246,2]:=41;
  FILLCHAR(pal[245,0],2,16);pal[245,2]:=24;
  pal[243,0]:=8;pal[243,1]:=32;pal[243,2]:=63;
  FOR b1:=0 TO 15 DO BEGIN
    FILLCHAR(pal[208+b1,0],2,b1*2+1);
    pal[208+b1,2]:=TRUNC(SQRT(b1*240))+3;
  END;
  MOVE(pal[214],pal[244],3);
  MOVE(pal[240,0],pal[224,0],48);
  MOVE(pal,pal2,768);
  pal2[244,0]:=45;pal2[244,1]:=45;pal2[244,2]:=63;
  FOR b1:=248 TO 255 DO FOR b2:=0 TO 2 DO pal2[b1,b2]:=ROUND(pal2[b1,b2]/1.25);
  FILLCHAR(pal2[247,0],2,56);pal[247,2]:=63;
  FILLCHAR(pal2[246,0],2,32);pal2[246,2]:=63;
  REPEAT
    LoadMMLtrack(0,0,0,'scr.Titel',203);
    InPic(pal,2,0,255);
    MOVE(pal,pal2,612);
    Field(200,168,439,'Installation',1);
    Field(200,208,439,'SystemÅberprÅfung',2);
    Field(200,248,439,'Informationen anzeigen',3);
    Field(200,288,439,'Programm beenden',4);
    fields^.cnt:=4;
    DrawFields;
    Mouse(1);
    REPEAT Mouse(3);
      clicked:=Click;
      CASE clicked OF 1:Install;
      END;
    UNTIL(clicked=4)OR(clicked=1);
  UNTIL clicked=4;
  ms.f:=0;Mouse(2);
  FreeFields;
  OutPic(pal,2,0,255);
END;

BEGIN
  oldexitproc:=EXITPROC;
  GETINTVEC($1C,ecpnt);
  GETINTVEC($5,oldprnt);
  GETINTVEC($9,@TasInt);
  TextMode;
  OutPut(0,0,prg_info,7);
  l1:=0;FOR b1:=1 TO 73 DO INC(l1,ORD(prg_info[b1]));
  IF 255-HI(l1)<>231 THEN IF LO(l1)<>20 THEN BEGIN
    OutPut(0,4,'Code modified, program haltet (255).',7);
    GotoXY(0,6);HALT(255);
  END;
  IF MEMAVAIL<150000 THEN BEGIN
    OutPut(0,5,'ERROR 001: Too few memory.',7);GotoXY(0,7);HALT(1);END;
  in0:=$101;INITGRAPH(in0,in1,'');
  IF GRAPHRESULT<>0 THEN BEGIN
    OutPut(0,5,'ERROR 002: Not able to activate VESA-Mode 101hex.',7);GotoXY(0,7);HALT(2);END;
  EXITPROC:=@ExitProcedure;
  Init_System;
  IF win95 THEN direx:=direx+'FTrade' ELSE direx:=direx+'FTRADE';
  Programm;
END.