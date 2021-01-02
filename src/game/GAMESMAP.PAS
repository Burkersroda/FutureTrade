{$N+,E+,G+}

UNIT Game;
{  Game-Unit for FutureTrade        }
{  (c)1996-99 by Ronny Burkersroda  }

INTERFACE USES vars,vesa,subs,effects,memory,dos,sb_vars;

PROCEDURE PlayGame;

IMPLEMENTATION

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
      3:IF active AND 5>0 THEN menutext:='ZURšCK' ELSE
       IF cheats AND 1=0 THEN menutext:='EINLEITUNG' ELSE menutext:='ANIMATIONEN';
      4:menutext:='SPIEL BEENDEN';
    END;
    GrBar(220,100+b1*41,419,139+b1*41,menutext);
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
PROCEDURE Einstellungen;
VAR oldact,oldgam:BYTE;oldcfeld:WORD;st0:STRING;txf:TEXT;
BEGIN
  IF(active AND 4=4)AND(active AND 1=0)THEN active:=active OR 16;
  Mouse(2);
  oldact:=active;oldgam:=gamma;oldcfeld:=cfeld;
  ClickField(0);
  GETIMAGE(220,130,315,294,page^[0]);
  FOR b1:=0 TO 1 DO BEGIN
    CASE b1 OF 0:st0:='GAMMA';1:st0:='NAMEN';2:st0:='';END;
    OutText(315,130+b1*41,st0+':',244,1,2);
  END;
  b2:=3;
  GETIMAGE(209,300,318,339,page^[48000]);
  GrBar(209,300,318,339,ok);
  GETIMAGE(320,300,429,339,page^[56000]);
  GrBar(320,300,429,339,abbruch);
  FOR b1:=0 TO 1 DO GETIMAGE(320,120+b1*41,409,159+b1*41,page^[16000+WORD(b1)*8000]);
  REPEAT
    FOR b1:=0 TO 1 DO IF(1 SHL b1)AND b2>0 THEN BEGIN
      CASE b1 OF 0:BEGIN STR(gamma,st0);SetPal(pal);END;
        1:IF active AND 8=8 THEN st0:=an ELSE st0:=aus;END;
      GrBar(320,120+b1*41,409,159+b1*41,st0);
    END;
    Mouse(1);b2:=0;
    REPEAT Mouse(3);Keys;
      IF Click(320,120,409,159,1)THEN BEGIN INC(gamma);b2:=1;END ELSE
       IF Click(320,120,409,159,2)THEN BEGIN DEC(gamma);b2:=1;END;
      IF gamma=11 THEN gamma:=1 ELSE IF gamma=0 THEN gamma:=10;
      IF Click(320,161,409,200,7)THEN BEGIN active:=active XOR 8;b2:=2;END;
      IF Click(209,300,318,339,7)THEN b2:=127 ELSE
       IF Click(320,300,429,339,7)THEN b2:=255;
    UNTIL b2>0;
    Mouse(2);
    FOR b1:=0 TO 1 DO IF(1 SHL b1)AND b2>0 THEN
     PUTIMAGE(320,120+b1*41,page^[16000+WORD(b1)*8000],0);
  UNTIL b2>126;
  IF b2=255 THEN BEGIN active:=oldact;gamma:=oldgam;SetPal(pal);END;
  IF active<>oldact THEN zoom:=zoom OR 128;
  PUTIMAGE(220,130,page^[0],0);
  PUTIMAGE(209,300,page^[48000],0);
  PUTIMAGE(320,300,page^[56000],0);
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
    WRITELN(txf);
    WRITELN(txf,ini_sound);
    IF sbautodetect THEN st0:=an ELSE st0:=aus;
    WRITELN(txf,ini_list10+'='+st0);
    IF exist_SB THEN BEGIN
      WRITELN(txf,ini_list11+'='+COPY(Dec2Hex(dsp_adr),2,3));
      STR(dsp_irq,st0);
      WRITELN(txf,ini_list12+'='+st0);
      STR(dma_ch,st0);
      WRITELN(txf,ini_list13+'='+st0);
    END;
    IF cheats>0 THEN BEGIN
      WRITELN(txf);
      WRITELN(txf,ini_cheat);
      IF cheats AND 1=1 THEN WRITELN(txf,ini_list20+'=',an);
    END;
    CLOSE(txf);
  END;
  ClickField(oldcfeld);
  Mouse(1);
  IF(active AND 4=4)AND(active AND 1=0)THEN active:=active AND NOT 16;
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
           ELSE BEGIN FILLCHAR(map[0]^[bre,hoe],page^[tst+1]+1,page^[tst]);
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
  CASE key[1] OF '„':Gross:='Ž';
    '”':Gross:='™';
    '':Gross:='š';
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
      IF(iws=7)AND(cp<>0)THEN GrBar(GETMAXX DIV 2-120,301,GETMAXX DIV 2+119,341,'L™SCHEN');
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
      GrBar(GETMAXX DIV 2-120,259,GETMAXX DIV 2-1,299,'L™SCHEN');
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
PROCEDURE PlayGame;
VAR xp,yp,i0:INTEGER;pb,cf:BYTE;st,s1:STRING;
    ntf:TEXT;
    ncount:WORD;
    ctof:RECORD
      n:BYTE;
      x,y:INTEGER;
    END;
    ware:ARRAY[1..2]OF LONGINT;
PROCEDURE MapXY2ScrXY(x0,y0:BYTE;VAR p0:point);
BEGIN
   p0.x:=((INTEGER(x0)-INTEGER(xp)-INTEGER(y0)+INTEGER(yp))*20+GETMAXX DIV 2*zoom)DIV zoom;
   p0.y:=(((INTEGER(y0)-INTEGER(yp)+INTEGER(x0)-INTEGER(xp))*10+GETMAXY DIV 2*zoom)-map[0]^[x0,y0])DIV zoom;
END;
PROCEDURE Waren(stw:BYTE);
BEGIN
  IF stw>20 THEN BEGIN ware[2]:=4194304;
    CASE mapx^.ft[stw-20] OF 0:ware[1]:=16777216;
      1:ware[1]:=131072;
      2:ware[1]:=16384;
      3:ware[1]:=8454533{1+256+4+128+65536+8388608};
      4:BEGIN ware[1]:=4194304;ware[2]:=0;END;
      5:ware[1]:=35913728{2097152+262144+33554432};
      6:ware[1]:=2048;
      7:ware[1]:=4192{32+64+4096};
      8:BEGIN ware[1]:=40960{8192+32768};INC(ware[2],64);END;
      9:BEGIN ware[1]:=538{2+16+8+512};
        INC(ware[2],1721728{524288+1024+131072+16384+128+256+1048576});END;
      10:BEGIN ware[1]:=525312{524288+1024};
        INC(ware[2],8454149{1+4+65536+8388608});END;
  END;END ELSE
   IF(mapx^.tt[stw]AND 2=2)OR(stw=mapx^.it)THEN BEGIN
      ware[1]:=67108863;ware[2]:=62914559;END ELSE BEGIN
    ware[1]:=0;ware[2]:=40155232;
    IF mapx^.tt[stw] AND 1=1 THEN BEGIN
      ware[1]:=ware[1] OR 9977988;ware[2]:=ware[2] OR 9977988;END;
    IF mapx^.tt[stw] AND 4=4 THEN BEGIN
      ware[1]:=ware[1] OR 26;ware[2]:=ware[2] OR 1573120;END;
    IF mapx^.tt[stw] AND 8=8 THEN BEGIN
      ware[1]:=ware[1] OR 16777345;ware[2]:=ware[2] OR 16778240;END;
    IF mapx^.tt[stw] AND 16=16 THEN ware[1]:=ware[1] OR 40960;
    IF mapx^.tt[stw] AND 32=32 THEN ware[1]:=ware[1] OR 4192;
    IF mapx^.tt[stw] AND 64=64 THEN BEGIN
      ware[1]:=ware[1] OR 35913728;ware[2]:=ware[2] OR 520;END;
    IF mapx^.tt[stw] AND 128=128 THEN BEGIN
      ware[1]:=ware[1] OR 16842770;ware[2]:=ware[2] OR 1043;END;
  END;
END;
FUNCTION Timing:BOOLEAN;
VAR x0,y0:WORD;
BEGIN
  Timing:=FALSE;
  INC(stime.ev,ttime DIV 50);
  IF active AND 19=0THEN BEGIN geld:=geld-2*ttime DIV 50;active:=active OR 64;END;
  DEC(ttime,ttime-ttime DIV 50);
  IF stime.ev DIV 7=stime.ev/7 THEN BEGIN active:=active OR 32;
    FOR b1:=1 TO mapx^.tc DO FOR l1:=0 TO 25 DO BEGIN
      mapx^.pr[b1,l1]:=mapx^.pr[b1,l1]*(RANDOM(110)/4000+0.9875);
      IF mapx^.pr[b1,l1]<GetPrice[l1]*0.8 THEN mapx^.pr[b1,l1]:=mapx^.pr[b1,l1]*1.05;
      IF mapx^.pr[b1,l1]>GetPrice[l1]*1.25 THEN mapx^.pr[b1,l1]:=mapx^.pr[b1,l1]*0.95;
    END;
  END;
  Mouse(2);
  IF stime.ev>99 THEN BEGIN INC(stime.gt,stime.ev DIV 100);
    PUTIMAGE(GETMAXX DIV 2-21,GETMAXY-14,tbkgr^[0],0);
    DEC(stime.ev,stime.ev DIV 100*100);
    IF stime.gt>=deathline THEN death:=TRUE;
  END;
  PUTIMAGE(GETMAXX DIV 2+6,GETMAXY-14,tbkgr^[1],0);
  OutBTxt(GETMAXX DIV 2-48,GETMAXY-14,TimeString,248);
  Mouse(1);
  IF(RANDOM(30-mapx^.itst*3)=3)THEN BEGIN b2:=0;
    IF mapx^.itst<5 THEN BEGIN
      IF mapx^.itst=0 THEN BEGIN b2:=1;
        PUTIMAGE(GETMAXX DIV 2-21,GETMAXY-14,tbkgr^[0],0);
        PUTIMAGE(GETMAXX DIV 2+6,GETMAXY-14,tbkgr^[1],0);
        Timing:=TRUE;
      END;
      INC(mapx^.itst);
    END;
    FOR b1:=3 DOWNTO 1 DO news^[b1+1]:=news^[b1];
    IF b2=0 THEN BEGIN
      REPEAT RESET(ntf);IF IORESULT<>0 THEN BEGIN CLOSE(ntf);RESET(ntf);END;
        l1:=RANDOM(ncount)+1;
        FOR l1:=1 TO l1 DO READLN(ntf,news^[1].st);
      UNTIL(news^[1].st[1]<>'#')AND(news^[1].st<>'');
      b1:=POS('~',news^[1].st);
      IF b1<>0 THEN news^[1].st:=COPY(news^[1].st,1,b1-1)
       +mapx^.tn[RANDOM(mapx^.tc)+1]+COPY(news^[1].st,b1+1,LENGTH(news^[1].st)-b1);
    END ELSE news^[1].st:='FREIE STADT '+mapx^.tn[mapx^.it]+' GEGRšNDET';
    news^[1].dt:=stime.gt;news^[1].ev:=stime.ev;
    IF sts=124 THEN active:=active OR 128;
  END;
  FOR b1:=1 TO 20 DO
   IF vertr^[b1].gd*100+vertr^[b1].ev<stime.gt*100+stime.ev THEN BEGIN
    vertr^[b1].s:=128;vertr^[b1].t:=0;
    IF vertr^[b1].db AND 128=128 THEN BEGIN
      IF vertr^[b1].s=0 THEN b2:=4 ELSE b2:=2;
      geld:=geld-vertr^[b1].pr DIV b2-vertr^[b1].cc*GetPrice[vertr^[b1].db-128];
      INC(trk.c[vertr^[b1].db-128],vertr^[b1].cc);
      vertr^[b1].db:=0;
      IF(sts=3)OR(sts=4)OR(sts=6)OR(sts=7)THEN active:=active OR 128;
      IF sts=7 THEN sts:=250;
    END;
  END;
  IF RANDOM(4)=2 THEN BEGIN
    IF(sts=4)OR(sts=6)OR(sts=7)THEN active:=active OR 128;
    b1:=1;
    WHILE((vertr^[b1].s<>0)AND(vertr^[b1].s<>128))OR(vertr^[b1].t<>0)OR(vertr^[b1].db<>0)DO INC(b1);
    IF b1=21 THEN b1:=RANDOM(20)+1
     ELSE IF RANDOM(3)=1 THEN b1:=RANDOM(b1-1)+1;
    IF vertr^[b1].db AND 128=0 THEN BEGIN
      REPEAT
        FILLCHAR(vertr^[b1],12,0);
        b2:=0;FOR b3:=1 TO mapx^.fc DO IF mapx^.ft[b3]=9 THEN b2:=1;
        CASE RANDOM(13) OF
          0..2:vertr^[b1].s:=0;
          3..5:REPEAT
            vertr^[b1].s:=RANDOM(mapx^.tc)+1;
          UNTIL(vertr^[b1].s<>mapx^.it)OR(mapx^.itst<>0);
          6..8:vertr^[b1].s:=RANDOM(mapx^.fc)+21;
          9,10:IF(b2=1)OR(mapx^.itst<>0)THEN BEGIN
            vertr^[b1].s:=0;
            vertr^[b1].t:=128;
            vertr^[b1].co:=RANDOM(10)+1;
            vertr^[b1].pr:=vertr^[b1].co*(RANDOM(201)+400);
          END ELSE b2:=2;
          11,12:BEGIN
            vertr^[b1].s:=0;
            vertr^[b1].t:=0;
            vertr^[b1].db:=0;
          END;
        END;
      UNTIL b2<>2;
      b2:=0;
      IF vertr^[b1].s<>128 THEN REPEAT
        IF vertr^[b1].t<>128 THEN BEGIN
          IF vertr^[b1].s<>0 THEN BEGIN
            Waren(vertr^[b1].s);
            REPEAT vertr^[b1].db:=RANDOM(26);
            UNTIL ware[1]AND(LONGINT(1)SHL vertr^[b1].db)>0;
          END;
          REPEAT vertr^[b1].t:=RANDOM(mapx^.tc)+1;
          UNTIL((mapx^.it<>vertr^[b1].t)OR(mapx^.itst<>0))AND(vertr^[b1].t<>vertr^[b1].s);
          Waren(vertr^[b1].t);
          IF vertr^[b1].s=0 THEN REPEAT vertr^[b1].db:=RANDOM(26);
          UNTIL ware[2]AND(LONGINT(1)SHL vertr^[b1].db)>0;
          IF ware[2]AND(LONGINT(1)SHL vertr^[b1].db)>0THEN BEGIN
            b2:=1;vertr^[b1].co:=ROUND(SQRT(RANDOM(36100)+3900));
            IF vertr^[b1].s=0 THEN vertr^[b1].pr:=ROUND((RANDOM(50)+110)*GetPrice[vertr^[b1].db]*vertr^[b1].co/100)
             ELSE BEGIN
              IF vertr^[b1].s<21 THEN BEGIN
                x0:=mapx^.tx[vertr^[b1].s];y0:=mapx^.ty[vertr^[b1].s];
              END ELSE BEGIN
                x0:=mapx^.fx[vertr^[b1].s-20];y0:=mapx^.fy[vertr^[b1].s-20];
              END;
              vertr^[b1].pr:=ROUND((RANDOM(50)+50)*vertr^[b1].co
               *Entfernung(x0,y0,mapx^.tx[vertr^[b1].t],mapx^.ty[vertr^[b1].t])/2500);
            END;
          END;
        END ELSE BEGIN
          FOR b3:=1TO mapx^.fc DO IF(mapx^.ft[b3]=9)AND(RANDOM(4)=2)
           THEN BEGIN vertr^[b1].s:=b3+20;b2:=1;END;
          IF(b2=0)AND(RANDOM(2)=0)AND(mapx^.itst<>0)THEN BEGIN
            vertr^[b1].s:=mapx^.it;b2:=1;END
        END;
      UNTIL b2=1;
      vertr^[b1].gd:=ROUND(SQRT(RANDOM(7)+1))-1;vertr^[b1].ev:=RANDOM(95)+5;
      IF vertr^[b1].s=0 THEN vertr^[b1].pr:=ROUND(vertr^[b1].pr*SQRT(SQRT(100/(vertr^[b1].gd*100+vertr^[b1].ev))))
       ELSE IF vertr^[b1].t<>128 THEN vertr^[b1].pr:=ROUND(vertr^[b1].pr*SQRT(1000/(vertr^[b1].gd*100+vertr^[b1].ev)));
      INC(vertr^[b1].gd,stime.gt);INC(vertr^[b1].ev,stime.ev);
      IF vertr^[b1].ev>99 THEN BEGIN INC(vertr^[b1].gd);DEC(vertr^[b1].ev,100);END;
    END;
  END;
