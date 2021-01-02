UNIT I_VARS;

INTERFACE

TYPE mouseprm=RECORD
                b,f,n:BYTE;
                on:BOOLEAN;
                c:ARRAY[1..2]OF BYTE;
                x,y,ox,oy:INTEGER;
                bg:ARRAY[0..228]OF BYTE;
              END;
     mpa_file=RECORD
                af:FILE;
                anz,pos:WORD;
                bez:STRING[32];
              END;
     ScrArray=ARRAY[0..64003]OF BYTE;
     m32k=ARRAY[0..32767]OF BYTE;
     m16k=ARRAY[0..16384]OF BYTE;
     clickfields=RECORD
                   cnt:BYTE;
                   x0,y0,x1:ARRAY[1..10]OF INTEGER;
                   tit:ARRAY[1..10]OF STRING[40];
                   bkgr:ARRAY[1..10,0..22]OF POINTER;
                 END;
     nsr=RECORD
           attr:LONGINT;
           e,z,m:COMP;
           h,l:LONGINT;
           n:COMP;
           name:ARRAY[0..259]OF CHAR;
           sname:ARRAY[0..13]OF CHAR;
           handle:WORD;
         END;
CONST prg_info:STRING[73]=
                 #10#13'GoldenWorks'' Installation program v1.0'#10#13+
                       '(c)1997-98 by Ronny Burkersroda';
      mml_main:STRING[11]='INSTALL.MML';
      mml_kopf:STRING[8]='MML 1.00';
      mml_tend:STRING[3]=#10#13#26;
      mml_spos:BYTE=0;
      direx:STRING[12]='\';
      cheats:BYTE=0;
      pdol:STRING[3]=' P$';
      tradeunits:STRING[3]=' TU';
      ctf:BYTE=0;
      time:LONGINT=0;
      ttime:LONGINT=0;
      time2:LONGINT=0;
      active:BYTE=0;
      music:BYTE=0;
      oldtrack:BYTE=0;
      cfeld:WORD=0;
      zoom:BYTE=2;
      x_p:WORD=0;
      videomode:WORD=2;
      CDRom:BOOLEAN=FALSE;
      timeout=2;
VAR exist_SB,exist_M,win95:BOOLEAN;
    ap,b1,b2,b3,pages,hixms,sts:BYTE;
    in0,in1:INTEGER;
    l1,mem,rspreis:LONGINT;
    geld:REAL;
    prm:STRING;
    pf:FILE;
    oldexitproc,oldprnt,ecpnt:POINTER;
    ms:mouseprm;
    xms:ARRAY[1..64]OF WORD;
    page:^ScrArray;
    TasInt:PROCEDURE;
    stat:BYTE ABSOLUTE $0040:$0017;
    fields:^clickfields;

IMPLEMENTATION END.