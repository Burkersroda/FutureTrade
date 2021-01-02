{$G+,I-,F-,S-,M 10240,0,512000}


USES MODEXLIB,CRT,DOS;

CONST erk:ARRAY[1..12]OF CHAR=('G','C','A',' ','1','.','0','0',#13,#10,#26,#26);

TYPE buffer=ARRAY[0..64999]OF BYTE;
     pal256=ARRAY[0..767]OF BYTE;

VAR buf:ARRAY[0..1]OF ^buffer;
    w0,pos,bps,std,min,sek,hsk:WORD;
    ctime:LONGINT;
    ani:FILE;
    bez:STRING[12];
    typ:BYTE;
    pal:pal256;
    key:ARRAY[1..2]OF CHAR;

PROCEDURE SetPal(palbuf:pal256);
VAR reg:REGISTERS;
BEGIN
  reg.ax:=$1012;
  reg.bx:=0;
  reg.cx:=256;
  reg.es:=SEG(palbuf);
  reg.dx:=OFS(palbuf);
  INTR($10,reg);
END;
PROCEDURE Keys;
BEGIN
  IF KEYPRESSED THEN BEGIN key[1]:=READKEY;
    IF key[1]=#0 THEN key[2]:=READKEY ELSE key[2]:=#0;END ELSE
   BEGIN key[1]:=#0;key[2]:=#0;END;
END;
PROCEDURE Play_GCA;
VAR b,dau,mode,uii:BYTE;br,ho,anz,pst:WORD;
    psn:ARRAY[0..3]OF WORD;fpos,brho:LONGINT;
    bittab:ARRAY[0..7]OF BYTE;
    temp:ARRAY[0..7999]OF BYTE;
    actpage:BYTE;
PROCEDURE LC2;
VAR bre,hoe,lng,tst,sx,sy:WORD;col,act,bst:BYTE;
    pal:ARRAY[0..767]OF BYTE;
BEGIN
  FOR hoe:=0 TO ho-1 DO BEGIN
    BLOCKREAD(ani,temp,2,w0);
    lng:=temp[0]+temp[1]*256;
    BLOCKREAD(ani,temp,lng,w0);
    bre:=0;
    tst:=0;
    WHILE tst<lng-1 DO BEGIN
      act:=temp[tst];
      FOR bst:=0 TO 7 DO
       IF tst<lng-1 THEN BEGIN
        INC(tst);
        IF act AND bittab[bst]=0THEN BEGIN
          IF(temp[tst]<>0)AND(bre<320)THEN BEGIN
            IF hoe<200 THEN buf[0]^[bre+hoe*320]:=temp[tst]
             ELSE IF hoe<400 THEN buf[1]^[bre+(hoe-200)*320]:=temp[tst];
          END;
          INC(bre);
        END ELSE BEGIN
          IF(temp[tst]<>0)AND(bre<320)THEN BEGIN
            IF hoe<200 THEN FILLCHAR(buf[0]^[bre+hoe*320],temp[tst+1]+1,temp[tst])
             ELSE IF hoe<400 THEN FILLCHAR(buf[1]^[bre+(hoe-200)*320],temp[tst+1]+1,temp[tst]);
          END;
          INC(tst);
          INC(bre,temp[tst]+1);
        END;
      END;
      INC(tst);
    END;
  END;
END;
BEGIN
  FOR w0:=0 TO 7 DO bittab[w0]:=TRUNC(EXP(LN(2)*w0));
  SEEK(ani,0);
  BLOCKREAD(ani,bez[1],12,w0);
  BLOCKREAD(ani,b,1,w0);
  bez[0]:=CHR(b);
  BLOCKREAD(ani,bez[1],b,w0);
  BLOCKREAD(ani,anz,2,w0);
  BLOCKREAD(ani,mode,1,w0);
  b:=FILEPOS(ani);
  REPEAT
    SEEK(ani,16+LENGTH(bez));
    pst:=0;
    bps:=0;
    GETTIME(std,min,sek,hsk);
    ctime:=std*360000+min*6000+sek*100+hsk;
    REPEAT INC(pst);
      Keys;
      IF key[1]=#27 THEN BREAK;
      BLOCKREAD(ani,b,1,w0);
      CASE b OF
        1:BEGIN
          FILLCHAR(pal[0],768,0);
          SetPal(pal);

          FILLCHAR(buf[0]^,64000,0);
          FILLCHAR(buf[1]^,64000,0);
          vscreen:=buf[0];
          P13_2_ModeX(0,16000);
          P13_2_ModeX(16000,16000);
          SetStart(0);
          actpage:=0;

          BLOCKREAD(ani,pal[3],765,w0);
          SetPal(pal);
        END;
        2:BEGIN BLOCKREAD(ani,temp,5,w0);
          br:=temp[0]+temp[1]*256;
          ho:=temp[2]+temp[3]*256;
          dau:=temp[4];

          actpage:=1-actpage;
          LC2;
          vscreen:=buf[0];
          P13_2_ModeX(actpage*32000,16000);
          vscreen:=buf[1];
          P13_2_ModeX(actpage*32000+16000,16000);
          WaitRetrace;
          SetStart(actpage*32000);

          Keys;
          IF key[1]=' ' THEN REPEAT Keys;UNTIL key[1]=' ';
          INC(bps,dau+1);
          IF key[1]=#27 THEN BREAK;
        END;
      END;
    UNTIL pst=anz;
    GETTIME(std,min,sek,hsk);
    ctime:=std*360000+min*6000+sek*100+hsk-ctime;
  UNTIL(key[1]=#27)OR(PARAMSTR(2)<>'');
END;

BEGIN
  IF (PARAMSTR(1)='/?') OR (PARAMSTR(1)='-?') THEN BEGIN
    WRITELN;WRITELN('GoldenWorks'' Animations-Player 2.2 - GCA  (c)1999 by Ronny Burkersroda');
    WRITELN;WRITELN('PLAY_GCA[.EXE] GCA-Datei');HALT;END;
  IF MEMAVAIL<256000 THEN BEGIN
    WRITELN('Zu wenig konventioneller Speicher!');HALT(1);END;

  ASSIGN(ani,PARAMSTR(1));
  RESET(ani,1);

  IF IORESULT<>0 THEN BEGIN
    WRITELN('Datei konnte nicht geîffnet werden!');HALT(4);END;
  bez[0]:=#12;
  BLOCKREAD(ani,bez[1],12,w0);
  IF bez<>erk THEN BEGIN erk[7]:='1';IF bez<>erk THEN BEGIN
      WRITELN('Kennung der Datei ist falsch!');CLOSE(ani);HALT(5);END
     ELSE typ:=110;END ELSE typ:=100;
  IF typ=100 THEN BEGIN
    WRITELN('Zum Abspielen einer GCA 1.00-Animation mu· PLAY_GCA 2.0 ausgefÅhrt werden.');
    CLOSE(ani);HALT(6);
  END;

  NEW(buf[0]);NEW(buf[1]);

  Init_ModeX;
  Enter400;

  Play_GCA;

  TEXTMODE(3);
  DISPOSE(buf[1]);DISPOSE(buf[0]);
  CLOSE(ani);

  IF bps<>0 THEN BEGIN
    WRITELN('Abspielzeit: ',ctime/100:0:1,' Sekunden');
    IF ctime<>0 THEN WRITELN('Bilder pro Sekunde: ',bps/ctime*100:0:1);
  END;
END.