END;
PROCEDURE InTown(VAR town:BYTE);
VAR wo0:WORD;ctf2,ctf3,scrollpos,oldcrt,newcrt:BYTE;
    oldtw,newtw:BYTE;roads:RECORD t,r:ARRAY[1..20]OF BYTE;a:BYTE;END;
    sgl:SINGLE;menge:INTEGER;
PROCEDURE IB;
BEGIN
  CASE mapx^.ft[town-20] OF
    0..3:st:='Bergwerk'+st;
    4:st:='Wasserpumpstation'+st;
    5,9:st:='Industrie'+st;
    6:st:='Hanfplantage'+st;
    7:st:='Farm'+st;
    8:st:='Ranch'+st;
    10:st:='Schmelzwerk'+st;
  END;
END;
PROCEDURE City;
VAR wo0:WORD;li0:LONGINT;
BEGIN
  OutPic(pal,4,0,255);
  PUTIMAGE(GETMAXX DIV 2-21,GETMAXY-14,tbkgr^[0],0);
  PUTIMAGE(GETMAXX DIV 2+6,GETMAXY-14,tbkgr^[1],0);
  SetActivePage(2);
  fillingcolor:=0;BAR(0,0,639,479);
  SetVisualPage(2);
  IF town<21 THEN IF mapx^.tt[town] AND 2=0 THEN BEGIN st:='Raumhafen';
    IF mapx^.it=town THEN BEGIN STR(mapx^.itst,st);st:='Freie Stadt.'+st;END ELSE
     IF mapx^.tt[town] AND 1=0 THEN BEGIN li0:=(stime.gt+4760)*100+stime.ev;
      STR((li0-li0 DIV 12*12)DIV 6+1,st);st:='Stadt.'+st;END;END
   ELSE BEGIN st:='Hauptstadt.';IF mapx^.tt[town]AND 128=128 THEN st:=st+'2' ELSE st:=st+'1';
  END ELSE BEGIN st:='';IB;END;
  LoadMMLtrack(0,0,0,'scr.'+st,235);OutPic(pal,255,0,255);
  GetCFOriginals(TRUE);
  IF town<21 THEN BEGIN IF st[LENGTH(st)]<#65 THEN st:=COPY(st,1,LENGTH(st)-2);
    wo0:=320-(LENGTH(st)*9)DIV 2;OutBTxt(wo0+16383,10,st,255);
    OutBTxt(wo0+16385,10,st,255);OutBTxt(wo0+16384,9,st,255);
    OutBTxt(wo0+16384,11,st,255);OutBTxt(wo0,10,st,248);
    OutText(319,21,mapx^.tn[town],237,2,17);OutText(321,21,mapx^.tn[town],237,2,17);
    OutText(320,20,mapx^.tn[town],237,2,17);OutText(320,22,mapx^.tn[town],237,2,17);
    OutText(320,21,mapx^.tn[town],244,2,2);
  END ELSE BEGIN STR(ORD(mapx^.tn[1,2])+ORD(mapx^.tn[2,1])-128,s1);
    STR(town-20,st);IF st[0]=#1 THEN st:='0'+st;IF s1[0]=#1 THEN s1:='0'+s1;
    st:='INDUSTRIE (ID-NR. '+s1+'-'+st+')';
    OutBTxt(16384+211,10,st,255);OutBTxt(16384+213,10,st,255);
    OutBTxt(16384+212,9,st,255);OutBTxt(16384+212,11,st,255);
    OutBTxt(212,10,st,248);st:='';ID(st,town-20);
    OutText(319,21,st,237,2,17);OutText(321,21,st,237,2,17);
    OutText(320,20,st,237,2,17);OutText(320,22,st,237,2,17);
    OutText(320,21,st,244,2,2);
  END;
  FILLCHAR(pal[255],3,63);
  InPic(pal,4,0,255);
  FOR b1:=0 TO 3 DO BEGIN
    FOR wo0:=0 TO 49 DO BEGIN
      GETIMAGE(40,wo0*2+50+b1*100,599,wo0*2+50+b1*100,page^[wo0*1128]);
      GETIMAGE(40,449-wo0*2-b1*100,599,449-wo0*2-b1*100,page^[wo0*1128+564]);
    END;
    RAM_2_XMS(page,xms[17+b1],64000);
  END;
  IF active AND 4=0 THEN BEGIN sts:=255;ClickField(33024);END
   ELSE BEGIN sts:=0;ClickField(64768);END;
END;
PROCEDURE SmallMap;
VAR x0,y0,x1,y1:INTEGER;
BEGIN
  SETCOLOR(244);
  FOR b2:=1 TO road^.sc DO IF(mapx^.itst<>0)OR
   ((road^.p1[b2]<>mapx^.it)AND(road^.p2[b2]<>mapx^.it))THEN BEGIN
    IF road^.p1[b2]>20 THEN
     BEGIN x0:=mapx^.fx[road^.p1[b2]-20];y0:=mapx^.fy[road^.p1[b2]-20];END
     ELSE BEGIN x0:=mapx^.tx[road^.p1[b2]];y0:=mapx^.ty[road^.p1[b2]];END;
    IF road^.p2[b2]>20 THEN
     BEGIN x1:=mapx^.fx[road^.p2[b2]-20];y1:=mapx^.fy[road^.p2[b2]-20];END
     ELSE BEGIN x1:=mapx^.tx[road^.p2[b2]];y1:=mapx^.ty[road^.p2[b2]];END;
    LINE(TRUNC((x0-y0)/smapdivx)+smapaddx,TRUNC((x0+y0)/smapdivy)+smapaddy,
     TRUNC((x1-y1)/smapdivx)+smapaddx,TRUNC((x1+y1)/smapdivy)+smapaddy);
  END;
  SETCOLOR(255);
  IF town>20 THEN BEGIN x0:=mapx^.fx[town-20];y0:=mapx^.fy[town-20];END
  ELSE BEGIN x0:=mapx^.tx[town];y0:=mapx^.ty[town];END;
  x1:=TRUNC((x0-y0)/smapdivx)+smapaddx;
  y1:=TRUNC((x0+y0)/smapdivy)+smapaddy;
  LINE(x1-2,y1,x1+2,y1);
  LINE(x1,y1-2,x1,y1+2);
  FOR b2:=1 TO 40 DO BEGIN
    IF b2<21 THEN BEGIN x1:=mapx^.tx[b2];y1:=mapx^.ty[b2];END
     ELSE BEGIN x1:=mapx^.fx[b2-20];y1:=mapx^.fy[b2-20];END;
    x0:=TRUNC((x1-y1)/smapdivx)+smapaddx;y0:=TRUNC((x1+y1)/smapdivy)+smapaddy;
    GETIMAGE(x0-2,y0-2,x0+2,y0+2,tile^[b2]);
  END;
END;
PROCEDURE GrScr(alles:BOOLEAN);
VAR x0,y0:INTEGER;
BEGIN
  FOR b1:=0 TO 3 DO BEGIN
    XMS_2_RAM(page,xms[17+b1],64000);
    FOR y0:=0 TO 49 DO BEGIN
      FOR x0:=4 TO 563 DO BEGIN
        IF(y0<30)OR(b1<3)OR alles THEN page^[x0+y0*1128]:=zpal[page^[x0+y0*1128]];
        IF(y0>20)OR(b1>0)OR alles THEN page^[x0+y0*1128+564]:=zpal[page^[x0+y0*1128+564]];
      END;
      PUTIMAGE(40,y0*2+50+b1*100,page^[y0*1128],0);
      PUTIMAGE(40,449-y0*2-b1*100,page^[y0*1128+564],0);
    END;
  END;
END;
PROCEDURE Prices(tof:BOOLEAN);
VAR x0,y0:INTEGER;
BEGIN
  Mouse(2);
  IF tof THEN BEGIN
    CopyPage(GetActivePage,1-(GetActivePage-2)+2);
    SetActivePage(1-(GetActivePage-2)+2);
    GrScr(FALSE);
  END;
  Waren(ctf2);
  IF(ctf2<21)AND tof THEN BEGIN st:=TypeName(ctf2);
    IF(mapx^.tt[ctf2] AND 3=1)AND(mapx^.it<>ctf2)THEN st:='DES '+st+'S'ELSE st:='DER '+st;
    IF mapx^.it=ctf2 THEN st:=COPY(st,1,9)+'N'+COPY(st,10,6);
    st:=st+' "'+mapx^.tn[ctf2]+'"';
  END ELSE IF tof THEN BEGIN st:='';ID(st,ctf2-20);
    CASE mapx^.ft[ctf2-20] OF 0,1,3,10:st:='DES '+st+'S';
      2,4,5,6,7,8,9:st:='DER '+st;
    END;
    s1:=TypeName(ctf2);st:=st+' '+s1;
  END;
  IF tof THEN BEGIN OutText(45,52,'PREISšBERSICHT '+st,240,4,1.5);
    SETFILLSTYLE(1,238);
  END;
  IF tof THEN BEGIN GrBar(40,410,219,449,'STADT WŽHLEN');
    GrBar(220,410,399,449,'INDUSTRIE WŽHLEN');
    GrBar(400,410,599,449,'NACHRICHTEN ANSEHEN');
    OutBTxt(55,78,'WARENBEZEICHNUNG',250);
    OutBTxt(340,78,'ANKAUFSPREIS',250);
    OutBTxt(470,78,'VERKAUFSPREIS',250);
  END;
  FOR y0:=0TO 25DO BEGIN IF ODD(y0) THEN x0:=244 ELSE x0:=247;
    BAR(50,y0*12+90,589,y0*12+100);
    OutBTxt(55,y0*12+91,GetWare[y0],x0);
    IF ctf2<21THEN sgl:=mapx^.pr[ctf2,y0]ELSE sgl:=GetPrice[y0];
    IF ware[1]AND(LONGINT(1)SHL y0)>0THEN BEGIN
      STR(sgl:7:2,st);Dot2Comma(st);st:=st+pdol;
    END ELSE st:='-';
    OutBTxt(587-LENGTH(st)*9,y0*12+91,st,x0);
    IF ware[2]AND(LONGINT(1)SHL y0)>0THEN BEGIN
      IF ctf2<21THEN STR(sgl*(0.98-mapx^.gs[ctf2]/10000):8:2,st)ELSE STR(sgl*1.1:8:2,st);
      Dot2Comma(st);st:=st+pdol;
    END ELSE st:='-';
    OutBTxt(448-LENGTH(st)*9,y0*12+91,st,x0);
  END;
  SetVisualPage(GetActivePage);
  IF active AND 4=0 THEN Clickfield(cfeld AND NOT 192) ELSE
    Clickfield((cfeld AND NOT 8312)OR 56448);
  Mouse(1);
  sts:=127;
