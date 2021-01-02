{$S-,N+,E+,I-,G+,F-}
{$A+,B-,P-,Q-,R-,T-,V+,X+}

UNIT Subs;
{  Main-Unit for FutureTrade        }
{  (c)1996-99 by Ronny Burkersroda  }

INTERFACE

USES crtn,dos,vesa,effects,vars,smix,
     modexlib,spx_clk,xms_unit,cdrom,sub_mml,sub_map,sub_text,sub_ctrl,sub_draw;

FUNCTION TypeName(nr:BYTE):STRING;
PROCEDURE Dot2Comma(VAR st0:STRING);
PROCEDURE OutPut(x,y:BYTE;st:STRING;col:WORD);
PROCEDURE GotoXY(x,y:BYTE);
PROCEDURE TextMode;
PROCEDURE ID(VAR st:STRING;byt:BYTE);
PROCEDURE Wait(ttw:WORD);

IMPLEMENTATION

FUNCTION TypeName(nr:BYTE):STRING;
VAR st,s1:STRING[20];
BEGIN
  IF nr<21 THEN BEGIN
    IF mapx^.tt[nr]AND 2=0THEN BEGIN st:='RAUMHAFEN';
      IF mapx^.it=nr THEN st:='FREIE STADT' ELSE
       IF mapx^.tt[nr]AND 1=0THEN st:='STADT';
    END ELSE st:='HAUPTSTADT';
  END ELSE BEGIN
    STR(ORD(mapx^.tn[1,2])+ORD(mapx^.tn[2,1])-128,s1);
    STR(nr-20,st);
    IF st[0]=#1 THEN st:='0'+st;
    IF s1[0]=#1 THEN s1:='0'+s1;
    st:='ID-NR. '+s1+'-'+st;
  END;
  TypeName:=st;
END;
PROCEDURE Wait(ttw:WORD);
VAR reg0:REGISTERS;
BEGIN
  IF key[1]=#32 THEN EXIT;
  time:=0;REPEAT Keys;reg0.ax:=3;INTR($33,reg0);
    IF reg0.bx=1 THEN key[1]:=#32 ELSE IF reg0.bx=2 THEN key[1]:=#27;
  UNTIL(key[1]=#27)OR(key[1]=#32)OR((ttw<>0)AND(time>=ttw))OR((ttw=0){AND(sound_ready)});
END;
PROCEDURE Dot2Comma(VAR st0:STRING);
VAR by0:BYTE;
BEGIN
  FOR by0:=1 TO LENGTH(st0) DO IF st0[by0]='.' THEN st0[by0]:=',';
END;
PROCEDURE OutPut(x,y:BYTE;st:STRING;col:WORD);
VAR reg:REGISTERS;
BEGIN
  reg.cx:=ORD(st[0]);reg.es:=SEG(st[1]);reg.bp:=OFS(st[1]);
  reg.ax:=$1300;reg.bx:=col;reg.dh:=y;reg.dl:=x;INTR($10,reg);
END;
PROCEDURE GotoXY(x,y:BYTE);ASSEMBLER;
ASM
  MOV AH,2
  MOV BH,0
  MOV DH,y
  MOV DL,x
  INT 10h
END;
PROCEDURE ID(VAR st:STRING;byt:BYTE);
BEGIN
  CASE mapx^.ft[byt] OF 0:st:=st+'URAN-BERGWERK';
    1:st:=st+'SILICIUM-BERGWERK';
    2:st:=st+'DIAMANDENMINE';
    3:st:=st+'ERZ-BERGWERK';
    4:st:=st+'WASSER-PUMPSTATION';
    5:st:=st+'GENUSSMITTELFABRIK';
    6:st:=st+'HANFPLANTAGE';
    7:st:=st+'FARM';
    8:st:=st+'RANCH';
    9:st:=st+'GšTERFABRIK';
    10:st:=st+'SCHMELZWERK';END;
END;
{PROCEDURE PlayCD(f,u:WORD);
TYPE k=array[0..6]OF WORD;
     r=RECORD
       l,s,m,f:BYTE;END;
VAR x:RECORD
        c,f,l:BYTE;a:r;END;
    y:RECORD
        c,t:BYTE;a:r;i:BYTE;END;
    g:RECORD
        c:k;v,a:LONGINT;END;
    s,o,v:WORD;
    n:^k;
    t:ARRAY[1..100]OF LONGINT;
    z:REGISTERS;
FUNCTION a(r:r):LONGINT;
VAR m,s,f:LONGINT;
BEGIN m:=r.m;s:=r.s;f:=r.f;a:=m*4500+s*75+f-150;END;
PROCEDURE i(VAR b);
BEGIN z.dx:=ofs(b);z.ds:=seg(b);z.bx:=s;z.ax:=$4402;z.cx:=7;msdos(z);END;
BEGIN
  IF f=0 THEN g.c[1]:=$85 ELSE g.c[1]:=$84;
  z.ax:=$1500;z.bx:=0;INTR($2f,z);v:=z.cx;
  GETMEM(n,z.bx*5+1);z.ax:=$1501;z.es:=seg(n^);z.bx:=ofs(n^)+1;INTR($2f,z);
  n:=PTR(n^[2],n^[1]);z.ax:=$3d00;z.ds:=seg(n^[5]);z.dx:=ofs(n^[5]);
  MSDOS(z);s:=z.ax;IF z.flags AND 1>0 THEN EXIT;x.c:=10;i(x);
  t[x.l+1]:=a(x.a);FOR o:=x.f TO x.l DO BEGIN y.c:=11;y.t:=o;i(y);
    t[o]:=a(y.a);END;IF f<x.f THEN f:=x.f;
  IF (u=0) OR (u>x.l) THEN u:=x.l;IF f>u THEN exit;
  g.c[0]:=21;g.c[6]:=0;g.v:=t[f];g.a:=t[u+1]-g.v;z.ax:=$1510;z.cx:=v;
  z.es:=SEG(g);z.bx:=OFS(g);INTR($2f,z);z.ah:=$3f;z.bx:=s;MSDOS(z);
  FREEMEM(n,z.bx*5+1);
END;}
PROCEDURE TextMode;ASSEMBLER;
ASM
  MOV AX,0003h
  INT 10h
END;

END.