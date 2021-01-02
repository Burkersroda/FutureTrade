{$A+,N+,E+}
UNIT VESA;

INTERFACE

CONST detect:INTEGER=$100;

{complete new types, constants and variables}
TYPE Pal256=ARRAY[0..255,0..2]OF BYTE;
CONST alpha:BYTE=255;
      actualcolor:BYTE=0;
      fillingcolor:BYTE=0;
VAR pal:Pal256;

PROCEDURE Arc(ni0,ni1:INTEGER;nw0,nw1,nw2:WORD); {not implemented}
PROCEDURE Bar(x0,y0,x1,y1:INTEGER);
PROCEDURE Bar3D(x0,y0,x1,y1:INTEGER;nw0:WORD;nb0:BOOLEAN); {calls PROC Bar}
PROCEDURE Circle(x0,y0:INTEGER;r0:WORD);
PROCEDURE ClearDevice;
PROCEDURE ClearViewPort; {not implemented}
PROCEDURE CloseGraph;
PROCEDURE DetectGraph(VAR ni0,ni1:INTEGER); {not implemented}
PROCEDURE DrawPoly(nw0:WORD;VAR nothing); {not implemented}
PROCEDURE Ellipse(ni0,ni1:INTEGER;nw0,nw1,nw2,nw3:WORD); {not implemented}
PROCEDURE FillEllipse(ni0,ni1:INTEGER;nw0,nw1:WORD); {not implemented}
PROCEDURE FillPoly(nw0:WORD;VAR nothing); {not implemented}
PROCEDURE FloodFill(ni0,ni1:INTEGER;nw0:WORD); {not implemented}
(*PROCEDURE GetArcCoords(VAR na0:ArcCoordsType); {not implemented}*)
PROCEDURE GetAspectRatio(VAR nw0,nw1:WORD); {not implemented}
FUNCTION GetBkColor:LONGINT; {not implemented}
FUNCTION GetColor:BYTE;
FUNCTION GetDriverName:STRING;
FUNCTION GetGraphMode:INTEGER;
PROCEDURE GetImage(x0,y0,x1,y1:INTEGER;VAR bitmap);
FUNCTION GetMaxColor:LONGINT;
FUNCTION GetMaxMode:INTEGER; {not implemented}
FUNCTION GetMaxX:INTEGER;
FUNCTION GetMaxY:INTEGER;
FUNCTION GetModeName(ni0:INTEGER):STRING;
PROCEDURE GetModeRange(ni0:INTEGER;VAR ni1,ni2:INTEGER); {not implemented}
FUNCTION GetPaletteSize:INTEGER;
FUNCTION GetPixel(x0,y0:INTEGER):LONGINT;
(*PROCEDURE GetTextSettings(VAR textinfo:TextSettingsType);*)
(*PROCEDURE GetViewSetting(VAR viewport:ViewPortType); {not implemented}*)
FUNCTION GetX:INTEGER; {not implemented}
FUNCTION GetY:INTEGER; {not implemented}
PROCEDURE GraphDefaults;
FUNCTION GraphErrorMsg(i0:INTEGER):STRING;
FUNCTION GraphResult:INTEGER;
FUNCTION ImageSize(x0,y0,x1,y1:INTEGER):WORD;
PROCEDURE InitGraph(VAR i0,ni0:INTEGER;ns0:STRING);
FUNCTION InstallUserDriver(is0:STRING;np0:POINTER):INTEGER;
PROCEDURE Line(x0,y0,x1,y1:INTEGER);
PROCEDURE LineRel(nx0,ny0:INTEGER); {not implemented}
PROCEDURE LineTo(nx0,ny0:INTEGER); {not implemented}
PROCEDURE MoveRel(nx0,ny0:INTEGER); {not implemented}
PROCEDURE MoveTo(nx0,ny0:INTEGER); {not implemented}
PROCEDURE OutText(ns0:STRING); {not implemented}
PROCEDURE OutTextXY(x0,y0:INTEGER;s0:STRING);
PROCEDURE PieSlice(nx0,ny0:INTEGER;nw0,nw1:WORD); {not implemented}
PROCEDURE PutImage(x0,y0:INTEGER;VAR bitmap;w0:WORD);
PROCEDURE PutPixel(x0,y0:INTEGER;w0:WORD);
PROCEDURE Rectangle(x0,y0,x1,y1:INTEGER);
FUNCTION RegisterBGIDriver(np0:POINTER):INTEGER; {not implemented}
PROCEDURE RestoreCrtMode;
PROCEDURE Sector(nx0,ny0:INTEGER;nw0,nw1,nw2,nw3:WORD); {not implemented}
PROCEDURE SetActivePage(w0:WORD);
PROCEDURE SetAspectRatio(nw0,nw1:WORD); {not implemented}
PROCEDURE SetBkColor(nl0:LONGINT); {not implemented}
PROCEDURE SetColor(l0:BYTE);
PROCEDURE SetFillStyle(nw0:WORD;l0:LONGINT);
PROCEDURE SetGraphMode(i0:INTEGER);
PROCEDURE SetViewPort(nx0,ny0,nx1,ny1:INTEGER;nb0:BOOLEAN); {not implemented}
PROCEDURE SetVisualPage(w0:WORD);