END;
PROCEDURE Truck(what:BYTE);
VAR x0,y0:INTEGER;
BEGIN
  Mouse(2);
  IF what=1 THEN BEGIN
    CopyPage(GetActivePage,1-(GetActivePage-2)+2);
    SetActivePage(1-(GetActivePage-2)+2);
    GrScr(TRUE);
    OutText(45,52,'šBERSICHT',240,4,1.5);
    SETFILLSTYLE(1,238);
    OutBTxt(55,78,'EIGENE LADUNG',250);
    OutBTxt(251,78,'ANZAHL',250);
    FOR y0:=0TO 25DO BEGIN IF ODD(y0) THEN x0:=244 ELSE x0:=247;
      BAR(50,y0*12+90,309,y0*12+100);
      OutBTxt(55,y0*12+91,GetWare[y0],x0);
      IF trk.c[y0]>0THEN BEGIN STR(trk.c[y0],st);st:=st+tradeunits;END ELSE st:='-';
      OutBTxt(305-LENGTH(st)*9,y0*12+91,st,x0);
    END;
    BAR(50,414,309,424);
    OutBTxt(55,415,'FREIER FRACHTRAUM',247);
    BAR(50,426,309,436);
    OutBTxt(55,427,'GESAMTER FRACHTRAUM',244);
    STR(trk.f,st);
    OutBTxt(278-LENGTH(st)*9,415,st+tradeunits,247);
    STR(trk.m,st);
    OutBTxt(278-LENGTH(st)*9,427,st+tradeunits,244);
  END;
  OutBTxt(428,78,'KAPITAL',250);
  BAR(330,90,589,112);
  STR(geld:0:2,st);Dot2Comma(st);
  active:=active AND NOT 64;
  OutText(459,92,st+pdol,240,2,1.5);
  IF(what=4)AND(scrollpos>0)THEN DEC(scrollpos);
  IF(what=5)AND(scrollpos<10)THEN INC(scrollpos);
  REPEAT
    IF(what=1)OR(what>=3)THEN BEGIN
      active:=active AND NOT 128;
      SETCOLOR(243);
      OutBTxt(424,136,'VERTRŽGE',250);
      BAR(330,148,589,436);
      y0:=142-scrollpos*25;
      FOR b1:=1TO 20DO IF vertr^[b1].db AND 128=128 THEN BEGIN
        IF vertr^[b1].t<>128 THEN st:=GetWare[vertr^[b1].db-128]ELSE BEGIN st:='UMBAU';s1:='IN';END;
        IF vertr^[b1].s=0 THEN s1:='FšR' ELSE IF vertr^[b1].t<>128 THEN s1:='VON';
        st:=st+' '+s1+' ';
        IF vertr^[b1].s<>0 THEN BEGIN
          IF vertr^[b1].s<21 THEN s1:=mapx^.tn[vertr^[b1].s]ELSE s1:=TypeName(vertr^[b1].s);
        END ELSE s1:=mapx^.tn[vertr^[b1].t];
        st:=st+s1;
        IF(vertr^[b1].s<>0)AND(vertr^[b1].t<>128)THEN st:=st+' NACH '+mapx^.tn[vertr^[b1].t];
        STR((vertr^[b1].gd+4760)/100:0:2,s1);
        st:=st+' BIS '+s1+':';
        STR(vertr^[b1].ev,s1);IF s1[0]=#1THEN s1:='0'+s1;
        st:=st+s1+' ST (';
        STR(vertr^[b1].pr,s1);
        st:=st+s1+pdol+') ';
        IF(y0>150)AND(y0<420)THEN LINE(334,y0+8,585,y0+8);
        REPEAT b2:=28;
          IF LENGTH(st)>28 THEN WHILE st[b2]<>' 'DO DEC(b2);
          s1:=COPY(st,1,b2-1);st:=COPY(st,b2+1,LENGTH(st)-b2);
          INC(y0,12);
          IF(y0>150)AND(y0<420)THEN OutBTxt(334,y0,s1,247);
        UNTIL st='';b2:=LENGTH(s1);
        STR(vertr^[b1].cc,st);STR(vertr^[b1].co,s1);
        st:=st+'/'+s1;
        IF b2>28-LENGTH(st)THEN INC(y0,12);
        IF(y0>150)AND(y0<420)THEN OutBTxt(586-LENGTH(st)*9,y0,st,254);
        INC(y0,4);
      END;
      wo0:=y0;
    END;
    IF wo0>420-scrollpos*25 THEN b1:=48 ELSE b1:=0;
    IF(b1=0)AND(scrollpos>0)THEN BEGIN scrollpos:=0;b1:=128;END;
  UNTIL(b1<>128);
  SetVisualPage(GetActivePage);
  Clickfield(((cfeld AND NOT 1144)OR 63872)OR b1);
  Mouse(1);
  sts:=3;
END;
PROCEDURE PutCross(tilenr,col:BYTE);
VAR x0,y0,x1:INTEGER;
BEGIN
  IF tilenr>20 THEN BEGIN x1:=mapx^.fx[tilenr-20];y0:=mapx^.fy[tilenr-20];END
   ELSE BEGIN x1:=mapx^.tx[tilenr];y0:=mapx^.ty[tilenr];END;
  x0:=TRUNC((x1-y0)/smapdivx)+smapaddx;y0:=TRUNC((x1+y0)/smapdivy)+smapaddy;
  IF col=0 THEN PUTIMAGE(x0-2,y0-2,tile^[tilenr],0)
   ELSE BEGIN IF col=128 THEN col:=247 ELSE col:=253;
    SETCOLOR(col);
    PUTPIXEL(x0,y0,col);
    RECTANGLE(x0-2,y0-2,x0+2,y0+2);
  END;
END;
PROCEDURE Names(what:BYTE);
BEGIN
  SETFILLSTYLE(1,238);
  IF(ms.x>49)AND(ms.x<250)THEN newtw:=(ms.y-90)DIV 12+1 ELSE newtw:=0;
  IF(ms.f=1)AND(ms.b=0)AND(what=3)AND(newtw<=mapx^.tc)AND(newtw>0)THEN BEGIN
    PutCross(ctf3,0);
    ctf3:=newtw;
    IF(mapx^.itst=0)AND(newtw>=mapx^.it)THEN INC(ctf3);
    INC(what,2);
  END;
  IF(ms.f=1)AND(ms.b=0)AND(what=4)AND(newtw<=mapx^.fc)AND(newtw>0)THEN BEGIN
    PutCross(ctf3,0);
    ctf3:=newtw+20;
    INC(what,2);
  END;
  IF((ctf3=newtw)AND(what=3))OR((ctf3=newtw+20)AND(what=4))THEN PutCross(ctf3,129)ELSE PutCross(ctf3,128);
  IF what>2 THEN BEGIN
    IF(newtw=oldtw)AND(what<5)THEN EXIT;
    Mouse(2);
  END;
  IF(what>4)OR(what<3)THEN BEGIN
    BAR(50,385,249,439);
    IF ctf3<21 THEN st:=mapx^.tn[ctf3]
     ELSE BEGIN st:='';ID(st,ctf3-20);END;
    OutText(150,393,st,240,2,1.5);
    st:=TypeName(ctf3);
    OutBTxt(150-TRUNC(LENGTH(st)*4.5),420,st,245);
  END;
  IF(what=1)OR(what=3)OR(what=5)THEN BEGIN
    b1:=0;
    FOR b3:=1 TO mapx^.tc DO IF(b3<>mapx^.it)OR(mapx^.itst<>0)THEN BEGIN
      IF what=1 THEN BAR(50,b1*12+90,249,b1*12+100);
      IF b3=ctf3 THEN b2:=247 ELSE b2:=243;
      IF newtw=b1+1 THEN b2:=253;
      IF(what<>3)OR(newtw=b1+1)OR(oldtw=b1+1)THEN OutBTxt(150-ROUND(LENGTH(mapx^.tn[b3])*4.5),b1*12+91,mapx^.tn[b3],b2);
      IF newtw=b1+1 THEN b2:=129 ELSE b2:=0;
      IF(what<>3)OR(newtw=b1+1)OR(oldtw=b1+1)THEN PutCross(b3,b2);
      INC(b1);
    END;
  END ELSE FOR b3:=1 TO mapx^.fc DO BEGIN
    IF what=2 THEN BAR(50,(b3-1)*12+90,249,(b3-1)*12+100);
    STR(b3,s1);st:='';ID(st,b3);
    IF b3<10 THEN s1:='0'+s1;st:=s1+': '+st;
    IF b3+20=ctf3 THEN b2:=247 ELSE b2:=243;
    IF newtw=b3 THEN b2:=253;
    IF(what<>4)OR(newtw=b3)OR(oldtw=b3)THEN OutBTxt(150-ROUND(LENGTH(st)*4.5),(b3-1)*12+91,st,b2);
    IF b3=newtw THEN b2:=129 ELSE b2:=0;
    IF(what<>4)OR(newtw=b3)OR(oldtw=b3)THEN PutCross(b3+20,b2);
  END;
  IF what>2 THEN BEGIN Mouse(1);oldtw:=newtw;END;
END;
PROCEDURE ChooseCity(what:BYTE);
BEGIN
  Mouse(2);
  CopyPage(GetActivePage,1-(GetActivePage-2)+2);
  SetActivePage(1-(GetActivePage-2)+2);
  GrScr(TRUE);
  sts:=127-what;
  ctf3:=ctf2;
  ms.f:=0;
  oldtw:=0;
  newtw:=0;
  IF what=1 THEN st:='STADT' ELSE st:='INDUSTRIE';
  OutText(45,52,st+' WŽHLEN',240,4,1.5);
  IF what=1 THEN st:='NAME' ELSE st:='ID: BEZEICHNUNG';
  OutBTxt(150-ROUND(LENGTH(st)*4.5),78,st,250);
  SmallMap;
  Names(what);
  SetVisualPage(GetActivePage);
  Clickfield(cfeld OR 192);
  Mouse(1);
END;
PROCEDURE Headlines;
VAR y0:BYTE;st1:STRING[5];st2:STRING[2];
BEGIN
  active:=active AND NOT 128;
  FOR y0:=1 TO 4 DO BEGIN
    SETFILLSTYLE(1,238);
    BAR(80,WORD(y0)*80+45,559,WORD(y0)*80+72);
    BAR(269,WORD(y0)*80+74,370,WORD(y0)*80+84);
    OutText(320,WORD(y0)*80+49,news^[y0].st,240,6,2);
    STR((news^[y0].dt+4760)/100:0:2,st1);STR(news^[y0].ev,st2);
    IF LENGTH(st2)=1 THEN st2:='0'+st2;
    OutBTxt(271,WORD(y0)*80+75,st1+':'+st2+' ST',245);
  END;
END;
PROCEDURE ShowNews;
BEGIN
  Mouse(2);
  CopyPage(GetActivePage,1-(GetActivePage-2)+2);
  SetActivePage(1-(GetActivePage-2)+2);
  GrScr(TRUE);
  sts:=124;
  ms.f:=0;
  OutText(320,56,'GOLDENWORKS INFORMATION NETWORK NEWS',240,6,1.5);
  OutText(320,78,'AKTUELLE SCHLAGZEILEN FšR HI-ECO-LE',240,6,1.5);
  Headlines;
  SetVisualPage(GetActivePage);
  Clickfield(cfeld OR 128);
  Mouse(1);
