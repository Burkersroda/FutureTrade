UNIT SuperVGA;
INTERFACE USES dos;

TYPE mmods=(_text,_text2,_text4,_herc,_cga1,_cga2,_pl1 ,
             _pl1e,_pl2 ,_pk2 ,_pl4 ,_pk4 ,_p8  ,_p15 ,_p16 ,_p24 ,_p32 );
     modetype=RECORD md,xres,yres,bytes:WORD;memmode:mmods;END;
     chips=(__vesa,__xbe,__none);
     cursortype=ARRAY[0..31]OF LONGINT;
     charr=ARRAY[1..255]OF CHAR;
     chptr=^charr;
     intarr=ARRAY[1..100]OF WORD;
     _vbe0=RECORD
             sign:LONGINT;
             vers:WORD;
             oemadr:chptr;
             capab:LONGINT;
             model:^intarr;
             mem:BYTE;
             xx:ARRAY[0..499]OF BYTE;
           END;
     _vbe1=RECORD
             attr:WORD;
             wina:BYTE;
             winb:BYTE;
             gran:WORD;
             winsiz:WORD;
             sega:WORD;
             segb:WORD;
             pagefunc:POINTER;
             bytes:WORD;
             width:WORD;
             height:WORD;
             charw:BYTE;
             charh:BYTE;
             planes:BYTE;
             bits:BYTE;
             nbanks:BYTE;
             model:BYTE;
             banks:BYTE;
             images:BYTE;
             res:BYTE;
             redinf:WORD;
             grninf:WORD;
             bluinf:WORD;
             resinf:WORD;
             x:ARRAY[BYTE]OF BYTE;
        END;
        _vbe1p=^_vbe1;
        _xbe0=RECORD
                sign:LONGINT;
                vers:WORD;
                oemadr:chptr;
                capab:LONGINT;
                xgas:WORD;
                xx:ARRAY[1..240]OF BYTE;
              END;
        _xbe1=RECORD
                oemadr:chptr;
                capab:LONGINT;
                romadr:LONGINT;
                memreg:LONGINT;
                iobase:WORD;
                vidadr:LONGINT;  {32bit address of video memory}
                adr4MB:LONGINT;
                adr1MB:LONGINT;
                adr64k:LONGINT;
                adroem:LONGINT;
                sizoem:WORD;
                modep:^intarr;
                memory:WORD;
                manid:LONGINT;
                xx:ARRAY[1..206]OF BYTE;
              END;
        _xbe2=RECORD
                attrib:WORD;
                bytes:WORD;
                pixels:WORD;
                lins:WORD;
                charw:BYTE;
                charh:BYTE;
                planes:BYTE;
                bits:BYTE;
                model:BYTE;
                images:BYTE;
                redinf:WORD;
                grninf:WORD;
                bluinf:WORD;
                resinf:WORD;
                xx:ARRAY[1..234]OF BYTE;
              END;

CONST attr=$3C0;
      seq=$3C4;
      grc=$3CE;
      header:ARRAY[chips]OF STRING[14]=('VESA','XBE','');
      chipnam:ARRAY[chips]OF STRING[8]=('VESA','XBE','?');
      colbits:ARRAY[mmods]OF integer=(0,0,0,1,1,1,1,2,2,2,4,4,8,15,16,24,24);
VAR vid:RECORD
          chip:chips;
          id:WORD;
          IOadr:WORD;
          Xseg:WORD;
          Phadr:LONGINT;
          version:WORD;
          subver:WORD;
          mem:WORD;
          sname:STRING[8];
          name:STRING[40];
        END;
        rp:registers;
        planes:WORD;
        modetbl:ARRAY[1..50]OF modetype;
        chip:chips;
        mm:WORD;
        vseg:WORD;
        version:WORD;
        subvers:WORD;
        IOadr:WORD;
        nomodes:WORD;
        instance:WORD;
        biosseg:WORD;
        name:STRING[40];
        curmode:WORD;
        memmode:mmods;
        crtc:WORD;
        pixels:WORD;
        lins:WORD;
        bytes:LONGINT;
        force_mm:WORD;
        extpixfact:WORD;
        extlinfact:WORD;
        charwid:WORD;
        charhigh:WORD;
        calcpixels,calclines,calcvseg,calcbytes:WORD;
        calcmmode:mmods;