{complete new functions and procedures}
PROCEDURE GetPixelColor(x0,y0:INTEGER);
FUNCTION GetActivePage:WORD;
PROCEDURE DrawPixel(x0,y0:INTEGER);
PROCEDURE PutLine(x0,y0,x1,y1:INTEGER;l0:LONGINT);
FUNCTION RGB2LongInt(r0,g0,b0:BYTE):LONGINT;
PROCEDURE LongInt2RGB(l0:LONGINT;VAR r0,g0,b0:BYTE);
FUNCTION LongInt2Red(l0:LONGINT):BYTE;
FUNCTION LongInt2Green(l0:LONGINT):BYTE;
FUNCTION LongInt2Blue(l0:LONGINT):BYTE;
PROCEDURE VerticalLine(x0,y0,y1:INTEGER);
PROCEDURE HorizontalLine(x0,x1,y0:INTEGER);
PROCEDURE PutHorizontalLine(x0,x1,y0:INTEGER;l0:BYTE);
FUNCTION GetGraphCardSpecs:STRING;
FUNCTION Pal2LongInt(b0:BYTE):LONGINT;
PROCEDURE CopyPage(source,dest:BYTE);

IMPLEMENTATION USES SUPERVGA;

{complete new types, constants and variables}
TYPE _64kB=ARRAY[0..65534]OF BYTE;
     resXY=RECORD x,y:INTEGER;END;
     pagetbl=RECORD max:BYTE;sx,sy:ARRAY[0..15]OF INTEGER;END;

CONST graphicresult:INTEGER=0;
      graphicmode:BYTE=0;
      visualpage:BYTE=0;
      activepage:BYTE=0;
VAR resolution:resXY;
    pagetable:pagetbl;

{local functions and procedures}

{global functions and procedures}
PROCEDURE Arc(ni0,ni1:INTEGER;nw0,nw1,nw2:WORD); {not implemented}
BEGIN END;
PROCEDURE Bar(x0,y0,x1,y1:INTEGER);
VAR l00,l01:LONGINT;
BEGIN
  INC(x0,pagetable.sx[activepage]);
  INC(y0,pagetable.sy[activepage]);
  INC(x1,pagetable.sx[activepage]);
  INC(y1,pagetable.sy[activepage]);
  FOR y0:=y0 TO y1 DO
   CASE memmode OF
    _p8:BEGIN
      l00:=y0*bytes+x0;
      l01:=y0*bytes+x1;
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0),fillingcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),fillingcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],SUCC(WORD(l01)),fillingcolor);
      END;
    END;
    _p15,_p16:BEGIN
      l00:=y0*bytes+(x0 SHL 1);
      l01:=y0*bytes+(x1 SHL 1);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*2,fillingcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),fillingcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+2,fillingcolor);
      END;
    END;
    _p32:BEGIN
      l00:=y0*bytes+(x0 SHL 2);
      l01:=y0*bytes+(x1 SHL 2);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*4,fillingcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),fillingcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+4,fillingcolor);
      END;
    END;
  END;
