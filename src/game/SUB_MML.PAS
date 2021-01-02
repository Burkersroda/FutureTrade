{$O+,G+,S-,F+,I-}
UNIT SUB_MML;
INTERFACE USES VARS,VESA,EFFECTS,SPX_CLK,MODEXLIB,CRTN,SMIX,CDROM,SUB_CTRL,SUB_DRAW;
FUNCTION LoadMMLtrack(ssx,ssy:WORD;coeff:WORD;labl:STRING;palend:BYTE):BOOLEAN;
PROCEDURE Intro(anim:BOOLEAN);
PROCEDURE Outro;
PROCEDURE GameOver(typ:BYTE);
IMPLEMENTATION
PROCEDURE OpenMML(st0:STRING;VAR tof:BOOLEAN);
VAR w0:WORD;non:BOOLEAN;
BEGIN
  tof:=FALSE;
  CLOSE(pf);ASSIGN(pf,st0);RESET(pf,1);
  IF IORESULT=0 THEN BEGIN
    BLOCKREAD(pf,page^[1],8,w0);st0:='';
    FOR w0:=1 TO w0 DO st0:=st0+CHR(page^[w0]);
    IF st0<>mml_kopf THEN BEGIN CLOSE(pf);OpenMML(mml_main,non);EXIT;END;
    BLOCKREAD(pf,page^[1],80,w0);st0:='';
    FOR w0:=1 TO w0 DO st0:=st0+CHR(page^[w0]);
    mml_spos:=POS(mml_tend,st0);
    IF mml_spos=0 THEN BEGIN CLOSE(pf);OpenMML(mml_main,non);EXIT;END;
    INC(mml_spos,10);
    tof:=TRUE;
  END;
END;
PROCEDURE Intro(anim:BOOLEAN);
VAR s1:STRING[1];
    mml_open:BOOLEAN;
PROCEDURE ShowIntro;
BEGIN
  esc:=TRUE;
  Keys;IF key[1]=#27 THEN EXIT;
  FILLCHAR(pal,768,0);
  SetPal(pal);
  soundbyte:=0;
  IF exist_SB THEN BEGIN
    IF LoadSound(sounds[0],'LGHTROCK')THEN soundbyte:=soundbyte OR 1;
    IF soundbyte AND 1=1 THEN StartSound(sounds[0],0,FALSE);
  END;
  LoadMMLtrack(0,0,0,'Lightrock Entertainment',255);
  IF soundbyte AND 1=1THEN BEGIN
    soundbyte:=soundbyte AND NOT 1;
    StopSound(0);
    FreeSound(sounds[0]);
  END;
  IF key[1]=#27 THEN EXIT;
  IF exist_SB THEN BEGIN
    FOR b1:=0 TO 3 DO BEGIN STR(b1+1,s1);
      IF LoadSound(sounds[b1],'INTRO'+s1)THEN soundbyte:=soundbyte OR(1 SHL b1);
    END;
  END;
  IF cdmusic AND(cd_rom<>'')THEN CD_Play(1);
  LoadMMLtrack(0,0,0,'Vorspann',255);
  IF key[1]=#27 THEN EXIT;
  FOR b1:=0 TO 3 DO  BEGIN STR(b1+1,s1);
    IF soundbyte AND(1 SHL b1)>0 THEN StartSound(sounds[b1],0,FALSE);
    LoadMMLtrack(0,1,0,'Intro '+s1,255);
    IF key[1]=#27 THEN EXIT;
  END;