PROCEDURE Vio(ax:WORD);
FUNCTION Inp(reg:WORD):BYTE;
PROCEDURE OutP(reg,val:WORD);
PROCEDURE OutPw(reg,val:WORD);
FUNCTION RdInx(pt,inx:WORD):WORD;
PROCEDURE WrInx(pt,inx,val:WORD);
PROCEDURE ModInx(pt,inx,mask,nwv:WORD);
PROCEDURE SetInx(pt,inx,val:WORD);
PROCEDURE ClrInx(pt,inx,val:WORD);
PROCEDURE SetBank(bank:WORD);
PROCEDURE SetVStart(x,y:WORD);
FUNCTION SetMode(md:WORD):boolean;
PROCEDURE VesaModeInfo(md:WORD;vbe1:_vbe1p);
PROCEDURE FindVideo;
PROCEDURE SelectVideo;

IMPLEMENTATION USES crtn;

CONST mmmask:ARRAY[0..8]OF BYTE=(0,0,0,0,1,3,3,7,15);
VAR spcreg:WORD;
    xgaseg:WORD;
    Phadr:LONGINT;
    old,curbank:WORD;
    vgran:WORD;

PROCEDURE Disable;
BEGIN
  INLINE($fa);
END;
PROCEDURE Enable;
BEGIN
  INLINE($fb);
END;
FUNCTION GtStr(VAR c:chptr):STRING;
VAR x:WORD;
  s:STRING;