END;
PROCEDURE Bar3D(x0,y0,x1,y1:INTEGER;nw0:WORD;nb0:BOOLEAN); {calls PROC Bar}
BEGIN
  Bar(x0,y0,x1,y1);
END;
PROCEDURE Circle(x0,y0:INTEGER;r0:WORD);
BEGIN END;
PROCEDURE ClearDevice;
VAR x0,y0,w00:WORD;
BEGIN
  w00:=PRED(mm DIV 64);
  IF memmode>_cga2 THEN FOR x0:=0 TO w00 DO BEGIN
    SetBank(x0);
    INLINE($8e/6/>vseg/$fc/$31/$ff/$31/$C0/$B9/>$8000/$f3/$ab);
  END;
END;
PROCEDURE ClearViewPort; {not implemented}
BEGIN END;
PROCEDURE CloseGraph;
BEGIN
  SetVStart(0,0);
  OutP($3c6,0);
  ASM
    MOV AX,3
    INT 10h
  END;
END;
PROCEDURE DetectGraph(VAR ni0,ni1:INTEGER); {not implemented}
BEGIN END;
PROCEDURE DrawPoly(nw0:WORD;VAR nothing); {not implemented}
BEGIN END;
PROCEDURE Ellipse(ni0,ni1:INTEGER;nw0,nw1,nw2,nw3:WORD); {not implemented}
BEGIN END;
PROCEDURE FillEllipse(ni0,ni1:INTEGER;nw0,nw1:WORD); {not implemented}
BEGIN END;
PROCEDURE FillPoly(nw0:WORD;VAR nothing); {not implemented}
BEGIN END;
PROCEDURE FloodFill(ni0,ni1:INTEGER;nw0:WORD); {not implemented}
BEGIN END;
(*PROCEDURE GetArcCoords(VAR na0:ArcCoordsType); {not implemented}
BEGIN END;
*)
PROCEDURE GetAspectRatio(VAR nw0,nw1:WORD); {not implemented}
BEGIN END;
FUNCTION GetBkColor:LONGINT; {not implemented}
BEGIN END;
FUNCTION GetColor:BYTE;
BEGIN
  GetColor:=actualcolor;
END;
FUNCTION GetDriverName:STRING;
BEGIN END;
FUNCTION GetGraphMode:INTEGER;
BEGIN END;
PROCEDURE GetImage(x0,y0,x1,y1:INTEGER;VAR bitmap);
VAR xc,yc,xz,yz:WORD;l00,l01:LONGINT;
    buffer:^_64kB;
