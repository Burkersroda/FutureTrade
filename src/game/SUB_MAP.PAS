{$O+,S-,G+,F+,N+,E+}
UNIT SUB_MAP;
INTERFACE USES VARS,VESA,SUB_TEXT,SUB_DRAW,SUB_CTRL,EFFECTS,SUB_MML,XMS_UNIT;
FUNCTION CreateMap:BOOLEAN;
FUNCTION Entfernung(x1,y1,x2,y2:INTEGER):LONGINT;
FUNCTION Schnitt(x11,y11,x12,y12,x21,y21,x22,y22:INTEGER):BOOLEAN;
PROCEDURE Sort(nr:WORD);
PROCEDURE MapPal;
IMPLEMENTATION
PROCEDURE Sort(nr:WORD);
VAR tn:STRING[20];tt:BYTE;tx,ty,ti:WORD;
BEGIN
  tn:=mapx^.tn[nr];mapx^.tn[nr]:=mapx^.tn[nr+1];mapx^.tn[nr+1]:=tn;
  tt:=mapx^.tt[nr];mapx^.tt[nr]:=mapx^.tt[nr+1];mapx^.tt[nr+1]:=tt;
  tx:=mapx^.tx[nr];mapx^.tx[nr]:=mapx^.tx[nr+1];mapx^.tx[nr+1]:=tx;
  ty:=mapx^.ty[nr];mapx^.ty[nr]:=mapx^.ty[nr+1];mapx^.ty[nr+1]:=ty;
  ti:=mapx^.ti[nr];mapx^.ti[nr]:=mapx^.ti[nr+1];mapx^.ti[nr+1]:=ti;
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
  IF(x11-x12=0)OR(x21-x22=0)OR(y11-y12=0)OR(y21-y22=0)THEN EXIT;
  m1:=(y11-y12)/(x11-x12);
  m2:=(y21-y22)/(x21-x22);
  n1:=y11-m1*x11;
  n2:=y21-m2*x21;
  IF m1=m2 THEN BEGIN
    IF n1<>n2 THEN Schnitt:=FALSE;
    EXIT;
  END;
  x0:=(n2-n1)/(m1-m2);
  y0:=m1*x0+n1;
  IF(y0<=y11+0.005)OR(y0>=y12-0.005)
   OR(y0<=y21+0.005)OR(y0>=y22-0.005)
   THEN Schnitt:=FALSE;
END;
FUNCTION CreateMap:BOOLEAN;
VAR panz,xm,ym,hoh,rad,bt,mp,mr:BYTE;xp,yp,bb,cc,dd,ee,ff,gg,hh,ii:WORD;
    jj,kk:INTEGER;
    lo0:LONGINT;abr:BOOLEAN;
    txt:TEXT;st:STRING;anz:ARRAY[0..2]OF BYTE;
FUNCTION Winkel(x1,y1,x2,y2:BYTE):INTEGER;
VAR winkel0:INTEGER;
BEGIN
  IF y1-y2=0 THEN winkel0:=90
   ELSE winkel0:=ROUND(ARCTAN((x2-x1)/(y2-y1))/Pi*180)+90;
  IF y1<y2 THEN INC(winkel0,180);
  Winkel:=winkel0;
END;
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
PROCEDURE PutTrees;
VAR x0,y0,by0,treetype:BYTE;
BEGIN
  FOR by0:=0 TO 3 DO FOR x0:=1 TO maxfieldx-2 DO FOR y0:=1 TO maxfieldy-2 DO IF RANDOM(6)=1 THEN
   IF(map[2]^[x0,y0]>=16)AND(map[2]^[x0,y0]<255)AND(map[2]^[x0,y0]MOD 4<3)THEN BEGIN
    INC(map[2]^[x0,y0]);
    treetype:=(map[2]^[x0,y0]DIV 4)*4;
    IF(map[2]^[x0-1,y0]=255)AND(map[0]^[x0-1,y0]>86)AND(map[0]^[x0-1,y0]<159)THEN map[2]^[x0-1,y0]:=treetype;
    IF(map[2]^[x0,y0-1]=255)AND(map[0]^[x0,y0-1]>86)AND(map[0]^[x0,y0-1]<159)THEN map[2]^[x0,y0-1]:=treetype;
    IF(map[2]^[x0+1,y0]=255)AND(map[0]^[x0+1,y0]>86)AND(map[0]^[x0+1,y0]<159)THEN map[2]^[x0+1,y0]:=treetype;
    IF(map[2]^[x0,y0+1]=255)AND(map[0]^[x0,y0+1]>86)AND(map[0]^[x0,y0+1]<159)THEN map[2]^[x0,y0+1]:=treetype;
  END;