BEGIN
  s:='';x:=1;
  IF c<>NIL THEN
    WHILE(x<255)AND(c^[x]<>#0)DO
    BEGIN
      IF c^[x]<>#7 THEN s:=s+c^[x];
      inc(x);
    END;
  gtstr:=s;
END;
PROCEDURE Vio(ax:WORD);
BEGIN
  rp.ax:=ax;
  INTR($10,rp);
END;
PROCEDURE VioP(ax,bx,cx,dx:WORD;p:POINTER);
BEGIN                            {INT 10h reg AX-DX, ES:DI = p}
  rp.ax:=ax;
  rp.bx:=bx;
  rp.cx:=cx;
  rp.dx:=dx;
  rp.di:=ofs(p^);
  rp.es:=seg(p^);
  INTR($10,rp);
END;
FUNCTION Inp(reg:WORD):BYTE;
BEGIN
  reg:=PORT[reg];
  inp:=reg;
END;
PROCEDURE Outp(reg,val:WORD);
BEGIN
  PORT[reg]:=val;
END;
FUNCTION InpW(reg:WORD):WORD;
BEGIN
  reg:=PORTW[reg];
  inpw:=reg;
END;
PROCEDURE OutpW(reg,val:WORD);
BEGIN
  PORTW[reg]:=val;
END;
FUNCTION RdInx(pt,inx:WORD):WORD;
VAR x:WORD;
BEGIN
  IF pt=$3C0 THEN x:=inp(CRTC+6);
  outp(pt,inx);
  rdinx:=inp(pt+1);
END;
PROCEDURE WrInx(pt,inx,val:WORD);
VAR x:WORD;
BEGIN
  IF pt=$3C0 THEN BEGIN
    x:=inp(CRTC+6);
    outp(pt,inx);
    outp(pt,val);
  END ELSE BEGIN
    outp(pt,inx);
    outp(pt+1,val);
  END;
END;
PROCEDURE WrInx2(pt,inx,val:WORD);
BEGIN
  wrinx(pt,inx,lo(val));
  wrinx(pt,inx+1,hi(val));
END;
PROCEDURE WrInx3(pt,inx:WORD;val:LONGINT);
BEGIN
  wrinx(pt,inx,lo(val));
  wrinx(pt,inx+1,hi(val));
  wrinx(pt,inx+2,val shr 16);
END;
PROCEDURE WrInx2M(pt,inx,val:WORD);
BEGIN
  wrinx(pt,inx,hi(val));
  wrinx(pt,inx+1,lo(val));
END;
PROCEDURE WrInx3M(pt,inx:WORD;val:LONGINT);
BEGIN
  wrinx(pt,inx+2,lo(val));
  wrinx(pt,inx+1,hi(val));
  wrinx(pt,inx,val shr 16);
END;
PROCEDURE ModInx(pt,inx,mask,nwv:WORD);
VAR temp:WORD;
BEGIN
  temp:=(rdinx(pt,inx)AND(not mask))+(nwv AND mask);
  wrinx(pt,inx,temp);
END;
PROCEDURE ModReg(reg,mask,nwv:WORD);
VAR temp:WORD;
BEGIN
  temp:=(inp(reg)AND(not mask))+(nwv AND mask);
  outp(reg,temp);
END;
PROCEDURE SetInx(pt,inx,val:WORD);
VAR x:WORD;
BEGIN
  x:=rdinx(pt,inx);
  wrinx(pt,inx,x or val);
END;
PROCEDURE ClrInx(pt,inx,val:WORD);
VAR x:WORD;
BEGIN
  x:=rdinx(pt,inx);
  wrinx(pt,inx,x AND(not val));
END;
FUNCTION GetBios(offs,lnn:WORD):STRING;
VAR s:STRING;
BEGIN
  s[0]:=chr(lnn);
  move(mem[biosseg:offs],s[1],lnn);
  getbios:=s;
END;
TYPE regblk=RECORD
              base:WORD;
              nbr:WORD;
              x:ARRAY[0..255]OF BYTE;
            END;
     regtype=RECORD
               chip:chips;
               mmode:mmods;
               mode,pixels,lins,bytes,tridold0d,tridold0e:WORD;
               attregs:ARRAY[0..31]OF BYTE;
               seqregs,grcregs,crtcregs,xxregs:regblk;
               stdregs:ARRAY[$3c0..$3df]OF BYTE;
               xgaregs:ARRAY[0..15]OF BYTE;
             END;
VAR rgs:regtype;
    oldreg:boolean;

PROCEDURE LoadModes;
VAR
  t:text;
  s,pat:STRING;
  md,x,xres,yres,err,mreq,byt:WORD;
  vbe0:_vbe0;
  vbe1:_vbe1;
  xbe1:_xbe1;
  xbe2:_xbe2;
  ok:boolean;
FUNCTION VESAmemmode(model,bits,redinf,grninf,bluinf,resinf:WORD):mmods;
const
  mode6s=4;
  mode:ARRAY[1..mode6s]OF mmods=(_p15,_p16,_p24,_p32);
  blui:ARRAY[1..mode6s]OF WORD =(   5,   5,    8,    8);
  grni:ARRAY[1..mode6s]OF WORD =($505,$506, $808, $808);
  redi:ARRAY[1..mode6s]OF WORD =($A05,$B05,$1008,$1008);
  resi:ARRAY[1..mode6s]OF WORD =($f01,   0,    0,$1808);
VAR x:WORD;
BEGIN
  VESAmemmode:=_text;
  IF(bits=15)AND(resinf=0)THEN resinf:=$F01;
  CASE model OF
    0:VESAmemmode:=_text;
    1:CASE bits OF
        1:VESAmemmode:=_cga1;
        2:VESAmemmode:=_cga2;
      END;
    2:memmode:=_herc;
    3:CASE bits OF
        2:VESAmemmode:=_pl2;
        4:VESAmemmode:=_pl4;
      END;
    4:CASE bits OF
        4:VESAmemmode:=_pk4;
        8:VESAmemmode:=_p8;
       15:VESAmemmode:=_p15;
       16:VESAmemmode:=_p16;
       24:VESAmemmode:=_p24;
      END;
    5:;
    6:FOR x:=1 TO mode6s DO
      IF(redinf=redi[x])AND(grninf=grni[x])AND(bluinf=blui[x])
        AND(resinf=resi[x])THEN VESAmemmode:=mode[x];
    7:;
  END;
END;
PROCEDURE AddMode(md,xres,yres,bytes:WORD;memmode:mmods);
BEGIN
  inc(nomodes);
  modetbl[nomodes].md     :=md;
  modetbl[nomodes].xres   :=xres;
  modetbl[nomodes].yres   :=yres;
  modetbl[nomodes].bytes  :=bytes;
  modetbl[nomodes].memmode:=memmode;
END;

BEGIN
  nomodes:=0;
  CASE chip OF
   __vesa:BEGIN
            vbe0.sign:=$41534556;  (* VESA *)
            viop($4f00,0,0,0,@vbe0);

               {S3 VESA driver can return wrong segment IF run with QEMM}
            IF seg(vbe0.model^)=$e000 THEN
              vbe0.model:=ptr($c000,ofs(vbe0.model^));
            x:=1;
            WHILE vbe0.model^[x]<>$FFFF DO
            BEGIN
              vesamodeinfo(vbe0.model^[x],@vbe1);
              IF(vbe1.attr AND 1)<>0 THEN
              BEGIN
                memmode:=VESAmemmode(vbe1.model,vbe1.bits,vbe1.redinf
                   ,vbe1.grninf,vbe1.bluinf,vbe1.resinf);
                addmode(vbe0.model^[x],vbe1.width,vbe1.height,vbe1.bytes,memmode);
              END;
              inc(x);
            END;
          END;
    __xbe:BEGIN
            viop($4E01,0,0,instance,@xbe1);
            x:=1;
            WHILE xbe1.modep^[x]<>$FFFF DO
            BEGIN
              viop($4E02,0,xbe1.modep^[x],instance,@xbe2);
              IF(rp.ax=$4E)AND((xbe2.attrib AND 1)>0)THEN
              BEGIN
                memmode:=VESAmemmode(xbe2.model,xbe2.bits,xbe2.redinf
                   ,xbe2.grninf,xbe2.bluinf,xbe2.resinf);
                addmode(xbe1.modep^[x],xbe2.pixels,xbe2.lins,xbe2.bytes,memmode);
              END;
              inc(x);
            END;

          END;
  END;
END;
PROCEDURE SelectVideo;
BEGIN
  LoadModes;
END;
PROCEDURE Addvideo;
VAR nam,s:STRING;
    nr,err:WORD;
BEGIN
  IF version<>0 THEN
   CASE version OF 90:nam:='VESA VBE';91:nam:='VESA XBE';END;
  nam:=nam+' / '+name;
  IF force_mm<>0 THEN mm:=force_mm;
  vid.chip    :=chip;
  vid.id      :=instance;   {instance(XBE)}
  vid.ioadr   :=IOadr;      {base I/O adr}
  vid.version :=version;
  vid.mem     :=mm;
  vid.name    :=nam;
  vid.xseg    :=XGAseg;
  vid.phadr   :=phadr;
  vid.subver  :=subvers;
  vid.sname   :=chipnam[chip];
END;
PROCEDURE UNK(vers,code:WORD);
BEGIN
  version:=vers;
  subvers:=code;
END;

PROCEDURE _Vesa;
VAR vesarec:_vbe0;x:WORD;
BEGIN
  VioP($4f00,0,0,0,@vesarec);
  IF(rp.ax=$4f)AND(vesarec.sign=$41534556)THEN BEGIN
    chip:=__vesa;
    mm:=vesarec.mem*LONGINT(64);
    name:=GtStr(vesarec.oemadr);
    UNK(90,vesarec.vers);
    AddVideo;
  END;
END;
PROCEDURE FindVideo;
BEGIN
  IF odd(inp($3CC))THEN CRTC:=$3D4 ELSE CRTC:=$3B4;
  _Vesa;
END;
PROCEDURE setbank(bank:word);
VAR x:word;
BEGIN
  IF bank=curbank THEN exit;
  vseg:=$a000;
  curbank:=bank;
  rp.bx:=0;
  bank:=bank*LONGINT(64)DIV vgran;
  rp.dx:=bank;
  vio($4f05);
  rp.bx:=1;
  rp.dx:=bank;
  vio($4f05);
END;

PROCEDURE vesamodeinfo(md:word;vbe1:_vbe1p);
const
  width :ARRAY[$100..$11b]OF word=
    (640,640,800,800,1024,1024,1280,1280,80,132,132,132,132
      ,320,320,320,640,640,640,800,800,800,1024,1024,1024,1280,1280,1280);
  height:ARRAY[$100..$11b]OF word=
    (400,480,600,600, 768, 768,1024,1024,60, 25, 43, 50, 60
      ,200,200,200,480,480,480,600,600,600, 768, 768, 768,1024,1024,1024);
  bits  :ARRAY[$100..$11b]OF BYTE=
    (  8,  8,  4,  8,   4,   8,   4,   8, 0,  0,  0,  0,  0
      , 15, 16, 24, 15, 16, 24, 15, 16, 24,  15,  16,  24,  15,  16,  24);


VAR
  vbxx:_vbe1;
BEGIN
  IF vbe1=NIL THEN vbe1:=@vbxx;
  fillchar(vbe1^,sizeOF(_vbe1),0);
  viop($4f01,0,md,0,vbe1);
  IF((vbe1^.attr AND 2)=0)AND(md>=$100)AND(md<=$11b)
   THEN
  BEGIN
    vbe1^.width :=width[md];
    vbe1^.height:=height[md];
    vbe1^.bits  :=bits[md];
  END;


  vgran :=vbe1^.gran;
  bytes :=vbe1^.bytes;
  pixels:=vbe1^.width;
  lins  :=vbe1^.height;
END;

FUNCTION safemode(md:word):boolean;
VAR x,y:word;
BEGIN                 {Checks IF we entered a Graph. mode}
  safemode:=false;
  wrinx(crtc,$11,0);
  wrinx(crtc,1,0);
  vio(lo(md));
  IF(rdinx(crtc,1)<>0)or(rdinx(crtc,$11)<>0)THEN
  BEGIN
    IF(md<=$13)or(mem[0:$449]<>3)THEN safemode:=true;
  END;
END;
FUNCTION setmode(md:word):boolean;
VAR x,y,prt:word;
BEGIN
  setmode:=true;
  curmode:=md;
  CASE chip OF
       __vesa:BEGIN
                rp.bx:=md;
                vio($4f02);
                IF rp.ax<>$4f THEN setmode:=false
                ELSE BEGIN
                  vesamodeinfo(md,NIL);
                  chip:=__vesa;
                END;
              END;
  ELSE setmode:=safemode(md);
  END;

  IF(inp($3CC)AND 1)=0 THEN crtc:=$3B4 ELSE crtc:=$3D4;
  CASE(rdinx(GRC,6)shr 2)AND 3 OF
    0,1:vseg:=$A000;
      2:vseg:=$B000;
      3:vseg:=$B800;
  END;


  curbank:=$ffff;    {Set curbank invalid }
  planes:=1;
  setinx(SEQ,4,2);    {Set "more than 64K" flag}

  CASE memmode OF
  _text,_text2,_text4,
  _pl1e,_pl2:planes:=2;
        _pl4:planes:=4;
  END;
  IF vseg=$A000 THEN
    FOR x:=1 TO mm DIV 64 DO
    BEGIN
      setbank(x-1);
      mem[vseg:$FFFF]:=0;
      fillchar(mem[vseg:0],$ffff,0);
    END;
END;






PROCEDURE setvstart(x,y:word);       {Set the display start address}
VAR
  l:LONGINT;
  stdvga:boolean;
BEGIN
  stdvga:=true;

  CASE chip OF
    __vesa:BEGIN
               rp.bx:=0;
               rp.cx:=x;
               rp.dx:=y;
               vio($4f07);
               IF rp.ax=0 THEN;
               stdvga:=false;
             END;
    END;

    y:=(l shr 18)AND(pred(mm)shr 8);
  IF stdvga THEN
  BEGIN
    x:=l shr 2;
    wrinx(crtc,13,lo(x));
    wrinx(crtc,12,hi(x));
  END;
END;

BEGIN END.