BEGIN
  buffer:=PTR(SEG(bitmap),OFS(bitmap));
  IF((x0<0)OR(x0>GETMAXX)OR(y0<0)OR(y0>GETMAXY))
   AND((x1<0)OR(x1>GETMAXX)OR(y1<0)OR(y1>GETMAXY))THEN BEGIN
    xz:=0;yz:=0;
    MOVE(xz,buffer^[0],2);
    MOVE(yz,buffer^[2],2);
    EXIT;
  END;
  INC(x0,pagetable.sx[activepage]);
  INC(y0,pagetable.sy[activepage]);
  INC(x1,pagetable.sx[activepage]);
  INC(y1,pagetable.sy[activepage]);
  IF x0>x1 THEN BEGIN xz:=x0;x0:=x1;x1:=xz;END;
  IF y0>y1 THEN BEGIN yz:=y0;y0:=y1;y1:=yz;END;
  xz:=x1-x0;yz:=y1-y0;
  MOVE(xz,buffer^[0],2);
  MOVE(yz,buffer^[2],2);
  FOR yc:=y0 TO y1 DO BEGIN
    yz:=(yc-y0)*(xz+1);
    CASE memmode OF
      _p8:BEGIN
        l00:=yc*bytes+x0;
        l01:=yc*bytes+x1;
        SetBank(l00 SHR 16);
        IF l00 SHR 16=l01 SHR 16 THEN MOVE(MEM[vseg:WORD(l00)],buffer^[4+yz],SUCC(x1-x0))
         ELSE BEGIN
          MOVE(MEM[vseg:WORD(l00)],buffer^[4+yz],65536-WORD(l00));
          SetBank(l01 SHR 16);
          MOVE(MEM[vseg:0],buffer^[4+yz+65536-WORD(l00)],SUCC(WORD(l01)));
        END;
      END;
    {_p15,_p16:BEGIN
      l00:=y0*bytes+(x0 SHL 1);
      l01:=y0*bytes+(x1 SHL 1);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*2,actualcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),actualcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+2,actualcolor);
      END;
    END;
    _p32:BEGIN
      l00:=y0*bytes+(x0 SHL 2);
      l01:=y0*bytes+(x1 SHL 2);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*4,actualcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),actualcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+4,actualcolor);
      END;
      END;}
    END;
  END;
END;
FUNCTION GetMaxColor:LONGINT;
BEGIN END;
FUNCTION GetMaxMode:INTEGER; {not implemented}
BEGIN END;
FUNCTION GetMaxX:INTEGER;
BEGIN
  GetMaxX:=resolution.x-1;
END;
FUNCTION GetMaxY:INTEGER;
BEGIN
  GetMaxY:=resolution.y-1;
END;
FUNCTION GetModeName(ni0:INTEGER):STRING;
VAR s00:STRING[16];
    s01:STRING[64];
BEGIN
  STR(HI(vid.subver),s00);
  STR(LO(vid.subver),s01);
  s01:=chipnam[vid.chip]+' '+s00+'.'+s01+': ';
  STR(resolution.x,s00);
  s01:=s01+s00+' x ';
  STR(resolution.y,s00);
  s01:=s01+s00+' x ';
  STR(colbits[memmode],s00);
  GetModeName:=s01+s00+' Bit';
END;
PROCEDURE GetModeRange(ni0:INTEGER;VAR ni1,ni2:INTEGER); {not implemented}
BEGIN END;
FUNCTION GetPaletteSize:INTEGER;
BEGIN END;
FUNCTION GetPixel(x0,y0:INTEGER):LONGINT;
CONST msk:ARRAY[0..7]OF BYTE=(128,64,32,16,8,4,2,1);
      plane:ARRAY[0..1]OF BYTE=(5,10);
      mscga4:ARRAY[0..3]OF BYTE=($3f,$cf,$f3,$fc);
      shcga4:ARRAY[0..3]OF BYTE=(6,4,2,0);
VAR l00:LONGINT;
    w00,w01:WORD;
BEGIN
  INC(x0,pagetable.sx[activepage]);
  INC(y0,pagetable.sy[activepage]);
  CASE memmode OF
    _p8:BEGIN
      l00:=y0*bytes+x0;
      SetBank(l00 SHR 16);
      GetPixel:=MEM[vseg:WORD(l00)];
    END;
    _p15,_p16:BEGIN
      l00:=y0*bytes+(x0 SHL 1);
      SetBank(l00 SHR 16);
      GetPixel:=MEMW[vseg:WORD(l00)];
    END;
    _p32:BEGIN
      l00:=y0*bytes+(x0 SHL 2);
      SetBank(l00 SHR 16);
      GetPixel:=MEML[vseg:WORD(l00)];
    END;
  END;
