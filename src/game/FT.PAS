{$S-,N+,E+,I-,G+,F-,M 65520,100000,650000}
{$A+,B-,P-,Q-,R-,T-,V+,X+}

PROGRAM Future_Trade;
{  (c)1996-99 by Ronny Burkersroda  }
{  status: alpha                    }

USES crt,dos,subs,
     vga,effects,memory,mod_sb,variab,errors,cd_utils;

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
    OutPut(0,5,prg_info,7);GotoXY(0,7);ErrorAddr:=NIL;
  END ELSE GotoXY(0,5);
  SETINTVEC($1C,ecpnt);
  SETINTVEC($5,oldprnt);
  SETINTVEC($9,@TasInt);
  IF exist_SB THEN Reset_SB16;
  FOR hiems:=1 TO hiems DO Freemem_EMS(ems[hiems]);
  FOR pages:=1 to pages do DISPOSE(page[pages-1]);
  IF map<>NIL THEN DISPOSE(map);
  IF mapx<>NIL THEN DISPOSE(mapx);
  IF road<>NIL THEN DISPOSE(road);
  IF cache<>NIL THEN DISPOSE(cache);
  IF news<>NIL THEN DISPOSE(news);
  IF vertr<>NIL THEN DISPOSE(vertr);
  IF vpl_main='' THEN CLOSE(pf);
  ClearKeyboardBuffer;
  EXITPROC:=oldexitproc;
END;
PROCEDURE KeyInt;INTERRUPT;
BEGIN
  IF (PORT[$60]=83) AND (stat AND 12=12) THEN BEGIN
    stat:=stat AND NOT 8;
    INLINE($9C);
    TasInt;
    HALT(1024);
  END;
  INLINE($9C);
  TasInt;
END;
PROCEDURE PrntInt;INTERRUPT;
BEGIN
END;
PROCEDURE Timer;INTERRUPT;
BEGIN
  INLINE($9C);INLINE($FF/$1E/ecpnt);INC(time);IF active AND 1=1 THEN INC(trk.pos,2);
END;
{$F-}
FUNCTION Click(x1,y1,x2,y2:INTEGER;but:BYTE):BOOLEAN;
VAR act:BOOLEAN;
BEGIN
  IF (ms.b AND but=0) OR (ms.x<x1) OR (ms.x>x2) OR (ms.y<y1) OR (ms.y>y2)
   OR (ms.f AND 1=0) THEN BEGIN Click:=FALSE;EXIT;END;
  Init_VOC('SCHALT1.SND');act:=TRUE;Invert(x1,y1,x2,y2,252,254,249,250);Show;
  REPEAT REPEAT UNTIL Mouse>0;
    IF ((ms.b AND but=0) OR (ms.x<x1) OR (ms.x>x2) OR (ms.y<y1) OR (ms.y>y2))
      AND act THEN BEGIN act:=FALSE;Voc_done;Init_VOC('SCHALT2.SND');
      Invert(x1,y1,x2,y2,254,252,250,249);END;
    IF ((ms.b AND but=but)
     AND (ms.x>=x1) AND (ms.x<=x2) AND (ms.y>=y1) AND (ms.y<=y2))
      AND NOT act THEN BEGIN act:=TRUE;Voc_done;Init_VOC('SCHALT1.SND');
      Invert(x1,y1,x2,y2,252,254,249,250);END;
    Show;
  UNTIL ms.b AND but=0;
  IF (ms.x>=x1) AND (ms.x<=x2) AND (ms.y>=y1) AND (ms.y<=y2) THEN Click:=TRUE
   ELSE Click:=FALSE;
  Voc_done;
END;
FUNCTION Klik(x1,y1:INTEGER;but:BYTE;txt:STRING):BOOLEAN;
VAR act:BOOLEAN;by1:BYTE;
PROCEDURE WrtTxt;
BEGIN
  OutBTxt(159-LENGTH(txt)*4,191,txt,250);OutBTxt(161-LENGTH(txt)*4,191,txt,250);
  OutBTxt(160-LENGTH(txt)*4,190,txt,250);OutBTxt(160-LENGTH(txt)*4,192,txt,250);
  OutBTxt(160-LENGTH(txt)*4,191,txt,248);
END;
BEGIN
  IF (ms.x<x1-10) OR (ms.x>x1+10) OR (ms.y<y1-10) OR (ms.y>y1+10)
   THEN BEGIN Klik:=FALSE;EXIT;END;
  act:=TRUE;WrtTxt;Show;
  IF (ms.b AND but=0) THEN BEGIN Klik:=FALSE;EXIT;END;
  REPEAT REPEAT UNTIL Mouse>0;
    IF ((ms.b AND but=0) OR (ms.x<x1) OR (ms.x>x1+10) OR (ms.y<y1-10) OR (ms.y>y1+10))
     AND act THEN BEGIN act:=FALSE;
      FOR by1:=0 TO 3 DO MOVE(page[1]^[by1*16000+15201],page[0]^[by1*16000+15201],560);END;
    IF ((ms.b AND but=but)
     AND (ms.x>=x1-10) AND (ms.x<=x1+10) AND (ms.y>=y1-10) AND (ms.y<=y1+10))
      AND NOT act THEN BEGIN act:=TRUE;WrtTxt;END;
    Show;
  UNTIL ms.b AND but=0;
  IF (ms.x>=x1-10) AND (ms.x<=x1+10) AND (ms.y>=y1-10) AND (ms.y<=y1+10) THEN Klik:=TRUE
   ELSE Klik:=FALSE;
END;
PROCEDURE Bl_Scr;
BEGIN
  FILLCHAR(page[0]^,64000,253);
  SLine(1,0,318,0,254);SLine(0,1,0,198,254);Pixel(0,0,255);
  SLine(1,199,318,199,252);SLine(319,1,319,198,252);Pixel(319,199,251);
  SLine(10,9,109,9,252);SLine(10,90,109,90,254);Pixel(9,9,251);
  SLine(9,10,9,89,252);SLine(110,10,110,89,254);Pixel(110,90,255);
  Block(100,190,219,198,'ZURöCK');