END;
PROCEDURE Targets(what:BYTE);
VAR x0,y0,x1,y1:INTEGER;
BEGIN
  SETFILLSTYLE(1,238);
  IF(ms.x>49)AND(ms.x<250)THEN newtw:=(ms.y-90)DIV 12+1 ELSE newtw:=0;
  IF(ms.f=1)AND(ms.b=0)AND(newtw<=roads.a)AND(newtw>0)THEN BEGIN
    ctf3:=newtw;
    INC(what);
  END;
  IF what>1 THEN BEGIN
    IF(newtw=oldtw)AND(what<3)THEN EXIT;
    Mouse(2);
  END;
  IF(what>2)OR(what=1)THEN BEGIN
    IF road^.p1[roads.r[ctf3]]>20 THEN
     BEGIN x0:=mapx^.fx[road^.p1[roads.r[ctf3]]-20];y0:=mapx^.fy[road^.p1[roads.r[ctf3]]-20];END
     ELSE BEGIN x0:=mapx^.tx[road^.p1[roads.r[ctf3]]];y0:=mapx^.ty[road^.p1[roads.r[ctf3]]];END;
    IF road^.p2[roads.r[ctf3]]>20 THEN
     BEGIN x1:=mapx^.fx[road^.p2[roads.r[ctf3]]-20];y1:=mapx^.fy[road^.p2[roads.r[ctf3]]-20];END
     ELSE BEGIN x1:=mapx^.tx[road^.p2[roads.r[ctf3]]];y1:=mapx^.ty[road^.p2[roads.r[ctf3]]];END;
    trk.dis:=Entfernung(x0,y0,x1,y1)*4;
    IF road^.p1[roads.r[ctf3]]=town THEN BEGIN
      trk.sx:=x0;trk.sy:=y0;trk.tx:=x1;trk.ty:=y1;
    END ELSE BEGIN trk.sx:=x1;trk.sy:=y1;trk.tx:=x0;trk.ty:=y0;END;
    BAR(50,365,249,439);
    IF roads.t[ctf3]<21 THEN st:=mapx^.tn[roads.t[ctf3]]
     ELSE BEGIN st:='';ID(st,roads.t[ctf3]-20);END;
    OutText(150,373,st,240,2,1.5);
    IF roads.t[ctf3]<21 THEN BEGIN
      IF mapx^.tt[roads.t[ctf3]] AND 2=0 THEN BEGIN st:='RAUMHAFEN';
        IF mapx^.it=roads.t[ctf3] THEN st:='FREIE STADT' ELSE
         IF mapx^.tt[roads.t[ctf3]] AND 1=0 THEN st:='STADT';
      END ELSE st:='HAUPTSTADT';
    END ELSE BEGIN
      STR(ORD(mapx^.tn[1,2])+ORD(mapx^.tn[2,1])-128,s1);
      STR(roads.t[ctf3]-20,st);IF st[0]=#1 THEN st:='0'+st;IF s1[0]=#1 THEN s1:='0'+s1;
      st:='ID-NR. '+s1+'-'+st;
    END;
    OutBTxt(150-TRUNC(LENGTH(st)*4.5),400,st,245);
    STR(trk.dis,st);
    st:='ENTFERNUNG: '+st+' KM';
    OutBTxt(150-TRUNC(LENGTH(st)*4.5),420,st,245);
  END;
  FOR b3:=1 TO roads.a DO BEGIN
    IF what=1 THEN BAR(50,(b3-1)*12+90,249,(b3-1)*12+100);
    IF roads.t[b3]<21 THEN st:=mapx^.tn[roads.t[b3]]
     ELSE BEGIN STR(roads.t[b3]-20,s1);st:='';ID(st,roads.t[b3]-20);
      IF roads.t[b3]<30 THEN s1:='0'+s1;st:=s1+': '+st;
    END;
    IF b3=ctf3 THEN b2:=247 ELSE b2:=243;
    IF newtw=b3 THEN b2:=253;
    IF(what<>2)OR(newtw=b3)OR(oldtw=b3)THEN OutBTxt(150-ROUND(LENGTH(st)*4.5),(b3-1)*12+91,st,b2);
    IF(what<>2)OR(newtw=b3)OR(oldtw=b3)THEN BEGIN
      IF b3=ctf3 THEN b2:=247 ELSE b2:=244;
      IF b3=newtw THEN b2:=253;
      SETCOLOR(b2);
      IF road^.p1[roads.r[b3]]>20 THEN
       BEGIN x0:=mapx^.fx[road^.p1[roads.r[b3]]-20];y0:=mapx^.fy[road^.p1[roads.r[b3]]-20];END
       ELSE BEGIN x0:=mapx^.tx[road^.p1[roads.r[b3]]];y0:=mapx^.ty[road^.p1[roads.r[b3]]];END;
      IF road^.p2[roads.r[b3]]>20 THEN
       BEGIN x1:=mapx^.fx[road^.p2[roads.r[b3]]-20];y1:=mapx^.fy[road^.p2[roads.r[b3]]-20];END
       ELSE BEGIN x1:=mapx^.tx[road^.p2[roads.r[b3]]];y1:=mapx^.ty[road^.p2[roads.r[b3]]];END;
      LINE(TRUNC((x0-y0)/smapdivx)+smapaddx,TRUNC((x0+y0)/smapdivy)+smapaddy,
       TRUNC((x1-y1)/smapdivx)+smapaddx,TRUNC((x1+y1)/smapdivy)+smapaddy);
    END;
  END;
  IF what>1 THEN BEGIN Mouse(1);oldtw:=newtw;END;
END;
PROCEDURE ChooseTarget;
VAR x0,y0,x1,y1:INTEGER;
BEGIN
  roads.a:=0;
  FOR x0:=1 TO mapx^.tc DO FOR x1:=1 TO road^.sc DO IF((mapx^.itst<>0)OR
   ((road^.p1[x1]<>mapx^.it)AND(road^.p2[x1]<>mapx^.it)))AND
   (((road^.p1[x1]=town)AND(road^.p2[x1]=x0))OR
   ((road^.p2[x1]=town)AND(road^.p1[x1]=x0)))AND(roads.a<20)THEN BEGIN
    INC(roads.a);roads.t[roads.a]:=x0;roads.r[roads.a]:=x1;
  END;
  FOR x0:=21 TO mapx^.fc+20 DO FOR x1:=1 TO road^.sc DO IF((mapx^.itst<>0)OR
   ((road^.p1[x1]<>mapx^.it)AND(road^.p2[x1]<>mapx^.it)))AND
   (((road^.p1[x1]=town)AND(road^.p2[x1]=x0))OR
   ((road^.p2[x1]=town)AND(road^.p1[x1]=x0)))AND(roads.a<20)THEN BEGIN
    INC(roads.a);roads.t[roads.a]:=x0;roads.r[roads.a]:=x1;
  END;
  Mouse(2);
  x1:=GetActivePage;
  x0:=1-(x1-2)+2;
  CopyPage(x1,x0);
  SetActivePage(x0);
  GrScr(TRUE);
  sts:=1;
  ctf3:=1;
  ms.f:=0;
  oldtw:=0;
  newtw:=0;
  trk.px:=65535;
  OutText(45,52,'ZIELORT WŽHLEN',240,4,1.5);
  OutBTxt(69,78,'NAME / BEZEICHNUNG',250);
  SmallMap;
  Targets(1);
  SetVisualPage(x0);
  Clickfield((cfeld OR 62656)AND NOT 2104);
  Mouse(1);
END;
PROCEDURE TradeWare(what:BYTE);
VAR x0,y0:INTEGER;newcf:WORD;newpage:BYTE;
BEGIN
  Waren(town);
  newcf:=0;
  IF(ms.x>49)AND(ms.x<177)THEN newtw:=(ms.y-90)DIV 12+1 ELSE
   IF(ms.x>462)AND(ms.x<590)THEN newtw:=(ms.y-90)DIV 12+128 ELSE newtw:=0;
  IF(newtw<128)AND(newtw>26)THEN newtw:=0 ELSE IF newtw>153 THEN newtw:=0;
  IF(ms.f=1)AND(ms.b=0)AND(what=2)AND(newtw<>0)AND(newtw<>ctf3)THEN BEGIN ctf3:=newtw;what:=4;menge:=0;END;
  IF(what>1)AND(what<5)THEN BEGIN
    IF(what=2)AND(newtw=oldtw)THEN EXIT;
    Mouse(2);
  END;
  FOR y0:=0 TO 25 DO BEGIN
    IF(what=1)AND(ctf3=0)AND(ware[1]AND(LONGINT(1)SHL y0)>0)THEN ctf3:=y0+1;
    IF(what=1)AND(ctf3<128)AND(ware[2]AND(LONGINT(1)SHL y0)>0)AND(trk.c[y0]>0)THEN ctf3:=y0+128;
    IF what=1 THEN BEGIN
      BAR(50,y0*12+90,176,y0*12+100);
      BAR(463,y0*12+90,589,y0*12+100);
    END;
    st:=GetWare[y0];
    IF ware[1]AND(LONGINT(1)SHL y0)>0THEN x0:=254 ELSE x0:=252;
    IF(ctf3<128)AND(ctf3=y0+1)THEN x0:=247;
    IF(newtw<128)AND(newtw=y0+1)THEN x0:=253;
    OutBTxt(113-TRUNC(LENGTH(st)*4.5),y0*12+91,st,x0);
    IF(ware[2]AND(LONGINT(1)SHL y0)>0)AND(trk.c[y0]>0)THEN x0:=254 ELSE x0:=252;
    IF(ctf3>127)AND(ctf3=y0+128)THEN x0:=247;
    IF(newtw>127)AND(newtw=y0+128)THEN x0:=253;
    OutBTxt(526-TRUNC(LENGTH(st)*4.5),y0*12+91,st,x0);
  END;
  IF(what<>2)AND(what<>5)AND(what<>6)THEN BEGIN
    BAR(186,90,453,149);
    IF ctf3<128 THEN st:=GetWare[ctf3-1] ELSE st:=GetWare[ctf3-128];
    s1:='';
    IF ctf3<128 THEN BEGIN IF ware[1]AND(LONGINT(1)SHL(ctf3-1))>0THEN st:=st+' KAUFEN'
     ELSE s1:='- NICHT GEHANDELT -';
    END ELSE BEGIN IF(ware[2]AND(LONGINT(1)SHL(ctf3-128))>0)AND(trk.c[ctf3-128]>0)THEN st:=st+' VERKAUFEN'
     ELSE IF trk.c[ctf3-128]>0 THEN s1:='- NICHT GEHANDELT -' ELSE s1:='- NICHT GELADEN -';
    END;
    IF s1='' THEN BEGIN newcf:=(cfeld OR 60856)AND NOT 4096;
      IF ctf3<128 THEN x0:=1 ELSE x0:=128;
      IF town<21THEN sgl:=mapx^.pr[town,ctf3-x0]ELSE sgl:=GetPrice[ctf3-x0];
      IF ctf3>127THEN IF town<21THEN sgl:=sgl*(0.98-mapx^.gs[ctf2]/10000)ELSE sgl:=sgl*1.1;
      STR(sgl:0:2,s1);Dot2Comma(s1);s1:=s1+pdol;
      s1:='PREIS: '+s1;
    END ELSE BEGIN sgl:=0;newcf:=(cfeld OR 60800)AND NOT 4216;END;
    OutText(320,99,st,240,2,1.5);
    OutBTxt(320-TRUNC(LENGTH(s1)*4.5),128,s1,245);
  END;
  IF(what=1)OR(what=5)OR(what=4)THEN BEGIN
    newpage:=1-(GetActivePage-2)+2;
    CopyPage(GetActivePage,newpage);
    SetActivePage(newpage);
    BAR(186,210,453,284);
    OutBTxt(227,220,'MENGE:',245);
    OutBTxt(236,235,'SOLL:',245);
    IF sgl>0 THEN BEGIN
      IF ctf3<128 THEN s1:='- KOSTEN:' ELSE s1:='+ GEWINN:';
      OutBTxt(200,250,s1,245);
    END;
    OutBTxt(200,265,'=  HABEN:',245);
    STR(menge,st);
    OutBTxt(412-LENGTH(st)*9,220,st+tradeunits,245);
    active:=active AND NOT 64;
    STR(geld:0:2,st);Dot2Comma(st);
    OutBTxt(412-LENGTH(st)*9,235,st+pdol,245);
    IF sgl>0 THEN BEGIN
      STR(menge*sgl:0:2,st);Dot2Comma(st);
      OutBTxt(412-LENGTH(st)*9,250,st+pdol,245);
    END;
    IF ctf3<128 THEN STR(geld-menge*sgl:0:2,st)ELSE STR(geld+menge*sgl:0:2,st);
    Dot2Comma(st);
    OutBTxt(412-LENGTH(st)*9,265,st+pdol,245);
    SetVisualPage(newpage);
  END;
  IF(what=1)OR(what=6)THEN BEGIN
    BAR(186,341,453,400);
    STR(trk.m,s1);
    STR(trk.f,st);
    s1:='GESAMT: '+s1+tradeunits;
    st:='FREI: '+st+tradeunits;
    OutText(320,350,st,240,2,1.5);
    OutBTxt(320-TRUNC(LENGTH(s1)*4.5),379,s1,245);
  END;
  IF newcf<>0 THEN ClickField(newcf);
  IF((what=2)AND(newtw<>oldtw))OR((what>2)AND(what<5))THEN BEGIN
    Mouse(1);
    oldtw:=newtw;
  END;
END;
PROCEDURE Trader;
VAR wo0:WORD;
BEGIN
  SETFILLSTYLE(1,238);
  menge:=0;
  sts:=2;
  Mouse(2);
  CopyPage(GetActivePage,1-(GetActivePage-2)+2);
  SetActivePage(1-(GetActivePage-2)+2);
  GrScr(TRUE);
  ctf3:=0;
  oldtw:=0;
  newtw:=0;
  OutText(45,52,'HŽNDLER',240,4,1.5);
  OutBTxt(90,78,'LAGER',250);
  OutBTxt(503,78,'TRUCK',250);
  OutBTxt(261,78,'INFORMATIONEN',250);
  OutBTxt(284,198,'RECHNUNG',250);
  OutBTxt(280,329,'FRACHTRAUM',250);
  SetVisualPage(GetActivePage);
  TradeWare(1);
  Mouse(1);