END;
(*PROCEDURE GetTextSettings(VAR textinfo:TextSettingsType);
BEGIN END;
*)
(*PROCEDURE GetViewSetting(VAR viewport:ViewPortType); {not implemented}
BEGIN END;
*)
FUNCTION GetX:INTEGER; {not implemented}
BEGIN END;
FUNCTION GetY:INTEGER; {not implemented}
BEGIN END;
PROCEDURE GraphDefaults;
BEGIN END;
FUNCTION GraphErrorMsg(i0:INTEGER):STRING;
BEGIN END;
FUNCTION GraphResult:INTEGER;
BEGIN
  GraphResult:=graphicresult;
  graphicresult:=0;
END;
FUNCTION ImageSize(x0,y0,x1,y1:INTEGER):WORD;
BEGIN END;
PROCEDURE InitGraph(VAR i0,ni0:INTEGER;ns0:STRING);
VAR cnt0:BYTE;
    w00:WORD;
BEGIN
  graphicresult:=0;
  FindVideo;
  IF chipnam[vid.chip]<>'VESA' THEN BEGIN graphicresult:=-2;EXIT;END;
  SelectVideo;
  OutP($3c6,0);
  ASM
    MOV AX,3
    INT 10h
  END;
  graphicmode:=0;
  FOR cnt0:=1 TO nomodes DO
   IF modetbl[cnt0].md=i0 THEN BEGIN
    graphicmode:=cnt0;
    memmode:=modetbl[graphicmode].memmode;
    pixels:=modetbl[graphicmode].xres;
    lins:=modetbl[graphicmode].yres;
    bytes:=modetbl[graphicmode].bytes;
    resolution.x:=modetbl[graphicmode].xres;
    resolution.y:=modetbl[graphicmode].yres;
  END;
  IF(memmode<>_p8)AND(memmode<>_p15)AND(memmode<>_p16)AND(memmode<>_p32)THEN graphicmode:=0;
  IF graphicmode=0 THEN BEGIN graphicresult:=-1;EXIT;END;
  IF NOT SetMode(modetbl[graphicmode].md)THEN BEGIN graphicresult:=-1;EXIT;END;
  IF memmode>=_pl4 THEN BEGIN
    w00:=RdInX(crtc,$13);
    IF(w00<128)AND((bytes*lins*planes*5 DIV 2)<mm*LONGINT(1024))
     AND(w00>0)AND((bytes DIV w00)IN[1,2,4,8,16])
     AND(memmode<>_cga1)AND(memmode<>_cga2)THEN BEGIN
      WrInX(crtc,$13,w00*2);
      bytes:=bytes*2;
      pixels:=pixels*2;
    END;
    CASE memmode OF
      _text,_text2,_text4:lins:=32768 DIV bytes;
      _cga1,_cga2:lins:=16384 DIV bytes;
      _pl1:lins:=mm*LONGINT(256)DIV bytes;
      ELSE lins:=mm*longint(1024)DIV(bytes*planes);
    END;
    CASE memmode OF
      _p8:pixels:=bytes;
      _p15,_p16:pixels:=bytes SHR 1;
      _p32:pixels:=bytes SHR 2;
    END;
  END;
  ClearDevice;
  pagetable.max:=(pixels DIV resolution.x)*(lins DIV resolution.y);
  IF pagetable.max>15 THEN pagetable.max:=15 ELSE DEC(pagetable.max);
  FOR cnt0:=0 TO pagetable.max DO BEGIN
    pagetable.sx[cnt0]:=(cnt0 MOD(pixels DIV resolution.x))*resolution.x;
    pagetable.sy[cnt0]:=(cnt0 DIV(pixels DIV resolution.x))*resolution.y;
  END;
  SetVisualPage(0);
END;
FUNCTION InstallUserDriver(is0:STRING;np0:POINTER):INTEGER;
BEGIN
  detect:=$101;
