{$O+,F+,G+,S-,I-}
UNIT SUB_DISK;
INTERFACE USES DOS,VESA,VARS,SUB_DRAW,SUB_CTRL,EFFECTS,SUB_TEXT,CRTN,XMS_UNIT,SUB_MAP;
PROCEDURE SavePicture;
FUNCTION MainMenu:BYTE;
PROCEDURE Highscores(edit:BOOLEAN);
PROCEDURE Einstellungen;
FUNCTION DiskOp(op:BYTE):BOOLEAN;
IMPLEMENTATION
PROCEDURE SavePicture;
VAR tempbuf:ARRAY[0..1077]OF BYTE;
    bmpf:FILE;
    xz,yz:WORD;
    sr:SEARCHREC;
    st0:STRING[4];
BEGIN
  IF DISKFREE(0)<(GETMAXX+1)*(GETMAXY+1)+1078 THEN EXIT;

  yz:=0;
  REPEAT
    STR(yz,st0);
    FOR xz:=1 TO 4-LENGTH(st0)DO st0:='0'+st0;
    FINDFIRST('BILD'+st0+'.BMP',$3F,sr);
    INC(yz);
  UNTIL(DOSERROR<>0)OR(yz=10000);
  IF yz=10000 THEN EXIT;

  ASSIGN(bmpf,'BILD'+st0+'.BMP');
  REWRITE(bmpf,1);
  IF IORESULT<>0 THEN EXIT;

  FILLCHAR(tempbuf,1078,0);
  tempbuf[26]:=1;          {?}
  tempbuf[47]:=1;          {?}
  tempbuf[28]:=8;          {Farbtiefe}
  tempbuf[18]:=LO(GETMAXX+1);{Grî·e x}
  tempbuf[19]:=HI(GETMAXX+1);
  tempbuf[22]:=LO(GETMAXY+1);{Grî·e y}
  tempbuf[23]:=HI(GETMAXY+1);
  tempbuf[10]:=LO(1078);   {Headergrî·e + Palettengrî·e}
  tempbuf[11]:=HI(1078);
  tempbuf[14]:=40;         {Headergrî·e ohne Kennung}
  tempbuf[0]:=66;          {"B"}
  tempbuf[1]:=77;          {"M"}
  tempbuf[2]:=54;          {Headergrî·e}
  tempbuf[3]:=180;         {?}

  FOR xz:=0 TO 255 DO FOR yz:=0 TO 2 DO BEGIN
    tempbuf[WORD(xz)*4+54]:=pal[xz,2]*4;
    tempbuf[WORD(xz)*4+55]:=pal[xz,1]*4;
    tempbuf[WORD(xz)*4+56]:=pal[xz,0]*4;
  END;

  BLOCKWRITE(bmpf,tempbuf,1078);

  FOR yz:=GETMAXY DOWNTO 0 DO BEGIN
    GETIMAGE(0,yz,GETMAXX+1,yz,tempbuf);
    BLOCKWRITE(bmpf,tempbuf[4],GETMAXX+1);
  END;

  CLOSE(bmpf);
  savepic:=FALSE;