END;
procedure plasma(x1,y1,x2,y2:word); { d'aprŠs Patrick Ruelle - Pascalissime 66 }

 function color(mc,n,dvd:integer):byte;
  begin
   color:=(mc+n-Random(2*n)) div dvd;
  end;

 var
  xn,yn,dxy,p1,p2,p3,p4:word;
 begin
  if (x2-x1<2)and(y2-y1<2) then exit;
  p1:=map[0]^[y1,x1];
  p2:=map[0]^[y2,x1];
  p3:=map[0]^[y1,x2];
  p4:=map[0]^[y2,x2];
  xn:=(x2+x1) shr 1;
  yn:=(y2+y1) shr 1;
  dxy:=(x2-x1+y2-y1);
  if map[0]^[y1,xn]=0 then map[0]^[y1,xn]:=Color(p1+p3,dxy,2);
  if map[0]^[yn,x1]=0 then map[0]^[yn,x1]:=Color(p1+p2,dxy,2);
  if map[0]^[yn,x2]=0 then map[0]^[yn,x2]:=Color(p3+p4,dxy,2);
  if map[0]^[y2,xn]=0 then map[0]^[y2,xn]:=Color(p2+p4,dxy,2);
  map[0]^[yn,xn]:=color(p1+p2+p3+p4,dxy,4);

  plasma(x1,y1,xn,yn);
  plasma(xn,y1,x2,yn);
  plasma(x1,yn,xn,y2);
  plasma(xn,yn,x2,y2);
 end;
VAR sorted:BOOLEAN;cpos,result:BYTE;snr:WORD;
    xz,yz:BYTE;col:SINGLE;ncol:INTEGER;
    triacol:ARRAY[0..1]OF ^undergroundtype;
    rawfile:FILE;
    flag:BOOLEAN;
    lo1:LONGINT;
    firsttownpos:BYTE;
BEGIN
  CreateMap:=FALSE;
  GetImage(190,120,449,298,page^);
  RAM2XMS(page,xms[1],50000,251500);
  GreenBar(190,120,449,298);
  OutText(320,130,'S Z E N E   E R S T E L L E N',243,2,1.75);
  GETIMAGE(190,130,315,240,page^[0]);
  FOR b1:=0 TO 2 DO BEGIN
    GETIMAGE(320,160+b1*41,429,199+b1*41,page^[16000+WORD(b1)*8000]);
    CASE b1 OF 0:st:='LANDSCHAFT';1:st:='STŽDTEANZAHL';2:st:='INDUSTRIEDICHTE';END;
    OutText(315,170+b1*41,st+':',244,1,2);
  END;
  GETIMAGE(190,300,319,339,page^[48000]);
  GrBar(190,300,319,339,ok);
  GETIMAGE(320,300,449,339,page^[56000]);
  GrBar(320,300,449,339,abbruch);
  b2:=255;FILLCHAR(anz[0],3,6);
  REPEAT
    FOR b1:=0 TO 2 DO IF(1 SHL b1)AND b2>0 THEN BEGIN
      CASE anz[b1] OF 6:st:='ZUFALL';
        1:CASE b1 OF 0:st:='FLACH';1,2:st:='MINIMUM';END;
        2:CASE b1 OF 0:st:='HšGELIG';1:st:='EINIGE';2:st:='GERING';END;
        3:CASE b1 OF 0:st:='AUSGEGLICHEN';1:st:='MEHRERE';2:st:='MITTEL';END;
        4:CASE b1 OF 0:st:='BERGIG';1:st:='VIELE';2:st:='HOCH';END;
        5:CASE b1 OF 0:st:='STARK BERGIG';1,2:st:='MAXIUMUM';END;
        7:st:='RUHIGE HšGEL';
        8:st:='NEUES GEBIET';
        9:st:='GROSSE TŽLER';
        10:st:='IM GEBIRGE';
        11:st:='HOHES LAND';
      END;
      GrBar(320,160+b1*41,429,199+b1*41,st);
    END;
    Mouse(1);b2:=0;
    REPEAT Mouse(3);Keys;
      FOR b1:=0 TO 2 DO IF Click(320,160+b1*41,429,199+b1*41,1)THEN BEGIN
        INC(b2,1 SHL b1);INC(anz[b1]);
        IF((anz[b1]=7)AND(b1<>0))OR((anz[b1]=12)AND(b1=0))THEN anz[b1]:=1;
       END ELSE IF Click(320,160+b1*41,429,199+b1*41,2)THEN BEGIN
        INC(b2,1 SHL b1);DEC(anz[b1]);
        IF anz[b1]=0 THEN CASE b1 OF 0:anz[b1]:=11;1..2:anz[b1]:=6;END;
       END;
      IF Click(190,300,319,339,7)THEN b2:=127;
      IF Click(320,300,449,339,7)THEN b2:=255;
    UNTIL b2>0;
    Mouse(2);
    FOR b1:=0 TO 2 DO IF(1 SHL b1)AND b2>0 THEN
     PUTIMAGE(320,160+b1*41,page^[16000+WORD(b1)*8000],0);
  UNTIL b2>126;
  PUTIMAGE(190,130,page^[0],0);
  PUTIMAGE(190,300,page^[48000],0);
  PUTIMAGE(320,300,page^[56000],0);
  XMS2RAM(page,xms[1],50000,251500);
  PutImage(190,120,page^,0);
  IF b2=255 THEN EXIT;
  GETIMAGE(40,440,179,459,page^[0]);GETIMAGE(180,440,209,459,page^[16000]);
  GETIMAGE(0,435,29,464,page^[32000]);
  OutText(40,440,'GENERIERE KARTE...',244,0,2);
  ClickField(128);
  mp:=0;stime.gt:=0;stime.ev:=20;death:=FALSE;
  IF cheatmoney=0 THEN geld:=1000 ELSE geld:=cheatmoney;
  IF anz[0]=6 THEN mp:=RANDOM(100)+50 ELSE mp:=RANDOM(25)+50*(anz[0]-1)+26;
  CASE anz[1]OF 6:mapx^.tc:=RANDOM(16)+5;
    1:mapx^.tc:=5;
    5:mapx^.tc:=20;
    ELSE BEGIN
      mapx^.tc:=RANDOM(4)+4*(anz[1]-1)+1;
      IF mapx^.tc<5 THEN mapx^.tc:=5;
    END;
  END;
  CASE anz[2]OF 6:mapx^.fc:=RANDOM(16)+5;
    1:mapx^.fc:=4;
    5:mapx^.fc:=20;
    ELSE BEGIN
      mapx^.fc:=RANDOM(4)+4*(anz[2]-1)+1;
      IF mapx^.fc<5 THEN mapx^.fc:=5;
    END;
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
  END ELSE BEGIN
    STR(anz[0]-7,st);
    LoadMMLTrack(0,0,0,'map.'+st,0);
  END;
  RAM2XMS(map[0],xms[1],62500,0);
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
  RAM2XMS(map[1],xms[1],62500,62500);
  DISPOSE(triacol[1]);DISPOSE(triacol[0]);
  NEW(map[0]);
  XMS2RAM(map[0],xms[1],62500,0);
  RANDOMIZE;
  REPEAT
  PUTIMAGE(180,440,page^[16000],0);PUTIMAGE(40,440,page^[0],0);
  OutText(40,440,'GENERIERE STŽDTE...',244,0,2);
  bb:=0;Mouse(1);
  firsttownpos:=0;
  FOR panz:=1 TO mapx^.tc DO REPEAT Mouse(3);
    IF ms.f=1 THEN IF ClickedField=23THEN BEGIN Mouse(2);
      ClickField(0);
      PUTIMAGE(40,440,page^[0],0);PUTIMAGE(180,440,page^[16000],0);
      EXIT;
    END;
    mapx^.tx[panz]:=RANDOM(maxfieldx-19)+10;mapx^.ty[panz]:=RANDOM(maxfieldy-19)+10;
    mapx^.ti[panz]:=RANDOM(59800)+200;mapx^.tt[panz]:=(RANDOM(255)+1)AND NOT 3;
    IF(RANDOM(4)=1)AND(bb<mapx^.tc DIV 5+1)THEN
     BEGIN mapx^.tt[panz]:=mapx^.tt[panz]OR 1;INC(bb);END;
    FOR b3:=0 TO 25 DO mapx^.pr[panz,b3]:=
     GetPrice[b3]+(SHORTINT(RANDOM(2)*2)-1)*RANDOM(ROUND(GetPrice[b3]))/10
     +RANDOM(ROUND(GetPrice[b3]))/18;
    mapx^.gs[panz]:=RANDOM(256);
    xp:=mapx^.tx[panz];yp:=mapx^.ty[panz];
    flag:=TRUE;
    FOR b3:=1 TO panz-1 DO IF Entfernung(xp,yp,mapx^.tx[b3],mapx^.ty[b3])<10 THEN flag:=FALSE;
    b3:=xp DIV 125+(yp DIV 125)*2;
    IF(firsttownpos AND(1 SHL b3)=0)AND flag THEN INC(firsttownpos,1 SHL b3)
     ELSE flag:=FALSE;
    IF firsttownpos=15 THEN firsttownpos:=0;
  UNTIL(map[0]^[xp,yp]>68)AND(map[0]^[xp,yp]<178)AND flag;
  ASSIGN(txt,'NAMES.TXT');
  RESET(txt);
  {WHILE IORESULT<>0 DO BEGIN CLOSE(txt);RESET(txt);END;}
  xp:=0;FILLCHAR(map[1]^,62500,0);
  IF IORESULT=0 THEN WHILE NOT EOF(txt)AND(xp<=maxfieldx) DO BEGIN
    READLN(txt,st);
    IF st='.' THEN INC(xp) ELSE
     IF (st[1]<>'#') AND (st[1]<>'~') THEN INC(map[1]^[xp,0]) ELSE
     IF st[1]='~' THEN INC(map[1]^[xp,1]);
  END ELSE BEGIN xp:=0;yp:=0;END;
  FOR panz:=1 TO mapx^.tc DO REPEAT mapx^.tn[panz]:='';ym:=0;
    IF xp<>0 THEN BEGIN CLOSE(txt);RESET(txt);
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
      IF st[LENGTH(st)]='~' THEN BEGIN CLOSE(txt);RESET(txt);
        FOR yp:=1 TO yp DO REPEAT READLN(txt,st);UNTIL st='.';
        FOR xm:=1 TO RANDOM(map[1]^[yp,1])+1 DO
         REPEAT READLN(txt,st);UNTIL st[1]='~';
        mapx^.tn[panz]:=COPY(mapx^.tn[panz],1,LENGTH(mapx^.tn[panz])-1)+
         COPY(st,2,LENGTH(st)-1);
      END;
      {STR(mapx^.tx[panz],st);
      mapx^.tn[panz]:=st+', ';
      STR(mapx^.ty[panz],st);
      mapx^.tn[panz]:=mapx^.tn[panz]+st;}
      FOR xm:=1 TO panz-1 DO IF mapx^.tn[xm]=mapx^.tn[panz] THEN INC(ym);
    END;
  UNTIL ym=0;
  CLOSE(txt);
  FOR panz:=1 TO mapx^.tc DO FOR xm:=1 TO LENGTH(mapx^.tn[panz]) DO
   CASE mapx^.tn[panz,xm] OF '„':mapx^.tn[panz,xm]:='Ž';
    '”':mapx^.tn[panz,xm]:='™';
    '':mapx^.tn[panz,xm]:='š';
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
      b3:=xp DIV 125+(yp DIV 125)*2;
      IF(firsttownpos AND(1 SHL b3)=0)AND flag THEN INC(firsttownpos,1 SHL b3)
       ELSE flag:=FALSE;
      IF firsttownpos=15 THEN firsttownpos:=0;
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
    lo1:=300;
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
          IF flag THEN FOR b3:=1 TO panz DO BEGIN
            IF road^.p1[b3]=xz THEN BEGIN
              bb:=ff;cc:=gg;b2:=road^.p2[b3];
              jj:=Winkel(ff,gg,hh,ii);
            END ELSE IF road^.p1[b3]=yz THEN BEGIN
              bb:=hh;cc:=ii;b2:=road^.p2[b3];
              jj:=Winkel(hh,ii,ff,gg);
            END ELSE IF road^.p2[b3]=xz THEN BEGIN
              bb:=ff;cc:=gg;b2:=road^.p1[b3];
              jj:=Winkel(ff,gg,hh,ii);
            END ELSE IF road^.p2[b3]=yz THEN BEGIN
              bb:=hh;cc:=ii;b2:=road^.p1[b3];
              jj:=Winkel(hh,ii,ff,gg);
            END ELSE CONTINUE;
            IF b2<21 THEN BEGIN dd:=mapx^.tx[b2];ee:=mapx^.ty[b2];END
             ELSE BEGIN dd:=mapx^.fx[b2-20];ee:=mapx^.fy[b2-20];END;
            kk:=Winkel(bb,cc,dd,ee);
            IF(ABS(kk-jj)<30)OR(360-ABS(kk-jj)<30)THEN flag:=FALSE;
          END;
          IF flag THEN FOR b3:=1 TO panz DO BEGIN
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
  UNTIL(xm<>0)OR(panz>mapx^.tc+mapx^.fc-2);
  road^.sc:=panz;
  {panz:=0;
  REPEAT
    INC(panz);
    b1:=road^.p1[panz];b2:=road^.p2[panz];
    IF b1<21 THEN BEGIN bb:=mapx^.tx[b1];cc:=mapx^.ty[b1];END
     ELSE BEGIN bb:=mapx^.fx[b1-20];cc:=mapx^.fy[b1-20];END;
    IF b2<21 THEN BEGIN dd:=mapx^.tx[b2];ee:=mapx^.ty[b2];END
     ELSE BEGIN dd:=mapx^.fx[b2-20];ee:=mapx^.fy[b2-20];END;
    xp:=0;yp:=0;
    FOR b3:=1 TO road^.sc DO IF panz<>b3 THEN BEGIN
      b1:=road^.p1[b3];b2:=road^.p2[b3];
      IF b1<21 THEN BEGIN ff:=mapx^.tx[b1];gg:=mapx^.ty[b1];END
       ELSE BEGIN ff:=mapx^.fx[b1-20];gg:=mapx^.fy[b1-20];END;
      IF b2<21 THEN BEGIN hh:=mapx^.tx[b2];ii:=mapx^.ty[b2];END
       ELSE BEGIN hh:=mapx^.fx[b2-20];ii:=mapx^.fy[b2-20];END;
      IF Schnitt(bb,cc,dd,ee,ff,gg,hh,ii)THEN BEGIN
        INC(xp);
        yp:=b3;
      END;
    END;
    IF xp>0 THEN BEGIN
      PUTIMAGE(40,440,page^[0],0);
      OutText(40,440,'STRASSE GESCHNITTEN',244,0,2);
      FOR b3:=panz TO road^.sc-1 DO BEGIN
        road^.p1[b3+1]:=road^.p1[b3];
        road^.p2[b3+1]:=road^.p2[b3];
      END;
      DEC(road^.sc);
    END;
  UNTIL panz=road^.sc;}
  Mouse(2);
  FILLCHAR(map[0]^,41,0);
  FOR panz:=1 TO road^.sc DO BEGIN
    xm:=road^.p1[panz];
    ym:=road^.p2[panz];
    IF xm<21 THEN INC(map[0]^[0,xm]);
    IF ym<21 THEN INC(map[0]^[0,ym]);
  END;
  ym:=0;
  FOR panz:=mapx^.tc DOWNTO 1 DO IF map[0]^[0,panz]>ym THEN BEGIN xm:=panz;ym:=map[0]^[0,panz];END;
  mapx^.tt[xm]:=mapx^.tt[xm]OR 2;
  xz:=xm;
  IF ym>5 THEN mapx^.tt[xm]:=mapx^.tt[xm]OR 128 ELSE mapx^.tt[xm]:=mapx^.tt[xm]AND NOT 128;
  FOR panz:=1 TO mapx^.tc DO
   IF(map[0]^[0,panz]<=ym)AND(mapx^.tt[panz]AND 3<>3)AND(panz<>xz)THEN BEGIN
    xm:=panz;
    ym:=map[0]^[0,panz];
  END;
  mapx^.it:=xm;mapx^.itst:=0;
  NEW(map[2]);FILLCHAR(map[2]^,62500,255);
  XMS2RAM(map[0],xms[1],62500,0);
  FOR ym:=1 TO maxfieldy-1 DO FOR xm:=1 TO maxfieldx-1 DO
   IF(RANDOM(15)=1)AND(map[0]^[xm,ym]>=66)AND(map[0]^[xm,ym]<=179)THEN map[2]^[xm,ym]:=32+RANDOM(2)*4;
  PutTrees;
  FOR panz:=1 TO mapx^.tc DO BEGIN
    IF mapx^.tt[panz] AND 2=2 THEN BEGIN
      IF mapx^.tt[panz] AND 128=128 THEN map[2]^[mapx^.tx[panz],mapx^.ty[panz]]:=3
       ELSE map[2]^[mapx^.tx[panz],mapx^.ty[panz]]:=2;
    END ELSE IF mapx^.it=panz THEN BEGIN
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
      0..3:map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=17;
      4:map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=13;
      5:map[2]^[mapx^.fx[panz],mapx^.fy[panz]]:=16;
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
  RAM2XMS(map[2],xms[1],62500,125000);
  DISPOSE(map[2]);map[2]:=NIL;
  FILLCHAR(vertr^,SIZEOF(contract),0);
  active:=active OR 1;active:=active AND NOT 6;
  news^[1].st:='HERZLICH WILLKOMMEN AUF HI-ECO-LE!';
  news^[1].dt:=stime.gt;news^[1].ev:=stime.ev;
  news^[2].st:='HANDELSKONTO WURDE ER™FFNET. KAPITAL: 1000'+pdol;
  news^[2].dt:=stime.gt;news^[2].ev:=stime.ev;
  news^[3].st:='IHRE HANDELSLIZENZ WURDE BESTŽTIGT. VIEL ERFOLG!';
  news^[3].dt:=stime.gt;news^[3].ev:=stime.ev-1;
  news^[4].st:='< MATTESH INC. / REGIERUNG VON HI-ECO-LE >';
  news^[4].dt:=stime.gt;news^[4].ev:=stime.ev-1;
  FILLCHAR(trk,SIZEOF(vehicle),0);
  FOR b1:=1 TO mapx^.tc DO IF mapx^.tt[b1] AND 2=2 THEN BEGIN
    trk.m:=40;
    trk.f:=40;
    ctf:=b1;
    trk.dis:=100;
    trk.pos:=100;
    trk.s:=b1;
    FOR b2:=1 TO road^.sc DO BEGIN
      IF road^.p1[b2]=b1 THEN trk.d:=road^.p2[b2]
       ELSE IF road^.p2[b2]=b1 THEN trk.d:=road^.p1[b2];
    END;
  END;
  CreateMap:=TRUE;
  ClickField(0);
  OutPic(pal,4,0,255);CLEARDEVICE;
  MapPal;
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

END.