END;
PROCEDURE Line(x0,y0,x1,y1:INTEGER);
VAR xz,yz,wx,p:INTEGER;xe:BYTE;pln:WORD;m:SINGLE;
BEGIN
  {IF y0=y1 THEN BEGIN PutHorizontalLine(x0,x1,y0,actualcolor);EXIT;END
   ELSE IF x0=x1 THEN BEGIN VerticalLine(x0,y0,y1);EXIT;END;}
  xz:=x1-x0;yz:=y1-y0;
  IF ABS(xz)<ABS(yz) THEN BEGIN
    m:=xz/yz;
    IF y0>y1 THEN BEGIN yz:=y0;y0:=y1;y1:=yz;xz:=x0;x0:=x1;x1:=xz;END;
    FOR yz:=y0 TO y1 DO IF(yz>=0)AND(yz<lins)THEN BEGIN
      xz:=TRUNC(m*(yz-y1))+x1;
      IF(xz>=0)AND(xz<pixels)THEN PutPixel(xz,yz,actualcolor);
    END;
  END ELSE BEGIN
    IF xz=0 THEN m:=1000 ELSE m:=yz/xz;
    IF x0>x1 THEN BEGIN yz:=y0;y0:=y1;y1:=yz;xz:=x0;x0:=x1;x1:=xz;END;
    FOR xz:=x0 TO x1 DO IF(xz>=0)AND(xz<pixels)THEN BEGIN
      yz:=TRUNC(m*(xz-x1))+y1;
      IF(yz>=0)AND(yz<lins)THEN PutPixel(xz,yz,actualcolor);
    END;
  END;
END;
PROCEDURE LineRel(nx0,ny0:INTEGER); {not implemented}
BEGIN END;
PROCEDURE LineTo(nx0,ny0:INTEGER); {not implemented}
BEGIN END;
PROCEDURE MoveRel(nx0,ny0:INTEGER); {not implemented}
BEGIN END;
PROCEDURE MoveTo(nx0,ny0:INTEGER); {not implemented}
BEGIN END;
PROCEDURE OutText(ns0:STRING); {not implemented}
BEGIN END;
PROCEDURE OutTextXY(x0,y0:INTEGER;s0:STRING);
BEGIN END;
PROCEDURE PieSlice(nx0,ny0:INTEGER;nw0,nw1:WORD); {not implemented}
BEGIN END;
PROCEDURE PutImage(x0,y0:INTEGER;VAR bitmap;w0:WORD);
VAR xc,yc,xz,yz,x1:WORD;l00,l01:LONGINT;
    buffer:^_64kB;
BEGIN
  buffer:=PTR(SEG(bitmap),OFS(bitmap));
  MOVE(buffer^[0],xz,2);
  MOVE(buffer^[2],yz,2);
  IF(x0+xz<0)OR(x0>GETMAXX)OR(y0+yz<0)OR(y0>GETMAXY)THEN EXIT;
  INC(x0,pagetable.sx[activepage]);
  INC(y0,pagetable.sy[activepage]);
  x1:=x0+xz;
  FOR yc:=y0 TO y0+yz DO BEGIN
    yz:=(yc-y0)*(xz+1);
    CASE memmode OF
      _p8:BEGIN
        l00:=yc*bytes+x0;
        l01:=yc*bytes+x1;
        SetBank(l00 SHR 16);
        IF l00 SHR 16=l01 SHR 16 THEN MOVE(buffer^[4+yz],MEM[vseg:WORD(l00)],SUCC(x1-x0))
         ELSE BEGIN
          MOVE(buffer^[4+yz],MEM[vseg:WORD(l00)],65536-WORD(l00));
          SetBank(l01 SHR 16);
          MOVE(buffer^[4+yz+65536-WORD(l00)],MEM[vseg:0],SUCC(WORD(l01)));
        END;
      END;
    {_p15,_p16:BEGIN
      l00:=y0*bytes+(x0 SHL 1);
      l01:=y0*bytes+(x1 SHL 1);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*2,actualcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),actualcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+2,actualcolor);
      END;
    END;
    _p32:BEGIN
      l00:=y0*bytes+(x0 SHL 2);
      l01:=y0*bytes+(x1 SHL 2);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*4,actualcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),actualcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+4,actualcolor);
      END;
      END;}
    END;
  END;