END;
PROCEDURE ContractView(what:BYTE);
BEGIN
  active:=active AND NOT 128;
  IF what<3 THEN BEGIN
    IF(ctf3=0)OR(vertr^[ctf3].s=128)OR(vertr^[ctf3].t=0)OR(vertr^[ctf3].db>127)
     OR(stime.gt*100+stime.ev>vertr^[ctf3].gd*100+vertr^[ctf3].ev)THEN ctf3:=1;
    WHILE((vertr^[ctf3].s=128)OR(vertr^[ctf3].t=0)OR(vertr^[ctf3].db>127))AND(ctf3<21)DO INC(ctf3);
    IF ctf3=21 THEN ctf3:=0;
  END;
  IF what>2 THEN ctf3:=newcrt;
  IF(ctf3<>0)AND(vertr^[ctf3].s=newtw)AND(vertr^[ctf3].t=oldtw)
   AND(wo0=vertr^[ctf3].db)AND(menge=vertr^[ctf3].co)THEN EXIT;
  IF(what=2)OR(what=4)THEN Mouse(2);
  BAR(50,110,267,339);
  IF ctf3=0 THEN BEGIN OutBTxt(136,214,'KEINE',244);OutBTxt(123,226,'AUFTRŽGE',244);
    IF what<3 THEN BEGIN
      FOR b1:=1 TO 40 DO PutCross(b1,0);
      SmallMap;
    END;
    ClickField((cfeld OR 48512)AND NOT 16504);
    IF(what=2)OR(what=4)THEN Mouse(1);EXIT;END;
  IF(vertr^[ctf3].s<>0)AND(vertr^[ctf3].t<>128)THEN st:='TRANSPORT'ELSE
   IF vertr^[ctf3].t=128THEN st:='TRUCK-UMBAU'ELSE st:='ERWERB';
  OutBTxt(55,130,'TYP:',244);
  OutBTxt(263-LENGTH(st)*9,130,st,247);
  s1:='';
  IF(vertr^[ctf3].s<>0)AND(vertr^[ctf3].t<>128)THEN BEGIN st:='VON:';s1:='NACH:';END ELSE
   IF vertr^[ctf3].t=128 THEN BEGIN st:='IN:';
  END ELSE st:='FšR:';
  OutBTxt(55,166,st,244);OutBTxt(55,202,s1,244);
  IF vertr^[ctf3].s<>0THEN BEGIN
    IF vertr^[ctf3].s<21THEN BEGIN st:=mapx^.tn[vertr^[ctf3].s];b1:=254;END
     ELSE BEGIN st:='';ID(st,vertr^[ctf3].s-20);b1:=252;END;
    OutBTxt(263-LENGTH(st)*9,166,st,255);
    st:=TypeName(vertr^[ctf3].s);
    OutBTxt(263-LENGTH(st)*9,178,st,b1);
  END;
  IF vertr^[ctf3].t<>128 THEN BEGIN
    IF vertr^[ctf3].t<21 THEN BEGIN st:=mapx^.tn[vertr^[ctf3].t];b2:=254;END
     ELSE BEGIN st:='';ID(st,vertr^[ctf3].t-20);b2:=252;END;
    IF vertr^[ctf3].s<>0 THEN b1:=202 ELSE b1:=166;
    OutBTxt(263-LENGTH(st)*9,b1,st,253);
    st:=TypeName(vertr^[ctf3].t);
    OutBTxt(263-LENGTH(st)*9,b1+12,st,b2);
    OutBTxt(55,b1+36,'WARE:',244);
    OutBTxt(263-LENGTH(GetWare[vertr^[ctf3].db AND NOT 128])*9,b1+36,GetWare[vertr^[ctf3].db AND NOT 128],247);
    OutBTxt(55,b1+60,'ANZAHL:',244);STR(vertr^[ctf3].co,st);st:=st+tradeunits;
    OutBTxt(263-LENGTH(st)*9,b1+60,st,247);
    OutBTxt(55,b1+84,'BEZAHLUNG:',244);STR(vertr^[ctf3].pr/1:0:2,st);Dot2Comma(st);
    st:=st+pdol;OutBTxt(263-LENGTH(st)*9,b1+84,st,247);
    OutBTxt(55,b1+108,'ZEITGRENZE:',244);
    STR((vertr^[ctf3].gd+4760)/100:0:2,st);
    STR(vertr^[ctf3].ev,s1);IF s1[0]=#1THEN s1:='0'+s1;
    st:=st+':'+s1+' ST';
    OutBTxt(263-LENGTH(st)*9,b1+108,st,247);
  END ELSE BEGIN
    OutBTxt(55,202,'FRACHTRAUM:',244);
    STR(vertr^[ctf3].co:3,st);
    st:='+ '+st+tradeunits;
    OutBTxt(263-LENGTH(st)*9,202,st,247);
    STR(trk.m+vertr^[ctf3].co:3,st);
    st:='= '+st+tradeunits;
    OutBTxt(263-LENGTH(st)*9,214,st,247);
    OutBTxt(55,238,'KOSTEN:',244);STR(vertr^[ctf3].pr/1:0:2,st);Dot2Comma(st);
    st:=st+pdol;OutBTxt(263-LENGTH(st)*9,238,st,247);
    OutBTxt(55,262,'ZEITGRENZE:',244);
    STR((vertr^[ctf3].gd+4760)/100:0:2,st);
    STR(vertr^[ctf3].ev,s1);IF s1[0]=#1THEN s1:='0'+s1;
    st:=st+':'+s1+' ST';
    OutBTxt(263-LENGTH(st)*9,262,st,247);
  END;
  IF what<3 THEN BEGIN
    FOR b3:=1 TO 20 DO IF(b3<>mapx^.it)OR(mapx^.itst<>0)THEN BEGIN
      IF vertr^[ctf3].s=b3 THEN b2:=128 ELSE b2:=0;
      IF vertr^[ctf3].t=b3 THEN b2:=129;
      PutCross(b3,b2);
    END;
    FOR b3:=1 TO 20 DO BEGIN
      IF vertr^[ctf3].s=b3+20 THEN b2:=128 ELSE b2:=0;
      PutCross(b3+20,b2);
    END;
  END;
  IF what<=2 THEN ClickField((cfeld OR 48624)AND NOT 16392);
  IF(what=2)OR(what=4)THEN Mouse(1);
  newtw:=vertr^[ctf3].s;oldtw:=vertr^[ctf3].t;
  wo0:=vertr^[ctf3].db;menge:=vertr^[ctf3].co;
END;
PROCEDURE Contracts;
BEGIN
  SETFILLSTYLE(1,238);
  newtw:=0;
  oldtw:=0;
  ctf3:=0;
  Mouse(2);
  b2:=0;
  FOR b1:=1 TO 20 DO IF vertr^[b1].db AND 128=128 THEN BEGIN
    IF(vertr^[b1].s=town)AND(vertr^[b1].t<>128)AND(trk.f>0)AND(vertr^[b1].co>0)THEN b2:=b2 OR 1;
    IF(vertr^[b1].t=town)AND(((vertr^[b1].s=0)AND(trk.c[vertr^[b1].db-128]>0))
     OR(vertr^[b1].cc>0))THEN b2:=b2 OR 2;
    IF(vertr^[b1].s=town)AND(vertr^[b1].t=128)AND(vertr^[b1].pr<=geld)THEN b2:=b2 OR 4;
  END;
  IF b2=0 THEN BEGIN
    CopyPage(GetActivePage,1-(GetActivePage-2)+2);
    SetActivePage(1-(GetActivePage-2)+2);
    GrScr(TRUE);
    sts:=4;
  END ELSE BEGIN
    CopyPage(GetActivePage,1-(GetActivePage-2)+2);
    SetActivePage(1-(GetActivePage-2)+2);
    GrScr(FALSE);
    sts:=6;
    CASE b2 OF 1:st:='BELADEN';
      2:st:='ENTLADEN';
      3:st:='BE- ODER ENTLADEN';
      4:st:='ERWEITERN';
      5:st:='BELADEN ODER ERWEITERN';
      6:st:='ENTLADEN ODER ERWEITERN';
      7:st:='BE-, ENTLADEN ODER ERWEITERN';
    END;
    GrBar(40,410,599,449,'TRUCK '+st);
  END;
  OutText(45,52,'AUFTRAGSANGEBOTE',240,4,1.5);
  SmallMap;
  SetVisualPage(GetActivePage);
  ContractView(1);
  Mouse(1);
END;
PROCEDURE ContractList;
VAR by0:BYTE;wo1:WORD;
BEGIN
  SETCOLOR(243);
  OutBTxt(424,100,'VERTRŽGE',250);
  SETCOLOR(243);
  FOR by0:=0 TO 5 DO RECTANGLE(331,111+by0*51,588,160+by0*51);
  wo1:=0;
  FOR b1:=1TO 20DO IF(l1 AND (LONGINT(1)SHL b1)>0)AND(wo1<6)THEN BEGIN
    BAR(332,112+wo1*51,587,159+wo1*51);
    IF vertr^[b1].t<>128 THEN st:=GetWare[vertr^[b1].db-128]ELSE BEGIN st:='UMBAU';s1:='IN';END;
    IF vertr^[b1].s=0 THEN s1:='FšR' ELSE IF vertr^[b1].t<>128 THEN s1:='VON';
    st:=st+' '+s1+' ';
    IF vertr^[b1].s<>0 THEN BEGIN
      IF vertr^[b1].s<21 THEN s1:=mapx^.tn[vertr^[b1].s]ELSE s1:=TypeName(vertr^[b1].s);
    END ELSE s1:=mapx^.tn[vertr^[b1].t];
    st:=st+s1;
    IF(vertr^[b1].s<>0)AND(vertr^[b1].t<>128)THEN st:=st+' NACH '+mapx^.tn[vertr^[b1].t];
    STR((vertr^[b1].gd+4760)/100:0:2,s1);
    st:=st+' BIS '+s1+':';
    STR(vertr^[b1].ev,s1);IF s1[0]=#1THEN s1:='0'+s1;
    st:=st+s1+' ST (';
    STR(vertr^[b1].pr,s1);
    st:=st+s1+pdol+') ';
    by0:=0;
    REPEAT b2:=28;
      IF LENGTH(st)>28 THEN WHILE st[b2]<>' 'DO DEC(b2);
      s1:=COPY(st,1,b2-1);st:=COPY(st,b2+1,LENGTH(st)-b2);
      OutBTxt(334,113+wo1*51+by0*12,s1,247);
      INC(by0);
    UNTIL st='';b2:=LENGTH(s1);
    STR(vertr^[b1].cc,st);STR(vertr^[b1].co,s1);
    IF vertr^[b1].t=128 THEN st:='+'+s1
     ELSE IF vertr^[b1].s=0 THEN st:='<'+s1+'>'
     ELSE st:=st+'/'+s1;
    OutBTxt(586-LENGTH(st)*9,113+wo1*51+36,st,254);
    IF b1=newcrt THEN BEGIN
      oldcrt:=b1;
      BAR(50,365,267,416);
      IF(newtw<>0)AND(oldtw<>128)THEN BEGIN
        IF(newtw=town)AND(menge>0)THEN BEGIN
          IF menge>trk.f THEN menge:=trk.f;
          STR(menge,st);
          st:='TRUCK MIT '+st+tradeunits+' BELADEN';
        END ELSE IF(oldtw=town)AND(vertr^[oldcrt].cc>0)THEN BEGIN
          STR(vertr^[oldcrt].cc,st);
          st:=st+tradeunits+' VOM TRUCK LADEN';
        END;
      END ELSE IF newtw=0 THEN BEGIN
        menge:=trk.c[vertr^[oldcrt].db-128];
        IF menge>vertr^[oldcrt].co THEN menge:=vertr^[oldcrt].co;
        STR(menge,st);
        st:=st+tradeunits+' VOM TRUCK LADEN';
      END ELSE IF oldtw=128 THEN BEGIN
        IF geld<vertr^[oldcrt].pr THEN BEGIN
          menge:=0;
          st:='ZU WENIG GELD';
        END ELSE st:='TRUCK AUSBAUEN';
      END;
      OutText(159,380,st,240,2,1.5);
    END;
    INC(wo1);
  END;
END;
PROCEDURE ContractPass;
VAR wo0:WORD;
BEGIN
  SETFILLSTYLE(1,238);
  menge:=0;
  sts:=7;
  Mouse(2);
  CopyPage(GetActivePage,1-(GetActivePage-2)+2);
  SetActivePage(1-(GetActivePage-2)+2);
  GrScr(TRUE);
  BAR(330,110,589,416);
  ctf3:=1;
  WHILE((vertr^[ctf3].s<>town)AND(vertr^[ctf3].t<>town))OR(vertr^[ctf3].db<128)AND(ctf3<21)DO INC(ctf3);
  l1:=0;
  newcrt:=0;
  oldcrt:=0;
  IF ctf3=21 THEN ctf3:=0
   ELSE FOR wo0:=ctf3 TO 20 DO IF vertr^[wo0].db AND 128=128 THEN BEGIN
    IF((vertr^[wo0].s=town)AND(((vertr^[wo0].t<>128)AND(trk.f>0)AND(vertr^[wo0].co>0))
    OR((vertr^[wo0].t=128)AND(vertr^[wo0].pr<=geld))))
    OR((vertr^[wo0].t=town)AND(((vertr^[wo0].s=0)AND(trk.c[vertr^[wo0].db-128]>0))
    OR(vertr^[wo0].cc>0)))THEN BEGIN
      INC(l1,ROUND(EXP(LN(2)*wo0)));
      IF newcrt=0 THEN newcrt:=wo0;
    END;
  END;
  OutText(45,52,'TRUCK-OPTIONEN',240,4,1.5);
  ContractView(3);
  ContractList;
  SetVisualPage(GetActivePage);
  ClickField(cfeld OR 112);
  Mouse(1);