END;
FUNCTION LoadVPic(x1,y1:INTEGER;VAR vplf:FILE;vpst:STRING;VAR palbuf:Pal256):BYTE;
TYPE char22=ARRAY[1..22]OF CHAR;
CONST vpl_kopf:char22=('V','G','A','-','P','i','c','t',
        'u','r','e','-','L','i','b','r','a','r','y',#10,#13,#26);
TYPE bufarray=ARRAY[1..11520]OF BYTE;
VAR c22,ch22:char22;buf:^bufarray;cw,vplg,br:WORD;xp,x,y,yp:INTEGER;ho,pln,mode:BYTE;
BEGIN
  IF hiems>17 THEN FOR b1:=1 TO 15 DO IF vpst=cache^[b1].n THEN BEGIN
    NEW(buf);
    EMS_2_RAM(buf,ems[17],11520);
    MOVE(buf^[(b1-1)*768+1],palbuf,768);
    EMS_2_RAM(page[0],ems[b1+17],64000);
    LoadVPic:=0;DISPOSE(buf);buf:=NIL;EXIT;
  END;
  SEEK(vplf,0);IF IORESULT<>0 THEN BEGIN LoadVPic:=1;EXIT;END;
  BLOCKREAD(vplf,c22,22,cw);IF c22<>vpl_kopf THEN BEGIN LoadVPic:=2;EXIT;END;
  FILLCHAR(ch22,22,0);MOVE(vpst[1],ch22,ORD(vpst[0]));
  BLOCKREAD(vplf,c22,22,cw);
  WHILE (c22<>ch22) AND NOT EOF(vplf) DO BEGIN
    BLOCKREAD(vplf,vplg,2,cw);
    SEEK(vplf,FILEPOS(vplf)+vplg+771);
    BLOCKREAD(vplf,c22,22,cw);END;
  IF EOF(vplf) THEN BEGIN LoadVPic:=3;EXIT;END;
  NEW(buf);
  BLOCKREAD(vplf,vplg,2,cw);BLOCKREAD(vplf,br,2,cw);BLOCKREAD(vplf,ho,1,cw);
  BLOCKREAD(vplf,palbuf,768,cw);
  FOR x:=x1 TO x1+br-1 DO BEGIN xp:=x DIV 4;
    pln:=x-xp*4;BLOCKREAD(vplf,mode,1,cw);FILLCHAR(buf^,200,0);
    CASE mode OF 1:BEGIN BLOCKREAD(vplf,buf^,ho,cw);
        FOR y:=0 TO ho-1 DO IF (y+y1>=0) AND (y+y1<200) AND (x>=0) AND (x<320) THEN
         page[0]^[(y+y1)*80+xp+1+pln*16000]:=buf^[y+1];END;
      2:BEGIN y:=0;WHILE y<ho DO BEGIN BLOCKREAD(vplf,buf^,2,cw);
          FOR yp:=y TO y+buf^[1]-1 DO IF (yp+y1>=0) AND (yp+y1<200) AND (x>=0) AND (x<320) THEN
           page[0]^[(yp+y1)*80+xp+1+pln*16000]:=buf^[2];
          INC(y,buf^[1]);END;END;END;END;
  IF (hiems>17) AND (br=320) AND (ho=200) THEN BEGIN mode:=0;
    FOR b1:=1 TO 15 DO IF (cache^[b1].n='') AND (hiems>b1+16) THEN mode:=b1;
    IF mode>0 THEN BEGIN cache^[mode].n:=vpst;
      EMS_2_RAM(buf,ems[17],11520);
      MOVE(palbuf,buf^[(mode-1)*768+1],768);
      RAM_2_EMS(buf,ems[17],11520);
      RAM_2_EMS(page[0],ems[mode+17],64000);
    END;
  END;
  LoadVPic:=0;DISPOSE(buf);buf:=NIL;
END;
PROCEDURE DiskOp(byt:BYTE);
VAR f0:FILE;mi:BOOLEAN;b5:BYTE;b4:WORD;sr:SEARCHREC;
    fn:ARRAY[1..18]OF RECORD n:STRING[10];d:STRING[20];END;
    palbf:Pal256;
PROCEDURE DaNaAu;
BEGIN
  CASE byt OF 0,1:prm:='.MAP';2..4:prm:='.SAV';END;
END;
PROCEDURE InPut;
VAR st:STRING;pos:BYTE;
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
  IF fn[b4-2].n='' THEN st:='' ELSE st:=fn[b4-2].d;
  pos:=LENGTH(st)+1;ms.on:=FALSE;time:=0;
  REPEAT
    FBox(125,b4*10-23,304,b4*10-17,253);
    IF time<4 THEN FBox(127+pos*8,b4*10-23,133+pos*8,b4*10-17,249);
    IF time>7 THEN time:=0;
    OutBTxt(135,b4*10-22,st,250);Show;
    Keys;
    IF (key[1]>#31) AND (key[1]<#155) AND (LENGTH(st)<20) THEN BEGIN
     st:=COPY(st,1,pos-1)+Gross+COPY(st,pos,LENGTH(st)-pos+1);INC(pos);END;
    IF (key[1]=#8) AND (pos>1) THEN BEGIN
     st:=COPY(st,1,pos-2)+COPY(st,pos,LENGTH(st)-pos+1);DEC(pos);END;
    CASE key[2] OF #75:IF pos>1 THEN DEC(pos);
      #77:IF pos<=LENGTH(st) THEN INC(pos);
      #83:IF (pos<=LENGTH(st)) AND (LENGTH(st)>0) THEN
       st:=COPY(st,1,pos-1)+COPY(st,pos+1,LENGTH(st)-pos);
      #71:pos:=1;
      #79:pos:=LENGTH(st)+1;
    END;
  UNTIL (key[1]=#27) OR (key[1]=#13);
  IF (key[1]<>#27) AND (st<>'') THEN fn[b4-2].d:=st;
  Block(120,b4*10-24,309,b4*10-16,fn[b4-2].d);
  IF (key[1]=#27) OR (st='') THEN b4:=0;
  ms.on:=TRUE;
END;
BEGIN
  IF map=NIL THEN BEGIN mi:=TRUE;NEW(map);END ELSE mi:=FALSE;
  FILLCHAR(page[0]^,64000,0);Show;Bl_Scr;
  CASE byt OF 0,1:prm:='SZENE';2..4:prm:='SPIELSTAND';END;
  OutText(20,100,prm,195,0,1);
  FOR b1:=0 TO 15 DO FILLCHAR(pal[b1+195,0],3,b1*2+33);
  CASE byt OF 0,1:prm:='Karte';2..4:prm:='Disk';END;
  LoadVPic(10,10,pf,prm,palbf);
  MOVE(palbf[0,0],pal[0,0],384);SetPal(pal);
  IF byt>2 THEN BEGIN
    Block(10,161,109,169,'SPEICHERN');
    Block(10,171,109,179,'LADEN');END;
  DaNaAu;
  FOR b1:=1 TO 18 DO BEGIN STR(b1,fn[b1].n);
    IF LENGTH(fn[b1].n)=1 THEN fn[b1].n:='0'+fn[b1].n;
    fn[b1].n:='FT #'+fn[b1].n+prm;
    FINDFIRST(fn[b1].n,$20,sr);
    IF DOSERROR<>0 THEN fn[b1].n:='' ELSE BEGIN
      ASSIGN(f0,sr.name);RESET(f0,1);
      BLOCKREAD(f0,fn[b1].d[1],6,b4);fn[b1].d[0]:=CHR(b4);CLOSE(f0);END;
    IF (fn[b1].n='') OR (fn[b1].d<>'FT'+prm) THEN fn[b1].d:='[FREI]' ELSE
     BEGIN RESET(f0,1);BLOCKREAD(f0,fn[b1].d,6,b4);
      BLOCKREAD(f0,fn[b1].d[0],1,b4);
      BLOCKREAD(f0,fn[b1].d[1],ORD(fn[b1].d[0]),b4);CLOSE(f0);END;
    Block(120,b1*10-4,309,b1*10+4,fn[b1].d);
  END;
  REPEAT
    FBox(20,118,99,134,253);
    CASE byt OF 0,3:prm:='SPEICHERN';1,2,4:prm:='LADEN';END;
    OutText(20,118,prm,195,0,1);
    Show;b4:=0;
    REPEAT REPEAT UNTIL Mouse>0;
      IF Click(10,161,109,169,1) AND (byt=4) THEN BEGIN byt:=3;b4:=1;END;
      IF Click(10,171,109,179,1) AND (byt=3) THEN BEGIN byt:=4;b4:=1;END;
      IF Click(100,190,219,198,1) THEN b4:=2;
      FOR b1:=1 TO 18 DO IF Click(120,b1*10-4,309,b1*10+4,1) THEN b4:=b1+2;
      IF (b4>2) AND ((byt=0) OR (byt=3)) THEN InPut;
      IF (b4>2) AND ((byt=1) OR (byt=2) OR (byt=4)) AND (fn[b4-2].n='')
       THEN b4:=0;
      Show;
    UNTIL b4>0;
  UNTIL b4>1;
  IF b4>2 THEN BEGIN DaNaAu;b1:=b4-2;
    CASE byt OF 0:BEGIN STR(b1,fn[b1].n);
        IF LENGTH(fn[b1].n)=1 THEN fn[b1].n:='0'+fn[b1].n;
        fn[b1].n:='FT #'+fn[b1].n+prm;
        ASSIGN(f0,fn[b1].n);REWRITE(f0,1);
        prm:='FT'+prm;
        BLOCKWRITE(f0,prm[1],6,b4);
        BLOCKWRITE(f0,fn[b1].d[0],1,b4);
        BLOCKWRITE(f0,fn[b1].d[1],LENGTH(fn[b1].d),b4);
        BLOCKWRITE(f0,mapx^,SIZEOF(map_xtra),b4);
        BLOCKWRITE(f0,road^,SIZEOF(streets),b4);
        FOR b5:=1 TO 15 DO BEGIN EMS_2_RAM(map,ems[b5],64000);
          BLOCKWRITE(f0,map^,64000,b4);END;
        BLOCKWRITE(f0,stime,SIZEOF(startime),b4);
        CLOSE(f0);
      END;
      1:BEGIN STR(b1,fn[b1].n);trk.p:=255;FILLCHAR(trk.c,26,0);
        IF LENGTH(fn[b1].n)=1 THEN fn[b1].n:='0'+fn[b1].n;
        fn[b1].n:='FT #'+fn[b1].n+prm;
        ASSIGN(f0,fn[b1].n);RESET(f0,1);
        BLOCKREAD(f0,prm[1],6,b4);
        BLOCKREAD(f0,fn[b1].d[0],1,b4);
        BLOCKREAD(f0,fn[b1].d[1],ORD(fn[b1].d[0]),b4);
        BLOCKREAD(f0,mapx^,SIZEOF(map_xtra),b4);
        BLOCKREAD(f0,road^,SIZEOF(streets),b4);
        FOR b5:=1 TO 15 DO BEGIN BLOCKREAD(f0,map^,64000,b4);
          RAM_2_EMS(map,ems[b5],64000);END;
        BLOCKREAD(f0,stime,SIZEOF(startime),b4);
        CLOSE(f0);
        FILLCHAR(vertr^,SIZEOF(contract),0);
      END;
    END;
  END ELSE b3:=255;
  IF mi THEN BEGIN DISPOSE(map);map:=NIL;END;
  time:=0;
END;
PROCEDURE Pal0;
VAR palbf:Pal256;
BEGIN
  palbf:=pal;FILLCHAR(palbf[224,0],48,0);SetPal(palbf);
END;
PROCEDURE Intro;
VAR mpa:mpa_file;b1:BYTE;w1,w2,w3:WORD;pb:Pal256;
    sbuf:ARRAY[1..3,0..399,0..39]OF BYTE;
BEGIN
  FILLCHAR(page[0]^,64000,0);Show;
  IF OpenMPA('LOGO.MPA',mpa)>0 THEN EXIT;
  Pal0;ClearKeyboardBuffer;
  LoadVPic(70,70,pf,'GoldenWorks SOFTWARE',pal);
  LoadVPic(118,172,pf,'prÑsentiert',pb);
  FOR w2:=0 TO 3 DO FOR w1:=13001 TO 16000 DO INC(page[0]^[w1+w2*16000],192);
  Show;
  InPic(pal,2,0,191);
  time:=0;
  BeginInPalEff;
  FOR w1:=1 TO 140 DO
   IF LoadMPA(8,72,mpa,192)=2 THEN BEGIN Show;
    Keys;IF key[1]=#27 THEN BEGIN CLOSE(mpa.af);EXIT;END;
    CASE w1 OF 2..12:InPal(pal,6,192,255);
      128:BeginOutPalEff;
      129..140:OutPal(pal,6,192,255);
    END;
    REPEAT UNTIL time>0;time:=0;END;
  CLOSE(mpa.af);
  FOR w2:=0 TO 3 DO FOR w1:=13001 TO 16000 DO page[0]^[w1+w2*16000]:=0;
  FOR w3:=70 TO 128 DO FOR w2:=0 TO 3 DO FOR w1:=1 TO 16 DO
   page[0]^[w1+w2*16000+w3*80]:=0;
  LoadVPic(60,160,pf,'e Ronny Burkersroda Sp',pb);
  FOR w2:=0 TO 3 DO FOR w1:=12001 TO 16000 DO INC(page[0]^[w1+w2*16000],192);
  Show;
  BeginInPalEff;
  FOR w1:=1 TO 25 DO BEGIN InPal(pal,6,192,255);
    Keys;IF key[1]=#27 THEN EXIT;
    REPEAT UNTIL time>0;time:=0;END;
  OutPic(pal,2,0,191);
  FOR w2:=0 TO 3 DO FOR w1:=5001 TO 11000 DO page[0]^[w1+w2*16000]:=0;
  IF OpenMPA('INTRO.MPA',mpa)>0 THEN EXIT;
  time:=0;
  BeginInPalEff;
  pb:=pal;
  FOR w1:=1 TO 15 DO
   IF LoadMPA(80,50,mpa,0)=1 THEN MOVE(pb[192,0],pal[192,0],64*3)
   ELSE BEGIN Show;
    Keys;IF key[1]=#27 THEN BEGIN CLOSE(mpa.af);EXIT;END;
    IF w1>1 THEN BEGIN InPal(pal,6,0,191);
      IF w1<5 THEN FOR w2:=0 TO 3 DO FOR w3:=0 TO 99 DO
       MOVE(page[0]^[w2*16000+(w3+50)*80+21],sbuf[w1-1,w2*100+w3,0],40);END;
    REPEAT UNTIL time>0;time:=0;END;
  CLOSE(mpa.af);
  IF OpenMPA('TITEL.MPA',mpa)>0 THEN EXIT;
  BeginOutPalEff;
  FOR w1:=1 TO 102 DO BEGIN
    Keys;IF key[1]=#27 THEN BEGIN CLOSE(mpa.af);EXIT;END;
    FOR w2:=0 TO 3 DO FOR w3:=0 TO 99 DO
     MOVE(sbuf[w1-(w1 DIV 3)*3+1,w2*100+w3,0],page[0]^[w2*16000+(w3+50)*80+21],40);
    CASE w1 OF 15..27:OutPal(pal,6,192,255);
      28:FOR w2:=0 TO 3 DO FOR w3:=12001 TO 16000 DO page[0]^[w3+w2*16000]:=0;
      29..46:IF LoadMPA(20,14,mpa,192)=1 THEN SetPal(pal);
      48..65:LoadMPA(120,160,mpa,192);
      90:BeginOutPalEff;
      91..102:OutPal(pal,6,0,255);
    END;
    Show;REPEAT UNTIL time>0;time:=0;
  END;
  CLOSE(mpa.af);
  FILLCHAR(page[0]^,64000,0);
END;
PROCEDURE Extro;
CONST y_pos:ARRAY[1..7]OF BYTE=(0,100,100,101,103,106,120);
VAR mpa:mpa_file;i0:INTEGER;w1,w2,w3:WORD;buf:^ScrArray;st:STRING[15];
BEGIN
  ms.on:=FALSE;Show;OutPic(pal,1,0,255);
  NEW(buf);FILLCHAR(page[0]^,64000,0);Show;
  IF OpenMPA('EXTRO.MPA',mpa)=0 THEN BEGIN time:=0;
    FOR b1:=0 TO 7 DO IF LoadMPA(0,y_pos[b1],mpa,0)=2 THEN BEGIN Show;
      IF b1=1 THEN BEGIN MOVE(page[0]^,page[1]^,64000);InPic(pal,3,0,255);
        REPEAT Keys;UNTIL (time>89) OR (key[1]=#27);END ELSE Keys;
      MOVE(page[1]^,page[0]^,64000);
      REPEAT UNTIL time>0;time:=0;
      IF key[1]=#27 THEN BREAK;END ELSE SetPal(pal);
    CLOSE(mpa.af);Show;time:=0;
    FOR w2:=0 TO 16 DO BEGIN
      FOR w1:=0 TO 255 DO IF pal[w1,2]<63 THEN INC(pal[w1,2]);
      SetPal(pal);REPEAT UNTIL time>0;time:=0;
    END;
  END ELSE FILLCHAR(page[1]^,64000,0);
  FILLCHAR(page[0]^,64000,0);
  OutBTxt(60,0,'SPIEL-ENDSTAND',250);OutBTxt(60,20,'GELD',250);
  STR(geld:0:2,st);FOR b1:=1 TO LENGTH(st) DO IF st[b1]='.' THEN st[b1]:=',';
  OutText(260,30,st+' P$',220,1,0.5);
  OutSTxt(60,100,'(C)1996 BY RONNY BURKERSRODA',250);
  MOVE(page[0]^,buf^,64000);time:=0;
  FOR i0:=199 DOWNTO -110 DO BEGIN MOVE(page[1]^,page[0]^,64000);
    FOR w2:=0 TO 109 DO IF (i0+w2<200) AND (i0+w2>=0) THEN FOR w1:=15 TO 64 DO
     FOR b1:=0 TO 3 DO BEGIN w3:=w1+w2*80+b1*16000+1;
      IF buf^[w3]<>0 THEN page[0]^[w3+i0*80]:=buf^[w3];END;
    Show;REPEAT UNTIL time>0;time:=0;
  END;
  DISPOSE(buf);
  OutPic(pal,1,0,255);
END;
PROCEDURE Outro;
VAR x1,by1:BYTE;y1:INTEGER;mpa:mpa_file;palbuf:Pal256;st:STRING;
BEGIN
  ms.on:=FALSE;Show;FILLCHAR(page[1]^,64000,0);MOVE(pal,palbuf,768);
  IF OpenMPA('OUTRO.MPA',mpa)=0 THEN
   FOR b1:=0 TO 10 DO IF LoadMPA(0,0,mpa,0)=2 THEN BEGIN
    FOR x1:=0 TO 3 DO FOR y1:=0 TO 99 DO
     MOVE(page[0]^[y1*80+x1*16000+1],
     page[1]^[x1*16000+1+TRUNC(((b1-1)/2-(b1-1) DIV 2)*16000)+y1*80],40);
    IF b1 DIV 2=b1/2 THEN RAM_2_EMS(@page[1]^[1],ems[b1 DIV 2],64000);
  END;Close(mpa.af);
  OpenMPA('GAMEOVER.MPA',mpa);
  OutPic(palbuf,1,0,255);FILLCHAR(page[0]^,64000,0);
  BeginInPalEff;time:=0;
  FOR by1:=1 TO 10 DO BEGIN
    FOR b1:=1 TO 10 DO BEGIN
      IF (b1-1) DIV 2=(b1-1)/2 THEN
       EMS_2_RAM(@page[1]^[1],ems[(b1-1) DIV 2+1],64000);
      FOR x1:=0 TO 3 DO FOR y1:=0 TO 99 DO
       MOVE(page[1]^[x1*16000+1+TRUNC(((b1-1)/2-(b1-1) DIV 2)*16000)+y1*80],
       page[0]^[y1*80+x1*16000+4021],40);
      IF (by1=2) AND (b1<7) THEN
       IF LoadMPA(88,7,mpa,240)=1 THEN SetPal(pal) ELSE LoadMPA(88,157,mpa,240);
      Show;CASE by1 OF 1:InPal(pal,7,0,235);9:BeginOutPalEff;10:OutPal(pal,7,0,255);END;
      REPEAT UNTIL time>0;time:=0;
      Keys;IF key[1]=#27 THEN Break;
    END;IF key[1]=#27 THEN Break;
  END;
  Close(mpa.af);
END;
PROCEDURE Init_System;
CONST s0:ARRAY[1..2] OF CHAR=(':',' ');
      nicht:ARRAY[1..6] OF CHAR=('N','I','C','H','T',' ');
VAR zeile:BYTE;f0:FILE;w:WORD;reg:REGISTERS;
    s1:STRING[3];s2:STRING[20];
PROCEDURE Stop(st1,st2:STRING);
VAR by:BYTE;
BEGIN
  FOR b2:=60 TO 79 DO FOR b1:=4 TO 75 DO FOR by:=0 TO 3 DO
   page[0]^[by*16000+b1+b2*80+1]:=ROUND((page[0]^[by*16000+b1+b2*80+1]+242*7)/8);
  FOR b2:=80 TO 129 DO FOR b1:=4 TO 75 DO FOR by:=0 TO 3 DO
   page[0]^[by*16000+b1+b2*80+1]:=ROUND((page[0]^[by*16000+b1+b2*80+1]+241*7)/8);
  OutText(24,60,'PROGRAMMABBRUCH',245,0,2);
  OutBTxt(160-LENGTH(st1)*4,90,st1,248);
  OutBTxt(160-LENGTH(st2)*4,100,st2,248);
  OutSTxt(132,120,'<ENTER>',244);
  Show;ClearKeyboardBuffer;
  REPEAT Keys;UNTIL key[1]=#13;
  OutSTxt(132,120,'<ENTER>',254);Show;
  REPEAT Keys;UNTIL key[1]=#0;
  HALT(128);
END;
PROCEDURE OutT(st:STRING);
BEGIN
  Pal0;OutBTxt(0,50+zeile*8,st,234);ShowPic(0,ap);InPic(pal,16,234,234);
  OutBTxt(0,50+zeile*8,st,250);ShowPic(0,ap);INC(zeile);
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
CONST ini_open:BOOLEAN=FALSE;
      eSB:BOOLEAN=FALSE;
VAR palb:Pal256;
BEGIN
  NEW(page[0]);pages:=1;FILLCHAR(page[0]^,64000,240);
  FILLCHAR(pal,768,0);zeile:=0;ms.on:=FALSE;
  InitVGA;SetPal(pal);ap:=0;SetScr(ap);
  force_dma:=FALSE;force_irq:=FALSE;force_base:=FALSE;
  FOR b1:=224 TO 239 DO BEGIN
    pal[b1,1]:=(b1-224)*3+16;pal[b1+16,1]:=(b1-224)*3+16;END;
  pal[240,1]:=4;
  OutBTxt(100,25,'BITTE WARTEN...',245);
  OutText(0,0,'INITIALISIERUNG     [FT-GAME-INTERFACE V1.0]',224,0,1);
  Show;InPic(pal,4,224,239);
  OutText(0,0,'INITIALISIERUNG     [FT-GAME-INTERFACE V1.0]',240,0,1);
  Show;Pal0;
  s1:='INI';OutT(s1+s0+'VGA AKTIVIERT');
  s1:='REQ';
  IF Test8086<2 THEN BEGIN
    CASE Test8086 OF 0:OutT(s1+s0+'XT-COMPUTER');1:OutT(s1+s0+'80286-PROZESSOR');END;
    Stop('ZUM AUSFöHREN WIRD EIN 80386','ODER HôHERER PROZESSOR BENôTIGT!');
  END ELSE OutT(s1+s0+'32-BIT-PROZESSOR VORHANDEN');
  s1:='MEM';
  IF MEMAVAIL<250000 THEN BEGIN OutT(s1+s0+'SPEICHERBEREICH ZU KLEIN');
    Stop('ES WERDEN MINDESTENS 500 KB KON-','VENTIONELLER SPEICHER BENôTIGT!');
  END ELSE OutT(s1+s0+'SPEICHER IN ORDNUNG');
  NEW(page[1]);pages:=2;
  IF NOT EMS_vorhanden THEN BEGIN OutT(s1+s0+'EMS '+nicht+'INSTALLIERT');
    Stop('ES MUSS EIN EMS-TREIBER','INSTALLIERT SEIN!');END;
  IF EMS_free<1024000 THEN BEGIN OutT(s1+s0+'EMS-SPEICHER ZU GERING');
    Stop('ES MUSS 1MB FREIER','EMS-SPEICHER VORHANDEN SEIN!');END;
  hiems:=0;
  WHILE (hiems<32) AND (Getmem_EMS(ems[hiems+1],64000)=0) DO INC(hiems);
  STR(hiems,s2);OutT(s1+s0+'EMS-RESERVIERUNG: '+s2+'*64kB');
  IF hiems<16 THEN Stop('ES SIND MINDESTENS 16 FREIE','EMS-SEITEN NOTWENDIG!');
  IF DISKFREE(0)<1485760 THEN s2:=nicht ELSE s2:='';
  OutT(s1+s0+'HD-SPEICHER '+s2+'IN ORDNUNG');
  s1:='VBL';
  IF Test8087=0 THEN s2:=nicht ELSE s2:='';
  OutT(s1+s0+'CO-PROZESSOR '+s2+'VORHANDEN');
  s1:='INI';
  ASSIGN(f0,'SETUP.INI');RESET(f0,1);
  IF IORESULT=0 THEN ini_open:=TRUE ELSE ini_open:=FALSE;
  IF ini_open THEN BEGIN BLOCKREAD(f0,prm[1],8,w);prm[0]:=CHR(w);
    IF prm<>setup_kopf THEN BEGIN ini_open:=FALSE;CLOSE(f0);END;END;
  IF ini_open THEN s2:='GEôFFNET' ELSE s2:='NICHT GEFUNDEN';
  OutT(s1+s0+'SETUP-DATEI '+s2);
  s1:='VPL';ASSIGN(pf,vpl_main);RESET(pf,1);vpl_main:='';
  IF LoadVPic(300,180,pf,'Test',palb)>0 THEN BEGIN OutT(s1+s0+'VPL-FEHLER');
    Stop('ES IST EIN FEHLER BEIM','LADEN DER VPL-DATEI AUFGETRETEN!');END;
  OutT(s1+s0+'VPL-DATEI GEôFFNET');
  s1:='SND';
  IF ini_open THEN BEGIN BLOCKREAD(f0,key[1],1,w);
    IF key[1]=#1 THEN BLOCKREAD(f0,prm[1],8,w);
    BLOCKREAD(f0,key[1],1,w);IF key[1]=#1 THEN eSB:=TRUE;
    IF eSB THEN BEGIN BLOCKREAD(f0,dsp_adr,2,w);
      BLOCKREAD(f0,dsp_irq,1,w);BLOCKREAD(f0,dma_ch,1,w);
      force_irq:=TRUE;force_dma:=TRUE;force_base:=TRUE;
      Startport:=dsp_adr;Endport:=dsp_adr;END;END;
  IF NOT ini_open THEN BEGIN IF NOT Init_SB THEN BEGIN exist_SB:=FALSE;s2:='NICHT ';END
     ELSE BEGIN s2:='';exist_SB:=TRUE;
    IF MixerDetected THEN BEGIN IF SBversmaj<4 THEN s2:='PRO ' ELSE s2:='16 ';END;END;END
   ELSE BEGIN IF eSB AND Init_SB THEN BEGIN exist_SB:=TRUE;s2:='';
        IF MixerDetected THEN BEGIN IF SBversmaj<4 THEN s2:='PRO ' ELSE s2:='16 ';END;END
       ELSE exist_SB:=FALSE;END;
  IF ini_open AND (NOT eSB) THEN OutT(s1+s0+'KEINE SOUNDKARTE') ELSE
   OutT(s1+s0+'SOUNDBLASTER '+s2+'GEFUNDEN');
  IF exist_SB THEN Reset_SB16;STR(DMA_ch,s2);
  IF exist_SB THEN BEGIN Reset_SB16;Init_SB;
    OutT(s1+s0+'BASE='+wrt_DSP_adr_SB16+' HEX # IRQ='+wrt_DSP_IRQ+' # DMA='+s2);END;
  s1:='INT';SETINTVEC($9,@KeyInt);
  OutT(s1+s0+'STRG+ALT+ENTF DEAKTIVIERT');
  SETINTVEC($5,@PrntInt);
  OutT(s1+s0+'HARDCOPY DEAKTIVIERT');
  SETCBREAK(FALSE);CHECKBREAK:=FALSE;
  OutT(s1+s0+'STRG+C DEAKTIVIERT');
  SETINTVEC($1C,@Timer);
  OutT(s1+s0+'TIMER AKTIVIERT');
  s1:='I/O';exist_M:=Mouse_Exist;ms.b:=0;ms.x:=160;ms.y:=100;
  IF exist_M THEN s2:='' ELSE s2:=nicht;
  OutT(s1+s0+'MOUSE-TREIBER '+s2+'INSTALLIERT');
  IF NOT exist_M THEN Stop('DER MOUSE-TREIBER IST','NICHT INSTALLIERT!');
  reg.ax:=$1500;reg.bx:=$0;INTR($2F,reg);
  IF reg.bx=0 THEN CDRom:=FALSE ELSE CDRom:=TRUE;
  IF CDRom THEN s2:='' ELSE s2:=nicht;
  OutT(s1+s0+'CD-ROM-TREIBER '+s2+'INSTALLIERT');
  IF ini_open THEN CLOSE(f0);OutPic(pal,4,224,255);
END;
PROCEDURE Cities(VAR cibuf:city_type);
VAR byt0,byt1,byt2:BYTE;stbuf:STRING[21];changed:BOOLEAN;
BEGIN
  FOR byt0:=1 TO mapx^.tc DO BEGIN cibuf[byt0].n:=mapx^.tn[byt0];
    cibuf[byt0].nr:=byt0;IF LENGTH(cibuf[byt0].n)<20 THEN
     FILLCHAR(cibuf[byt0].n[LENGTH(cibuf[byt0].n)+1],20-LENGTH(cibuf[byt0].n),0);END;
  REPEAT changed:=FALSE;
    FOR byt0:=1 TO mapx^.tc-1 DO BEGIN byt1:=0;byt2:=0;
      REPEAT INC(byt1);
        IF cibuf[byt0].n[byt1]>cibuf[byt0+1].n[byt1] THEN byt2:=1 ELSE
         IF cibuf[byt0].n[byt1]<cibuf[byt0+1].n[byt1] THEN byt2:=2;
      UNTIL (byt2<>0) OR (byt1=20);
      IF byt2=1 THEN BEGIN changed:=TRUE;MOVE(cibuf[byt0].n[0],stbuf,22);
        MOVE(cibuf[byt0+1],cibuf[byt0],22);
        MOVE(stbuf,cibuf[byt0+1].n[0],22);END;
    END;
  UNTIL NOT changed;
END;
PROCEDURE PlayGame;
VAR ctf,zb:BYTE;
    xp,yp:INTEGER;
    ncount:WORD;
    ntf:TEXT;
    st:STRING;
    ware:ARRAY[1..2]OF LONGINT;
PROCEDURE ID(byt:BYTE);
BEGIN
  CASE mapx^.ft[byt] OF 0:st:=st+'URAN';
    1:st:=st+'SILICIUM';
    2:st:=st+'DIAMANDENMINE';
    3:st:=st+'ERZE / EDELMETALLE';
    4:st:=st+'WASSER';
    5:st:=st+'GENUSSMITTEL';
    6:st:=st+'HOLZ';
    7:st:=st+'GETREIDE';
    8:st:=st+'VIEH';
    9:st:=st+'GöTERFABRIK';
    10:st:=st+'SCHMELZWERK';END;
END;
PROCEDURE IB;
BEGIN
  CASE mapx^.ft[ctf-20] OF 0..4:st:='Bergwerk'+st;
    5,6,9,10:st:='Industrie'+st;
    7,8:st:='Farm'+st;
  END;
END;
PROCEDURE DrawMap(dt:BYTE);
VAR om,zy,xm,ym,am:BYTE;ax,ay,pln,wx,wy,gx,gy:WORD;
BEGIN
  om:=0;
  gx:=(xp DIV 320+1)*320-xp;gy:=(yp DIV 200+1)*200-yp;
  IF gx>320 THEN gx:=320;IF gy>200 THEN gy:=200;
  CASE dt OF
    1:BEGIN gx:=4;FOR pln:=0 TO 199 DO BEGIN ay:=pln*80+2;
        MOVE(page[1]^[ay-1],page[0]^[ay],79);
        MOVE(page[1]^[15999+ay],page[0]^[16000+ay],79);
        MOVE(page[1]^[31999+ay],page[0]^[32000+ay],79);
        MOVE(page[1]^[47999+ay],page[0]^[48000+ay],79);END;END;
    2:BEGIN gx:=316;FOR pln:=0 TO 199 DO BEGIN ay:=pln*80+2;
        MOVE(page[1]^[ay],page[0]^[ay-1],79);
        MOVE(page[1]^[16000+ay],page[0]^[15999+ay],79);
        MOVE(page[1]^[32000+ay],page[0]^[31999+ay],79);
        MOVE(page[1]^[48000+ay],page[0]^[47999+ay],79);END;END;
    3:BEGIN gy:=4;MOVE(page[1]^[1],page[0]^[321],15680);
      MOVE(page[1]^[16001],page[0]^[16321],15680);
      MOVE(page[1]^[32001],page[0]^[32321],15680);
      MOVE(page[1]^[48001],page[0]^[48321],15680);END;
    4:BEGIN gy:=196;MOVE(page[1]^[321],page[0]^[1],15680);
      MOVE(page[1]^[16321],page[0]^[16001],15680);
      MOVE(page[1]^[32321],page[0]^[32001],15680);
      MOVE(page[1]^[48321],page[0]^[48001],15680);END;
  END;
  IF dt<>5 THEN BEGIN
    IF (dt<>2) AND (dt<>4) THEN FOR ax:=0 TO gx-1 DO BEGIN
      wx:=ax DIV 4;pln:=(ax-wx*4)*16000+wx+1;
      xm:=(xp+ax) DIV 320;wx:=xp+ax-xm*320;
      FOR ay:=0 TO gy-1 DO BEGIN
        ym:=(yp+ay) DIV 200;wy:=yp+ay-ym*200;
        am:=xm+ym*3+1;IF am<>om THEN BEGIN om:=am;EMS_2_RAM(map,ems[am],64000);END;
        page[0]^[pln+ay*80]:=map^[wx+wy*320+1] DIV 4+128;END;END;
    IF (dt<>2) AND (dt<>3) THEN FOR ax:=0 TO gx-1 DO BEGIN
      wx:=ax DIV 4;pln:=(ax-wx*4)*16000+wx+1;
      xm:=(xp+ax) DIV 320;wx:=xp+ax-xm*320;
      FOR ay:=gy TO 199 DO BEGIN
        ym:=(yp+ay) DIV 200;wy:=yp+ay-ym*200;
        am:=xm+ym*3+1;IF am<>om THEN BEGIN om:=am;EMS_2_RAM(map,ems[am],64000);END;
        page[0]^[pln+ay*80]:=map^[wx+wy*320+1] DIV 4+128;END;END;
    IF (dt<>1) AND (dt<>4) THEN FOR ax:=gx TO 319 DO BEGIN
      wx:=ax DIV 4;pln:=(ax-wx*4)*16000+wx+1;
      xm:=(xp+ax) DIV 320;wx:=xp+ax-xm*320;
      FOR ay:=0 TO gy-1 DO BEGIN
        ym:=(yp+ay) DIV 200;wy:=yp+ay-ym*200;
        am:=xm+ym*3+1;IF am<>om THEN BEGIN om:=am;EMS_2_RAM(map,ems[am],64000);END;
        page[0]^[pln+ay*80]:=map^[wx+wy*320+1] DIV 4+128;END;END;
    IF (dt<>1) AND (dt<>3) THEN FOR ax:=gx TO 319 DO BEGIN
      wx:=ax DIV 4;pln:=(ax-wx*4)*16000+wx+1;
      xm:=(xp+ax) DIV 320;wx:=xp+ax-xm*320;
      FOR ay:=gy TO 199 DO BEGIN
        ym:=(yp+ay) DIV 200;wy:=yp+ay-ym*200;
        am:=xm+ym*3+1;IF am<>om THEN BEGIN om:=am;EMS_2_RAM(map,ems[am],64000);END;
        page[0]^[pln+ay*80]:=map^[wx+wy*320+1] DIV 4+128;END;END;
    MOVE(page[0]^,page[1]^,64000);END ELSE MOVE(page[1]^,page[0]^,64000);
  FOR am:=1 TO road^.sc DO BEGIN
    IF road^.p1[am]>20 THEN
     BEGIN wx:=mapx^.fx[road^.p1[am]-20];wy:=mapx^.fy[road^.p1[am]-20];END
     ELSE BEGIN wx:=mapx^.tx[road^.p1[am]];wy:=mapx^.ty[road^.p1[am]];END;
    IF road^.p2[am]>20 THEN
     BEGIN gx:=mapx^.fx[road^.p2[am]-20];gy:=mapx^.fy[road^.p2[am]-20];END
     ELSE BEGIN gx:=mapx^.tx[road^.p2[am]];gy:=mapx^.ty[road^.p2[am]];END;
    Line(wx-xp,wy-yp,gx-xp,gy-yp,253);
  END;
  FOR am:=1 TO mapx^.fc DO IF (mapx^.fx[am]>=xp) AND (mapx^.fx[am]<xp+320)
    AND (mapx^.fy[am]>=yp) AND (mapx^.fy[am]<yp+200) THEN BEGIN
      Pixel(mapx^.fx[am]-xp,mapx^.fy[am]-yp,192);st:='';
      IF active AND 8=8 THEN BEGIN STR(am,st);st:=st+'-';ID(am);
        OutSTxt(mapx^.fx[am]-xp-LENGTH(st)*3,mapx^.fy[am]-yp+2,st,192);END;END;
  FOR am:=1 TO mapx^.tc DO IF (mapx^.tx[am]>=xp) AND (mapx^.tx[am]<xp+320)
    AND (mapx^.ty[am]>=yp) AND (mapx^.ty[am]<yp+200) THEN BEGIN
    IF mapx^.tt[am] AND 2=2 THEN om:=193 ELSE om:=194;
    Pixel(mapx^.tx[am]-xp,mapx^.ty[am]-yp,om);
    IF active AND 8=8 THEN
     OutSTxt(mapx^.tx[am]-xp-LENGTH(mapx^.tn[am])*3,mapx^.ty[am]-yp+2,mapx^.tn[am],om);END;
  IF active AND 2=2 THEN BEGIN
    STR((stime.gt+4760)/100:0:2,st);OutBTxt(168-LENGTH(st)*8,109,st,255);
    STR(stime.ev,st);IF LENGTH(st)=1 THEN st:='0'+st;
    OutBTxt(168,109,':'+st+' ST',255);
    IF active AND 4=0 THEN BEGIN st:='START';om:=254;am:=192;END ELSE
     BEGIN IF active AND 1=1 THEN BEGIN st:='PAUSE';om:=255;am:=193;END ELSE
       BEGIN st:='WEITER';om:=249;am:=194;END;END;
    OutBTxt(103,109,CHR(om),253);OutBTxt(105,109,CHR(om),253);
    OutBTxt(104,108,CHR(om),253);OutBTxt(104,110,CHR(om),253);
    OutBTxt(104,109,CHR(om),am);
    Block(90,116,229,124,st);
    IF active AND 8=8 THEN st:='N' ELSE st:='US';
    Block(90,143,229,151,'NAMEN: A'+st);
    Block(90,134,229,142,'SUCHEN');
    IF active AND 4=4 THEN BEGIN am:=ctf;ctf:=trk.p;
      IF trk.p<>0 THEN BEGIN IF ctf<21 THEN st:='STADT'
       ELSE BEGIN st:='';IB;END;ctf:=am;
        IF LENGTH(st)=8 THEN st:='ZUM '+st ELSE st:='ZUR '+st;
        Block(90,125,229,133,st);END;
      st:='DISK-OPERATION';END ELSE st:='SZENE SPEICHERN';
    Block(90,152,229,160,st);
    Block(90,161,229,169,'<BEENDEN>');
  END;
END;
PROCEDURE Waren(stw:BYTE);
BEGIN
  IF stw>20 THEN BEGIN ware[2]:=512;
    CASE mapx^.ft[stw-20] OF 0:ware[1]:=1;
      1:ware[1]:=2;
      2:ware[1]:=8;
      3:ware[1]:=500;
      4:BEGIN ware[1]:=512;ware[2]:=0;END;
      5:ware[1]:=7168;
      6:ware[1]:=8192;
      7:ware[1]:=114688;
      8:ware[1]:=393216;
      9:BEGIN ware[1]:=50331648;INC(ware[2],1573306);END;
      10:BEGIN ware[1]:=1572864;INC(ware[2],340);END;
  END;END ELSE
   IF mapx^.tt[stw] AND 2=2 THEN BEGIN
      ware[1]:=67108863;ware[2]:=67108351;END ELSE BEGIN
    ware[1]:=0;ware[2]:=515584;
    IF mapx^.tt[stw] AND 1=1 THEN BEGIN
      ware[1]:=ware[1] OR 50331648;ware[2]:=ware[2] OR 50331648;END;
    IF mapx^.tt[stw] AND 4=4 THEN BEGIN
      ware[1]:=ware[1] OR 33554432;ware[2]:=ware[2] OR 1572920;END;
    IF mapx^.tt[stw] AND 8=8 THEN BEGIN
      ware[1]:=ware[1] OR 16777216;ware[2]:=ware[2] OR 162;END;
    IF mapx^.tt[stw] AND 16=16 THEN ware[1]:=ware[1] OR 114688;
    IF mapx^.tt[stw] AND 32=32 THEN ware[1]:=ware[1] OR 393216;
    IF mapx^.tt[stw] AND 64=64 THEN BEGIN
      ware[1]:=ware[1] OR 324;ware[2]:=ware[2] OR 324;END;
    IF mapx^.tt[stw] AND 128=128 THEN BEGIN
      ware[1]:=ware[1] OR 14680064;ware[2]:=ware[2] OR 14680064;END;
  END;
END;
PROCEDURE p2k;
VAR by0:BYTE;
BEGIN
  FOR by0:=1 TO LENGTH(st) DO IF st[by0]='.' THEN st[by0]:=',';
END;
PROCEDURE GoCity;
TYPE vbdg=RECORD
            a:BYTE;
            z,r,s:ARRAY[1..20]OF BYTE;
            e:ARRAY[1..20]OF WORD;
          END;
VAR palbf:Pal256;
    act,ch,sp,km:BYTE;
    vbd:vbdg;
PROCEDURE Verbindung;
VAR by0,by1,by2:BYTE;x1,y1,x2,y2:INTEGER;
BEGIN
  vbd.a:=0;
  FOR by0:=1 TO road^.sc DO IF vbd.a<20 THEN BEGIN
    by1:=road^.p1[by0];by2:=road^.p2[by0];
    IF (by1=ctf) OR (by2=ctf) THEN BEGIN
      IF by1<21 THEN BEGIN x1:=mapx^.tx[by1];y1:=mapx^.ty[by1];END
       ELSE BEGIN x1:=mapx^.fx[by1-20];y1:=mapx^.fy[by1-20];END;
      IF by2<21 THEN BEGIN x2:=mapx^.tx[by2];y2:=mapx^.ty[by2];END
       ELSE BEGIN x2:=mapx^.fx[by2-20];y2:=mapx^.fy[by2-20];END;
      IF by1=ctf THEN BEGIN INC(vbd.a);vbd.z[vbd.a]:=by2;vbd.s[vbd.a]:=by0;
        vbd.r[vbd.a]:=2;vbd.e[vbd.a]:=Entfernung(x1,y1,x2,y2);END ELSE
      IF by2=ctf THEN BEGIN INC(vbd.a);vbd.z[vbd.a]:=by1;vbd.s[vbd.a]:=by0;
        vbd.r[vbd.a]:=1;vbd.e[vbd.a]:=Entfernung(x1,y1,x2,y2);END;END;END;
END;
PROCEDURE Haendler;
VAR mpa:mpa_file;mpa_x:BOOLEAN;palbuf:Pal256;doing,cho1,cho2,may1,may2:BYTE;
    sgl1,sgl2:SINGLE;s3:STRING[3];
    wa,ca:RECORD
           a:BYTE;
           n:ARRAY[1..26]OF BYTE;END;
PROCEDURE Cargo;
BEGIN
  ca.a:=0;FOR b1:=0 TO 25 DO IF (trk.c[b1]>0) AND
   (ware[2] AND TRUNC(EXP(b1*LN(2)))>0) THEN BEGIN INC(ca.a);ca.n[ca.a]:=b1;END;
END;
PROCEDURE WriteCargo(nr:BYTE);
VAR col:BYTE;
BEGIN
  IF nr>=ca.a THEN EXIT;
  IF nr=may1 THEN col:=245 ELSE col:=244;
  FBox(174,nr*7+9,235,nr*7+15,col);
  IF nr=cho1 THEN col:=243 ELSE col:=246;
  OutSTxt(175,nr*7+10,GetWare[ca.n[nr+1]],col);
END;
PROCEDURE WriteWare(nr:BYTE);
VAR col:BYTE;
BEGIN
  IF nr>=wa.a THEN EXIT;
  IF nr=may2 THEN col:=248 ELSE col:=247;
  FBox(249,nr*7+9,310,nr*7+15,col);
  IF nr=cho2 THEN col:=243 ELSE col:=250;
  OutSTxt(250,nr*7+10,GetWare[wa.n[nr+1]],col);
END;
BEGIN
  FILLCHAR(page[0]^,64000,0);Waren(ctf);wa.a:=0;
  FOR b1:=0 TO 25 DO IF ware[1] AND TRUNC(EXP(b1*LN(2)))>0 THEN
   BEGIN INC(wa.a);wa.n[wa.a]:=b1;END;Cargo;
  MOVE(pal,palbuf,768);FILLCHAR(palbuf[240,0],27,0);
  palbuf[247,2]:=20;palbuf[248,0]:=5;palbuf[248,1]:=5;palbuf[248,2]:=40;
  palbuf[244,1]:=15;palbuf[245,0]:=3;palbuf[245,2]:=3;palbuf[245,1]:=30;palbuf[246,1]:=63;
  FOR b1:=0 TO 3 DO FILLCHAR(palbuf[240+b1,0],3,b1*12+21);
  OpenMPA('WAREN.MPA',mpa);
  IF mpa.bez='Waren' THEN mpa_x:=FALSE ELSE mpa_x:=TRUE;
  Block(0,180,84,198,'OK');Block(85,180,169,198,'ZURöCK');
  Show;SetPal(pal);
  OutText(10,80,'PREIS:',240,0,4);
  Block(10,111,38,129,'5¸');Block(39,111,57,129,'¸');
  Block(112,111,130,129,'˝');Block(131,111,159,129,'5˝');
  FBox(170,5,239,194,244);FBox(245,5,314,194,247);
  cho1:=255;may1:=255;cho2:=255;may2:=255;doing:=4;l1:=0;
  IF ca.a<>0 THEN cho1:=0 ELSE cho2:=0;
  FOR b1:=0 TO 25 DO BEGIN WriteWare(b1);WriteCargo(b1);END;
  REPEAT
    IF cho1=255 THEN WHILE ((l1>trk.f) OR (geld-l1*sgl2<0)) AND (l1>0) DO DEC(l1)
     ELSE WHILE l1>trk.c[ca.n[cho1+1]] DO DEC(l1);
    IF l1<0 THEN l1:=0;
    CASE doing OF 2:IF may2<>(ms.y-10) DIV 7 THEN BEGIN b1:=may2;
        may2:=(ms.y-10) DIV 7;WriteWare(b1);WriteWare(may2);may1:=255;END;
      3:IF may1<>(ms.y-10) DIV 7 THEN BEGIN b1:=may1;
        may1:=(ms.y-10) DIV 7;WriteCargo(b1);WriteCargo(may1);may2:=255;END;
      4:BEGIN mpa.pos:=0;
        IF cho1=255 THEN b1:=wa.n[cho2+1] ELSE b1:=ca.n[cho1+1];
        SEEK(mpa.af,20+3474*LONGINT(b1));LoadMPA(0,0,mpa,0);
        MOVE(palbuf[240,0],pal[240,0],48);
        FBox(70,10,159,29,0);OutText(70,10,GetWare[b1],240,0,4);
        st:='KAUFEN:';IF cho1<>255 THEN st:='VER'+st;
        FBox(10,70,90,74,0);OutBTxt(10,70,st,242);
        IF cho1=255 THEN b1:=wa.n[cho2+1] ELSE b1:=ca.n[cho1+1];
        IF ctf<21 THEN sgl2:=mapx^.pr[ctf,b1] ELSE sgl2:=GetPrice[b1];
        IF cho1<>255 THEN IF ctf<21 THEN sgl2:=sgl2*0.98 ELSE sgl1:=sgl2*1.1;
        STR(sgl2:0:2,st);
        p2k;FBox(80,80,159,99,0);OutText(162,80,st+pdol,240,1,4);
        FBox(9,9,60,60,0);Show;
        LoadMPA(10,10,mpa,0);
        SetPal(pal);l1:=0;doing:=5;
      END;
    END;
    IF doing=5 THEN BEGIN FBox(100,70,159,74,0);
      STR(trk.m,s3);STR(trk.f,st);st:=st+'/'+s3;OutBTxt(160-LENGTH(st)*8,70,st,242);
      FBox(60,111,109,129,0);FBox(10,140,159,169,0);
      STR(l1,st);OutText(99,111,st,240,1,4);
      SLine(25,160,159,160,242);
      STR(geld:14:2,st);p2k;OutBTxt(25,140,st+pdol,242);
      sgl1:=sgl2*l1;STR(sgl1:13:2,st);p2k;
      IF cho1=255 THEN BEGIN st:='-'+st;sgl1:=geld-sgl1;END
       ELSE BEGIN st:='+'+st;sgl1:=geld+sgl1;END;
      OutBTxt(25,150,st+pdol,242);
      STR(sgl1:13:2,st);p2k;OutBTxt(25,165,'='+st+pdol,242);
    END;
    Show;
    REPEAT REPEAT UNTIL Mouse>0;doing:=0;
      IF Click(85,180,169,198,1) THEN doing:=1;
      IF Click(10,111,38,129,1) THEN BEGIN INC(l1,5);doing:=5;END;
      IF Click(39,111,57,129,1) THEN BEGIN INC(l1);doing:=5;END;
      IF Click(112,111,130,129,1) THEN BEGIN DEC(l1);doing:=5;END;
      IF Click(131,111,159,129,1) THEN BEGIN DEC(l1,5);doing:=5;END;
      IF Click(0,180,84,198,1) THEN IF cho1=255 THEN BEGIN geld:=geld-l1*sgl2;
        INC(trk.c[wa.n[cho2+1]],l1);DEC(trk.f,l1);Cargo;
        FOR b1:=0 TO ca.a-1 DO WriteCargo(b1);doing:=5;END
       ELSE BEGIN geld:=geld+l1*sgl2;FBox(174,ca.a*7+2,235,ca.a*7+8,244);
        DEC(trk.c[ca.n[cho1+1]],l1);INC(trk.f,l1);doing:=5;b1:=ca.a;Cargo;
        IF b1>ca.a THEN doing:=4;
        IF ca.a=0 THEN BEGIN cho1:=255;cho2:=0;WriteWare(0);END
         ELSE IF cho1>=ca.a THEN BEGIN cho1:=0;END;
        FOR b1:=0 TO ca.a-1 DO WriteCargo(b1);END;
      IF (ms.x>244) AND (ms.x<315) AND (ms.y>9) AND (ms.y<9+7*wa.a) THEN doing:=2
       ELSE IF may2<>255 THEN BEGIN b1:=may2;may2:=255;WriteWare(b1);END;
      IF (ms.b AND 1=1) AND (may2<>255) AND (may2<>cho2) THEN BEGIN
        doing:=4;b1:=cho2;cho2:=may2;WriteWare(b1);WriteWare(cho2);
        b1:=cho1;cho1:=255;WriteCargo(b1);END;
      IF (ms.x>169) AND (ms.x<239) AND (ms.y>9) AND (ms.y<9+7*ca.a) THEN doing:=3
       ELSE IF may1<>255 THEN BEGIN b1:=may1;may1:=255;WriteCargo(b1);END;
      IF (ms.b AND 1=1) AND (may1<>255) AND (may1<>cho1) THEN BEGIN
        doing:=4;b1:=cho1;cho1:=may1;WriteCargo(b1);WriteCargo(cho1);
        b1:=cho2;cho2:=255;WriteWare(b1);END;
      IF geld>=rspreis THEN doing:=1;
      Show;
    UNTIL doing>0;
  UNTIL doing=1;
  CLOSE(mpa.af);
END;
PROCEDURE Terminal;
VAR palbuf:Pal256;x1,y1,nxt,origcity:BYTE;cf:LONGINT;cfd:BOOLEAN;
PROCEDURE Pal240;
BEGIN
  FOR b1:=1 TO 4 DO MOVE(pal[28,0],pal[240+b1,0],3);
END;
PROCEDURE TScr;
BEGIN
  MOVE(page[1]^,page[0]^,64000);
  Block(50,72,269,88,'UNINET-OS 3.12B');
  Block(50,92,269,108,'KARTE');
  Block(50,112,269,128,'WAREN-PREISE');
  Block(50,132,269,148,'UNINET..LOGOUT');
  OutBTxt(52,60,'ZUGANGSBERECHTIGUNG STUFE 2',240);
  Pal240;MOVE(pal[28,0],pal[240,0],3);
  FOR b1:=1 TO 4 DO IF LENGTH(news^[b1])<35 THEN
   OutBTxt(5,151+b1*10,news^[b1],240+b1) ELSE OutSTxt(5,151+b1*10,news^[b1],240+b1);
  cf:=0;nxt:=0;time:=0;
END;
PROCEDURE uninetOS;
VAR xc,yc:BYTE;
PROCEDURE Scroll;
BEGIN
  MOVE(page[0]^,page[1]^,64000);
  FOR b1:=0 TO 3 DO BEGIN
    MOVE(page[1]^[640+b1*16000],page[0]^[b1*16000],15360);
    FILLCHAR(page[0]^[15360+b1*16000],640,28);END;
END;
PROCEDURE Out(tx:STRING);
BEGIN
  OutBTxt(xc*8+1,yc*8+1,tx,97);Show;
  IF yc>23 THEN Scroll ELSE INC(yc);
  xc:=0;
END;
PROCEDURE InPut(tx:STRING;VAR ist:STRING);
VAR stg:STRING;pos:BYTE;
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
  OutBTxt(xc*8+1,yc*8+1,tx,97);INC(xc,LENGTH(tx));Show;
  stg:=ist;pos:=LENGTH(stg)+1;time:=0;
  REPEAT
    FBox(xc*8,yc*8,(LENGTH(stg)+xc)*8+16,yc*8+6,28);
    IF time<4 THEN FBox((xc+pos)*8-8,yc*8,(xc+pos)*8,yc*8+6,165);
    IF time>7 THEN time:=0;
    OutBTxt(xc*8+1,yc*8+1,stg,97);Show;
    Keys;
    IF (key[1]>#31) AND (key[1]<#155) AND (LENGTH(stg)<39-xc) THEN BEGIN
     VOC_done;Init_VOC('BEEP.SND');
     stg:=COPY(stg,1,pos-1)+Gross+COPY(stg,pos,LENGTH(stg)-pos+1);INC(pos);END;
    IF (key[1]=#8) AND (pos>1) THEN BEGIN
     stg:=COPY(stg,1,pos-2)+COPY(stg,pos,LENGTH(stg)-pos+1);DEC(pos);END;
    CASE key[2] OF #75:IF pos>1 THEN DEC(pos);
      #77:IF pos<=LENGTH(stg) THEN INC(pos);
      #83:IF (pos<=LENGTH(stg)) AND (LENGTH(stg)>0) THEN
       stg:=COPY(stg,1,pos-1)+COPY(stg,pos+1,LENGTH(stg)-pos);
      #71:pos:=1;
      #79:pos:=LENGTH(stg)+1;
    END;
  UNTIL (key[1]=#13) OR (key[2]=#72) OR (key[2]=#80);
  FBox(xc*8,yc*8,(LENGTH(stg)+xc)*8+16,yc*8+6,28);
  IF key[2]=#72 THEN ist:=#1 ELSE IF key[2]=#80 THEN ist:=#2 ELSE
   BEGIN ist:=stg;OutBTxt(xc*8+1,yc*8+1,ist,97);
    IF yc>23 THEN Scroll ELSE INC(yc);xc:=0;END;
  Show;
END;
PROCEDURE Quit;
BEGIN
  Out('ARE YOU SURE TO WANT TO QUIT (Y/N)');
  REPEAT st:='';InPut('?',st);
    IF (st='Y') OR (st='YES') OR (st='YO') THEN Halt(256);
  UNTIL (st='N') OR (st='NO');
END;
PROCEDURE Memory;
BEGIN
  STR(MEMAVAIL/1024:9:1,st);
  Out('HEAP:'+st+' KB');
  STR(mem/1024:9:1,st);
  Out(' MAX:'+st+' KB');
  STR((mem-MEMAVAIL)/1024:8:1,st);
  Out(' USED:'+st+' KB');
  STR(EMS_free/1024:10:1,st);
  Out('EMS:'+st+' KB');
  STR(DISKFREE(0)/1024:9:0,st);
  Out('DISK:'+st+' KB');
END;
PROCEDURE CD_Play;
VAR by0:BYTE;wo0:WORD;
BEGIN
  IF NOT CDRom THEN BEGIN Out('!ERROR: NO CD-ROM-DRIVE FOUNDED');EXIT;END;
  wo0:=0;
  IF LENGTH(st)=4 THEN by0:=1 ELSE VAL(COPY(st,5,LENGTH(st)-4),by0,wo0);
  IF wo0<>0 THEN BEGIN Out('!ERROR: UNCORRECT PARAMETER');EXIT;END;
  STR(by0,st);Out('PLAYING CD FROM TRACK '+st+'.');
  PlayCD(0,0);PlayCD(by0,0);
END;
BEGIN
  ms.on:=FALSE;MOVE(page[1]^,page[0]^,64000);FBox(276,156,319,199,28);
  xc:=0;yc:=6;Out('UNINET-OS 3.12B');st:='';
  Out('(C)44.78 BY GOLDENWORKS SOFTWARE');INC(yc);
  Out('TYPE "EXIT" TO RETURN TO TERMINAL.');INC(yc);Init_VOC('BEEP.SND');
  REPEAT
    IF st='CLS' THEN BEGIN FILLCHAR(page[0]^,64000,28);xc:=0;yc:=0;END
     ELSE IF st='QUIT' THEN Quit
     ELSE IF st='MEM' THEN Memory
     ELSE IF COPY(st,1,4)='CD P' THEN CD_Play
     ELSE IF (st='CD S') AND CDRom THEN BEGIN Out('STOPPING CD.');PlayCD(0,0);END
     ELSE IF st='' THEN ELSE Out('!ERROR: UNKNOWN COMMAND');
    st:='';InPut('>',st);
  UNTIL st='EXIT';
  ms.on:=TRUE;
  LoadVPic(0,0,pf,'Terminal-Bildschirm',palbuf);
  FBox(0,0,319,2,0);SLine(318,199,319,199,21);MOVE(page[0]^,page[1]^,64000);
  TScr;SetPal(pal);VOC_done;
END;
PROCEDURE ChooseCity;
VAR byt0,byt1,byt2,byt3,byt4:BYTE;city:^city_type;
PROCEDURE WriteCity(coi,nr:BYTE);
BEGIN
  IF coi=0 THEN OutBTxt(10,nr*7+53,city^[nr+1].n,255) ELSE
   BEGIN STR(nr+1,st);IF LENGTH(st)=1 THEN st:='0'+st;st:='I'+st+': ';
    OutBTxt(160,nr*7+53,st,255);st:='';
    ID(nr+1);OutSTxt(200,nr*7+53,st,255);END;
END;
BEGIN
  NEW(city);
  MOVE(page[1]^,page[0]^,64000);FBox(276,156,319,199,28);
  byt3:=0;byt4:=0;FBox(5,50,314,194,10);
  Cities(city^);
  FOR byt0:=1 TO mapx^.tc DO WriteCity(0,byt0-1);
  FOR byt0:=1 TO mapx^.fc DO WriteCity(1,byt0-1);
  REPEAT
    byt1:=(ms.y-52) DIV 7;byt2:=ms.x DIV 160;
    IF byt1>19 THEN IF ms.y<52 THEN byt1:=0 ELSE byt1:=19;
    IF (byt2=0) AND (byt1>=mapx^.tc) THEN byt1:=mapx^.tc-1 ELSE
     IF (byt2=1) AND (byt1>=mapx^.fc) THEN byt1:=mapx^.fc-1;
    FBox(9+150*byt4,52+byt3*7,157+150*byt4,58+byt3*7,10);
    WriteCity(byt4,byt3);byt3:=byt1;byt4:=byt2;
    FBox(9+150*byt2,52+byt1*7,157+150*byt2,58+byt1*7,97);
    WriteCity(byt2,byt1);
    Show;REPEAT UNTIL Mouse>0;
  UNTIL ms.b<>0;byt3:=ms.b;
  IF byt3 AND 2=2 THEN BEGIN
    FBox(9+150*byt2,52+byt1*7,157+150*byt2,58+byt1*7,10);WriteCity(byt2,byt1);END;
  REPEAT Mouse;Show;UNTIL ms.b<>byt3;
  IF byt3 AND 1=1 THEN IF byt2=0 THEN ctf:=city^[byt1+1].nr ELSE ctf:=byt1+21;
  DISPOSE(city);
END;
{PROCEDURE PrsInfo;
VAR by0,by1:BYTE;
BEGIN
  MOVE(page[1]^,page[0]^,64000);FBox(276,156,319,199,28);
  Block(50,172,269,188,'ZURöCK');Pal240;
  OutBTxt(50,60,'ID:',241);OutBTxt(140,60,'NG-M-00350197322',242);
  OutBTxt(50,70,'GUTHABEN:',241);
  STR(geld:13:2,st);p2k;OutBTxt(140,70,st+' P$',242);
  OutBTxt(50,80,'VERTRéGE:',241);OutBTxt(140,80,'KEINE',242);
  OutBTxt(50,140,'SONSTIGES:',241);
  IF stime.gt>=timeout THEN BEGIN OutBTxt(140,150,'[\BANKBETRUG]',242);
    st:='PD-HAFTBEFEHL';END ELSE st:='-';
  OutBTxt(140,140,st,242);
  Show;cf:=0;time:=0;nxt:=1;
  REPEAT
    REPEAT
      IF (cf<12) AND (time>0) THEN BEGIN IF nxt<3 THEN BEGIN
          pal[240+nxt,1]:=43-cf*2;pal[240+nxt,2]:=63-cf*2;SetPal(pal);END;
        INC(cf);IF cf=12 THEN BEGIN cf:=0;INC(nxt);END;
        time:=0;END;
    UNTIL Mouse>0;
    Show;
  UNTIL Click(50,172,269,188,1);
  TScr;SetPal(pal);
END;}
PROCEDURE Prices;
VAR by0,by1,by2,col:BYTE;sgl:SINGLE;
BEGIN
  by1:=5;
  REPEAT
    IF by1=3 THEN ChooseCity;
    IF by1>2 THEN BEGIN Waren(ctf);sp:=0;
      MOVE(page[1]^,page[0]^,64000);
      FBox(276,156,319,199,28);
      Block(5,176,24,194,'¸');
      Block(25,176,44,194,'˝');
      Block(45,176,239,194,'STADT / INDUSTRIE');
      Block(240,176,314,194,'ZURöCK');END;
    by2:=0;FBox(5,50,314,169,10);
    FOR by0:=0 TO 25 DO IF (by0<>22) AND (by0<>23) THEN BEGIN col:=0;
      IF ware[1] AND TRUNC(EXP(by0*LN(2)))>0 THEN BEGIN INC(by2);col:=247;END;
      IF ware[2] AND TRUNC(EXP(by0*LN(2)))>0 THEN IF col=0 THEN BEGIN
        col:=246;INC(by2);END ELSE col:=245;
      IF (col<>0) AND (by2>sp*12) AND (by2<sp*12+14) THEN BEGIN
        OutBTxt(10,(by2-sp*12)*8+57,GetWare[by0],col);
        IF ctf<21 THEN sgl:=mapx^.pr[ctf,by0] ELSE sgl:=GetPrice[by0];
        STR(sgl:7:2,st);p2k;
        IF col<>246 THEN OutSTxt(172,(by2-sp*12)*8+57,st+pdol,254);
        IF ctf<21 THEN STR(sgl*0.98:8:2,st) ELSE STR(sgl*1.1:8:2,st);p2k;
        IF col<>247 THEN OutSTxt(244,(by2-sp*12)*8+57,st+pdol,254);
      END;
    END;
    IF ctf<21 THEN st:=mapx^.tn[ctf] ELSE
     BEGIN STR(ctf-20,st);IF LENGTH(st)=1 THEN st:='0'+st;
      st:='I'+st+': ';ID(ctf-20);END;
    FBox(8,53,11+LENGTH(st)*8,61,97);OutBTxt(10,55,st,255);
    Show;
    REPEAT REPEAT UNTIL Mouse>0;
      Show;by1:=0;
      IF Click(5,176,24,194,1) THEN by1:=1 ELSE
       IF Click(25,176,44,194,1) THEN by1:=2 ELSE
       IF Click(45,176,239,194,1) THEN by1:=3 ELSE
       IF Click(240,176,314,194,1) THEN by1:=4;
    UNTIL by1>0;
    IF (by1=1) AND (sp>0) THEN DEC(sp);
    IF (by1=2) AND (by2>sp*12+13) THEN INC(sp);
  UNTIL by1=4;
  TScr;SetPal(pal);
END;
BEGIN
  ms.on:=FALSE;MOVE(pal,palbuf,768);BlackPal;origcity:=ctf;
  LoadVPic(0,0,pf,'Terminal-Bildschirm',pal);
  MOVE(palbuf[249,0],pal[249,0],21);
  FBox(0,0,319,2,0);SLine(318,199,319,199,21);MOVE(page[0]^,page[1]^,64000);
  pal[245,0]:=63;pal[246,1]:=63;pal[247,2]:=63;
  TScr;MOVE(pal,palbuf,768);BlackPal;Show;InPic(pal,2,0,255);
  ms.on:=TRUE;show;
  REPEAT
    REPEAT
      IF (cf<12) AND (time>0) THEN BEGIN IF nxt<5 THEN BEGIN
          pal[240+nxt,1]:=43-cf*2;pal[240+nxt,2]:=63-cf*2;SetPal(pal);END;
        IF nxt=19 THEN FOR b1:=1 TO 4 DO BEGIN DEC(pal[240+b1,1]);
          DEC(pal[240+b1,2]);SetPal(pal);END;
        INC(cf);IF cf=12 THEN BEGIN cf:=0;INC(nxt);
          IF nxt=20 THEN BEGIN nxt:=1;Pal240;SetPal(pal);END;END;
        time:=0;END;
    UNTIL Mouse>0;
    IF Click(50,72,269,88,1) THEN uninetOS;
    IF Click(50,92,269,108,1) THEN act:=16;
    IF Click(50,112,269,128,1) THEN Prices;
    Show;
  UNTIL (Click(50,132,269,148,1)) OR (act=16);
  OutPic(pal,8,0,255);ctf:=origcity;
END;
PROCEDURE Angebote;
VAR palbuf:Pal256;by1,by2:BYTE;x0,y0:INTEGER;
BEGIN
  LoadVPic(0,0,pf,'Angebot-Bildschirm',palbuf);
  MOVE(page[0]^,page[1]^,64000);
  MOVE(palbuf,pal,744);pal[240,1]:=50;
  BlackPal;Show;SetPal(pal);
  REPEAT MOVE(page[1]^,page[0]^,64000);
    FOR by1:=1 TO 10 DO IF (vertr^[by1].s<>0) OR (vertr^[by1].t<>0) THEN BEGIN
      x0:=(by1-1-(by1-1) DIV 5*5)*60+10;y0:=(by1-1) DIV 5*65+50;
      IF vertr^[by1].db AND 128=128 THEN st:='rot' ELSE st:='grÅn';
      LoadVPic(x0,y0,pf,'Clip ('+st+')',palbuf);
      IF vertr^[by1].s=0 THEN st:='BESORGEN' ELSE
       IF vertr^[by1].t=0 THEN st:='AUSBAU' ELSE st:='TRANSPORT';
      OutSTxt(x0+1,y0+17,st,240);
      STR(vertr^[by1].pr,st);
      OutSTxt(x0+42-LENGTH(st)*6,y0+24,st+pdol,240);
      IF (vertr^[by1].s=0) OR (vertr^[by1].t<>0) THEN st:=GetWare[vertr^[by1].db AND NOT 128];
      OutSTxt(x0+1,y0+31,st,240);
      STR(vertr^[by1].co,st);OutSTxt(x0+54-LENGTH(st)*6,y0+38,st+'X',240);
    END;
    Block(201,181,319,199,'ZURöCK');by1:=0;Show;
    REPEAT REPEAT UNTIL Mouse>0;Show;
      IF Click(201,181,319,199,1) THEN by1:=1;
      IF ms.b=1 THEN BEGIN x0:=(ms.x-10) DIV 60;y0:=(ms.y-48) DIV 65;
        IF (x0>=0) AND (x0<=5) AND ((y0=0) OR (y0=1)) THEN BEGIN
          REPEAT REPEAT UNTIL Mouse>0;Show;UNTIL ms.b AND 1=0;
          IF (x0=(ms.x-10) DIV 60) AND (y0=(ms.y-48) DIV 65)
           AND ((vertr^[x0+y0*5+1].s<>0) OR (vertr^[x0+y0*5+1].t<>0)) THEN by1:=2;
        END;
      END;
    UNTIL by1<>0;
    IF by1=2 THEN BEGIN MOVE(page[1]^,page[0]^,64000);
      by1:=x0+y0*5+1;
      IF vertr^[by1].s=0 THEN st:='BESORGEN' ELSE
       IF vertr^[by1].t=0 THEN st:='AUSBAU' ELSE st:='TRANSPORT';
      OutBTxt(20,50,st,240);
      IF st<>'AUSBAU' THEN BEGIN
        st:=GetWare[vertr^[by1].db AND NOT 128];
        OutBTxt(30,70,'WARE: '+st,240);
        STR(vertr^[by1].co,st);OutBTxt(30,80,'ANZAHL: '+st,240);
        STR(vertr^[by1].pr,st);st:='AUSZAHLUNG: '+st+pdol;
        IF vertr^[by1].s>0 THEN BEGIN
          OutBTxt(30,110,st,240);
          IF vertr^[by1].s<21 THEN st:=mapx^.tn[vertr^[by1].s] ELSE BEGIN
            STR(vertr^[by1].s-20,st);IF LENGTH(st)=1 THEN st:='0'+st;
            st:='I'+st+' - ';ID(vertr^[by1].s-20);END;
          OutBTxt(30,90,'QUELLE: '+st,240);
        END ELSE OutBTxt(30,90,st,240);
        OutBTxt(30,100,'ZIEL: '+mapx^.tn[vertr^[by1].t],240);
      END ELSE BEGIN
        STR(vertr^[by1].co,st);OutBTxt(30,70,'ERWEITERUNG: '+st,240);
        STR(vertr^[by1].pr,st);OutBTxt(30,80,'KOSTEN: '+st+pdol,240);
        STR(vertr^[by1].s-128,st);IF LENGTH(st)=1 THEN st:='0'+st;
        st:='I'+st+' - ';ID(vertr^[by1].s-128);
        OutBTxt(30,90,'ORT: '+st,240);
      END;
      STR((vertr^[by1].gd+4760)/100:0:2,st);
      OutBTxt(30,120,'AUSLAUF-ZEIT: '+st+':',240);
      STR(vertr^[by1].ev,st);IF LENGTH(st)=1 THEN st:='0'+st;
      OutBTxt(190,120,st+',00 ST',240);
      IF vertr^[by1].db AND 128=0 THEN BEGIN
        Block(50,161,159,179,'ANNEHMEN');Block(160,161,269,179,'VERWEIGERN');
      END ELSE BLOCK(50,161,269,179,'ZURöCK');
      Show;by2:=0;
      REPEAT REPEAT UNTIL Mouse>0;Show;
        IF vertr^[by1].db AND 128=0 THEN BEGIN
          IF Click(50,161,159,179,1) THEN by2:=1 ELSE
           IF Click(160,161,269,179,1) THEN by2:=2;
        END ELSE IF Click(50,161,269,179,1) THEN by2:=2;
      UNTIL by2<>0;
      IF by2=1 THEN vertr^[by1].db:=vertr^[by1].db OR 128;
      by1:=0;
    END;
  UNTIL by1=1;
END;
TYPE klikfld=ARRAY[0..3]OF RECORD
               x:INTEGER;y:BYTE;END;
VAR klkf:klikfld;klkt:ARRAY[0..3]OF STRING[8];
PROCEDURE GetCoord;
CONST HptStd:klikfld=((x:110;y:138),(x:166;y:111),(x:168;y:86),(x:166;y:26));
      StdRhf:klikfld=((x:138;y:45),(x:248;y:135),(x:116;y:64),(x:92;y:56));
      Stadt:klikfld=((x:152;y:82),(x:296;y:68),(x:174;y:65),(x:130;y:65));
      Farm:klikfld=((x:54;y:130),(x:74;y:107),(x:144;y:86),(x:148;y:41));
      Brgwrk:klikfld=((x:230;y:20),(x:21;y:97),(x:41;y:50),(x:70;y:80));
      Indstr:klikfld=((x:271;y:66),(x:283;y:136),(x:247;y:91),(x:233;y:137));
BEGIN
  klkt[0]:='AUSFAHRT';klkt[1]:='HéNDLER';klkt[2]:='TERMINAL';klkt[3]:='ANGEBOTE';
  IF ctf<21 THEN BEGIN
    IF mapx^.tt[ctf] AND 2=0 THEN IF mapx^.tt[ctf] AND 1=1 THEN
     klkf:=StdRhf ELSE klkf:=Stadt ELSE klkf:=HptStd END ELSE
   BEGIN IB;CASE st[1] OF 'B':klkf:=Brgwrk;'I':klkf:=Indstr;'F':klkf:=Farm;END;END;
END;
PROCEDURE DrawMenu;
BEGIN
  IF active AND 16=16 THEN BEGIN Block(90,162,229,170,'DISK-OPERATION');
    Block(90,171,229,179,'<BEENDEN>');
  END ELSE FOR b1:=0 TO 3 DO MOVE(page[1]^[b1*16000+12961],page[0]^[b1*16000+12961],1440);
END;
PROCEDURE City;
BEGIN
  IF ctf<21 THEN IF mapx^.tt[ctf] AND 2=0 THEN BEGIN
    st:='Stadt';IF mapx^.tt[ctf] AND 1=1 THEN st:=st+' mit Raumhafen';END
   ELSE st:='Hauptstadt'
  ELSE BEGIN st:='';IB;END;
  LoadVPic(0,0,pf,st,pal);
  MOVE(palbf[241,0],pal[241,0],45);
  FOR b1:=0 TO 7 DO FILLCHAR(pal[241+b1,0],3,b1*4+35);
  IF ctf<21 THEN BEGIN OutBTxt(5,5,st+':',248);
    OutText(4,12,mapx^.tn[ctf],0,0,16);
    OutText(6,12,mapx^.tn[ctf],0,0,16);
    OutText(5,11,mapx^.tn[ctf],0,0,16);
    OutText(5,13,mapx^.tn[ctf],0,0,16);
    OutText(5,12,mapx^.tn[ctf],241,0,2);
    STR(mapx^.ti[ctf],st);OutSTxt(255-LENGTH(st)*6,15,st+' EINWOHNER',248);
  END ELSE BEGIN STR(ctf-20,st);st:=' ('+st+'):';
    IB;OutBTxt(5,5,st,248);
    st:='';ID(ctf-20);OutText(4,12,st,0,0,16);OutText(6,12,st,0,0,16);
    OutText(5,11,st,0,0,16);OutText(5,13,st,0,0,16);OutText(5,12,st,241,0,2);
  END;MOVE(page[0]^[1],page[1]^[1],64000);
  sp:=0;GetCoord;DrawMenu;
  BlackPal;Show;SetPal(pal);
END;
PROCEDURE VSource(cnr:BYTE);
VAR palbuf:Pal256;
BEGIN
  IF trk.f=0 THEN EXIT;
  FILLCHAR(page[0]^,64000,0);Show;
  LoadVPic(0,0,pf,'Ein/Auslade-Bildschirm',palbuf);
  MOVE(palbuf,pal,744);SetPal(pal);
  OutBTxt(60,50,'WARE:',255);
  OutBTxt(60,70,'ZIEL:',255);
  Block(50,101,269,119,'FAHRZEUG BELADEN');
  Block(50,131,269,149,'NICHT BELADEN');Show;
  REPEAT UNTIL Mouse>0;
END;
PROCEDURE VDest(cnr:BYTE);
VAR palbuf:Pal256;
BEGIN
  {IF trk.f}
  FILLCHAR(page[0]^,64000,0);Show;
  LoadVPic(0,0,pf,'Ein/Auslade-Bildschirm',palbuf);
  MOVE(palbuf,pal,744);SetPal(pal);Show;
  REPEAT UNTIL Mouse>0;
END;
PROCEDURE VerbWahl;
VAR palbuf:Pal256;ausw,maybe:BYTE;
PROCEDURE WriteVerb(byt:BYTE);
VAR x1,y1,col:BYTE;s3:STRING[3];
BEGIN
  IF (vbd.a<byt) OR (byt=0) THEN EXIT;
  IF vbd.z[byt]<21 THEN st:=mapx^.tn[vbd.z[byt]]
   ELSE BEGIN STR(vbd.z[byt]-20,st);IF LENGTH(st)=1 THEN st:='0'+st;
    st:='I'+st+': ';ID(vbd.z[byt]-20);END;
  IF maybe=byt THEN FBox(159,byt*8+11,299,byt*8+17,249) ELSE
   FOR y1:=byt*8+11 TO byt*8+17 DO FOR x1:=0 TO 3 DO
   MOVE(page[1]^[y1*80+40+x1*16000],page[0]^[y1*80+40+x1*16000],40);
  IF ausw=byt THEN BEGIN col:=255;
    FOR y1:=150 TO 154 DO FOR x1:=0 TO 3 DO
    MOVE(page[1]^[y1*80+20+x1*16000],page[0]^[y1*80+20+x1*16000],11);
    STR(vbd.e[byt],s3);OutBTxt(114-LENGTH(s3)*8,150,s3,250);
  END ELSE col:=250;
  OutSTxt(160,byt*8+12,st,col);
END;
PROCEDURE DrawStreets;
VAR by1,col:BYTE;x1,y1,x2,y2:INTEGER;
BEGIN
  FOR by1:=1 TO road^.sc DO BEGIN
    IF by1=vbd.s[ausw] THEN col:=255 ELSE col:=252;
    IF road^.p1[by1]<21 THEN BEGIN x1:=mapx^.tx[road^.p1[by1]];y1:=mapx^.ty[road^.p1[by1]];END
     ELSE BEGIN x1:=mapx^.fx[road^.p1[by1]-20];y1:=mapx^.fy[road^.p1[by1]-20];END;
    IF road^.p2[by1]<21 THEN BEGIN x2:=mapx^.tx[road^.p2[by1]];y2:=mapx^.ty[road^.p2[by1]];END
     ELSE BEGIN x2:=mapx^.fx[road^.p2[by1]-20];y2:=mapx^.fy[road^.p2[by1]-20];END;
    Line(x1 DIV 8+10,y1 DIV 8+10,x2 DIV 8+10,y2 DIV 8+10,col);END;
END;
BEGIN
  LoadVPic(0,0,pf,'Verbindungs-Bildschirm',palbuf);
  MOVE(page[0]^,page[1]^,64000);
  MOVE(palbuf,pal,741);act:=0;maybe:=0;ausw:=1;Verbindung;
  OutBTxt(161,10,'ZIEL:',249);OutBTxt(161,12,'ZIEL:',249);
  OutBTxt(160,11,'ZIEL:',249);OutBTxt(162,11,'ZIEL:',249);
  OutBTxt(161,11,'ZIEL:',250);
  OutSTxt(10,150,'ENTFERNUNG:',250);OutSTxt(122,150,'KM',250);
  FOR b1:=1 TO vbd.a DO WriteVerb(b1);DrawStreets;
  Block(20,171,159,189,'OK');Block(160,171,299,189,'ABBRUCH');
  BlackPal;Show;SetPal(pal);
  REPEAT
    REPEAT UNTIL Mouse>0;
    b1:=maybe;
    IF (ms.x>158) AND (ms.x<300) THEN BEGIN
      IF ms.y>18 THEN maybe:=(ms.y-10) DIV 8 ELSE maybe:=0;
      IF maybe>vbd.a THEN maybe:=0;
    END ELSE maybe:=0;
    IF maybe<>b1 THEN BEGIN WriteVerb(b1);WriteVerb(maybe);END;
    IF (maybe<>0) AND (ms.b=1) THEN BEGIN b1:=ausw;ausw:=maybe;
      WriteVerb(b1);WriteVerb(ausw);DrawStreets;END;
    IF Click(20,171,159,189,1) THEN act:=1;
    IF Click(160,171,299,189,1) THEN act:=2;
    Show;
  UNTIL act<>0;
  IF act=1 THEN BEGIN trk.p:=0;trk.s:=vbd.s[ausw];trk.d:=vbd.r[ausw];trk.dis:=vbd.e[ausw];END;
  IF act=2 THEN BEGIN act:=0;City;END;
END;
BEGIN
  MOVE(pal,palbf,768);
  FOR b1:=1 TO 10 DO IF vertr^[b1].db AND 128=128 THEN BEGIN
    IF vertr^[b1].s=ctf THEN VSource(b1) ELSE
     IF vertr^[b1].t=ctf THEN VDest(b1);END;
  IF ctf<21 THEN BEGIN xp:=mapx^.tx[ctf];yp:=mapx^.ty[ctf];END
   ELSE BEGIN xp:=mapx^.fx[ctf-20];yp:=mapx^.fy[ctf-20];END;
  xp:=(xp-160) DIV 4*4;yp:=(yp-100) DIV 4*4;
  IF xp<0 THEN xp:=0 ELSE IF xp>640 THEN xp:=640;
  IF yp<0 THEN yp:=0 ELSE IF yp>800 THEN yp:=800;
  ms.n:=0;City;
  REPEAT REPEAT UNTIL Mouse>0;act:=0;
    FOR b1:=0 TO 3 DO MOVE(page[1]^[b1*16000+15201],page[0]^[b1*16000+15201],560);
    FOR b1:=0 TO 3 DO IF Klik(klkf[b1].x,klkf[b1].y,1,klkt[b1]) THEN act:=b1+1;
    IF act=2 THEN BEGIN Haendler;City;END;
    IF act=3 THEN BEGIN Terminal;IF act<>16 THEN City;END;
    IF act=4 THEN BEGIN Angebote;City;END;
    IF active AND 16=16 THEN BEGIN
      IF Click(90,162,229,170,1) THEN BEGIN act:=16;ctf:=130;END;
      IF Click(90,171,229,179,1) THEN BEGIN act:=16;ctf:=129;END;END;
    IF (ms.f AND 1=1) AND (ms.b AND 2=2) THEN BEGIN
      active:=active XOR 16;DrawMenu;END;
    IF act=1 THEN VerbWahl;
    IF geld>=rspreis THEN act:=16;
    Show;
  UNTIL (act=1) OR (act=16);
  FOR b1:=1 TO 10 DO IF vertr^[b1].db AND 128=128 THEN BEGIN
    IF vertr^[b1].s=ctf THEN VSource(b1) ELSE
     IF vertr^[b1].t=ctf THEN VDest(b1);END;
  IF act=1 THEN active:=active OR 1 ELSE active:=active AND NOT 1;
  IF ctf<>128 THEN BEGIN DrawMap(0);BlackPal;Show;
    MOVE(palbf,pal,768);SetPal(pal);time:=0;trk.pos:=0;END;
END;
PROCEDURE PoV;
VAR x1,y1,x2,y2,xz,yz,ox,wx:INTEGER;xe:BYTE;pln,cnt:WORD;m:SINGLE;
BEGIN
  CASE trk.d OF 1:BEGIN x1:=road^.p2[trk.s];x2:=road^.p1[trk.s];END;
    2:BEGIN x1:=road^.p1[trk.s];x2:=road^.p2[trk.s];END;END;
  IF x1<21 THEN BEGIN y1:=mapx^.ty[x1];x1:=mapx^.tx[x1];END
   ELSE BEGIN y1:=mapx^.fy[x1-20];x1:=mapx^.fx[x1-20];END;
  IF x2<21 THEN BEGIN y2:=mapx^.ty[x2];x2:=mapx^.tx[x2];END
   ELSE BEGIN y2:=mapx^.fy[x2-20];x2:=mapx^.fx[x2-20];END;
  x1:=x1-xp;x2:=x2-xp;y1:=y1-yp;y2:=y2-yp;xz:=x2-x1;yz:=y2-y1;cnt:=0;ox:=20000;
  IF ABS(xz)<ABS(yz) THEN BEGIN
    m:=xz/yz;
    IF y1<y2 THEN
     FOR yz:=y1 TO y2 DO BEGIN INC(cnt);IF (yz>=0) AND (yz<200) THEN BEGIN
        xz:=ROUND(m*(yz-y1))+x1;xe:=xz DIV 4;pln:=(xz-INTEGER(xe)*4)*16000+1;
        IF (xz>=0) AND (xz<320) AND (cnt=trk.pos) THEN page[0]^[xe+pln+yz*80]:=249;
    END;END ELSE
     FOR yz:=y1 DOWNTO y2 DO BEGIN INC(cnt);IF (yz>=0) AND (yz<200) THEN BEGIN
        xz:=ROUND(m*(yz-y1))+x1;xe:=xz DIV 4;pln:=(xz-INTEGER(xe)*4)*16000+1;
        IF (xz>=0) AND (xz<320) AND (cnt=trk.pos) THEN page[0]^[xe+pln+yz*80]:=249;
    END;END;
  END ELSE BEGIN
    m:=yz/xz;
    IF x1<x2 THEN
     FOR xz:=x1 TO x2 DO BEGIN INC(cnt);IF (xz>=0) AND (xz<320) THEN BEGIN
        xe:=xz DIV 4;pln:=(xz-INTEGER(xe)*4)*16000+1;yz:=ROUND(m*(xz-x1))+y1;
        IF (yz>=0) AND (yz<200) AND (cnt=trk.pos) THEN page[0]^[xe+pln+yz*80]:=249;
    END;END ELSE
      FOR xz:=x1 DOWNTO x2 DO BEGIN INC(cnt);IF (xz>=0) AND (xz<320) THEN BEGIN
        xe:=xz DIV 4;pln:=(xz-INTEGER(xe)*4)*16000+1;yz:=ROUND(m*(xz-x1))+y1;
        IF (yz>=0) AND (yz<200) AND (cnt=trk.pos) THEN page[0]^[xe+pln+yz*80]:=249;
    END;END;
 END;
END;
BEGIN
  b3:=0;rspreis:=10000;NEW(news);
  ASSIGN(ntf,'NEWS.TXL');RESET(ntf);ncount:=0;RANDOMIZE;
  WHILE NOT EOF(ntf) AND (ncount<65535) DO BEGIN READLN(ntf,news^[1]);INC(ncount);END;
  NEW(map);FILLCHAR(news^,SIZEOF(nachrichten),0);
  active:=0;FILLCHAR(pal[0,0],735,0);
  FOR b1:=0 TO 63 DO pal[b1+128,1]:=b1;
  FOR b1:=0 TO 32 DO pal[b1+128,0]:=24-b1 DIV 2;
  pal[192,0]:=63;pal[193,1]:=63;pal[194,2]:=63;
  FOR b1:=0 TO 15 DO FILLCHAR(pal[b1+195,0],3,b1*2+33);
  BlackPal;xp:=320;yp:=400;DrawMap(0);Show;SetPal(pal);
  IF stime.gt=255 THEN BEGIN stime.gt:=0;stime.ev:=RANDOM(90);END;
  IF trk.p=255 THEN BEGIN FILLCHAR(trk,SIZEOF(vehicle),0);geld:=5000;
    FOR b1:=1 TO mapx^.tc DO IF mapx^.tt[b1] AND 2=2 THEN BEGIN trk.m:=40;trk.f:=40;
      trk.p:=b1;trk.d:=0;trk.pos:=0;END;END;
  REPEAT INC(time2,time);time:=0;
    IF (time2>49) AND (active AND 1=1) THEN BEGIN INC(stime.ev,time2 DIV 50);time2:=0;
      IF trk.p<>0 THEN geld:=geld-2;
      IF stime.ev DIV 20=stime.ev/20 THEN BEGIN RESET(ntf);
        FOR b1:=3 DOWNTO 1 DO news^[b1+1]:=news^[b1];
        REPEAT l1:=RANDOM(ncount)+1;FOR l1:=1 TO l1 DO READLN(ntf,news^[1]);
        UNTIL (news^[1,1]<>'#') AND (news^[1]<>'');b1:=POS('~',news^[1]);
        IF b1<>0 THEN news^[1]:=COPY(news^[1],1,b1-1)
         +mapx^.tn[RANDOM(mapx^.tc)+1]+COPY(news^[1],b1+1,LENGTH(news^[1])-b1);
      END;
      IF stime.ev DIV 7=stime.ev/7 THEN FOR b1:=1 TO mapx^.tc DO
       FOR l1:=0 TO 25 DO mapx^.pr[b1,l1]:=mapx^.pr[b1,l1]*(RANDOM(110)/1000+0.95);
      IF stime.ev>99 THEN BEGIN INC(stime.gt,stime.ev DIV 100);
        DEC(stime.ev,stime.ev DIV 100*100);END;
      IF active AND 2=2 THEN DrawMap(5);
    END ELSE IF active AND 1=0 THEN BEGIN time2:=0;time:=0;END;
    IF (RANDOM(600)=RANDOM(400)+100) AND (active AND 1=1) THEN BEGIN
      b1:=RANDOM(10)+1;IF vertr^[b1].db AND 128=0 THEN BEGIN
        CASE RANDOM(10) OF 0..2:vertr^[b1].s:=0;
          3..5:vertr^[b1].s:=RANDOM(mapx^.tc)+1;
          6..8:vertr^[b1].s:=RANDOM(mapx^.fc)+21;
          9:BEGIN vertr^[b1].s:=128;vertr^[b1].t:=0;vertr^[b1].co:=RANDOM(10)+1;
            vertr^[b1].pr:=vertr^[b1].co*(RANDOM(201)+400);END;
        END;
        l1:=0;
        REPEAT
          IF vertr^[b1].s<>128 THEN BEGIN
            IF vertr^[b1].s<>0 THEN BEGIN Waren(vertr^[b1].s);
              REPEAT vertr^[b1].db:=RANDOM(26);
              UNTIL ware[1] AND TRUNC(EXP(vertr^[b1].db*LN(2)))>0;
            END;
            vertr^[b1].t:=RANDOM(mapx^.tc)+1;
            IF vertr^[b1].s=0 THEN BEGIN Waren(vertr^[b1].t);
              REPEAT vertr^[b1].db:=RANDOM(26);
              UNTIL ware[2] AND TRUNC(EXP(vertr^[b1].db*LN(2)))>0;
            END ELSE Waren(vertr^[b1].t);
            IF ware[2] AND TRUNC(EXP(vertr^[b1].db*LN(2)))>0 THEN BEGIN
              l1:=1;vertr^[b1].co:=RANDOM(96)+5;
              vertr^[b1].pr:=RANDOM(200)+ROUND((GetPrice[vertr^[b1].db]+
               RANDOM(ROUND(GetPrice[vertr^[b1].db]*20))/10)*vertr^[b1].co);
            END;
          END ELSE FOR zb:=1 TO mapx^.fc DO IF (mapx^.ft[zb]=9) AND
           (RANDOM(4)=2) THEN BEGIN INC(vertr^[b1].s,zb);l1:=1;END;
        UNTIL l1=1;
        vertr^[b1].gd:=stime.gt+RANDOM(2);
        vertr^[b1].ev:=stime.ev+RANDOM(95)+5;
        IF vertr^[b1].ev>99 THEN BEGIN INC(vertr^[b1].gd);DEC(vertr^[b1].ev,100);END;
      END;
    END;
    Keys;
    IF (Mouse AND 1=1) AND (ms.b AND 2=2) THEN BEGIN
      active:=active XOR 2;DrawMap(5);END;
    ctf:=0;
    IF active AND 2=2 THEN BEGIN
      IF Click(90,116,229,124,1) THEN BEGIN
        IF active AND 4=0 THEN BEGIN active:=active OR 4;ctf:=trk.p;END;
        active:=active XOR 1;DrawMap(5);END;
      IF Click(90,152,229,160,1) THEN ctf:=130;
      IF Click(90,143,229,151,1) THEN BEGIN active:=active XOR 8;DrawMap(5);END;
      IF (trk.p<>0) AND (active AND 4=4) AND Click(90,125,229,133,1) THEN ctf:=trk.p;
    END;
    IF trk.p=0 THEN BEGIN DrawMap(5);PoV;
      IF trk.pos>=trk.dis THEN BEGIN
        CASE trk.d OF 1:trk.p:=road^.p1[trk.s];2:trk.p:=road^.p2[trk.s];END;
        geld:=geld-trk.dis DIV 5-5;ctf:=trk.p;
      END;
    END;
    IF (ctf<>0) AND (ctf<128) AND (trk.p<>0) THEN GoCity;
    IF (ms.x=0) AND (xp>3) THEN BEGIN DEC(xp,4);DrawMap(1);END;
    IF (ms.y=0) AND (yp>3) THEN BEGIN DEC(yp,4);DrawMap(3);END;
    IF (ms.x=319) AND (xp<637) THEN BEGIN INC(xp,4);DrawMap(2);END;
    IF (ms.y=199) AND (yp<797) THEN BEGIN INC(yp,4);DrawMap(4);END;
    IF geld>=rspreis THEN BEGIN Box(10,70,309,129,0);Box(11,71,308,128,254);
      FBox(12,72,307,127,253);STR(geld:0:2,st);p2k;
      OutBTxt(68-LENGTH(st)*4,80,'SIE BESITZEN JETZT '+st+' P$,',255);
      OutBTxt(40,90,'GENUG GELD FöR EIN RAUMSCHIFF.',255);
      Block(13,108,159,126,'WEITERSPIELEN');
      Block(160,108,306,126,'RAUMSCHIFF KAUFEN');Show;
      REPEAT REPEAT UNTIL Mouse>0;b1:=0;
        IF Click(13,108,159,126,1) THEN b1:=1;
        IF Click(160,108,306,126,1) THEN b1:=2;
        Show;
      UNTIL b1<>0;b3:=255;rspreis:=2147483647;
      CASE b1 OF 1:DrawMap(0);2:ctf:=128;END;
    END;
    IF (stime.gt>=timeout) AND (RANDOM(500)=RANDOM(400)) AND (active AND 1=1) THEN BEGIN
      Box(10,70,309,129,0);Box(11,71,308,128,254);FBox(12,72,307,127,253);
      OutBTxt(72,80,'IHRE KREDITGEBER HABEN',255);
      OutBTxt(64,90,'SIE AUSFINDIG GEMACHT...',255);
      Block(13,108,306,126,'SPIEL BEENDEN');Show;
      REPEAT REPEAT UNTIL Mouse>0;Show;UNTIL Click(13,108,306,126,1);
      ctf:=128;b3:=254;rspreis:=0;
    END;
    IF (active AND 2=2) AND Click(90,161,229,169,1) THEN ctf:=129;
    IF ctf=129 THEN BEGIN
      Box(60,70,259,129,0);Box(61,71,258,128,254);FBox(62,72,257,127,253);
      OutBTxt(80,80,'WOLLEN SIE DAS SPIEL',255);
      OutBTxt(92,90,'WIRKLICH BEENDEN?',255);
      Block(63,108,159,126,'OK');
      Block(160,108,256,126,'ABBRUCH');Show;
      REPEAT REPEAT UNTIL Mouse>0;b1:=0;
        IF Click(63,108,159,126,1) THEN b1:=1;
        IF Click(160,108,256,126,1) THEN b1:=2;
        Show;
      UNTIL b1<>0;
      IF b1=2 THEN BEGIN ctf:=0;DrawMap(5);END;
    END;
    IF ctf=130 THEN BEGIN
      IF active AND 4=0 THEN DiskOp(0) ELSE DiskOp(3);
      DrawMap(0);ctf:=0;
    END;
    Show;
  UNTIL (ctf=128) OR (ctf=129);
  DISPOSE(map);map:=NIL;CLOSE(ntf);
  DISPOSE(news);news:=NIL;
END;
PROCEDURE MakeMap;
VAR panz,xm,ym,hoh,rad,bt,am,mp,mr:BYTE;xp,yp,bb:WORD;lo0:LONGINT;
    txt:TEXT;st:STRING;
PROCEDURE DrawC;
VAR ax,ay:WORD;cp:SINGLE;wert:INTEGER;
BEGIN
  cp:=0;
  IF bt=0 THEN wert:=128-INTEGER(ROUND(hoh*(1-rad/mr)))
   ELSE wert:=INTEGER(ROUND(hoh*(1-rad/mr)))+128;
  REPEAT ax:=160+ROUND(sin(cp)*rad);ay:=100-ROUND(cos(cp)*rad);
    IF (ax>=0) AND (ax<320) AND (ay>=0) AND (ay<200) THEN buff^[ax+ay*320+1]:=wert;
    cp:=cp+1/rad;
  UNTIL cp>=2*Pi;
END;
PROCEDURE FillC;
VAR ax,ay,pix:WORD;w1,w2,w3,w4:BYTE;
BEGIN
  FOR ax:=160-rad TO 160+rad DO FOR ay:=100-rad TO 100+rad DO BEGIN
    pix:=ax+ay*320+1;
    w1:=buff^[pix-1];w2:=buff^[pix+1];w3:=buff^[pix-320];w4:=buff^[pix+320];
    IF (buff^[pix]=0) AND (w1<>0) AND (w2<>0) AND (w3<>0) AND (w4<>0) THEN
     buff^[pix]:=WORD(w1+w2+w3+w4) DIV 4;
  END;
END;
PROCEDURE CopyC;
VAR ax,ay,ox,oy,wert:INTEGER;pix,pix2:WORD;
BEGIN
  FOR ax:=160-rad TO 160+rad DO BEGIN ox:=ax+xp-160;
    IF (ox>=0) AND (ox<960) THEN FOR ay:=100-rad TO 100+rad DO BEGIN
      oy:=ay+yp-100;pix2:=ax+ay*320+1;
      IF (oy>=0) AND (oy<1000) AND (buff^[pix2]>0) THEN BEGIN
        xm:=ox DIV 320;ym:=oy DIV 200;
        IF (xm+ym*3+1<>am) AND (am>0) THEN RAM_2_EMS(map,ems[am],64000);
        IF xm+ym*3+1<>am THEN BEGIN am:=xm+ym*3+1;EMS_2_RAM(map,ems[am],64000);END;
        pix:=(ox-xm*320)+(oy-ym*200)*320+1;
        wert:=map^[pix]+INTEGER(buff^[pix2]-128);
        IF wert<0 THEN map^[pix]:=0 ELSE IF wert>255 THEN map^[pix]:=255
         ELSE map^[pix]:=wert;
      END;
    END;
  END;
  RAM_2_EMS(map,ems[am],64000);
END;
BEGIN
  NEW(map);NEW(buff);
  MOVE(page[1]^,page[0]^,64000);
  Block(180,61,198,79,'¸');
  Block(261,61,279,79,'˝');
  Block(180,81,198,99,'¸');
  Block(261,81,279,99,'˝');
  Block(180,101,198,119,'¸');
  Block(261,101,279,119,'˝');
  Block(40,141,159,159,'OK');
  Block(160,141,279,159,'ABBRUCH');
  OutBTxt(40,68,'Berge / TÑler:',216);
  OutBTxt(40,88,'StÑdte:',216);
  OutBTxt(40,108,'Fabriken / Werke:',216);
  MOVE(page[0]^,map^,64000);
  mp:=0;mapx^.tc:=0;mapx^.fc:=0;stime.gt:=255;
  trk.p:=255;FILLCHAR(trk.c,26,0);
  REPEAT
    MOVE(map^,page[0]^,64000);
    IF mp=0 THEN st:='ZUFALL' ELSE STR(mp,st);
    OutBTxt(230-LENGTH(st)*4,68,st,216);
    IF mapx^.tc=0 THEN st:='ZUFALL' ELSE STR(mapx^.tc,st);
    OutBTxt(230-LENGTH(st)*4,88,st,216);
    IF mapx^.fc=0 THEN st:='ZUFALL' ELSE STR(mapx^.fc,st);
    OutBTxt(230-LENGTH(st)*4,108,st,216);
    Show;
    REPEAT UNTIL Mouse>0;b3:=0;
    IF Click(180,61,198,79,1) AND (mp<250) THEN INC(mp,10);
    IF Click(261,61,279,79,1) AND (mp>0) THEN DEC(mp,10);
    IF Click(180,81,198,99,1) AND (mapx^.tc<20) THEN INC(mapx^.tc,2);
    IF Click(261,81,279,99,1) AND (mapx^.tc>0) THEN DEC(mapx^.tc,2);
    IF Click(180,101,198,119,1) AND (mapx^.fc<20) THEN INC(mapx^.fc,2);
    IF Click(261,101,279,119,1) AND (mapx^.fc>0) THEN DEC(mapx^.fc,2);
    IF Click(40,141,159,159,1) THEN b3:=1;
    IF Click(160,141,279,159,1) THEN b3:=2;
  UNTIL b3<>0;
  IF b3=2 THEN BEGIN DISPOSE(map);map:=NIL;DISPOSE(buff);buff:=NIL;b3:=255;EXIT;END;
  MOVE(page[1]^,page[0]^,64000);
  OutText(95,82,'GENERIERE KARTE...',200,0,1);
  MOVE(page[0]^,page[1]^,64000);
  ms.on:=FALSE;
  Show;
  FILLCHAR(map^,64000,128);
  FOR xp:=1 TO 15 DO RAM_2_EMS(map,ems[xp],64000);
  IF mp=0 THEN mp:=RANDOM(45)+30;am:=0;
  FOR panz:=1 TO mp DO BEGIN
    xp:=RANDOM(960);
    yp:=RANDOM(1000);
    bt:=RANDOM(2);
    hoh:=RANDOM(54)+10;
    mr:=TRUNC(RANDOM(hoh-10)/0.9)+40;
    FILLCHAR(buff^,64000,0);
    FOR rad:=1 TO mr DO DrawC;
    FillC;CopyC;
    STR(ROUND(panz/mp*70),st);
    MOVE(page[1]^,page[0]^,64000);
    OutBTxt(156-LENGTH(st)*4,110,st+'%',215);
    Show;
  END;
  FOR xm:=0 TO 2 DO FOR ym:=0 TO 4 DO BEGIN
    EMS_2_RAM(map,ems[ym*3+xm+1],64000);
    STR(ym+xm*5+71,st);
    MOVE(page[1]^,page[0]^,64000);
    OutBTxt(156-LENGTH(st)*4,110,st+'%',215);
    Show;
    FOR xp:=0 TO 159 DO FOR yp:=0 TO 99 DO BEGIN
      hoh:=map^[yp*640+xp*2+1];rad:=map^[yp*640+xp*2+2];
      bt:=map^[yp*640+xp*2+321];mr:=map^[yp*640+xp*2+322];
      map^[yp*640+xp*2+1]:=(hoh*3+rad+bt+mr) DIV 6;
      map^[yp*640+xp*2+2]:=(rad*3+hoh+bt+mr) DIV 6;
      map^[yp*640+xp*2+321]:=(bt*3+rad+hoh+mr) DIV 6;
      map^[yp*640+xp*2+322]:=(mr*3+rad+bt+hoh) DIV 6;
    END;
    RAM_2_EMS(map,ems[ym*3+xm+1],64000);
  END;
  RandSeed:=1234567890;
  FOR xm:=0 TO 2 DO FOR ym:=0 TO 4 DO BEGIN
    EMS_2_RAM(map,ems[ym*3+xm+1],64000);
    STR(ym+xm*5+86,st);
    MOVE(page[1]^,page[0]^,64000);
    OutBTxt(156-LENGTH(st)*4,110,st+'%',215);
    Show;
    FOR xp:=0 TO 319 DO FOR yp:=0 TO 199 DO BEGIN
      hoh:=RANDOM(4);
      CASE RANDOM(2) OF 1:IF map^[yp*320+xp+1]<255-hoh THEN INC(map^[yp*320+xp+1],hoh);
        0:IF map^[yp*320+xp+1]>hoh THEN DEC(map^[yp*320+xp+1],hoh);END;
    END;
    RAM_2_EMS(map,ems[ym*3+xm+1],64000);
  END;
  Randomize;
  MOVE(page[1]^,page[0]^,64000);
  OutBTxt(136,110,'STéDTE',215);Show;
  IF mapx^.tc=0 THEN mapx^.tc:=RANDOM(16)+5;
  bb:=0;
  FOR panz:=1 TO mapx^.tc DO REPEAT
    mapx^.tx[panz]:=RANDOM(960);mapx^.ty[panz]:=RANDOM(1000);
    mapx^.ti[panz]:=RANDOM(59800)+200;mapx^.tt[panz]:=RANDOM(256);
    mapx^.tt[panz]:=mapx^.tt[panz] AND NOT 3;
    IF (RANDOM(4)=1) AND (bb<mapx^.tc DIV 5+1) THEN
     BEGIN INC(mapx^.tt[panz]);INC(bb);END;
    FOR b3:=0 TO 25 DO mapx^.pr[panz,b3]:=
     GetPrice[b3]+(SHORTINT(RANDOM(2)*2)-1)*RANDOM(ROUND(GetPrice[b3]))/10
     +RANDOM(ROUND(GetPrice[b3]))/23;
    xm:=mapx^.tx[panz] DIV 320;ym:=mapx^.ty[panz] DIV 200;
    xp:=mapx^.tx[panz]-xm*320;yp:=mapx^.ty[panz]-ym*200;
    EMS_2_RAM(map,ems[ym*3+xm+1],64000);
  UNTIL (map^[xp+yp*320+1]>63) AND (map^[xp+yp*320+1]<193);
  ASSIGN(txt,'NAMES.TXL');RESET(txt);
  xp:=0;FILLCHAR(buff^,64000,0);
  IF IORESULT=0 THEN WHILE NOT EOF(txt) AND (xp<30000) DO BEGIN
    READLN(txt,st);
    IF st='.' THEN INC(xp) ELSE
     IF (st[1]<>'#') AND (st[1]<>'~') THEN INC(buff^[xp*2+1]) ELSE
     IF st[1]='~' THEN INC(buff^[xp*2+2]);
  END ELSE BEGIN xp:=0;yp:=0;END;
  FOR panz:=1 TO mapx^.tc DO REPEAT mapx^.tn[panz]:='';ym:=0;
    IF xp<>0 THEN BEGIN RESET(txt);
      FOR yp:=1 TO RANDOM(xp)+1 DO REPEAT READLN(txt,st);UNTIL st='.';
      FOR xm:=1 TO RANDOM(buff^[yp*2+1])+1 DO
       REPEAT READLN(txt,st);UNTIL (st[1]<>'~') AND (st[1]<>'#');
      mapx^.tn[panz]:=st;
      IF st[LENGTH(st)]='~' THEN BEGIN RESET(txt);
        FOR yp:=1 TO yp DO REPEAT READLN(txt,st);UNTIL st='.';
        FOR xm:=1 TO RANDOM(buff^[yp*2+2])+1 DO
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
  IF mapx^.fc=0 THEN mapx^.fc:=RANDOM(16)+5;
  MOVE(page[1]^,page[0]^,64000);
  bb:=0;
  FOR panz:=1 TO mapx^.fc DO BEGIN
    REPEAT
      MOVE(page[1]^,page[0]^,64000);
      OutBTxt(80,110,'FABRIKEN / BERGWERKE',215);
      STR(ROUND(panz/mapx^.fc*100),st);
      OutBTxt(156-LENGTH(st)*4,120,st+'%',215);Show;
      mapx^.fx[panz]:=RANDOM(960);mapx^.fy[panz]:=RANDOM(1000);
      xm:=mapx^.fx[panz] DIV 320;ym:=mapx^.fy[panz] DIV 200;
      xp:=mapx^.fx[panz]-xm*320;yp:=mapx^.fy[panz]-ym*200;
      EMS_2_RAM(map,ems[ym*3+xm+1],64000);xm:=1;
      IF map^[xp+yp*320+1]<111 THEN mapx^.ft[panz]:=RANDOM(3) ELSE
      IF map^[xp+yp*320+1]>143 THEN mapx^.ft[panz]:=RANDOM(5)+2
       ELSE BEGIN mapx^.ft[panz]:=RANDOM(6)+5;xm:=RANDOM(500 DIV mp);END;
    UNTIL (xm=1) AND (bb AND TRUNC(EXP(mapx^.ft[panz]*LN(2)))=0);
    INC(bb,TRUNC(EXP(mapx^.ft[panz]*LN(2))));
    IF bb=2047 THEN bb:=0;
  END;
  MOVE(page[1]^,page[0]^,64000);
  OutBTxt(128,110,'STRASSEN',215);Show;
  road^.sc:=mapx^.tc+mapx^.fc;
  FOR panz:=1 TO mapx^.tc DO BEGIN yp:=0;
    REPEAT b3:=0;xp:=2500;
      road^.p1[panz]:=panz;
      FOR xm:=1 TO mapx^.tc DO IF xm<>panz THEN BEGIN
        lo0:=Entfernung(mapx^.tx[xm],mapx^.ty[xm],mapx^.tx[panz],mapx^.ty[panz]);
        IF (lo0>yp) AND (lo0<xp) THEN BEGIN road^.p2[panz]:=xm;xp:=lo0;END;
      END;
      FOR xm:=1 TO mapx^.fc DO BEGIN
        lo0:=Entfernung(mapx^.fx[xm],mapx^.fy[xm],mapx^.tx[panz],mapx^.ty[panz]);
        IF (lo0>yp) AND (lo0<xp) THEN BEGIN road^.p2[panz]:=xm+20;xp:=lo0;END;
      END;
      FOR xm:=1 TO panz-1 DO IF panz<>xm THEN
       IF ((road^.p1[panz]=road^.p1[xm]) AND (road^.p2[panz]=road^.p2[xm]))
       OR ((road^.p1[panz]=road^.p2[xm]) AND (road^.p2[panz]=road^.p1[xm]))
       THEN BEGIN b3:=1;yp:=xp;END;
    UNTIL (road^.p1[panz]<>road^.p2[panz]) AND (b3=0);
  END;
  FOR panz:=1 TO mapx^.fc DO BEGIN yp:=0;
    REPEAT b3:=0;xp:=2500;
      road^.p1[panz+mapx^.tc]:=panz+20;
      FOR xm:=1 TO mapx^.tc DO BEGIN
        lo0:=Entfernung(mapx^.tx[xm],mapx^.ty[xm],mapx^.fx[panz],mapx^.fy[panz]);
        IF (lo0>yp) AND (lo0<xp) THEN BEGIN road^.p2[panz+mapx^.tc]:=xm;xp:=lo0;END;
      END;
      FOR xm:=1 TO mapx^.fc DO IF panz<>xm THEN BEGIN
        lo0:=Entfernung(mapx^.fx[xm],mapx^.fy[xm],mapx^.fx[panz],mapx^.fy[panz]);
        IF (lo0>yp) AND (lo0<xp) THEN BEGIN road^.p2[panz+mapx^.tc]:=xm+20;xp:=lo0;END;
      END;
      FOR xm:=1 TO panz+mapx^.tc-1 DO IF panz+mapx^.tc<>xm THEN
       IF ((road^.p1[panz+mapx^.tc]=road^.p1[xm]) AND (road^.p2[panz+mapx^.tc]=road^.p2[xm]))
       OR ((road^.p1[panz+mapx^.tc]=road^.p2[xm]) AND (road^.p2[panz+mapx^.tc]=road^.p1[xm]))
       THEN BEGIN b3:=1;yp:=xp;END;
    UNTIL (road^.p1[panz+mapx^.tc]<>road^.p2[panz+mapx^.tc]) AND (b3=0);
  END;
  FILLCHAR(map^,mapx^.tc,0);
  FOR panz:=1 TO road^.sc DO
   FOR ym:=1 TO 2 DO BEGIN IF ym=1 THEN xm:=road^.p1[panz] ELSE xm:=road^.p2[panz];
    IF xm<21 THEN INC(map^[xm]);END;
  ym:=0;
  FOR panz:=1 TO mapx^.tc DO IF map^[panz]>ym THEN BEGIN xm:=panz;ym:=map^[xm];END;
  INC(mapx^.tt[xm],2);mapx^.tt[xm]:=mapx^.tt[xm] OR 1;
  FILLCHAR(vertr^,SIZEOF(contract),0);
  ms.on:=TRUE;DISPOSE(map);map:=NIL;DISPOSE(buff);buff:=NIL;
END;
PROCEDURE MainMenu;
BEGIN
  Block(80,61,239,79,'NEUES SPIEL');
  Block(80,81,239,99,'SPIELSTAND LADEN');
  Block(80,101,239,119,'INTRO WIEDERHOLEN');
  Block(80,121,239,139,'SPIEL BEENDEN');
END;
FUNCTION NewGame:BYTE;
BEGIN
  MOVE(page[1]^,page[0]^,64000);
  Block(80,61,239,79,'KARTE ERSTELLEN');
  Block(80,81,239,99,'KARTE LADEN');
  Block(80,121,239,139,'HAUPTMENö');
  Show;
  REPEAT REPEAT UNTIL Mouse>0;b3:=0;
    FOR b1:=0 TO 3 DO IF b1<>2 THEN
     IF Click(80,61+b1*20,239,79+b1*20,1) THEN b3:=b1+1;
    Show;
  UNTIL b3<>0;
  MOVE(page[1]^,page[0]^,64000);
  MainMenu;
  NewGame:=b3;
END;
PROCEDURE MainScreen;
BEGIN
  Show;
  LoadVPic(0,0,pf,'MainScreen',pal);
  MOVE(page[0]^,page[1]^,64000);
  MainMenu;
  FOR b1:=0 TO 4 DO FILLCHAR(pal[b1+251,0],3,b1*6+24);
  pal[249,2]:=31;pal[250,2]:=63;
  FOR b1:=0 TO 15 DO BEGIN FILLCHAR(pal[b1+200,0],2,b1 DIV 2+16);pal[b1+200,2]:=b1+38;END;
  FILLCHAR(pal[216,0],2,48);pal[216,2]:=63;
  ms.on:=TRUE;BlackPal;Show;SetPal(pal);
END;

BEGIN
  mem:=MEMAVAIL;
  TextMode;
  OutPut(0,0,prg_info,7);
  l1:=0;FOR b1:=1 TO 111 DO INC(l1,ORD(prg_info[b1]));
  IF l1<>8782 THEN BEGIN
    OutPut(0,5,'Code modified, program haltet (255).',7);
    GotoXY(0,7);HALT(255);END;
  IF NOT _VGA THEN BEGIN
    OutPut(0,5,'ERROR 001: VGA-Card not found.',7);GotoXY(0,7);HALT(1);END;
  IF MEMAVAIL<250000 THEN BEGIN
    OutPut(0,5,'ERROR 002: Too few memory.',7);GotoXY(0,7);HALT(2);END;
  GETINTVEC($1C,ecpnt);
  GETINTVEC($5,oldprnt);
  GETINTVEC($9,@TasInt);
  oldexitproc:=EXITPROC;
  pages:=0;exist_SB:=FALSE;
  EXITPROC:=@ExitProcedure;
  Init_System;
  NEW(mapx);NEW(road);NEW(cache);NEW(vertr);
  FILLCHAR(cache^,SIZEOF(cache_def),0);
  RANDOMIZE;
  FILLCHAR(page[0]^,64000,0);Show;Pal0;
  Intro;MouseReset;ms.x:=160;ms.y:=80;ms.c[1]:=251;ms.c[2]:=255;ms.n:=0;
  MainScreen;
  REPEAT REPEAT UNTIL Mouse>0;b3:=0;
    FOR b1:=0 TO 3 DO
     IF Click(80,61+b1*20,239,79+b1*20,1) THEN b3:=b1+1;
    CASE b3 OF
      1:BEGIN b2:=NewGame;CASE b2 OF 1:MakeMap;2:DiskOp(1);END;
        IF (b2<3) AND (b3<>255) THEN PlayGame ELSE b3:=0;
        IF rspreis=2147483647 THEN Extro ELSE IF rspreis=0 THEN Outro;
        IF b2<3 THEN MainScreen;b3:=0;END;
      2:BEGIN DiskOp(2);MainScreen;END;
      3:BEGIN ms.on:=FALSE;Intro;MainScreen;ms.on:=TRUE;END;
    END;
    Show;
  UNTIL b3=4;
END.