END;
PROCEDURE PutPixel(x0,y0:INTEGER;w0:WORD);
VAR l00:LONGINT;
BEGIN
  IF(x0<0)OR(x0>GETMAXX)OR(y0<0)OR(y0>GETMAXY)THEN EXIT;
  INC(x0,pagetable.sx[activepage]);
  INC(y0,pagetable.sy[activepage]);
  l00:=y0*bytes+x0;
  SetBank(l00 SHR 16);
  MEM[vseg:WORD(l00)]:=w0;
END;
PROCEDURE Rectangle(x0,y0,x1,y1:INTEGER);
BEGIN
  HorizontalLine(x0,x1,y0);HorizontalLine(x0,x1,y1);
  VerticalLine(x0,y0,y1);VerticalLine(x1,y0,y1);
END;
FUNCTION RegisterBGIDriver(np0:POINTER):INTEGER; {not implemented}
BEGIN END;
PROCEDURE RestoreCrtMode;
BEGIN END;
PROCEDURE Sector(nx0,ny0:INTEGER;nw0,nw1,nw2,nw3:WORD); {not implemented}
BEGIN END;
PROCEDURE SetActivePage(w0:WORD);
BEGIN
  activepage:=w0;
END;
PROCEDURE SetAspectRatio(nw0,nw1:WORD); {not implemented}
BEGIN END;
PROCEDURE SetBkColor(nl0:LONGINT); {not implemented}
BEGIN END;
PROCEDURE SetColor(l0:BYTE);
BEGIN
  actualcolor:=l0;
END;
PROCEDURE SetFillStyle(nw0:WORD;l0:LONGINT);
BEGIN
  fillingcolor:=l0;
END;
PROCEDURE SetGraphMode(i0:INTEGER);
BEGIN END;
PROCEDURE SetViewPort(nx0,ny0,nx1,ny1:INTEGER;nb0:BOOLEAN); {not implemented}
BEGIN END;
PROCEDURE SetVisualPage(w0:WORD);
BEGIN
  IF w0=visualpage THEN EXIT;
  IF w0>pagetable.max THEN EXIT;
  SetVStart(pagetable.sx[w0],pagetable.sy[w0]);
  visualpage:=w0;
END;

{complete new functions and procedures}
PROCEDURE GetPixelColor(x0,y0:INTEGER);
BEGIN END;
PROCEDURE DrawPixel(x0,y0:INTEGER);
BEGIN END;
PROCEDURE PutLine(x0,y0,x1,y1:INTEGER;l0:LONGINT);
BEGIN END;
FUNCTION RGB2LongInt(r0,g0,b0:BYTE):LONGINT;
BEGIN
  CASE colbits[memmode]OF
    8:RGB2LongInt:=r0;
    15:RGB2LongInt:=((r0 SHR 3)SHL 5+(g0 SHR 3))SHL 5+(b0 SHR 3);
    16:RGB2LongInt:=((r0 SHR 3)SHL 6+(g0 SHR 2))SHL 5+(b0 SHR 3);
    24:RGB2LongInt:=(LONGINT(r0)SHL 8+g0)SHL 8+b0;
  END;
END;
PROCEDURE LongInt2RGB(l0:LONGINT;VAR r0,g0,b0:BYTE);
BEGIN END;
FUNCTION LongInt2Red(l0:LONGINT):BYTE;
BEGIN END;
FUNCTION LongInt2Green(l0:LONGINT):BYTE;
BEGIN END;
FUNCTION LongInt2Blue(l0:LONGINT):BYTE;
BEGIN END;
PROCEDURE VerticalLine(x0,y0,y1:INTEGER);
VAR yc:INTEGER;
BEGIN
  IF y0>y1 THEN BEGIN yc:=y0;y0:=y1;y1:=yc;END;
  FOR yc:=y0 TO y1 DO PutPixel(x0,yc,actualcolor);