END;
PROCEDURE LoadTruck;
BEGIN
  FILLCHAR(roads,SIZEOF(roads),0);
  FOR b1:=1 TO 20 DO IF(vertr^[b1].s=town)OR((vertr^[b1].t=town)AND(vertr^[b1].cc<>0))
   THEN BEGIN INC(roads.a);roads.r[roads.a]:=b1;END;
  IF roads.a=0THEN Truck(1)ELSE BEGIN
    SETFILLSTYLE(1,238);
    newtw:=0;
    oldtw:=0;
    ctf3:=0;
    sts:=5;
  END;
END;
VAR mappage:BYTE;poi0,poi1:point;
BEGIN
  trk.dis:=0;
  active:=active OR 16;
  Mouse(2);
  active:=(active OR 1)AND NOT 2;
  mappage:=GetActivePage;
  ClickField(0);
  City;
  ctf2:=town;
  Mouse(1);
  active:=active AND NOT 16;
  REPEAT Mouse(3);
    CASE oldtrack OF 0:IF active AND 7=6 THEN music:=3 ELSE music:=5;
      5:IF active AND 4=0 THEN music:=5 ELSE
       IF active AND 3=2 THEN music:=3 ELSE music:=1;
      1,2:IF active AND 3=2 THEN music:=3 ELSE music:=2;
      3,4:music:=2;
    END;
    IF ttime>49 THEN BEGIN
      IF Timing AND((sts=4)OR(sts=6)OR(sts=1)OR(sts=126)OR(sts=125))THEN BEGIN
        Mouse(2);
        FOR b1:=1 TO 40 DO PutCross(b1,0);
        SmallMap;
        Mouse(1);
      END;
      IF((sts=4)OR(sts=6)OR(sts=7))AND(active AND 128=128)THEN ContractView(2+sts DIV 7*2);
      IF(sts=3)AND(active AND 128=128)THEN Truck(3);
      IF(sts=124)AND(active AND 128=128)THEN Headlines;
    END;
    cf:=ClickedField;
    CASE sts OF 255:Prices(TRUE);
      254:ChooseTarget;
      253:Prices(FALSE);
      252:Trader;
      251:BEGIN TradeWare(3);sts:=2;END;
      250:Contracts;
      249:ContractPass;
    END;
    IF active AND 64=64 THEN BEGIN
      IF sts=2 THEN BEGIN
        Mouse(2);
        WHILE(geld-menge*sgl<0)AND(menge>0)DO DEC(menge);
        TradeWare(5);
        IF menge=0 THEN ClickField(cfeld AND NOT 64)
         ELSE ClickField(cfeld OR 64);
        Mouse(1);
      END;
      IF sts=3 THEN Truck(2);
    END;
    IF(sts=2)AND((cf=19)OR(cf=20)OR(cf=21)OR(cf=22)OR(cf=35)OR(cf=36)OR(cf=37)OR(cf=38))THEN BEGIN
      IF cf=20THEN INC(menge)ELSE IF cf=36THEN INC(menge,5);
      IF cf=21THEN DEC(menge)ELSE IF cf=37THEN DEC(menge,5);
      IF cf=19THEN menge:=255;
      IF ctf3<128 THEN WHILE((geld-menge*sgl<0)OR(menge>trk.f))AND(menge>0)DO DEC(menge)
       ELSE WHILE menge>trk.c[ctf3-128]DO DEC(menge);
      IF(menge<0)OR(cf=35)THEN menge:=0;
      IF(cf=22)OR(cf=38)THEN BEGIN
        IF ctf3<128 THEN BEGIN geld:=geld-menge*sgl;
          INC(trk.c[ctf3-1],menge);
          DEC(trk.f,menge);
        END ELSE BEGIN geld:=geld+menge*sgl;
          DEC(trk.c[ctf3-128],menge);
          INC(trk.f,menge);
        END;
        ctf3:=0;menge:=0;ms.f:=0;ms.b:=0;
        Mouse(2);TradeWare(1);Mouse(1);
      END ELSE BEGIN
        Mouse(2);
        TradeWare(5);
        IF menge=0 THEN ClickField(cfeld AND NOT 64)
         ELSE ClickField(cfeld OR 64);
        Mouse(1);
      END;
    END;
    IF(sts=7)AND((cf=20)OR(cf=21)OR(cf=36)OR(cf=37))THEN BEGIN
      IF(cf=20)OR(cf=36)THEN BEGIN
        REPEAT INC(newcrt);
          IF newcrt>20 THEN newcrt:=1;
        UNTIL l1 AND ROUND(EXP(LN(2)*newcrt))>0;
        ContractView(4);
      END ELSE BEGIN
        REPEAT DEC(newcrt);
          IF newcrt<1 THEN newcrt:=20;
        UNTIL l1 AND ROUND(EXP(LN(2)*newcrt))>0;
        ContractView(4);
      END;
      ContractList;
    END ELSE IF(sts=7)AND((cf=22)OR(cf=38))THEN BEGIN
      IF(newtw<>0)AND(oldtw<>128)THEN BEGIN
        IF(newtw=town)AND(menge>0)THEN BEGIN
          INC(vertr^[oldcrt].cc,menge);
          DEC(vertr^[oldcrt].co,menge);
          DEC(trk.f,menge);
          sts:=250;
        END ELSE IF(oldtw=town)AND(vertr^[oldcrt].cc>0)THEN BEGIN
          INC(trk.f,vertr^[oldcrt].cc);
          vertr^[oldcrt].cc:=0;
          IF vertr^[oldcrt].co=0 THEN BEGIN
            vertr^[oldcrt].s:=0;
            vertr^[oldcrt].t:=0;
            vertr^[oldcrt].db:=0;
            geld:=geld+vertr^[oldcrt].pr;
          END;
          sts:=250;
        END;
      END ELSE IF(newtw=0)AND(menge>0)THEN BEGIN
        DEC(vertr^[oldcrt].co,menge);
        DEC(trk.c[vertr^[oldcrt].db-128],menge);
        INC(trk.f,menge);
        IF vertr^[oldcrt].co=0 THEN BEGIN
          vertr^[oldcrt].s:=0;
          vertr^[oldcrt].t:=0;
          vertr^[oldcrt].db:=0;
          geld:=geld+vertr^[oldcrt].pr;
        END;
        sts:=250;
      END ELSE IF(oldtw=128)AND(geld>=vertr^[oldcrt].pr)THEN BEGIN
        geld:=geld-vertr^[oldcrt].pr;
        INC(trk.f,menge);
        INC(trk.m,menge);
        vertr^[oldcrt].s:=0;
        vertr^[oldcrt].t:=0;
        vertr^[oldcrt].db:=0;
        sts:=250;
      END;
    END;
    IF((sts=4)OR(sts=6))AND(((cf>19)AND(cf<23))OR((cf>35)AND(cf<39)))THEN BEGIN
      IF(cf=20)OR(cf=36)THEN REPEAT IF ctf3=20 THEN ctf3:=1 ELSE INC(ctf3);
      UNTIL(vertr^[ctf3].s<>128)AND(vertr^[ctf3].t<>0)AND(vertr^[ctf3].db<128);
      IF(cf=21)OR(cf=37)THEN REPEAT IF ctf3=1 THEN ctf3:=20 ELSE DEC(ctf3);
      UNTIL(vertr^[ctf3].s<>128)AND(vertr^[ctf3].t<>0)AND(vertr^[ctf3].db<128);
      IF cf=22 THEN vertr^[ctf3].db:=vertr^[ctf3].db OR 128;
      IF(cf=22)AND((vertr^[ctf3].s=town)OR(vertr^[ctf3].t=town))THEN sts:=250
       ELSE ContractView(2);
    END;
    IF(sts=3)AND(cf=21)THEN Truck(4);
    IF(sts=3)AND(cf=20)THEN Truck(5);
    IF cf=42THEN BEGIN scrollpos:=0;LoadTruck;END;
    IF cf=26THEN BEGIN scrollpos:=0;Truck(1);END;
    IF(cf=30)OR(cf=46)THEN sts:=250;
    IF(cf=22)OR(cf=38)THEN CASE sts OF
      125,126:BEGIN ctf2:=ctf3;sts:=255;END;
      1:BEGIN active:=(active OR 2)AND NOT 1;
        town:=roads.t[ctf3];
        trk.pos:=0;
        geld:=geld-trk.dis DIV(250 DIV trk.m)-5;
      END;
    END;
    IF(sts=127)AND Click(40,410,219,449,7)THEN ChooseCity(1);
    IF(sts=127)AND Click(220,410,399,449,7)THEN ChooseCity(2);
    IF(sts=127)AND Click(400,410,599,449,7)THEN ShowNews;
    IF(sts=6)AND Click(40,410,599,449,7)THEN sts:=249;
    IF sts=1 THEN Targets(2);
    IF sts=126 THEN Names(3);
    IF sts=125 THEN Names(4);
    IF sts=2 THEN BEGIN
      TradeWare(2);
      IF(menge=0)AND(cfeld AND 64=64)THEN BEGIN
        Mouse(2);
        Clickfield(cfeld AND NOT 64);
        Mouse(1);
      END;
    END;
    IF active AND 32=32 THEN BEGIN active:=active AND NOT 32;
      CASE sts OF 127:sts:=253;
        2:sts:=251;
      END;
    END;
    IF(cf=29)OR(cf=45)THEN sts:=255;
    IF(cf=27)OR(cf=43)THEN sts:=254;
    IF(cf=28)OR(cf=44)THEN sts:=252;
    IF(cf=23)OR(cf=39)THEN IF(sts=127)OR((sts>0)AND(sts<5))OR(sts=6)THEN BEGIN
      Mouse(2);
      FOR b1:=0 TO 3 DO BEGIN
        XMS_2_RAM(page,xms[17+b1],64004);
        FOR wo0:=0 TO 49 DO BEGIN
          PUTIMAGE(40,wo0*2+50+b1*100,page^[wo0*1128],0);
          PUTIMAGE(40,449-wo0*2-b1*100,page^[wo0*1128+564],0);
        END;
      END;
      ClickField(64768);Mouse(1);sts:=0;
    END ELSE IF(sts>123)AND(sts<127)THEN sts:=255 ELSE IF sts=7 THEN sts:=250;
    IF(cf=31)OR(cf=47)THEN BEGIN
      MOUSE(2);
      active:=active OR 16;
      ClickField(cfeld AND NOT 32768);
      active:=active XOR 1;
      ClickField(cfeld OR 32768);
      MOUSE(1);
      active:=active AND NOT 16;
    END;
  UNTIL(cf=24)OR(cf=40)OR(active AND 2=2)OR(geld<min_geld)OR(geld>=max_geld)OR(death);
  Mouse(2);
  ClickField(0);
  OutPic(pal,4,0,255);
  SetActivePage(mappage);
  SetVisualPage(mappage);
  MapPal;
  IF ctf2>20 THEN BEGIN poi0.x:=mapx^.fx[ctf2-20];poi0.y:=mapx^.fy[ctf2-20];END
   ELSE BEGIN poi0.x:=mapx^.tx[ctf2];poi0.y:=mapx^.ty[ctf2];END;
  IF town>20 THEN BEGIN poi1.x:=mapx^.fx[town-20];poi1.y:=mapx^.fy[town-20];END
   ELSE BEGIN poi1.x:=mapx^.tx[town];poi1.y:=mapx^.ty[town];END;
  DEC(poi0.x,3);DEC(poi0.y,3);
  DEC(ctf2,3);DEC(ctf3,3);
  ctf2:=(poi0.x+poi1.x)DIV 2;
  ctf3:=(poi0.y+poi1.y)DIV 2;
  MapXY2ScrXY(poi0.x,poi0.y,poi0);
  MapXY2ScrXY(poi1.x,poi1.y,poi1);
  {STR(poi0.x,st);
  OutBTxt(40,5,st,255);
  STR(poi0.y,st);
  OutBTxt(100,5,st,255);
  STR(poi1.x,st);
  OutBTxt(40,20,st,255);
  STR(poi1.y,st);
  OutBTxt(100,20,st,255);}
  IF(poi0.x<20)OR(poi0.x>=GETMAXX-20)OR(poi0.y<20)OR(poi0.y>=GETMAXY-20)OR
   (poi1.x<20)OR(poi1.x>=GETMAXX-20)OR(poi1.y<20)OR(poi1.y>=GETMAXY-20)THEN BEGIN
    xp:=ctf2;yp:=ctf3;
    IF town>20 THEN BEGIN ctf2:=mapx^.fx[town-20];ctf3:=mapx^.fy[town-20];END
     ELSE BEGIN ctf2:=mapx^.tx[town];ctf3:=mapx^.ty[town];END;
    MapXY2ScrXY(ctf2,ctf3,poi0);
    WHILE(poi0.x<20)OR(poi0.y>=GETMAXX-20)OR(poi0.y<20)OR(poi0.y>=GETMAXY-20)DO BEGIN
      INC(zoom,zoom);
      MapXY2ScrXY(ctf2,ctf3,poi0);
    END;
    zoom:=zoom OR 128;
  END ELSE BEGIN
    GetCFOriginals(FALSE);
    IF zoom=16 THEN wo0:=33297 ELSE IF zoom=1 THEN wo0:=33313 ELSE wo0:=33329;
    IF active AND 2=2 THEN wo0:=wo0 AND NOT 512;
    ClickField(wo0);
  END;
  ms.b:=0;
  Mouse(1);
END;
PROCEDURE PoV;
VAR pln:INTEGER;m:SINGLE;
    xz,yz,percent:SINGLE;
    p1,p2:point;
    backgr,ico:truckbackground;
