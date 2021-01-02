UNIT VARS;

INTERFACE USES smix;

TYPE vehiclebackground=RECORD
                       xy:ARRAY[0..3]OF BYTE;
                       c:ARRAY[0..19,0..19]OF BYTE;
                     END;
     mouseprm=RECORD
                b,f,n:BYTE;
                on,arrow:BOOLEAN;
                c:ARRAY[1..2]OF BYTE;
                x,y,ox,oy:INTEGER;
                bg:ARRAY[0..228]OF BYTE;
              END;
     mpa_file=RECORD
                af:FILE;
                anz,pos:WORD;
                bez:STRING[32];
              END;
     startime=RECORD
                gt:LONGINT;
                ev:BYTE;
              END;
     streets=RECORD
               sc:BYTE;
               p1,p2:ARRAY[1..100]OF BYTE;
             END;
     vehicle=RECORD
               c:ARRAY[0..25]OF BYTE;
               pos,dis,sx,sy,tx,ty,px,py:WORD;
               m,f,d,s,p,percpos:BYTE;
               backgr:vehiclebackground;
             END;
     oponent=RECORD
               last_town:BYTE;
               actual_town:BYTE;
               sx,sy,tx,ty:WORD;
               position:WORD;
               distance:WORD;
               backgr_x:WORD;
               backgr_y:WORD;
               backgr:vehiclebackground;
               staytime,endtime:WORD;
             END;
     nachrichten=ARRAY[1..4]OF RECORD
                                 st:STRING[60];
                                 dt:INTEGER;ev:BYTE;
                               END;
     contract=ARRAY[1..20]OF RECORD
                               db,s,t:BYTE;
                               gd:WORD;ev,co,cc:BYTE;
                               pr:LONGINT;
                             END;
     map_xtra=RECORD
                tc,fc:BYTE;
                tt,ft:ARRAY[1..20]OF BYTE;
                tx,ty,ti,fx,fy:ARRAY[1..20]OF WORD;
                tn:ARRAY[1..20]OF STRING[20];
                pr:ARRAY[1..20,0..25]OF SINGLE;
                gs:ARRAY[1..20]OF BYTE;
                it,itst:BYTE;
              END;
     point=RECORD x,y:INTEGER;END;
     ScrArray=ARRAY[0..64003]OF BYTE;
     m32k=ARRAY[0..32767]OF BYTE;
     icons=ARRAY[0..14,0..19,0..19]OF BYTE;
     cforiginals=ARRAY[0..13,0..903]OF BYTE;
     timerbackgrounds=ARRAY[0..1326]OF BYTE;
     tiletype=ARRAY[1..40,0..28]OF BYTE;
