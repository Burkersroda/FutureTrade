{$S-,D+,N+,E+,I-,G+,F-,M 65520,100000,555360}
{$A+,B-,P-,Q-,R-,T-,V+,X+}

PROGRAM FutureTrade;
{  (c)2000 by Ronny Burkersroda  }
{  status: version 1.01          }

USES crtn,dos,vesa,subs,errors,effects,normfont,vars,game,xms_unit,smix,getsbset,cdrom,
     sub_mml,sub_text,sub_ctrl,sub_draw,overlay;
{$O SUB_MML}
{$O SUB_MAP}
{$O FONTUNIT}
{$O SUB_DISK}

{$F+}
PROCEDURE ExitProcedure;
BEGIN
  TextMode;
  IF ErrorAddr<>NIL THEN BEGIN
    OutPut(0,0,prg_info,7);
    STR(EXITCODE,prm);prg_info:='Error '+prm;
    prm:=GetError(EXITCODE);
    IF prm<>'' THEN prg_info:=prg_info+': '+prm;
    prg_info:=prg_info+' (at ';
    prg_info:=prg_info+Dec2Hex(SEG(ErrorAddr^))+':';
    prg_info:=prg_info+Dec2Hex(OFS(ErrorAddr^))+').';
    OutPut(0,5,prg_info,7);
    GotoXY(0,7);ErrorAddr:=NIL;
  END;
  {STR(minavail,prm);
  OutPut(0,7,'least free memory while execution: '+prm+' bytes.',7);}
  SETINTVEC($1C,ecpnt);
  SETINTVEC($5,oldprnt);
  SETINTVEC($9,@TasInt);
  FOR hixms:=1 TO hixms DO XMSFree(xms[hixms]);
  FOR hixms:=0 TO 2 DO IF map[hixms]<>NIL THEN DISPOSE(map[hixms]);
  IF soundon THEN BEGIN
    CloseSoundResourceFile;
    FOR hixms:=0 TO 7 DO IF soundbyte AND(1 SHL hixms)>0THEN FreeSound(sounds[hixms]);
  END;
  IF cd_rom<>'' THEN CD_Exit;
  IF exist_SB THEN BEGIN
    ShutdownMixing;
    ShutdownSB;
    {ShutdownSharing;}
  END;
  IF page<>NIL THEN DISPOSE(page);
  IF mapx<>NIL THEN DISPOSE(mapx);
  IF road<>NIL THEN DISPOSE(road);
  IF news<>NIL THEN DISPOSE(news);
  IF vertr<>NIL THEN DISPOSE(vertr);
  IF icon<>NIL THEN DISPOSE(icon);
  IF cfo<>NIL THEN DISPOSE(cfo);
  IF tbkgr<>NIL THEN DISPOSE(tbkgr);
  ClearKeyboardBuffer;
  CHDIR(COPY(startdir,1,2));
  CHDIR(startdir);
  EXITPROC:=oldexitproc;
END;
FUNCTION DetectSVGA256:INTEGER;
BEGIN
  DetectSVGA256:=videomode;
END;
PROCEDURE KeyInt;INTERRUPT;
BEGIN
  IF(PORT[$60]=83)AND(stat AND 12=12)THEN BEGIN
    stat:=stat AND NOT 8;
    INLINE($9C);
    TasInt;
    HALT(1024);
  END ELSE IF(PORT[$60]=31)AND(stat AND 12=12)THEN BEGIN
    savepic:=TRUE;
  END;
  INLINE($9C);
  TasInt;
END;
PROCEDURE PrntInt;INTERRUPT;
BEGIN
  savepic:=TRUE;
END;
PROCEDURE Timer;INTERRUPT;
BEGIN
  INLINE($9C);INLINE($FF/$1E/ecpnt);
  INC(time);INC(tip.time);INC(cdtimecounter);
  IF active AND 17=0 THEN BEGIN IF trk.dis<>0 THEN INC(trk.pos,2);
    IF enemy.endtime=0 THEN INC(enemy.position,4)
     ELSE INC(enemy.staytime);
    IF active AND 4=4 THEN INC(ttime) ELSE ttime:=0;END;
  IF MAXAVAIL<minavail THEN minavail:=MAXAVAIL;