BEGIN
  IF(trk.pos>trk.dis)OR(active AND 2=0)THEN EXIT;
  percent:=trk.pos/trk.dis;
  xz:=INTEGER(trk.tx-trk.sx)*percent+trk.sx;
  yz:=INTEGER(trk.ty-trk.sy)*percent+trk.sy;
  p1.x:=TRUNC((xz-xp-yz+yp)*20+GETMAXX DIV 2*zoom)DIV zoom;
  p1.y:=TRUNC((yz-yp+xz-xp)*10+GETMAXY DIV 2*zoom-map[0]^[ROUND(xz),ROUND(yz)])DIV zoom;
  IF trk.px<>65535 THEN BEGIN
    WaitRetrace;
    Mouse(2);
    PutImage(trk.px-10,trk.py-10,trk.backgr,0);
    Mouse(1);
  END;
  trk.px:=p1.x;trk.py:=p1.y;
  Mouse(2);GetImage(p1.x-10,p1.y-10,p1.x+9,p1.y+9,backgr);Mouse(1);
  trk.backgr:=backgr;
  IF percent<1 THEN BEGIN
    {FOR p2.y:=0 TO 19 DO FOR p2.x:=0 TO 19 DO BEGIN
      p1.x:=ABS(p2.x-10);p1.y:=ABS(p2.y-10);
      IF((p1.x<9)AND(p1.y<10))OR((p1.x<10)AND(p1.y<9))
       THEN backgr.c[p2.x,p2.y]:=zpal[backgr.c[p2.x,p2.y]];
    END;}
    FOR p2.y:=0 TO 4 DO FOR p2.x:=0 TO ROUND(COS(p2.y/10*Pi)*4) DO BEGIN
      backgr.c[9-p2.x,9-p2.y]:=zpal[backgr.c[9-p2.x,9-p2.y]];
      backgr.c[10+p2.x,9-p2.y]:=zpal[backgr.c[10+p2.x,9-p2.y]];
      backgr.c[9-p2.x,10+p2.y]:=zpal[backgr.c[9-p2.x,10+p2.y]];
      backgr.c[10+p2.x,10+p2.y]:=zpal[backgr.c[10+p2.x,10+p2.y]];
    END;
    FOR b1:=0 TO 4 DO
     FOR p2.y:=0 TO b1 DO FOR p2.x:=0 TO ROUND(COS(p2.y/((b1+1)*2)*Pi)*b1) DO BEGIN
      INC(backgr.c[9-p2.x,9-p2.y],2);
      INC(backgr.c[10+p2.x,9-p2.y],2);
      INC(backgr.c[9-p2.x,10+p2.y],2);
      INC(backgr.c[10+p2.x,10+p2.y],2);
    END;
    {MOVE(icon^[8],ico.c,400);
    FOR p2.y:=0 TO 19 DO FOR p2.x:=0 TO 19 DO
     IF(ico.c[p2.y,p2.x]<>0)AND(ico.c[p2.y,p2.x]>backgr.c[p2.x,p2.y])THEN
     backgr.c[p2.x,p2.y]:=ico.c[p2.y,p2.x];}
    Mouse(2);PutImage(trk.px-10,trk.py-10,backgr,0);Mouse(1);
  END;
END;
PROCEDURE RenderMap(tof:BOOLEAN);
CONST actualvalue1:SINGLE=64.1024;
      actualvalue2:SINGLE=128.512;
      width=9920;
      heigth=5256;
      {width=640;
      heigth=480;}
VAR actualxmspage:BYTE;
    bmpf:FILE;
    mapline:ARRAY[0..9999]OF BYTE;
FUNCTION NextValue1:SINGLE;
BEGIN
  IF actualvalue1<10249.21939 THEN actualvalue1:=actualvalue1*4.2183
   ELSE actualvalue1:=actualvalue1/44.183;
  NextValue1:=FRAC(actualvalue1);
END;
FUNCTION NextValue2:SINGLE;
BEGIN
  IF actualvalue2<200249.2939 THEN actualvalue2:=actualvalue2*4.2183
   ELSE actualvalue2:=actualvalue2/44.183;
  NextValue2:=FRAC(actualvalue2)*2;
END;
PROCEDURE GradientLine(x1,y1,x2,y2:INTEGER;col0,col1,typ0,typ1:BYTE);
VAR xz,yz,wx,p,smaller:INTEGER;xe,col,typ,xmspage,ye:BYTE;pln:WORD;m,perc:SINGLE;
BEGIN
  xz:=x2-x1;yz:=y2-y1;
  IF ABS(xz)<ABS(yz) THEN BEGIN
    m:=xz/yz;
    IF y1>y2 THEN BEGIN yz:=y1;y1:=y2;y2:=yz;xz:=x1;x1:=x2;x2:=xz;
      xe:=col0;col0:=col1;col1:=xe;xe:=typ0;typ0:=typ1;typ1:=xe;
      IF x1<x2 THEN smaller:=x1 ELSE smaller:=x2;END;
    FOR yz:=y1 TO y2 DO IF (yz>=trng.y1) AND (yz<=trng.y2) THEN BEGIN
      xz:=TRUNC(m*(yz-y1))+x1;
      IF(xz>=trng.x1)AND(xz<=trng.x2)THEN BEGIN
        perc:=(yz-y1)/(y2-y1+1);
        col:=TRUNC(col0*(1-perc)+col1*perc+NextValue2);
        IF(typ0<>typ1)AND(NextValue2<0.5)THEN BEGIN
          IF typ0<typ1 THEN typ:=typ0 ELSE typ:=typ1;
          col:=col DIV 4+128+typ DIV 4;
        END ELSE IF perc<NextValue1 THEN INC(col,typ0) ELSE INC(col,typ1);
        IF(xz>=0)AND(xz<width)AND(yz>=trng.y1)AND(yz<trng.y2)THEN BEGIN
          page^[xz+(yz-trng.y1)*width]:=col;
        END;
      END;
    END;
  END ELSE BEGIN
    IF xz=0 THEN m:=500 ELSE m:=yz/xz;
    IF x1>x2 THEN BEGIN yz:=y1;y1:=y2;y2:=yz;xz:=x1;x1:=x2;x2:=xz;
      xe:=col0;col0:=col1;col1:=xe;xe:=typ0;typ0:=typ1;typ1:=xe;END;
    FOR xz:=x1 TO x2 DO IF (xz>=trng.x1) AND (xz<=trng.x2) THEN BEGIN
      yz:=TRUNC(m*(xz-x1))+y1;
      IF(yz>=trng.y1)AND(yz<=trng.y2)THEN BEGIN perc:=(xz-x1)/(x2-x1+1);
        col:=TRUNC(col0*(1-perc)+col1*perc+NextValue2);
        IF(typ0<>typ1)AND(NextValue2<0.5)THEN BEGIN
          IF typ0<typ1 THEN typ:=typ0 ELSE typ:=typ1;
          col:=col DIV 4+128+typ DIV 4;
        END ELSE IF perc<NextValue1 THEN INC(col,typ0) ELSE INC(col,typ1);
        IF(xz>=0)AND(xz<width)AND(yz>=trng.y1)AND(yz<trng.y2)THEN BEGIN
          page^[xz+(yz-trng.y1)*width]:=col;
        END;
      END;
    END;
  END;
END;
PROCEDURE DrawTriangles(x1,y1,y2,x3,y3,x4,y4:INTEGER;col0,col1,col2,col3,typ0,typ1,typ2,typ3:BYTE);
VAR yz:INTEGER;xe,typ:BYTE;perc:SINGLE;
BEGIN
  IF y1>y2 THEN BEGIN yz:=y1;y1:=y2;y2:=yz;xe:=col0;col0:=col1;col1:=xe;
    xe:=typ0;typ0:=typ1;typ1:=xe;END;
  FOR yz:=y1 TO y2 DO BEGIN perc:=(yz-y1)/(y2-y1+1);
    xe:=TRUNC(col0*(1-perc)+col1*perc+RANDOM(200)/100);
    IF perc>NextValue1 THEN typ:=typ1 ELSE typ:=typ0;
    GradientLine(x1,yz,x3,y3,xe,col2,typ,typ2);
    GradientLine(x1,yz,x4,y4,xe,col3,typ,typ3);
  END;
END;
FUNCTION GetType(heigth:BYTE):BYTE;
BEGIN
  CASE heigth OF
    0..63:GetType:=0;
    64..65:GetType:=64;
    66..179:GetType:=32;
    180..209:GetType:=64;
    210..255:GetType:=96;
  END;
END;
VAR xz,yz:BYTE;x1,y1,xt,yt,x2,y2:INTEGER;p1,p2,p3,p4:point;w0:WORD;
    xnz,ynz,percent:SINGLE;
BEGIN
  Mouse(2);
  GrBar(220,220,419,260,'BERECHNE DARSTELLUNG...');
  ClickField(0);

  ASSIGN(bmpf,'MAP~TEMP.BMP');
  REWRITE(bmpf,1);
  FILLCHAR(mapline,1078,0);
  mapline[26]:=1;
  mapline[47]:=1;
  mapline[28]:=8;          {Farbtiefe}
  mapline[18]:=LO(width);   {Gr”áe x}
  mapline[19]:=HI(width);
  mapline[22]:=LO(heigth);   {Gr”áe y}
  mapline[23]:=HI(heigth);
  mapline[10]:=LO(1078);   {Headergr”áe + Palettengr”áe}
  mapline[11]:=HI(1078);
  mapline[14]:=40;         {Headergr”áe ohne Kennung}
  mapline[0]:=66;          {"B"}
  mapline[1]:=77;          {"M"}
  mapline[2]:=54;          {Headergr”áe}
  mapline[3]:=180;         {?}

  FOR xz:=0 TO 255 DO FOR yz:=0 TO 2 DO BEGIN
    mapline[WORD(xz)*4+54]:=pal[xz,2]*4;
    mapline[WORD(xz)*4+55]:=pal[xz,1]*4;
    mapline[WORD(xz)*4+56]:=pal[xz,0]*4;
  END;

  BLOCKWRITE(bmpf,mapline,1078,w0);

  {GETIMAGE(0,0,639,95,page^);
  FILLCHAR(page^[4],64000,0);
  FOR actualxmspage:=9 DOWNTO 5 DO RAM_2_XMS(page,xms[actualxmspage],61444);}
  trng.x1:=0;trng.x2:=width-1;
  XMS_2_RAM(map[0],xms[1],62500);
  XMS_2_RAM(map[1],xms[2],62500);
  SetActivePage(1-GetActivePage);
  xp:=125;yp:=125;
  trng.y1:=0;
  WHILE trng.y1<=heigth-6 DO BEGIN
    trng.y2:=trng.y1+6;
    FILLCHAR(page^,width*6,240);
    FOR yz:=1 TO maxfieldy-2 DO
     FOR xz:=1 TO maxfieldx-2 DO BEGIN
      xt:=(INTEGER(xz-xp)-yz+yp)*20+width DIV 2;
      yt:=INTEGER(yz-yp+xz-xp)*10+heigth DIV 2;
      p1.x:=xt;
      p1.y:=yt-map[0]^[xz,yz];
      IF(p1.x>trng.x1-40)AND(p1.x<trng.x2+40)AND(p1.y>trng.y1-40)AND(p1.y<trng.y2+60)THEN BEGIN
        p2.x:=xt-20;
        p2.y:=yt+10-map[0]^[xz,yz+1];
        p3.x:=xt+20;
        p3.y:=yt+10-map[0]^[xz+1,yz];
        p4.y:=yt+20-map[0]^[xz+1,yz+1];
        DrawTriangles(p1.x,p1.y,p4.y,p2.x,p2.y,p3.x,p3.y,
         map[1]^[xz,yz]AND NOT 192,map[1]^[xz+1,yz+1]AND NOT 192,
         map[1]^[xz,yz+1]AND NOT 192,map[1]^[xz+1,yz]AND NOT 192,
         GetType(map[0]^[xz,yz]),GetType(map[0]^[xz+1,yz+1]),
         GetType(map[0]^[xz,yz+1]),GetType(map[0]^[xz+1,yz]));
      END;
    END;
    BLOCKWRITE(bmpf,page^,width*6,w0);
    INC(trng.y1,6);
  END;
  {RAM_2_XMS(page,xms[actualxmspage],61444);}
  {FOR actualxmspage:=4 DOWNTO 0 DO BEGIN
    XMS_2_RAM(page,xms[actualxmspage+5],61444);
    PUTIMAGE(0,WORD(actualxmspage)*96,page^,0);
  END;}
  FOR xz:=1 TO road^.sc DO BEGIN
    yz:=road^.p1[xz];
    IF(yz=mapx^.it)AND(mapx^.itst=0)THEN CONTINUE;
    IF yz>20 THEN BEGIN x1:=mapx^.fx[yz-20];y1:=mapx^.fy[yz-20];END
     ELSE BEGIN x1:=mapx^.tx[yz];y1:=mapx^.ty[yz];END;
    yz:=road^.p2[xz];
    IF(yz=mapx^.it)AND(mapx^.itst=0)THEN CONTINUE;
    IF yz>20 THEN BEGIN x2:=mapx^.fx[yz-20];y2:=mapx^.fy[yz-20];END
     ELSE BEGIN x2:=mapx^.tx[yz];y2:=mapx^.ty[yz];END;
    xt:=Entfernung(x1,y1,x2,y2);
    FOR yt:=0 TO xt DO BEGIN
      percent:=yt/xt;
      xnz:=INTEGER(x2-x1)*percent+x1;
      ynz:=INTEGER(y2-y1)*percent+y1;
      p1.x:=TRUNC((xnz-xp-ynz+yp)*20+GETMAXX DIV 2*zoom)DIV zoom;
      p1.y:=TRUNC((ynz-yp+xnz-xp)*10+GETMAXY DIV 2*zoom-map[0]^[ROUND(xnz),ROUND(ynz)])DIV zoom;
      IF(yt<>0)AND(((p1.x>=0)AND(p1.x<=GETMAXX))OR((p1.y>=0)AND(p1.y<=GETMAXY))
       OR((p2.x>=0)AND(p2.x<GETMAXX))OR((p2.y>=0)AND(p2.y<GETMAXY)))
       THEN BEGIN
         IF(p1.x>=0)AND(p1.x<GETMAXX)AND(p1.y>=0)AND(p1.y<GETMAXY)
          THEN p3.x:=TRUNC((GetPixel(p1.x,p1.y)MOD 32)/1.5)+96;
         SetColor(p3.x);
         Line(p1.x,p1.y,p2.x,p2.y);
       END;
      p2:=p1;
    END;
  END;
  XMS_2_RAM(page,xms[4],64004);
  XMS_2_RAM(map[1],xms[3],62500);
  FOR yz:=1 TO maxfieldy-2 DO
   FOR xz:=1 TO maxfieldx-2 DO IF map[1]^[xz,yz]<>255 THEN BEGIN
    xt:=(INTEGER(xz-xp)-yz+yp)*20+GETMAXX DIV 2*zoom;
    yt:=INTEGER(yz-yp+xz-xp)*10+GETMAXY DIV 2*zoom;
    xt:=xt DIV zoom;yt:=(yt-map[0]^[xz,yz])DIV zoom;
    IF(xt>trng.x1-40)AND(yt>trng.y1-40)AND(xt<trng.x2+40)AND(yt<trng.y2+40)THEN BEGIN
      FOR y1:=0 TO 39 DIV zoom DO BEGIN
        y2:=yt-20 DIV zoom+y1;
        IF(y2>=0)AND(y2<480)THEN BEGIN
          w0:=y1*40*zoom+WORD(map[1]^[xz,yz])*1600;
          FOR x1:=0 TO 39 DIV zoom DO BEGIN
            x2:=xt-20 DIV zoom+x1;
            IF(page^[w0+x1*zoom]<>200)AND(x2>=0)AND(x2<640)THEN PUTPIXEL(x2,y2,page^[w0+x1*zoom]);
          END;
        END;
      END;
    END;
  END;
  IF zoom<16 THEN BEGIN
    FOR xz:=1 TO mapx^.tc DO IF(mapx^.it<>xz)OR(mapx^.itst>0)THEN BEGIN
      xt:=(INTEGER(mapx^.tx[xz]-xp)-mapx^.ty[xz]+yp)*20+GETMAXX DIV 2*zoom;
      yt:=INTEGER(mapx^.ty[xz]-yp+mapx^.tx[xz]-xp)*10+GETMAXY DIV 2*zoom;
      xt:=xt DIV zoom;yt:=(yt-map[0]^[mapx^.tx[xz],mapx^.ty[xz]])DIV zoom;
      IF zoom<4 THEN OutBTxt(xt-LENGTH(mapx^.tn[xz])*9 DIV 2,yt+12,mapx^.tn[xz],251)
       ELSE OutSTxt(xt-LENGTH(mapx^.tn[xz])*3,yt+5,mapx^.tn[xz],251)
    END;
    FOR xz:=1 TO mapx^.fc DO BEGIN
      xt:=((INTEGER(mapx^.fx[xz]-xp)-mapx^.fy[xz]+yp)*20+GETMAXX DIV 2*zoom)DIV zoom;
      yt:=((INTEGER(mapx^.fy[xz]-yp+mapx^.fx[xz]-xp)*10+GETMAXY DIV 2*zoom)-map[0]^[mapx^.fx[xz],mapx^.fy[xz]])DIV zoom;
      {xt:=xt DIV zoom;yt:=(yt-map[0]^[mapx^.fx[xz],mapx^.fy[xz]])DIV zoom;}
      STR(xz,st);st:=st+': ';ID(st,xz);
      IF zoom<4 THEN OutBTxt(xt-LENGTH(st)*9 DIV 2,yt+12,st,251)
       ELSE OutSTxt(xt-LENGTH(st)*3,yt+5,st,251)
    END;
  END;
  trk.px:=65535;
  GetCFOriginals(TRUE);
  IF zoom=16 THEN w0:=33297 ELSE IF zoom=1 THEN w0:=33313 ELSE w0:=33329;
  IF active AND 2=2 THEN w0:=w0 AND NOT 512;
  SetVisualPage(GetActivePage);
  CLOSE(bmpf);
  ClickField(w0);
  active:=active AND NOT 16;
  Mouse(1);
  PoV;