CONST prg_info:STRING[84]=
                 #10#13'FutureTrade Version 1.01'#10#13+
                       'A Space In Motion Titel'#10#13+
                       '(c)2000 Ronny Burkersroda';
      ini_name:STRING[6]='FT.INI';
      ini_kopf:STRING[13]='[FutureTrade]';
      ini_sound:STRING[7]='[Sound]';
      ini_cheat:STRING[7]='[Cheat]';
      ini_list00:STRING[5]='GAMMA';
      ini_list01:STRING[10]='VIDEO_SYNC';
      ini_list02:STRING[12]='VIDEO_FORMAT';
      ini_list03:STRING[12]='INSTALL_DIR';
      ini_list04:STRING[9]='DITHERING';
      ini_list05:STRING[10]='QUICK_TIPS';
      ini_list10:STRING[4]='AUTO';
      ini_list11:STRING[4]='PORT';
      ini_list12:STRING[3]='IRQ';
      ini_list13:STRING[3]='DMA';
      ini_list14:STRING[5]='SOUND';
      ini_list15:STRING[8]='CD_AUDIO';
      ini_list20:STRING[11]='ALLE_VIDEOS';
      ini_list21:STRING[4]='GELD';
      ini_list22:STRING[5]='FEIND';
      mml_main:STRING[12]='PICTURES.MML';
      mml_anim:STRING[12]='HI-VIDEO.MML';
      mml_kopf:STRING[8]='MML 1.00';
      mml_tend:STRING[3]=#10#13#26;
      mml_spos:BYTE=0;
      cheats:BYTE=0;
      pdol:STRING[3]=' I$';
      tradeunits:STRING[3]=' HE';
      ctf:BYTE=0;
      dithering:WORD=1;
      quicktips:BOOLEAN=TRUE;
      time:LONGINT=0;
      ttime:LONGINT=0;
      time2:LONGINT=0;
      active:BYTE=0;
      cfeld:WORD=0;
      zoom:BYTE=2;
      drawedpos:BYTE=0;
      drawedpos_enemy:BYTE=0;
      x_p:WORD=0;
      videomode:BYTE=2;
      timeout=2;
      cheatmoney:LONGINT=0;
      ok:STRING[2]='OK';
      an:STRING[2]='AN';
      aus:STRING[3]='AUS';
      abbruch:STRING[7]='ABBRUCH';
      GetWare:ARRAY[0..25]OF STRING[13]=
        ('ALUMINIUM','ANTRIEBSTEILE','EISEN-ERZ','ELEKTRONIK','FAHRZEUGTEILE',
         'GEMšSE','GETEIDE','GOLD','KUPFER','LUXUSGšTER','METALL','NUTZHANF',
         'OBST','RIND','ROHDIAMANDEN','SCHWEIN','SILBER','SILICIUM-ERZ',
         'SPIRITUOSEN','STANNETT','SUPRAX','TABAK','TRINKWASSER','TURRION-ERZ',
         'URAN','WEIN');
      GetPrice:ARRAY[0..25]OF SINGLE=
        (0050,9300,0045,0915,5300,0016,15.4,0140,0055,1850,0052,0032,17.2,
         24.3,0400,24.2,0080,0090,42.5,0094,2400,0037,12.5,0850,2400,0036);
      QuickTip:ARRAY[0..15,0..1]OF STRING[13]=
        (('HAUPTMENš','EINSTELLUNGEN'),
         ('',''),
         ('',''),
         ('FšLLEN','LEEREN'),
         ('PLUS','ZOOM'),
         ('MINUS','ZOOM'),
         ('BESTŽTIGUNG',''),
         ('ABBRUCH',''),
         ('KARTE',''),
         ('ORTSANSICHT',''),
         ('šBERSICHT',''),
         ('ORT WECHSELN',''),
         ('HŽNDLER',''),
         ('TERMINAL','MITTEILUNGEN'),
         ('VERTRŽGE',''),
         ('PLAY','PAUSE'));
      maxfieldx=249;
      maxfieldy=249;
      minavail:LONGINT=655360;
      fpsticks=211; {186=25.0 fps}
                    {211=22.0 fps}
                    {255=18.2 fps}
      syncanimation:BOOLEAN=TRUE;
      max_geld=1000000;
      min_geld=-10000;
      {deathline=39;}
      sbautodetect:BOOLEAN=TRUE;
      smapdivx=1.4;
      smapdivy=1.4;
      smapaddx=430;
      smapaddy=61;
      base_io:WORD=544;
      dsp_irq:BYTE=7;
      dsp_dma8:BYTE=1;
      dsp_dma16:BYTE=1;
      maxloadedsounds=10;
      soundon:BOOLEAN=TRUE;
      cdmusic:BOOLEAN=TRUE;
      savepic:BOOLEAN=FALSE;
      soundbyte:WORD=0;
      cdtimecounter:WORD=0;
      cd_rom:STRING[3]='';
      startdir:STRING[80]='';
      installdir:STRING[80]='';
TYPE undergroundtype=ARRAY[0..maxfieldx,0..maxfieldy] OF BYTE;
VAR exist_SB,exist_M,death:BOOLEAN;
    ap,b1,b2,b3,pages,hixms,sts:BYTE;
    in0,in1:INTEGER;
    l1,mem,rspreis:LONGINT;
    geld:REAL;
    prm:STRING;
    pf:FILE;
    oldexitproc,oldprnt,ecpnt:POINTER;
    ms:mouseprm;
    xms:ARRAY[1..64]OF WORD;
    tilpal:ARRAY[0..191]OF BYTE;
    trk:vehicle;
    enemy:oponent;
    road:^streets;
    stime:startime;
    news:^nachrichten;
    vertr:^contract;
    icon:^icons;
    mapx:^map_xtra;
    cfo:^cforiginals;
    tbkgr:^timerbackgrounds;
    page,tpage:^ScrArray;
    tile:^tiletype;
    sounds:ARRAY[0..maxloadedsounds-1]OF PSound;
    map:ARRAY[0..2]OF ^undergroundtype;
    posit:point;
    {trng:RECORD x1,y1,x2,y2:INTEGER;END;}
    range:RECORD x_min,x_max,y_min,y_max:INTEGER;END;
    active_sm_name:BYTE;
    old_tile:RECORD
               x,y:INTEGER;
               b:ARRAY[0..999]OF BYTE;
             END;
    tip:RECORD
      time:BYTE;
      backgr:ARRAY[0..1,0..563]OF BYTE;xpos,ypos:INTEGER;
    END;
    TasInt:PROCEDURE;
    stat:BYTE ABSOLUTE $0040:$0017;

IMPLEMENTATION END.