END;
PROCEDURE HorizontalLine(x0,x1,y0:INTEGER);
BEGIN
  PutHorizontalLine(x0,x1,y0,actualcolor);
END;
PROCEDURE PutHorizontalLine(x0,x1,y0:INTEGER;l0:BYTE);
VAR l00,l01:LONGINT;
BEGIN
  INC(x0,pagetable.sx[activepage]);
  INC(x1,pagetable.sx[activepage]);
  INC(y0,pagetable.sy[activepage]);
  l01:=y0*bytes;
  l00:=l01+x0;
  INC(l01,x1);
  SetBank(l00 SHR 16);
  IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0),l0)
   ELSE BEGIN
    FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),l0);
    SetBank(l01 SHR 16);
    FILLCHAR(MEM[vseg:0],SUCC(WORD(l01)),l0);
  END;
END;
FUNCTION GetGraphCardSpecs:STRING;
VAR s00:STRING[64];
BEGIN
  IF vid.mem>1023 THEN BEGIN STR(vid.mem DIV 1024,s00);s00:=s00+' MB';
  END ELSE BEGIN STR(vid.mem,s00);s00:=s00+' kB';END;
  GetGraphCardSpecs:=vid.name+' '+s00;
END;
FUNCTION Pal2LongInt(b0:BYTE):LONGINT;
BEGIN
  Pal2LongInt:=RGB2LongInt(pal[b0,0]SHL 2,pal[b0,1]SHL 2,pal[b0,2]SHL 2);
END;
PROCEDURE CopyPage(source,dest:BYTE);
VAR buffer:ARRAY[0..2559]OF BYTE;
    yz0,yz1,yc:INTEGER;l00,l01:LONGINT;
BEGIN
  IF source=dest THEN EXIT;
  IF(source>pagetable.max)OR(dest>pagetable.max)THEN EXIT;
  FOR yc:=0 TO resolution.y-1 DO BEGIN
    CASE memmode OF
      _p8:BEGIN
        l00:=(yc+pagetable.sy[source])*bytes+pagetable.sx[source];
        l01:=(yc+pagetable.sy[source])*bytes+pagetable.sx[source]+resolution.x-1;
        SetBank(l00 SHR 16);
        IF l00 SHR 16=l01 SHR 16 THEN BEGIN
          MOVE(MEM[vseg:WORD(l00)],buffer,resolution.x);
        END ELSE BEGIN
          MOVE(MEM[vseg:WORD(l00)],buffer,65536-WORD(l00));
          SetBank(l01 SHR 16);
          MOVE(MEM[vseg:0],buffer[65536-WORD(l00)],SUCC(WORD(l01)));
        END;
        l00:=(yc+pagetable.sy[dest])*bytes+pagetable.sx[dest];
        l01:=(yc+pagetable.sy[dest])*bytes+pagetable.sx[dest]+resolution.x-1;
        SetBank(l00 SHR 16);
        IF l00 SHR 16=l01 SHR 16 THEN BEGIN
          MOVE(buffer,MEM[vseg:WORD(l00)],resolution.x);
        END ELSE BEGIN
          MOVE(buffer,MEM[vseg:WORD(l00)],65536-WORD(l00));
          SetBank(l01 SHR 16);
          MOVE(buffer[65536-WORD(l00)],MEM[vseg:0],SUCC(WORD(l01)));
        END;
      END;
    {_p15,_p16:BEGIN
      l00:=y0*bytes+(x0 SHL 1);
      l01:=y0*bytes+(x1 SHL 1);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*2,actualcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),actualcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+2,actualcolor);
      END;
    END;
    _p32:BEGIN
      l00:=y0*bytes+(x0 SHL 2);
      l01:=y0*bytes+(x1 SHL 2);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*4,actualcolor)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),actualcolor);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+4,actualcolor);
      END;
      END;}
    END;
  END;
END;
FUNCTION GetActivePage:WORD;
BEGIN
  GetActivePage:=activepage;
END;

BEGIN END.