END;
{$F-}

PROCEDURE Init_System;
CONST s0:ARRAY[1..2] OF CHAR=(':',' ');
      nicht:ARRAY[1..6] OF CHAR=('N','I','C','H','T',' ');
      inipos:BYTE=0;
VAR zeile:BYTE;txf:TEXT;w:WORD;reg:REGISTERS;
    s1:STRING[3];s2:STRING[80];s3:STRING[10];
PROCEDURE OutT(st:STRING);
BEGIN
  OutBTxt(0,50+zeile*12,st,245);
  INC(zeile);
END;
PROCEDURE Stop(fnr:BYTE;st1:STRING);
VAR nrst:STRING[3];
BEGIN
  STR(fnr,nrst);
  OutT('');
  OutBTxt(0,50+zeile*12,'FEHLER '+nrst+': '+st1+'!',252);
  OutBTxt((LENGTH(nrst)+9)*9,50+zeile*12,st1,245);
  INC(zeile);
  OutT('<ENTER>');
  REPEAT Keys;
  UNTIL key[1]=#13;
  HALT(fnr);
END;
CONST ini_open:BOOLEAN=FALSE;
      eSB:BOOLEAN=FALSE;
VAR palb:Pal256;w0:WORD;sr:SEARCHREC;
BEGIN
  zeile:=0;
  s2:=PARAMSTR(0);
  FOR w:=1 TO LENGTH(s2)DO IF s2[w]='\'THEN zeile:=w;
  GETDIR(0,startdir);
  IF zeile<>0 THEN BEGIN
    s2:=COPY(s2,1,zeile);
    IF LENGTH(s2)>3 THEN s2:=COPY(s2,1,LENGTH(s2)-1);
    CHDIR(COPY(s2,1,2));
    CHDIR(s2);
  END;
  RANDOMIZE;
  exist_SB:=FALSE;
  FILLCHAR(pal,768,0);
  SetPal(pal);
  zeile:=0;
  ms.on:=FALSE;
  NEW(page);
  XPal;
  InPic(pal,4,236,255);
  s1:='VID';
  OutT(s1+s0+'VIDEOMODUS '+GETMODENAME(videomode)+' AKTIVIERT');
  s1:='OVR';
  OvrInit('FTRADE.EXE');
  IF OVRRESULT<>0 THEN s2:=nicht ELSE s2:='';
  OutT(s1+s0+'OVERLAY '+s2+'INITIIERT');
  IF s2<>'' THEN Stop(12,'DAS OVERLAY KONNTE NICHT INITIIERT WERDEN');
  STR(OVRGETBUF/1024:0:1,s2);
  OutT(s1+s0+s2+' KB OVERLAY-PUFFER');
  OutText(0,0,'INITIALISIERUNG: FUTURETRADE 1.01',236,0,1);
  s1:='CPU';
  CASE Test8086 OF
    0:s2:='XT';
    1:s2:='80286';
    2:s2:='32-BIT';
  END;
  OutT(s1+s0+s2+'-PROZESSOR');
  IF w<2 THEN Stop(1,'DIE PROZESSORLEISTUNG IST NICHT AUSREICHEND');
  IF Test8087=0 THEN s2:=nicht ELSE s2:='';
  OutT(s1+s0+'CO-PROZESSOR '+s2+'ERKANNT');
  s1:='I/O';
  exist_M:=Mouse_Exist;
  MouseReset;ms.b:=0;ms.x:=320;ms.y:=240;ms.ox:=320;ms.oy:=240;
  IF exist_M THEN s2:='' ELSE s2:=nicht;
  OutT(s1+s0+'MOUSE-TREIBER '+s2+'ERKANNT');
  IF s2=nicht THEN Stop(2,'ZUM SPIELEN WIRD EINE MOUSE BEN™TIGT');
  reg.ax:=$1500;reg.bx:=$0;INTR($2F,reg);
  IF reg.bx=0 THEN s2:=nicht ELSE s2:='';
  OutT(s1+s0+'CD-ROM-TREIBER '+s2+'ERKANNT');
  IF s2='' THEN BEGIN
    s2:=CHR(reg.cx+65)+':';
    FINDFIRST(s2+'\*.*',$3F,sr);
    WHILE(DOSERROR=0)AND(sr.name<>'INSTALL.FFL')DO FINDNEXT(sr);
    IF sr.name<>'INSTALL.FFL' THEN Stop(3,'CD KONNTE NICHT IM LAUFWERK '+s2+' ERKANNT WERDEN')
     ELSE cd_rom:=s2+'\';
  END ELSE Stop(13,'EIN CD-ROM-TREIBER MUSS INSTALLIERT SEIN');
  IF cd_rom<>'' THEN CD_Init;
  s1:='MEM';STR(MEMAVAIL/1024:0:1,s2);
  IF MEMAVAIL<216064 THEN BEGIN OutT(s1+s0+'SPEICHERBEREICH ZU KLEIN');
    Stop(4,'ES WERDEN MINDESTENS 500 KB KONVENTIONELLER SPEICHER BEN™TIGT');
  END ELSE OutT(s1+s0+'KONVENTIONELLER SPEICHER IN ORDNUNG ('+s2+' KB)');
  NEW(mapx);NEW(road);NEW(vertr);NEW(icon);NEW(cfo);NEW(tbkgr);
  NEW(map[0]);NEW(map[1]);
  IF NOT XMSInstalled THEN BEGIN OutT(s1+s0+'XMS '+nicht+'INSTALLIERT');
    Stop(5,'ES MUSS EIN XMS-TREIBER INSTALLIERT SEIN');END;
  XMSInit;
  STR(HI(XMSGetVersion),s2);
  STR(LO(XMSGetVersion):2,s3);
  IF s3[1]=' 'THEN s3[1]:='0';
  OutT(s1+s0+'XMS-TREIBER '+s2+'.'+s3+' GEFUNDEN');
  STR(GetFreeXMS,s2);
  IF GetFreeXMS<800 THEN BEGIN OutT(s1+s0+'XMS-SPEICHER ZU GERING');
    Stop(6,'ES MUSS 1024 KB FREIER XMS-SPEICHER VORHANDEN SEIN');
  END ELSE OutT(s1+s0+'XMS-SPEICHER IN ORDNUNG ('+s2+' KB)');
  FOR hixms:=1 TO 64 DO xms[hixms]:=0;
  hixms:=0;
  WHILE(hixms<1)AND(XMSAllocate(xms[hixms+1],800))DO INC(hixms);
  STR(hixms,s2);
  OutT(s1+s0+s2+'*800 KB XMS ALLOKIERT');
  IF hixms<1 THEN Stop(7,'ES KONNTE KEIN XMS ALLOKIERT WERDEN');
  STR(GetFreeXMS,s2);
  {InitSharing;}
  IF DISKFREE(0)<1485760 THEN BEGIN
    s2:='';
    s3:=nicht
  END ELSE BEGIN
    s3:='';
    STR(DISKFREE(0)/1048576:0:1,s2);
    s2:=' ('+s2+' MB)';
  END;
  OutT(s1+s0+'HD-SPEICHER '+s3+'IN ORDNUNG'+s2);
  IF s3=nicht THEN Stop(12,'SPEICHER FšR SPIELSTŽNDE AUF DER FESTPLATTE IST ZU GERING');
  s1:='INI';
  ASSIGN(txf,ini_name);RESET(txf);
  IF IORESULT<>0 THEN BEGIN CLOSE(txf);RESET(txf);END;
  IF IORESULT=0 THEN BEGIN ini_open:=TRUE;s2:='GE™FFNET';END ELSE
   BEGIN ini_open:=FALSE;s2:='NICHT GEFUNDEN';END;
  OutT(s1+s0+'SETUP-DATEI '+s2);
  IF ini_open THEN BEGIN
    REPEAT READLN(txf,s2);
      s2:=UpString(s2);
      IF s2=UpString(ini_kopf)THEN inipos:=1 ELSE
       IF s2=UpString(ini_sound)THEN inipos:=2 ELSE
       IF s2=UpString(ini_cheat)THEN inipos:=3 ELSE
       IF(s2[1]='[')AND(s2[ORD(s2[0])]=']')THEN inipos:=255;
      w:=POS('=',s2);s3:=COPY(s2,w+1,LENGTH(s2)-w);s2:=COPY(s2,1,w-1);
      IF(s2<>'')AND(s3<>'')THEN BEGIN
        CASE inipos OF 1:BEGIN
            IF s2=ini_list00 THEN BEGIN VAL(s3,gamma,w);
              IF(gamma<1)OR(gamma>10)THEN gamma:=5;END;
            IF s2=ini_list01 THEN IF s3=an THEN syncanimation:=TRUE
             ELSE IF s3=aus THEN syncanimation:=FALSE;
            IF(s2=ini_list02)AND((s3='HI')OR(s3=aus)OR(s3='LO'))THEN MOVE(s3[1],mml_anim[1],LENGTH(s3));
            IF s2=ini_list03 THEN installdir:=s3;
            IF s2=ini_list04 THEN IF s3=an THEN dithering:=1
             ELSE IF s3=aus THEN dithering:=0;
            IF s2=ini_list05 THEN IF s3=an THEN quicktips:=TRUE
             ELSE IF s3=aus THEN quicktips:=FALSE;
          END;
          2:BEGIN
            IF s2=ini_list10 THEN BEGIN
              IF s3=an THEN sbautodetect:=TRUE
              ELSE IF s3=aus THEN sbautodetect:=FALSE;
            END;
            IF s2=ini_list11 THEN BEGIN
              base_io:=Hex2Dec(s3);
              STR(base_io,s3);
              IF base_io=0 THEN Stop(8,'FEHLER IN FT.INI BEI '+ini_list11);
            END ELSE IF s2=ini_list12 THEN BEGIN
              VAL(s3,dsp_irq,w);
              IF w<>0 THEN Stop(8,'FEHLER IN FT.INI BEI '+ini_list12);
            END ELSE IF s2=ini_list13 THEN BEGIN
              VAL(s3,dsp_dma8,w);
              IF w<>0 THEN Stop(8,'FEHLER IN FT.INI BEI '+ini_list13);
              dsp_dma16:=dsp_dma8;
            END;
            IF s2=ini_list14 THEN BEGIN
              IF s3=an THEN soundon:=TRUE
              ELSE IF s3=aus THEN soundon:=FALSE;
            END;
            IF s2=ini_list15 THEN BEGIN
              IF s3=an THEN cdmusic:=TRUE
              ELSE IF s3=aus THEN cdmusic:=FALSE;
            END;
          END;
          3:BEGIN
            IF s2=ini_list20 THEN IF s3=an THEN cheats:=cheats OR 1
             ELSE IF s3=aus THEN cheats:=cheats AND NOT 1;
            IF s2=ini_list21 THEN VAL(s3,cheatmoney,w0);
            IF s2=ini_list22 THEN IF s3=aus THEN cheats:=cheats OR 4
             ELSE IF s3=an THEN cheats:=cheats AND NOT 4;
          END;
        END;
      END;
    UNTIL EOF(txf);
    IF inipos>0 THEN OutT(s1+s0+'WERTE GESETZT');
    CLOSE(txf);
  END;
  s1:='MML';
  ASSIGN(pf,mml_main);RESET(pf,1);
  IF IORESULT=0 THEN BEGIN {mml_main:='';}
    BLOCKREAD(pf,page^[1],8,w);s2:='';
    FOR w:=1 TO w DO s2:=s2+CHR(page^[w]);
    IF s2<>mml_kopf THEN BEGIN OutT(s1+s0+s1+'-FEHLER');
      Stop(9,'DER DATEIKOPF ENTSPRICHT NICHT DER '+s1+'-NORM');END;
    BLOCKREAD(pf,page^[1],80,w);s2:='';
    FOR w:=1 TO w DO s2:=s2+CHR(page^[w]);
    mml_spos:=POS(mml_tend,s2);
    IF mml_spos=0 THEN BEGIN OutT(s1+s0+s1+'-FEHLER');
      Stop(10,'DIE '+s1+'-DATEI KONNTE NICHT RICHTIG GELESEN WERDEN');END;
    INC(mml_spos,10);
  END ELSE OutT(s1+s0+s1+'-DATEI GE™FFNET');
  IF NOT LoadMMLtrack(500,0,0,'til.Lightrock',234) THEN BEGIN
    OutT(s1+s0+'TEST-BILD '+nicht+'GELADEN');
    Stop(11,'TEST-BILD KANN NICHT AUS DER '+s1+'-DATEI GELESEN WERDEN');
  END ELSE OutT(s1+s0+'BILD GELADEN');
  IF soundon AND OpenSoundResourceFile('SOUND.LIB')THEN s2:='' ELSE BEGIN
    s2:=nicht;
    soundon:=FALSE;
  END;
  OutT(s1+s0+'SOUND-LIBRARY '+s2+'GE™FFNET');
  IF soundon AND LoadSound(sounds[1],'CLICK')THEN BEGIN
    s2:='';
    soundbyte:=2;
  END ELSE BEGIN
    s2:=nicht;
    soundon:=FALSE;
  END;
  OutT(s1+s0+'SAMPLES '+s2+'EINGELADEN');
  s1:='SND';
  IF soundon AND sbautodetect THEN BEGIN
    IF NOT GetSettings(base_io,dsp_irq,dsp_dma8,dsp_dma16)THEN s2:=nicht
     ELSE s2:='';
    OutT(s1+s0+'BLASTER-VARIABLE '+s2+'GEFUNDEN UND GELESEN');
  END;
  IF soundon AND InitSB(base_io,dsp_irq,dsp_dma8,dsp_dma16)THEN BEGIN
    exist_SB:=TRUE;s2:='';
    IF HI(dspversion)>=2 THEN BEGIN
      IF sixteenbit THEN s2:='16 ' ELSE s2:='PRO ';
    END;
    InitMixing;
  END ELSE BEGIN
    s2:='NICHT ';
    exist_SB:=FALSE;
  END;
  OutT(s1+s0+'SOUNDBLASTER '+s2+'ERKANNT');
  IF exist_SB THEN BEGIN
    SetMasterVolume(255);SetCDVolume(255);SetWaveVolume(128);
    s3:=Dec2Hex(base_io);
    s2:='BASE='+s3+' HEX # ';
    STR(dsp_irq,s3);
    s2:=s2+'IRQ='+s3+' # ';
    STR(dsp_dma8,s3);
    s2:=s2+'DMA8='+s3;
    IF sixteenbit THEN BEGIN STR(dsp_dma16,s3);
      s2:=s2+' # DMA16='+s3;
    END;
    OutT(s1+s0+s2);
    OutT(s1+s0+'SMIX 1.3-SOUNDSYSTEM INITIIERT. (C)1995 ETHAN BRODSKY');
  END;
  s1:='IRQ';
  SETINTVEC($5,@PrntInt);
  {SETINTVEC($9,@KeyInt);
  OutT(s1+s0+'TASTATUR-INTERRUPTS VERBOGEN');}
  SETCBREAK(TRUE);CHECKBREAK:=TRUE;
  OutT(s1+s0+'STRG+C DEAKTIVIERT');
  SETINTVEC($1C,@Timer);
  OutT(s1+s0+'TIMER AKTIVIERT');
  s1:='MEM';STR(MEMAVAIL/1000:0:1,s2);
  OutT(s1+s0+s2+' KB SPEICHER NOCH VERFšGBAR');
  {REPEAT UNTIL KEYPRESSED;}
  tip.xpos:=-1;
  ms.arrow:=FALSE;
  REPEAT
    ASM
      MOV AH,02
      INT 16h
      MOV b1,AL
    END;
  UNTIL b1 AND 8=0;
  OutPic(pal,4,0,255);
  LoadMMLtrack(0,0,0,'ico',0);
  FOR b1:=0 TO 14 DO FOR b2:=0 TO 19 DO FOR b3:=0 TO 19 DO BEGIN
    icon^[b1,b2,b3]:=GETPIXEL((b1-b1 DIV 5*5)*20+b2+0,b1 DIV 5*20+b3+0);
    icon^[b1,b2,b3]:=(pal[icon^[b1,b2,b3],0]+pal[icon^[b1,b2,b3],1]+
     pal[icon^[b1,b2,b3],0]);
    IF icon^[b1,b2,b3]>0 THEN icon^[b1,b2,b3]:=icon^[b1,b2,b3] DIV 13+236;
  END;
  LoadMMLtrack(0,0,0,'til.1',0);
  MOVE(pal[0,0],tilpal[0],192);
  FOR b3:=0 TO 15 DO FOR b1:=0 TO 39 DO BEGIN w:=WORD(b1)*40+WORD(b3)*1600;
    FOR b2:=0 TO 39 DO page^[w+b2]:=GETPIXEL(b2+WORD(b3)*40,b1)+160;
  END;
  FOR b3:=0 TO 15 DO FOR b1:=0 TO 39 DO BEGIN w:=WORD(b1)*40+WORD(b3)*1600+25600;
    FOR b2:=0 TO 39 DO page^[w+b2]:=GETPIXEL(b2+WORD(b3)*40,b1+40)+160;
  END;
  FOR b3:=0 TO 7 DO FOR b1:=0 TO 39 DO BEGIN w:=WORD(b1)*40+WORD(b3)*1600+51200;
    FOR b2:=0 TO 39 DO page^[w+b2]:=GETPIXEL(b2+WORD(b3)*40,b1+440)+160;
  END;
  RAM2XMS(page,xms[1],64000,187500);
  CLEARDEVICE;