END;
FUNCTION MainMenu:BYTE;
VAR menutext:STRING[40];
BEGIN
  ms.arrow:=FALSE;
  GETIMAGE(220,138,419,341,page^[0]);
  FOR b1:=0 TO 4 DO BEGIN
    CASE b1 OF
      0:menutext:='SZENE ERSTELLEN';
      1:menutext:='SPIEL LADEN';
      2:BEGIN
        IF active AND 4=0 THEN menutext:='EINSTELLUNGEN'
         ELSE menutext:='SPIEL SPEICHERN';
      END;
      3:IF active AND 5>0 THEN menutext:='ZURöCK'
       ELSE IF mml_anim[3]<>'-' THEN menutext:='BESTENLISTE'
       ELSE IF cheats AND 1=0 THEN menutext:='EINLEITUNG'
       ELSE menutext:='ANIMATIONEN';
      4:menutext:='SPIEL BEENDEN';
    END;
    {CASE b1 OF
      0:menutext:='STORY';
      1:menutext:='TECHNIK';
      2:menutext:='BILDER';
      3:menutext:='TRAILER';
      4:menutext:='ZURöCK';
    END;}
    GrBar(220,138+b1*41,419,177+b1*41,menutext);
  END;
  Mouse(1);
  REPEAT Keys;
    IF(key[2]=#72)OR(key[2]=#80)THEN BEGIN
      ms.x:=320;IF ms.y<120 THEN ms.y:=120;
      ms.y:=(ms.y-138)DIV 41*41+158;
      IF ms.y>284 THEN ms.y:=284;
      IF key[2]=#72 THEN DEC(ms.y,41) ELSE INC(ms.y,41);
      IF ms.y<158 THEN ms.y:=322 ELSE IF ms.y>322 THEN ms.y:=158;
    END ELSE key[2]:=#0;
    IF key[2]=#0 THEN Mouse(3) ELSE Mouse(7);
    b2:=255;
    FOR b1:=0 TO 4 DO IF Click(220,138+b1*41,419,177+b1*41,7)THEN b2:=b1;
    IF savepic THEN SavePicture;
  UNTIL b2<>255;
  MainMenu:=b2;
  Mouse(2);
  PUTIMAGE(220,138,page^[0],0);
END;
PROCEDURE Highscores(edit:BOOLEAN);
VAR cnt:WORD;cby:BYTE;
    txt:STRING[20];txt2:STRING[2];
    highscorefile:FILE;
    bestenliste:ARRAY[0..9]OF RECORD
                                name:STRING[10];
                                zeit:startime;
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
  txt:='';
  pos:=1;
  time:=0;
  REPEAT
    SETCOLOR(238);
    BAR(234,150+cby*14,334,162+cby*14);
    OutBTxt(236,152+cby*14,txt,250);
    REPEAT Keys;
      IF(time<4)OR(key[2]<>#0)THEN SETCOLOR(238) ELSE SETCOLOR(247);
      IF time>7 THEN time:=0;
      IF(time=0)OR(time=4)OR(key[2]<>#0)THEN BEGIN
        RECTANGLE(226+pos*9,161+cby*14,234+pos*9,162+cby*14);
      END;
      CASE key[2] OF #75:IF pos>1 THEN DEC(pos);
        #77:IF pos<LENGTH(txt)+1 THEN INC(pos);
        #71:pos:=1;
        #79:pos:=LENGTH(txt)+1;
      END;
      IF key[2]<>#83 THEN key[2]:=#0;
      IF(key[1]<#32)AND(key[1]<>#8)AND(key[1]<>#27)AND(key[1]<>#13)AND(key[1]<>#1)THEN key[1]:=#0;
    UNTIL(key[1]<>#0)OR(key[2]<>#0);
    IF(key[1]>#31)AND(key[1]<#155)AND(LENGTH(txt)<10)THEN BEGIN
     txt:=COPY(txt,1,pos-1)+Gross+COPY(txt,pos,LENGTH(txt)-pos+1);INC(pos);END;
    IF(key[1]=#8)AND(pos>1)THEN BEGIN
     txt:=COPY(txt,1,pos-2)+COPY(txt,pos,LENGTH(txt)-pos+1);DEC(pos);END;
    IF(key[2]=#83)AND(pos<=LENGTH(txt))AND(LENGTH(txt)>0)THEN txt:=COPY(txt,1,pos-1)+COPY(txt,pos+1,LENGTH(txt)-pos);
  UNTIL(key[1]=#13)AND(txt<>'');
  key[1]:=#0;
  key[2]:=#0;
END;
BEGIN
  ms.arrow:=FALSE;
  GetImage(190,120,449,298,page^);
  RAM2XMS(page,xms[1],50000,251500);
  GreenBar(190,120,449,298);
  OutText(320,125,'D I E   B E S T E N   Z E H N',243,2,1.75);
  GETIMAGE(190,300,449,339,page^[48000]);
  GrBar(190,300,449,339,'ZURöCK');
  FILLCHAR(bestenliste,sizeof(bestenliste),0);
  ASSIGN(highscorefile,'HIGHSCO.RES');
  RESET(highscorefile,1);
  IF IORESULT=0 THEN BEGIN
    BLOCKREAD(highscorefile,bestenliste,sizeof(bestenliste),cnt);
    CLOSE(highscorefile);
  END;
  IF edit THEN cby:=255 ELSE cby:=254;
  FOR cnt:=0 TO 9 DO BEGIN
    IF(cby=255)AND((LONGINT(stime.gt)*100+stime.ev<
     LONGINT(bestenliste[cnt].zeit.gt)*100+bestenliste[cnt].zeit.ev)OR
     ((bestenliste[cnt].zeit.gt=0)AND(bestenliste[cnt].zeit.ev=0)))THEN BEGIN
      FOR cby:=8 DOWNTO cnt DO bestenliste[cby+1]:=bestenliste[cby];
      cby:=cnt;
      bestenliste[cby].zeit:=stime;
      bestenliste[cby].name:='';
    END;
    STR(cnt+1,txt);
    IF cnt<9 THEN txt:=' '+txt;
    txt:=txt+'. ';
    IF(bestenliste[cnt].zeit.gt<>0)OR(bestenliste[cnt].zeit.ev<>0)THEN
     txt:=txt+bestenliste[cnt].name
     ELSE txt:=txt+'-';
    OutBTxt(200,152+cnt*14,txt,248);
    IF(bestenliste[cnt].zeit.gt<>0)OR(bestenliste[cnt].zeit.ev<>0)THEN BEGIN
      STR((bestenliste[cnt].zeit.gt+4760)/100:0:2,txt);
      STR(bestenliste[cnt].zeit.ev,txt2);
      IF LENGTH(txt2)=1 THEN txt2:='0'+txt2;
      txt:=txt+':'+txt2+' ST';
    END ELSE txt:='';
    OutBTxt(440-LENGTH(txt)*9,152+cnt*14,txt,248);
  END;
  IF cby<10 THEN BEGIN
    GetImage(234,150+cby*14,334,162+cby*14,page^[0]);
    Input;
    bestenliste[cby].name:=txt;
    PutImage(234,150+cby*14,page^[0],0);
    OutBTxt(236,152+cby*14,txt,248);
  END;
  Mouse(1);
  REPEAT
    Mouse(3);
    IF savepic THEN SavePicture;
  UNTIL Click(190,300,449,339,7);
  Mouse(2);
  PutIMAGE(190,300,page^[48000],0);
  XMS2RAM(page,xms[1],50000,251500);
  PutImage(190,120,page^,0);
  REWRITE(highscorefile,1);
  IF IORESULT=0 THEN BEGIN
    BLOCKWRITE(highscorefile,bestenliste,sizeof(bestenliste),cnt);
    CLOSE(highscorefile);
    IF cnt<>sizeof(bestenliste) THEN ERASE(highscorefile);
  END;
END;
PROCEDURE Einstellungen;
VAR oldact,oldgam,olddith:BYTE;oldcfeld:WORD;st0:STRING;txf:TEXT;
BEGIN
  ms.arrow:=FALSE;
  IF(active AND 4=4)AND(active AND 1=0)THEN active:=active OR 16;
  Mouse(2);
  oldact:=active;oldgam:=gamma;olddith:=dithering;oldcfeld:=cfeld;
  ClickField(0);
  GetImage(210,120,429,298,page^[0]);
  RAM2XMS(page,xms[1],40000,251500);
  GreenBar(210,120,429,298);
  GETIMAGE(220,160,315,294,page^[0]);
  OutText(320,130,'E I N S T E L L U N G E N',243,2,1.75);
  FOR b1:=0 TO 2 DO BEGIN
    CASE b1 OF 0:st0:='HELLIGKEIT';1:st0:='QUALITéT';2:st0:='QUICKTIPS';END;
    OutText(315,170+b1*41,st0+':',241,1,1.5);
  END;
  b2:=7;
  GETIMAGE(210,300,319,339,page^[48000]);
  GrBar(210,300,319,339,ok);
  GETIMAGE(320,300,429,339,page^[56000]);
  GrBar(320,300,429,339,abbruch);
  FOR b1:=0 TO 2 DO GETIMAGE(320,160+b1*41,409,199+b1*41,page^[16000+WORD(b1)*8000]);
  REPEAT
    FOR b1:=0 TO 2 DO IF(1 SHL b1)AND b2>0 THEN BEGIN
      CASE b1 OF 0:BEGIN STR(gamma,st0);SetPal(pal);END;
        1:IF dithering=1 THEN st0:='HOCH' ELSE st0:='NIEDRIG';
        2:IF quicktips THEN st0:=an ELSE st0:=aus;
      END;
      GrBar(320,160+b1*41,409,199+b1*41,st0);
    END;
    Mouse(1);b2:=0;
    REPEAT Mouse(3);Keys;
      IF Click(320,160,409,199,1)THEN BEGIN INC(gamma);b2:=1;END ELSE
       IF Click(320,160,409,199,2)THEN BEGIN DEC(gamma);b2:=1;END;
      IF gamma=11 THEN gamma:=1 ELSE IF gamma=0 THEN gamma:=10;
      IF Click(320,201,409,240,7)THEN BEGIN dithering:=1-dithering;b2:=2;END;
      IF Click(320,242,409,281,7)THEN BEGIN quicktips:=NOT quicktips;b2:=4;END;
      IF Click(210,300,319,339,7)THEN b2:=127 ELSE
       IF Click(320,300,429,339,7)THEN b2:=255;
      IF savepic THEN SavePicture;
    UNTIL b2>0;
    Mouse(2);
    FOR b1:=0 TO 2 DO IF(1 SHL b1)AND b2>0 THEN
     PUTIMAGE(320,160+b1*41,page^[16000+WORD(b1)*8000],0);
  UNTIL b2>126;
  IF b2=255 THEN BEGIN active:=oldact;gamma:=oldgam;dithering:=olddith;SetPal(pal);END;
  IF dithering<>olddith THEN zoom:=zoom OR 128;
  PUTIMAGE(220,160,page^[0],0);
  PUTIMAGE(210,300,page^[48000],0);
  PUTIMAGE(320,300,page^[56000],0);
  XMS2RAM(page,xms[1],40000,251500);
  PutImage(210,120,page^[0],0);
  IF b2=127 THEN BEGIN
    ASSIGN(txf,ini_name);
    RESET(txf);IF IORESULT=0 THEN BEGIN CLOSE(txf);ERASE(txf);END;
    REWRITE(txf);
    WRITELN(txf,ini_kopf);
    WRITELN(txf,ini_list00+'=',gamma);
    IF syncanimation THEN st0:=an ELSE st0:=aus;
    WRITELN(txf,ini_list01+'='+st0);
    IF mml_anim[3]='-' THEN st0:=COPY(mml_anim,1,2)
     ELSE st0:=aus;
    WRITELN(txf,ini_list02+'='+st0);
    WRITELN(txf,ini_list03+'='+installdir);
    IF dithering=1 THEN st0:=an
     ELSE st0:=aus;
    WRITELN(txf,ini_list04+'='+st0);
    IF quicktips THEN st0:=an
     ELSE st0:=aus;
    WRITELN(txf,ini_list05+'='+st0);
    WRITELN(txf);
    WRITELN(txf,ini_sound);
    IF soundon THEN st0:=an ELSE st0:=aus;
    WRITELN(txf,ini_list14+'='+st0);
    IF sbautodetect THEN st0:=an ELSE st0:=aus;
    WRITELN(txf,ini_list10+'='+st0);
    WRITELN(txf,ini_list11+'='+Dec2Hex(base_io));
    STR(dsp_irq,st0);
    WRITELN(txf,ini_list12+'='+st0);
    STR(dsp_dma8,st0);
    WRITELN(txf,ini_list13+'='+st0);
    IF cdmusic THEN st0:=an ELSE st0:=aus;
    WRITELN(txf,ini_list15+'='+st0);
    IF cheats>0 THEN BEGIN
      WRITELN(txf);
      WRITELN(txf,ini_cheat);
      IF cheats AND 1=1 THEN WRITELN(txf,ini_list20+'=',an);
      IF cheatmoney<>0 THEN BEGIN
        STR(cheatmoney,st0);
        WRITELN(txf,ini_list21+'=',st0);
      END;
      IF cheats AND 4=4 THEN WRITELN(txf,ini_list22+'=',aus);
    END;
    CLOSE(txf);
  END;
  IF zoom AND 128=0 THEN ClickField(oldcfeld);
  Mouse(1);
  IF(active AND 4=4)AND(active AND 1=0)THEN active:=active AND NOT 16;
END;
FUNCTION DiskOp(op:BYTE):BOOLEAN;
CONST kennung:STRING[22]='FutureTrade SAVEGAME: ';
VAR sr:SEARCHREC;s1:STRING;s2:STRING[3];st:STRING[24];cp,cnt,iws:BYTE;
    names:ARRAY[1..100]OF STRING[12];bez:ARRAY[1..100]OF STRING[24];f0:FILE;
    x1,y1,x2,x3:WORD;
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
    SETCOLOR(238);
    BAR(GETMAXX DIV 2-114,239,GETMAXX DIV 2+113,250);
    OutBTxt(GETMAXX DIV 2-113,240,st,247);
    IF(ms.x>=GETMAXX DIV 2-134)AND(ms.x<=GETMAXX DIV 2+113)
     AND(ms.y>=219)AND(ms.y<=250)THEN Mouse(1);
    REPEAT Keys;Mouse(3);
      IF Click(GETMAXX DIV 2,259,GETMAXX DIV 2+119,299,7) THEN key[1]:=#27;
      IF Click(GETMAXX DIV 2-120,259,GETMAXX DIV 2-1,299,7) THEN key[1]:=#13;
      IF(op=2)AND(cp<>0)AND Click(GETMAXX DIV 2-120,301,GETMAXX DIV 2+119,341,7) THEN key[1]:=#1;
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
  UNTIL(key[1]=#27)OR((key[1]=#13)AND(st<>''))OR((key[1]=#1)AND(op=2));
  IF key[1]=#13 THEN s1:=st ELSE IF key[1]=#1 THEN INC(cp,100) ELSE cp:=245;
  Mouse(2);
END;
PROCEDURE HeapSort;
FUNCTION CompareString(first,second:STRING):BYTE;
VAR counter,lengthfirst,lengthsecond,maxlength:BYTE;
BEGIN
  lengthfirst:=LENGTH(first);
  lengthsecond:=LENGTH(second);
  IF lengthfirst>lengthsecond THEN maxlength:=lengthfirst
   ELSE maxlength:=lengthsecond;
  counter:=0;
  WHILE counter<maxlength DO BEGIN
    INC(counter);
    IF(first[counter]<second[counter])OR(lengthfirst<counter)THEN
     BEGIN CompareString:=1;EXIT;END;
    IF(first[counter]>second[counter])OR(lengthsecond<counter)THEN
     BEGIN CompareString:=2;EXIT;END;
  END;
  CompareString:=0;
END;
PROCEDURE Change(first,second:WORD);
VAR temp24:STRING[24];temp12:STRING[12];
BEGIN
  temp24:=bez[first];
  bez[first]:=bez[second];
  bez[second]:=temp24;
  temp12:=names[first];
  names[first]:=names[second];
  names[second]:=temp12;
END;
PROCEDURE Heapify(left,right:WORD);
VAR pos,counter:WORD;
    first:STRING[24];
BEGIN
  counter:=1;
  REPEAT
    pos:=2*left;
    IF pos<=right THEN BEGIN
      first:=UpString(bez[pos]);
      IF pos=right THEN BEGIN
        IF first>UpString(bez[left]) THEN Change(left,pos);
      END ELSE BEGIN
        IF first<UpString(bez[pos+1]) THEN INC(pos);
        IF UpString(bez[left])<UpString(bez[pos]) THEN BEGIN
          Change(left,pos);
          INC(counter);
          left:=pos;
        END;
      END;
    END;
    DEC(counter);
  UNTIL(counter=0);
END;

VAR left,right:WORD;
BEGIN
  {HeapSort-Algorithmus}
  left:=cnt DIV 2+1;
  right:=cnt;
  WHILE(left>1)DO BEGIN
    DEC(left);
    Heapify(left,right);
  END;
  WHILE(right>1)DO BEGIN
    Change(right,left);
    DEC(right);
    Heapify(left,right);
  END;
END;
PROCEDURE DrawIt;
VAR z0:BYTE;ya:BYTE;col:BYTE;
BEGIN
  ya:=138;IF(op=2)AND(cnt<100)THEN BEGIN z0:=0;INC(ya,12);END ELSE z0:=1;
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
  IF(op=2)AND(DISKFREE(0)<250000)THEN EXIT;
  s2:='SAV';
  cnt:=0;
  FINDFIRST('FT???.'+s2,$3F,sr);
  WHILE(DOSERROR=0)AND(cnt<100)DO BEGIN
    IF sr.attr AND $3F=$20 THEN BEGIN
      INC(cnt);
      names[cnt]:=sr.name;
      ASSIGN(f0,sr.name);
      RESET(f0,1);
      BLOCKREAD(f0,s1[1],60,x1);
      s1[0]:=CHR(x1);
      bez[cnt]:=COPY(s1,23,POS(mml_tend,s1)-23);
      CLOSE(f0);
      IF COPY(s1,1,LENGTH(kennung))<>kennung THEN DEC(cnt);
    END;
    FINDNEXT(sr);
  END;
  HeapSort;
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
  s1:='SPIELSTAND';
  IF op=1 THEN s1:=s1+' LADEN' ELSE s1:=s1+' SPEICHERN';
  OutText(GETMAXX DIV 2,125,s1,240,6,1.5);
  SETCOLOR(238);
  FOR y1:=0 TO 12 DO BAR(GETMAXX DIV 2-109,y1*12+149,GETMAXX DIV 2+108,y1*12+159);
  Mouse(1);iws:=0;
  REPEAT
    IF(ms.y>148)AND(ms.y<304)THEN cp:=(ms.y-149)DIV 12 ELSE cp:=254;
    DrawIt;
    REPEAT Mouse(3);UNTIL ms.f<>0;
    IF Click(GETMAXX DIV 2-120,319,GETMAXX DIV 2+119,359,7)THEN iws:=255;
    IF ms.b<>0 THEN iws:=1;
    IF(ms.f=1)AND(ms.b=0)AND(cp<=cnt)THEN INC(iws,5);
  UNTIL iws>5;
  Mouse(2);
  PUTIMAGE(GETMAXX DIV 2-120,120,page^,0);
  IF(iws<>255)AND(cp<254)THEN BEGIN
    IF op=2 THEN BEGIN
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
      IF cp<>0 THEN GrBar(GETMAXX DIV 2-120,301,GETMAXX DIV 2+119,341,'LôSCHEN');
      InPut;
      PUTIMAGE(GETMAXX DIV 2-120,120,page^,0);
      IF(cp>100)AND(cp<201)THEN BEGIN
        ASSIGN(f0,names[cp-100]);
        RESET(f0,1);
        IF IORESULT=0 THEN BEGIN
          CLOSE(f0);
          ERASE(f0);
        END;
      END;
      IF cp<101 THEN BEGIN
        IF cp=0 THEN BEGIN
          x1:=0;
          REPEAT
            INC(x1);
            STR(x1,st);
            FOR x2:=1 TO 3-LENGTH(st) DO st:='0'+st;
            st:='FT'+st+'.'+s2;
            FINDFIRST(st,$3F,sr);
          UNTIL DOSERROR<>0;
        END ELSE st:=names[cp];
        ASSIGN(f0,st);
        REWRITE(f0,1);
        BLOCKWRITE(f0,kennung[1],LENGTH(kennung),x1);
        BLOCKWRITE(f0,s1[1],LENGTH(s1),x1);
        BLOCKWRITE(f0,mml_tend[1],3,x1);
        XMS2RAM(map[0],xms[1],62500,0);
        BLOCKWRITE(f0,map[0]^,62500,x1);
        XMS2RAM(map[0],xms[1],62500,62500);
        BLOCKWRITE(f0,map[0]^,62500,x1);
        XMS2RAM(map[0],xms[1],62500,125000);
        BLOCKWRITE(f0,map[0]^,62500,x1);
        BLOCKWRITE(f0,trk,SIZEOF(vehicle),x1);
        BLOCKWRITE(f0,enemy,SIZEOF(oponent),x1);
        BLOCKWRITE(f0,road^,SIZEOF(streets),x1);
        BLOCKWRITE(f0,stime,SIZEOF(startime),x1);
        BLOCKWRITE(f0,news^,SIZEOF(nachrichten),x1);
        BLOCKWRITE(f0,vertr^,SIZEOF(contract),x1);
        BLOCKWRITE(f0,geld,SIZEOF(REAL),x1);
        BLOCKWRITE(f0,ctf,1,x1);
        BLOCKWRITE(f0,mapx^,SIZEOF(map_xtra),x1);
        CLOSE(f0);
        DiskOp:=TRUE;
      END;
    END ELSE BEGIN
      IF cp<101 THEN BEGIN
        ASSIGN(f0,names[cp]);
        RESET(f0,1);
        BLOCKREAD(f0,s1,60,x1);
        s1[0]:=CHR(x1);
        SEEK(f0,POS(mml_tend,s1)+3);
        IF map[0]=NIL THEN BEGIN
          NEW(map[0]);
          NEW(map[1]);
        END;
        BLOCKREAD(f0,map[0]^,62500,x1);
        RAM2XMS(map[0],xms[1],62500,0);
        BLOCKREAD(f0,map[0]^,62500,x1);
        RAM2XMS(map[0],xms[1],62500,62500);
        BLOCKREAD(f0,map[0]^,62500,x1);
        RAM2XMS(map[0],xms[1],62500,125000);
        BLOCKREAD(f0,trk,SIZEOF(vehicle),x1);
        BLOCKREAD(f0,enemy,SIZEOF(oponent),x1);
        BLOCKREAD(f0,road^,SIZEOF(streets),x1);
        BLOCKREAD(f0,stime,SIZEOF(startime),x1);
        BLOCKREAD(f0,news^,SIZEOF(nachrichten),x1);
        BLOCKREAD(f0,vertr^,SIZEOF(contract),x1);
        BLOCKREAD(f0,geld,SIZEOF(REAL),x1);
        BLOCKREAD(f0,ctf,1,x1);
        BLOCKREAD(f0,mapx^,SIZEOF(map_xtra),x1);
        CLOSE(f0);
        OutPic(pal,4,0,255);
        CLEARDEVICE;
        MapPal;
        DiskOp:=TRUE;
      END;
    END;
  END;
END;

END.