END;
BEGIN
  OutPic(pal,4,0,255);
  Keys;
  IF soundbyte AND 2=2 THEN FreeSound(sounds[1]);
  soundbyte:=0;
  IF(mml_anim[3]='-')AND(key[1]<>#27)THEN BEGIN
    OpenMML(mml_anim,mml_open);
    IF mml_open THEN BEGIN
      CLOSEGRAPH;
      Init_ModeX;
      Enter400;
      Delay(1000);
      ShowIntro;
      CD_Stop;
      IF soundbyte>0 THEN BEGIN
        StopSound(0);
        FOR b1:=3 DOWNTO 0 DO IF soundbyte AND(1 SHL b1)>0THEN FreeSound(sounds[b1]);
        soundbyte:=soundbyte AND NOT 15;
      END;
      {in0:=DETECT;INITGRAPH(in0,in1,'');}
      SetGraphMode($101);
      Mouse_Exist;MouseReset;
    END;
  END;
  IF LoadSound(sounds[1],'CLICK')THEN soundbyte:=soundbyte OR 2;
  OpenMML(mml_main,mml_open);
  CLEARDEVICE;
  IF anim THEN BEGIN
    IF LoadSound(sounds[0],'TITEL')THEN soundbyte:=soundbyte OR 1;
    IF soundbyte AND 1=1 THEN StartSound(sounds[0],0,FALSE);
    LoadMMLtrack(65535,0,0,'ani.Titel',255);
    IF soundbyte AND 1=1THEN BEGIN
      soundbyte:=soundbyte AND NOT 1;
      StopSound(0);
      FreeSound(sounds[0]);
    END;
  END;
  SetVisualPage(GetActivePage);
  SetActivePage(1-GetActivePage);
  LoadMMLtrack(0,0,0,'scr.Titel',0);
  XPal;
  WaitRetrace;
  SetVisualPage(GetActivePage);
  SetPal(pal);
  GetCFOriginals(TRUE);
END;
PROCEDURE Outro;
VAR mml_open:BOOLEAN;
PROCEDURE ShowOutro;
VAR st0:STRING[2];
BEGIN
  IF exist_SB THEN BEGIN
    FOR b1:=0 TO 9 DO BEGIN STR(b1+1,st0);
      IF LoadSound(sounds[b1],'OUTRO'+st0)THEN soundbyte:=soundbyte OR(1 SHL b1);
    END;
  END;
  IF cdmusic AND(cd_rom<>'')THEN CD_Play(4);
  FOR b1:=0TO 10DO BEGIN
    BlackPal;STR(b1+1,st0);
    IF soundbyte AND(1 SHL b1)>0 THEN StartSound(sounds[b1],0,FALSE);
    LoadMMLtrack(0,0,0,'Outro '+st0,255);IF key[1]=#27 THEN EXIT;
  END;
END;
BEGIN
  esc:=TRUE;
  Keys;IF key[1]=#27 THEN EXIT;
  IF soundbyte AND 2=2 THEN FreeSound(sounds[1]);
  soundbyte:=0;
  IF mml_anim[3]='-' THEN BEGIN
    OpenMML(mml_anim,mml_open);
    IF mml_open THEN BEGIN
      CLOSEGRAPH;
      Init_ModeX;
      Enter400;
      Delay(1000);
      ShowOutro;
      CD_Stop;
      IF soundbyte>0 THEN BEGIN
        StopSound(0);
        FOR b1:=9 DOWNTO 0 DO IF soundbyte AND(1 SHL b1)>0THEN FreeSound(sounds[b1]);
        soundbyte:=soundbyte AND NOT 1023;
      END;
      {in0:=DETECT;INITGRAPH(in0,in1,'');}
      SetGraphMode($101);
      Mouse_Exist;MouseReset;
    END;
  END;
  IF LoadSound(sounds[1],'CLICK')THEN soundbyte:=soundbyte OR 2;
  XPal;
  OpenMML(mml_main,mml_open);
  CLEARDEVICE;
  LoadMMLtrack(0,0,0,'scr.Titel',235);
  XPal;
  WaitRetrace;
  SetPal(pal);
  SetVisualPage(GetActivePage);
  active:=active AND NOT 5;
  GetCFOriginals(TRUE);
END;
PROCEDURE GameOver(typ:BYTE);
VAR mml_open:BOOLEAN;
PROCEDURE ShowOutro;
VAR s1:STRING[1];
BEGIN
  esc:=TRUE;
  Keys;IF key[1]=#27 THEN EXIT;
  IF typ=1 THEN BEGIN
    IF exist_SB THEN FOR b1:=0 TO 3 DO BEGIN STR(b1+1,s1);
      IF LoadSound(sounds[b1],'DEATH'+s1)THEN soundbyte:=soundbyte OR(1 SHL b1);
    END;
    IF cdmusic AND(cd_rom<>'') THEN CD_Play(2);
    BlackPal;
    IF soundbyte AND 1=1 THEN StartSound(sounds[0],0,FALSE);
    LoadMMLtrack(0,0,0,'Game Over 1',255);IF key[1]=#27 THEN EXIT;
    BlackPal;
    IF soundbyte AND 2=2 THEN StartSound(sounds[1],0,FALSE);
    LoadMMLtrack(0,0,0,'Game Over 2',255);IF key[1]=#27 THEN EXIT;
    BlackPal;
    IF soundbyte AND 4=4 THEN StartSound(sounds[2],0,FALSE);
    LoadMMLtrack(0,0,0,'Game Over 3',255);IF key[1]=#27 THEN EXIT;
    BlackPal;
    LoadMMLtrack(32769,0,0,'Game Over 4',255);
    IF soundbyte AND 8=8 THEN StartSound(sounds[3],0,FALSE);
    InPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
    LoadMMLtrack(32768,0,0,'Game Over 4',255);IF key[1]=#27 THEN EXIT;
    BlackPal;
    LoadMMLtrack(0,0,0,'Game Over 5',255);IF key[1]=#27 THEN EXIT;
    BlackPal;
    LoadMMLtrack(0,0,0,'Game Over 6',255);IF key[1]=#27 THEN EXIT;
    OutPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
  END ELSE BEGIN
    IF exist_SB THEN FOR b1:=0 TO 3 DO BEGIN STR(b1+1,s1);
      IF LoadSound(sounds[b1],'CAPTIVE'+s1)THEN soundbyte:=soundbyte OR(1 SHL b1);
    END;
    IF cdmusic AND(cd_rom<>'') THEN CD_Play(3);
    BlackPal;
    IF soundbyte AND 1=1 THEN StartSound(sounds[0],0,FALSE);
    LoadMMLtrack(0,0,0,'Game Over 7',255);IF key[1]=#27 THEN EXIT;
    BlackPal;
    IF soundbyte AND 2=2 THEN StartSound(sounds[1],0,FALSE);
    LoadMMLtrack(0,0,0,'Game Over 8',255);IF key[1]=#27 THEN EXIT;
    BlackPal;
    IF soundbyte AND 4=4 THEN StartSound(sounds[2],0,FALSE);
    LoadMMLtrack(0,0,0,'Game Over 9',255);IF key[1]=#27 THEN EXIT;
    BlackPal;
    IF soundbyte AND 8=8 THEN StartSound(sounds[3],0,FALSE);
    LoadMMLtrack(0,0,0,'Game Over 10',255);IF key[1]=#27 THEN EXIT;
    OutPic(pal,1,0,255);IF key[1]=#27 THEN EXIT;
  END;
END;
BEGIN
  IF soundbyte AND 2=2 THEN FreeSound(sounds[1]);
  soundbyte:=0;
  IF mml_anim[3]='-' THEN BEGIN
    OpenMML(mml_anim,mml_open);
    IF mml_open THEN BEGIN
      CLOSEGRAPH;
      Init_ModeX;
      Enter400;
      Delay(1000);
      ShowOutro;
      CD_Stop;
      IF soundbyte>0 THEN BEGIN
        StopSound(0);
        FOR b1:=3 DOWNTO 0 DO IF soundbyte AND(1 SHL b1)>0THEN FreeSound(sounds[b1]);
        soundbyte:=soundbyte AND NOT 63;
      END;
      SetGraphMode($101);
      Mouse_Exist;MouseReset;
    END;
  END;
  IF LoadSound(sounds[1],'CLICK')THEN soundbyte:=soundbyte OR 2;
  XPal;
  OpenMML(mml_main,mml_open);
  CLEARDEVICE;
  LoadMMLtrack(0,0,0,'scr.Titel',235);
  XPal;
  WaitRetrace;
  SetPal(pal);
  SetVisualPage(GetActivePage);
  active:=active AND NOT 5;
  GetCFOriginals(TRUE);
END;
FUNCTION LoadMMLtrack(ssx,ssy:WORD;coeff:WORD;labl:STRING;palend:BYTE):BOOLEAN;
VAR tanz,tco,sx,sy,blockpos:WORD;
    temp:ARRAY[0..1023]OF BYTE;
    filetemp:m32k;
    s40:STRING[40];
    sp:LONGINT;
    typ:BYTE;
PROCEDURE ReadFile(count:WORD);
VAR w00,w01:WORD;
BEGIN
  IF blockpos=0 THEN BLOCKREAD(pf,filetemp,32768,w00);
  IF count+blockpos<=32768 THEN BEGIN
    MOVE(filetemp[blockpos],temp,count);
    INC(blockpos,count);
  END ELSE BEGIN
    w01:=32768-blockpos;
    MOVE(filetemp[blockpos],temp,w01);
    BLOCKREAD(pf,filetemp,32768,w00);
    blockpos:=count-w01;
    MOVE(filetemp,temp[w01],blockpos);
  END;
  IF blockpos=32768 THEN blockpos:=0;
END;
FUNCTION LiesTrack:BOOLEAN;
FUNCTION Bild8Bit:BOOLEAN;
VAR br,ho,bre,hoe,lng,tst:WORD;col,act,bst:BYTE;
    gd,gm:INTEGER;
BEGIN
  Bild8Bit:=FALSE;

  SEEK(pf,sp);
  blockpos:=0;
  ReadFile(776);

  br:=temp[4]+temp[5]*256;
  ho:=temp[6]+temp[7]*256;
  IF ssx=65535 THEN sx:=(GETMAXX+1-br)DIV 2 ELSE sx:=ssx;
  IF ssy=65535 THEN sy:=(GETMAXY+1-ho)DIV 2 ELSE sy:=ssy;
  IF ssx=65534 THEN BEGIN sx:=0;sy:=0;END;
  FILLCHAR(pal[0],WORD(palend+1)*3,0);
  IF palend>0 THEN BEGIN SetPal(pal);MOVE(temp[8],pal[0],WORD(palend+1)*3);
  END ELSE MOVE(temp[8],pal[0],768);
  FOR hoe:=0 TO ho-1 DO BEGIN
    ReadFile(2);
    lng:=temp[0]+temp[1]*256;
    ReadFile(lng);
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
VAR palcng:BOOLEAN;
    dau,actpage,act,bitst,bufnr,bufho:BYTE;
    br,ho,anz,pst,bre,hoe,hoehe,lng,tst,addy,addx:WORD;
    l00,l01,l02:LONGINT;
    scrbuf:ARRAY[0..1]OF ^ScrArray;
BEGIN
  GCAni:=FALSE;

  SEEK(pf,sp+4);
  blockpos:=0;
  ReadFile(3);
  anz:=temp[0]+temp[1]*256;

  actpage:=0;
  pst:=0;
  time:=0;
  palcng:=FALSE;

  DISPOSE(map[1]);map[1]:=NIL;
  DISPOSE(map[0]);map[0]:=NIL;
  NEW(scrbuf[0]);NEW(scrbuf[1]);
  FILLCHAR(scrbuf[0]^,64000,0);
  FILLCHAR(scrbuf[1]^,64000,0);


  REPEAT
    INC(pst);
    Keys;IF key[1]=#27 THEN BREAK;
    ReadFile(1);
    CASE temp[0] OF
      1:BEGIN
        IF(ssx<>32768)THEN BEGIN
          FILLCHAR(pal[0,0],WORD(palend)*3,0);
          {SetPal(pal);}
        END;

        br:=0;ho:=0;
        IF(ssx<>32768)AND(ssx<>32769)THEN palcng:=TRUE;

        ReadFile(765);
        MOVE(temp,pal[1,0],WORD(palend)*3);

        l00:=GetClock;
        l02:=0;
      END;
      2:BEGIN
        ReadFile(5);
        br:=temp[0]+temp[1]*256;
        ho:=temp[2]+temp[3]*256;
        dau:=temp[4];

        IF(ssx=65535)THEN SetActivePage(1-GetActivePage);

        FOR hoehe:=0 TO ho-1 DO BEGIN
          IF ho<=200 THEN hoe:=hoehe*2
          ELSE hoe:=hoehe;

          bufnr:=hoe DIV 200;
          bufho:=hoe MOD 200;

          ReadFile(2);
          lng:=temp[0]+temp[1]*256;

          ReadFile(lng);
          bre:=0;
          tst:=0;
          addy:=WORD(bufho)*320;
          WHILE tst<lng-1 DO BEGIN
            act:=temp[tst];
            FOR bitst:=0 TO 7 DO
             IF tst<lng-1 THEN BEGIN
              INC(tst);
              IF act AND(1 SHL bitst)=0THEN BEGIN
                IF temp[tst]<>0 THEN BEGIN
                  IF(ssx<>65535)THEN BEGIN
                    IF bufnr<2 THEN scrbuf[bufnr]^[addy+bre]:=temp[tst];
                  END ELSE PutPixel(bre,hoehe,temp[tst]);
                END;
                INC(bre);
              END ELSE BEGIN
                addx:=temp[tst+1]+1;
                IF temp[tst]<>0 THEN BEGIN
                  IF(ssx<>65535)THEN BEGIN
                    IF bufnr<2 THEN FILLCHAR(scrbuf[bufnr]^[addy+bre],addx,temp[tst]);
                  END ELSE PutHorizontalLine(bre,bre+addx-1,hoehe,temp[tst]);
                END;
                INC(tst);
                INC(bre,addx);
              END;
            END;
            INC(tst);
          END;
        END;

        IF(ssx<>65535)THEN BEGIN
          actpage:=1-actpage;
          vscreen:=scrbuf[0];
          P13_2_ModeX(actpage*32000,16000);
          vscreen:=scrbuf[1];
          P13_2_ModeX(actpage*32000+16000,16000);
          IF syncanimation THEN WaitRetrace;
          SetStart(actpage*32000);
        END ELSE SetVisualPage(GetActivePage);

        IF palcng THEN BEGIN SetPal(pal);palcng:=FALSE;END;

        REPEAT
          l01:=GetClock;
          IF l01<>l00 THEN BEGIN
            INC(l02,l01-l00);
            l00:=l01;
          END;
        UNTIL l02>=(dau+1)*fpsticks;
        DEC(l02,fpsticks);

        IF KEYPRESSED THEN key[1]:=CHAR(LO(READKEY));
        IF(key[1]=#27){OR(key[1]=#32)}THEN BREAK;
      END;
    END;
  UNTIL(pst=anz)OR((ssx=32769)AND(pst=2));
  DISPOSE(scrbuf[1]);DISPOSE(scrbuf[0]);
  NEW(map[0]);NEW(map[1]);
END;
FUNCTION Karte:BOOLEAN;
VAR w0:WORD;
BEGIN
  Karte:=FALSE;
  SEEK(pf,sp);
  BLOCKREAD(pf,map[0]^,4,w0);
  IF w0<>4 THEN EXIT;
  BLOCKREAD(pf,map[0]^,62500,w0);
  Karte:=TRUE;
END;
BEGIN
  CASE typ OF
    1:LiesTrack:=Karte;
    {1:LiesTrack:=Entpacken;
    2:LiesTrack:=BlockEntpacken;}
    3:LiesTrack:=Bild8Bit;
    5:LiesTrack:=GCAni;
  END;
END;
BEGIN
  LoadMMLtrack:=FALSE;

  SEEK(pf,mml_spos);
  blockpos:=0;
  ReadFile(2);
  tanz:=temp[0]+temp[1]*256;

  FOR tanz:=1 TO tanz DO BEGIN
    ReadFile(3);
    tco:=temp[0]+temp[1]*256;

    typ:=temp[2];
    ReadFile(typ);
    MOVE(temp,s40[1],typ);
    s40[0]:=CHR(typ);

    ReadFile(5);
    typ:=temp[0];
    sp:=LONGINT(temp[1])+LONGINT(temp[2])*256+LONGINT(temp[3])*65536+LONGINT(temp[4])*16777216;
    IF((labl='#*')AND(coeff=tco))OR(labl=s40)THEN BEGIN
      LoadMMLtrack:=LiesTrack;BREAK;
    END;
  END;
END;

END.