END;
FUNCTION Scenes:BYTE;
VAR menutext:STRING[40];
BEGIN
  GETIMAGE(220,100,419,303,page^[0]);
  FOR b1:=0 TO 4 DO BEGIN
    CASE b1 OF 0:menutext:='EINLEITUNG';
      1:menutext:='ERMORDUNG';
      2:menutext:='VERHAFTUNG';
      3:menutext:='ENDSEQUENZ';
      4:menutext:='ZURšCK';
    END;
    GrBar(240,100+b1*41,399,139+b1*41,menutext);
  END;Mouse(1);
  REPEAT Keys;
    IF(key[2]=#72)OR(key[2]=#80)THEN BEGIN ms.x:=320;IF ms.y<120 THEN ms.y:=120;
      ms.y:=(ms.y-100)DIV 41*41+120;IF ms.y>284 THEN ms.y:=284;
      IF key[2]=#72 THEN DEC(ms.y,41) ELSE INC(ms.y,41);
      IF ms.y<120 THEN ms.y:=284 ELSE IF ms.y>284 THEN ms.y:=120;
    END ELSE key[2]:=#0;
    IF key[2]=#0 THEN Mouse(3) ELSE Mouse(7);
    b2:=255;FOR b1:=0 TO 4 DO IF Click(240,100+b1*41,399,139+b1*41,7)THEN b2:=b1;
  UNTIL b2<>255;
  Scenes:=b2;
  Mouse(2);
  PUTIMAGE(220,100,page^[0],0);
END;
BEGIN
  NEW(news);NEW(tile);
  ASSIGN(ntf,'NEWS.TXT');RESET(ntf);ncount:=0;
  WHILE NOT EOF(ntf)AND(ncount<65535)DO BEGIN READLN(ntf,news^[1].st);INC(ncount);END;
  Intro(TRUE);
  REPEAT pb:=0;music:=0;oldtrack:=0;
    IF active AND 5=4THEN active:=active OR 16;
    ClickField(0);
    REPEAT
      CASE MainMenu OF 0:IF CreateMap THEN BEGIN pb:=255;
          FOR zoom:=1 TO mapx^.tc DO IF mapx^.tt[zoom] AND 2=2 THEN BEGIN
            xp:=mapx^.tx[zoom]-3;yp:=mapx^.ty[zoom]-3;
          END;
          active:=active OR 1;active:=active AND NOT 2;zoom:=130;END;
        1:IF DiskOp(1) THEN BEGIN pb:=255;
          active:=active OR 1;active:=active AND NOT 2;zoom:=130;END;
        3:BEGIN IF active AND 5>0 THEN pb:=255 ELSE
           IF cheats AND 1=0 THEN Intro(FALSE) ELSE
           CASE Scenes OF
            0:Intro(FALSE);
            1:GameOver(1);
            2:GameOver(2);
            3:Outro;
          END;
        END;
        4:HALT(0);
      END;
    UNTIL pb=255;
    active:=active OR 4;
    IF trk.p=255 THEN BEGIN FILLCHAR(trk,SIZEOF(vehicle),0);geld:=5000;
      FOR b1:=1 TO 4 DO BEGIN
        REPEAT RESET(ntf);IF IORESULT<>0 THEN BEGIN CLOSE(ntf);RESET(ntf);END;
          l1:=RANDOM(ncount)+1;
          FOR l1:=1 TO l1 DO READLN(ntf,news^[b1].st);
        UNTIL(news^[b1].st[1]<>'#')AND(news^[b1].st<>'');
        b2:=POS('~',news^[b1].st);
        IF b2<>0 THEN news^[b1].st:=COPY(news^[b1].st,1,b2-1)
         +mapx^.tn[RANDOM(mapx^.tc)+1]+COPY(news^[b1].st,b2+1,LENGTH(news^[b1].st)-b2);
        news^[b1].dt:=-1;news^[b1].ev:=94+RANDOM(5)-b1*5;
      END;
      FOR b1:=1 TO mapx^.tc DO IF mapx^.tt[b1] AND 2=2 THEN BEGIN trk.m:=40;trk.f:=40;
        ctf:=b1;trk.d:=0;trk.pos:=0;END;END;
    IF zoom<128 THEN BEGIN
      IF zoom=16 THEN l1:=33297 ELSE IF zoom=1 THEN l1:=33313 ELSE l1:=33329;
      IF active AND 2=2 THEN l1:=l1 AND NOT 512;
      ClickField(l1);
      IF active AND 5=4THEN active:=active AND NOT 16;
    END;
    ctof.n:=0;
    Mouse(1);
    REPEAT
      CASE oldtrack OF 0:IF active AND 7=6 THEN music:=3 ELSE music:=5;
        5:IF active AND 4=0 THEN music:=5 ELSE
         IF active AND 3=2 THEN music:=3 ELSE music:=1;
        1,2:IF active AND 3=2 THEN music:=3 ELSE music:=1;
        3:IF active AND 3=2 THEN music:=4 ELSE music:=1;
        4:IF active AND 3=2 THEN music:=3 ELSE music:=1;
      END;
      IF zoom AND 128=128 THEN BEGIN DEC(zoom,128);RenderMap(FALSE);END;
      REPEAT
        REPEAT Mouse(3);
          CASE oldtrack OF 0:IF active AND 7=6 THEN music:=3 ELSE music:=5;
            5:IF active AND 4=0 THEN music:=5 ELSE
            IF active AND 3=2 THEN music:=3 ELSE music:=1;
            1,2:IF active AND 3=2 THEN music:=3 ELSE music:=1;
            3:IF active AND 3=2 THEN music:=4 ELSE music:=1;
            4:IF active AND 3=2 THEN music:=3 ELSE music:=1;
          END;
          IF ttime>49 THEN IF Timing THEN RenderMap(TRUE);
          IF active AND 5=4 THEN BEGIN
            IF active AND 2=2 THEN BEGIN
              PoV;
              IF trk.pos>trk.dis THEN InTown(ctf);
            END;
          END;
        UNTIL(ms.f<>0)OR(geld<min_geld)OR(geld>=max_geld)OR(death);
        IF ms.b=0 THEN cf:=ClickedField;
      UNTIL(ms.b<>0)OR(zoom AND 128=128)OR(geld<min_geld)OR(geld>=max_geld)OR(death);
      cf:=ClickedField;
      IF(ms.b=1)AND(cf=255)THEN BEGIN
        REPEAT Mouse(3);UNTIL ms.b AND 1=0;
        INC(xp,INTEGER(ms.y-GETMAXY DIV 2)*zoom DIV 20+INTEGER(ms.x-GETMAXX DIV 2)*zoom DIV 40);
        INC(yp,INTEGER(ms.y-GETMAXY DIV 2)*zoom DIV 20-INTEGER(ms.x-GETMAXX DIV 2)*zoom DIV 40);
        IF xp<1 THEN xp:=1 ELSE IF xp>maxfieldx-1 THEN xp:=maxfieldx-1;
        IF yp<1 THEN yp:=1 ELSE IF yp>maxfieldy-1 THEN yp:=maxfieldy-1;
        zoom:=zoom OR 128;
      END;
      IF((cf=20)OR(cf=36))AND(zoom<>1)THEN zoom:=zoom DIV 2+128;
      IF(cf=25)OR(cf=41)THEN InTown(ctf);
      IF cf=32 THEN Einstellungen;
      IF((ms.b=2)AND(cf=255))AND(zoom<>16)THEN BEGIN
        IF cf=255 THEN REPEAT Mouse(3);UNTIL ms.b AND 2=0;
        xp:=maxfieldx DIV 2;yp:=maxfieldy DIV 2;
        zoom:=zoom OR 128;
      END;
      IF((cf=21)OR(cf=37))AND(zoom<>16)THEN BEGIN
        zoom:=zoom*2+128;IF zoom=144 THEN BEGIN xp:=125;yp:=125;END;
      END;
      IF(cf=31)OR(cf=47)THEN BEGIN
        MOUSE(2);
        active:=active OR 16;
        ClickField(cfeld AND NOT 32768);
        active:=active XOR 1;
        ClickField(cfeld OR 32768);
        MOUSE(1);
        active:=active AND NOT 16;
      END;
    UNTIL(cf=16)OR(geld<min_geld)OR(geld>=max_geld)OR(death);
    Mouse(2);
    IF death THEN BEGIN
      OutPic(pal,1,0,255);
      GameOver(1);
    END ELSE BEGIN
      IF geld<min_geld THEN BEGIN
        OutPic(pal,1,0,255);
        GameOver(2);
      END;
      IF geld>=max_geld THEN BEGIN
        OutPic(pal,1,0,255);
        Outro;
      END;
    END;
  UNTIL pb=0;
  DISPOSE(tile);tile:=NIL;
  DISPOSE(news);news:=NIL;
  CLOSE(ntf);
END;

BEGIN END.