END;

BEGIN
  oldexitproc:=EXITPROC;
  GETINTVEC($1C,ecpnt);
  GETINTVEC($5,oldprnt);
  GETINTVEC($9,@TasInt);
  TextMode;
  OutPut(0,0,prg_info,7);
  l1:=0;FOR b1:=1 TO 84 DO INC(l1,ORD(prg_info[b1]));
  IF(HI(l1)<>12*4-24)OR(LO(l1)<>194)THEN BEGIN
    OutPut(0,5,'Code modified, program haltet (255).',7);
    GotoXY(0,7);HALT(255);
  END;
  IF MEMAVAIL<250000 THEN BEGIN
    OutPut(0,5,'ERROR 001: Too few memory.',7);GotoXY(0,7);HALT(1);END;
  IF SVGAInit<>0 THEN BEGIN
    OutPut(0,5,'ERROR 002: Not able to activate VESA.',7);GotoXY(0,7);HALT(2);END;
  IF SetGraphMode($101)<>0 THEN BEGIN
    OutPut(0,5,'ERROR 003: Not able to switch to VESA-Mode 101hex.',7);GotoXY(0,7);HALT(3);END;
  InstallUserDriver;
  EXITPROC:=@ExitProcedure;
  Init_System;
  PlayGame;
  CLOSE(pf);
END.