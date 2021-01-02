{$A+,N+,E+}
UNIT VESA;

INTERFACE

{complete new types, constants and variables}
CONST detect:INTEGER=$100;
      vesaok=$004F;
      alpha:BYTE=255;
      actualcolor:LONGINT=0;
      fillingcolor:LONGINT=0;

TYPE VesaInfoTyp=RECORD
       signature:ARRAY[1..4]OF CHAR;
       version:WORD;
       oemsptr:POINTER;
       capability:LONGINT;
       modeptr:POINTER;
       memory:WORD;
       reserved:ARRAY[1..236]OF CHAR;
     END;
     ModeInfoTyp=RECORD
                  ModeAttr      : Word;
                  WinAAttr      : Byte;
                  WinBAttr      : Byte;
                  WinGran       : Word;
                  WinSize       : Word;
                  WinASeg       : Word;
                  WinBSeg       : Word;
                  WinFuncPtr    : Pointer;
                  ScanLine      : Word;
                  XRes          : Word;
                  YRes          : Word;
                  XCharSize     : Byte;
                  YCharSize     : Byte;
                  NumOfPlanes   : Byte;
                  BitsPerPixel  : Byte;
                  NumOfBanks    : Byte;
                  MemoryModel   : Byte;
                  BankSize      : Byte;
                  ImagePages    : Byte;
                  Reserved0     : Byte;
                  RedMaskSize   : Byte;
                  RedMaskPos    : Byte;
                  GreenMaskSize : Byte;
                  GreenMaskPos  : Byte;
                  BlueMaskSize  : Byte;
                  BlueMaskPos   : Byte;
                  ResMaskSize   : Byte;
                  ResMaskPos    : Byte;
                  DirectScrInfo : Byte;
                  Dummy         : Array[1..216] of Byte;
     END;
     Pal256=ARRAY[0..255,0..2]OF BYTE;

VAR pal:Pal256;

  Function  VESA_Detect( var Info : VesaInfoTyp ) : Integer;
  Function  VESA_ModeInfo( M: Word; var I: ModeInfoTyp ): Integer;
  Function  VESA_SetMode( Mode : Word ) : Integer;
  Function  VESA_GetMode( var Mode:Word ) : Integer;
  Function  VESA_SetScan( PPL: Word ) : Integer;
  Function  VESA_GetScan( var PPL,BPL,MAX: Word ) : Integer;
  Function  VESA_SetDisp( X,Y: Word ) : Integer;
  Function  VESA_GetDisp( var X,Y: Word ) : Integer;

  Function  SvgaInit : Integer;
  Function  SetGraphMode( Modus: Word ) : Integer;
  Procedure CloseGraph;
  Procedure RestoreCrtMode;
  Procedure SetWorkStart( X,Y: Word );
  Procedure SetDispStart( X,Y: Word );
  Procedure WaitForSync;
  Function  CheckSync : Integer;
  Procedure DisplayOn;
  Procedure DisplayOff;
  Function  GetMaxX : Word;
  Function  GetMaxY : Word;
  Procedure MoveTo( X,Y: Word );
  Procedure SetColor( Color: Word );
  Procedure PutPixel( X,Y,Color: Word );
  Function  GetPixel( X,Y: Word ) : Word;
  Procedure Line( X1,Y1,X2,Y2 : Word );
  Procedure LineTo( X,Y : Word );
  Procedure XLine( X,Y,Len: Word );
  Procedure YLine( X,Y,Len: Word );
  Procedure Rectangle( X1,Y1,X2,Y2 : Word );
  Procedure Bar( X1,Y1,X2,Y2 : Word );
  Procedure ClearDevice;
  Procedure PutXLine( var Adresse; Len: Word );
  Procedure GetXLine( var Adresse; Len: Word );
  Procedure PutYLine( var Adresse; Len: Word );
  Procedure GetYLine( var Adresse; Len: Word );
  Procedure SaveBox( X1,Y1,X2,Y2: Word; var Adresse );
  Procedure LoadBox( X1,Y1,X2,Y2: Word; var Adresse );

  Procedure InitFont;
  Procedure TextColor( Col1,Col2: Word );
  Procedure TextSize( Zoom: Word );
  Procedure WriteCharXY( X,Y: Word; Ascii: Char );
  Procedure WriteTextXY( X,Y: Word; Text: String );
  Procedure OutCharXY( X,Y: Word; Ascii: Char );
  Procedure OutTextXY( X,Y: Word; Text: String );


PROCEDURE Arc(ni0,ni1:INTEGER;nw0,nw1,nw2:WORD); {not implemented}
PROCEDURE Bar3D(x0,y0,x1,y1:INTEGER;nw0:WORD;nb0:BOOLEAN); {calls PROC Bar}
PROCEDURE Circle(x0,y0:INTEGER;r0:WORD);
PROCEDURE ClearViewPort; {not implemented}
PROCEDURE DetectGraph(VAR ni0,ni1:INTEGER); {not implemented}
PROCEDURE DrawPoly(nw0:WORD;VAR nothing); {not implemented}
PROCEDURE Ellipse(ni0,ni1:INTEGER;nw0,nw1,nw2,nw3:WORD); {not implemented}
PROCEDURE FillEllipse(ni0,ni1:INTEGER;nw0,nw1:WORD); {not implemented}
PROCEDURE FillPoly(nw0:WORD;VAR nothing); {not implemented}
PROCEDURE FloodFill(ni0,ni1:INTEGER;nw0:WORD); {not implemented}
(*PROCEDURE GetArcCoords(VAR na0:ArcCoordsType); {not implemented}*)
PROCEDURE GetAspectRatio(VAR nw0,nw1:WORD); {not implemented}
FUNCTION GetBkColor:LONGINT; {not implemented}
FUNCTION GetColor:LONGINT;
FUNCTION GetDriverName:STRING;
FUNCTION GetGraphMode:INTEGER;
PROCEDURE GetImage(x0,y0,x1,y1:INTEGER;VAR bitmap);
FUNCTION GetMaxColor:LONGINT;
FUNCTION GetMaxMode:INTEGER; {not implemented}
FUNCTION GetModeName(ni0:INTEGER):STRING;
PROCEDURE GetModeRange(ni0:INTEGER;VAR ni1,ni2:INTEGER); {not implemented}
FUNCTION GetPaletteSize:INTEGER;
(*PROCEDURE GetTextSettings(VAR textinfo:TextSettingsType);*)
(*PROCEDURE GetViewSetting(VAR viewport:ViewPortType); {not implemented}*)
FUNCTION GetX:INTEGER; {not implemented}
FUNCTION GetY:INTEGER; {not implemented}
PROCEDURE GraphDefaults;
FUNCTION GraphErrorMsg(i0:INTEGER):STRING;
FUNCTION GraphResult:INTEGER;
FUNCTION ImageSize(x0,y0,x1,y1:INTEGER):WORD;
PROCEDURE InitGraph(VAR i0,ni0:INTEGER;ns0:STRING);
FUNCTION InstallUserDriver:INTEGER;
PROCEDURE Line2(x0,y0,x1,y1:INTEGER);
PROCEDURE LineRel(nx0,ny0:INTEGER); {not implemented}
PROCEDURE MoveRel(nx0,ny0:INTEGER); {not implemented}
PROCEDURE OutText(ns0:STRING); {not implemented}
PROCEDURE PieSlice(nx0,ny0:INTEGER;nw0,nw1:WORD); {not implemented}
PROCEDURE PutImage(x0,y0:INTEGER;VAR bitmap;w0:WORD);
FUNCTION RegisterBGIDriver(np0:POINTER):INTEGER; {not implemented}
PROCEDURE Sector(nx0,ny0:INTEGER;nw0,nw1,nw2,nw3:WORD); {not implemented}
PROCEDURE SetActivePage(w0:WORD);
PROCEDURE SetAspectRatio(nw0,nw1:WORD); {not implemented}
PROCEDURE SetBkColor(nl0:LONGINT); {not implemented}
PROCEDURE SetFillStyle(nw0:WORD;l0:LONGINT);
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
PROCEDURE PutHorizontalLine(x0,x1,y0:INTEGER;l0:LONGINT);
FUNCTION GetGraphCardSpecs:STRING;
FUNCTION Pal2LongInt(b0:BYTE):LONGINT;
PROCEDURE CopyPage(source,dest:BYTE);

IMPLEMENTATION

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

TYPE
  VideoTyp = Record
               WinSegA    : Word;
               WinSegB    : Word;
               WinOfsA    : Word;
               WinOfsB    : Word;
               CalcRead   : Word;
               CalcWrite  : Word;
               IncRBank   : Word;
               IncWBank   : Word;
               DecRBank   : Word;
               DecWBank   : Word;
               BankA      : Word;
               BankB      : Word;
               GranStep   : Word;
               StartX     : Word;
               StartY     : Word;
               XP         : Word;
               YP         : Word;
               Color      : Longint;
             End;


  TxtTyp = Record
             FX,FY     : Word;
             Col1,Col2 : Word;
             Bpc,Zoom  : Word;
             Bpl       : Word;     { Bytes per Line }
             Font      : Pointer;
           End;

CONST
  MAXLINE =  1200;

VAR
  VesaInfo   : VesaInfoTyp;                  { VESA-Information           }
  Info       : ModeInfoTyp;                  { VESA-Modus Information     }
  RowAddr    : Array [0..MAXLINE-1] of Word; { Adreá-Berechnung (Offset)  }
  BankNum    : Array [0..MAXLINE-1] of Word; { Adreá-Berechnung (Bank)    }
  Video      : VideoTyp;                     { Treiber Variablen          }
  TXT        : TxtTyp;


{$L VESA.OBJ}
 Function  VESA_Detect( var Info : VesaInfoTyp ) : Integer;       EXTERNAL;
 Function  VESA_ModeInfo( M: Word; var I: ModeInfoTyp ): Integer; EXTERNAL;
 Function  VESA_SetMode( Mode : Word ) : Integer;                 EXTERNAL;
 Function  VESA_GetMode( var Mode:Word ) : Integer;               EXTERNAL;
 Function  VESA_SetScan( PPL: Word ) : Integer;                   EXTERNAL;
 Function  VESA_GetScan( var PPL,BPL,MAX: Word ) : Integer;       EXTERNAL;
 Function  VESA_SetDisp( X,Y: Word ) : Integer;                   EXTERNAL;
 Function  VESA_GetDisp( var X,Y: Word ) : Integer;               EXTERNAL;

{$L SVGA256.OBJ}
 Function  SvgaInit : Integer;                                    EXTERNAL;
 Function  SetGraphMode( Modus: Word ) : Integer;                 EXTERNAL;
 Procedure CloseGraph;                                            EXTERNAL;
 Procedure RestoreCrtMode;                                        EXTERNAL;
 Procedure SetWorkStart( X,Y: Word );                             EXTERNAL;
 Procedure SetDispStart( X,Y: Word );                             EXTERNAL;
 Procedure WaitForSync;                                           EXTERNAL;
 Function  CheckSync : Integer;                                   EXTERNAL;
 Procedure DisplayOn;                                             EXTERNAL;
 Procedure DisplayOff;                                            EXTERNAL;
 Function  GetMaxX : Word;                                        EXTERNAL;
 Function  GetMaxY : Word;                                        EXTERNAL;
 Procedure MoveTo( X,Y: Word );                                   EXTERNAL;
 Procedure SetColor( Color: Word );                               EXTERNAL;
 Procedure PutPixel( X,Y,Color: Word );                           EXTERNAL;
 Function  GetPixel( X,Y: Word ) : Word;                          EXTERNAL;
 Procedure Line( X1,Y1,X2,Y2 : Word );                            EXTERNAL;
 Procedure LineTo( X,Y : Word );                                  EXTERNAL;
 Procedure XLine( X,Y,Len: Word );                                EXTERNAL;
 Procedure YLine( X,Y,Len: Word );                                EXTERNAL;
 Procedure Rectangle( X1,Y1,X2,Y2: Word );                        EXTERNAL;
 Procedure Bar( X1,Y1,X2,Y2: Word );                              EXTERNAL;
 Procedure ClearDevice;                                           EXTERNAL;
 Procedure PutXLine( var Adresse; Len: Word );                    EXTERNAL;
 Procedure GetXLine( var Adresse; Len: Word );                    EXTERNAL;
 Procedure PutYLine( var Adresse; Len: Word );                    EXTERNAL;
 Procedure GetYLine( var Adresse; Len: Word );                    EXTERNAL;
 Procedure SaveBox( X1,Y1,X2,Y2: Word; var Adresse );             EXTERNAL;
 Procedure LoadBox( X1,Y1,X2,Y2: Word; var Adresse );             EXTERNAL;

 Procedure InitFont;                                              EXTERNAL;
 Procedure TextColor( Col1,Col2: Word );                          EXTERNAL;
 Procedure TextSize( Zoom: Word );                                EXTERNAL;
 Procedure WriteCharXY( X,Y: Word; Ascii: Char );                 EXTERNAL;
 Procedure WriteTextXY( X,Y: Word; Text: String );                EXTERNAL;
 Procedure OutCharXY( X,Y: Word; Ascii: Char );                   EXTERNAL;
 Procedure OutTextXY( X,Y: Word; Text: String );                  EXTERNAL;


{local functions and procedures}

{global functions and procedures}
PROCEDURE Arc(ni0,ni1:INTEGER;nw0,nw1,nw2:WORD); {not implemented}
BEGIN END;
PROCEDURE Bar3D(x0,y0,x1,y1:INTEGER;nw0:WORD;nb0:BOOLEAN); {calls PROC Bar}
BEGIN
  Bar(x0,y0,x1,y1);
END;
PROCEDURE Circle(x0,y0:INTEGER;r0:WORD);
BEGIN END;
PROCEDURE ClearViewPort; {not implemented}
BEGIN END;
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
FUNCTION GetColor:LONGINT;
BEGIN END;
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
  IF x0>x1 THEN BEGIN xz:=x0;x0:=x1;x1:=xz;END;
  IF y0>y1 THEN BEGIN yz:=y0;y0:=y1;y1:=yz;END;
  xz:=x1-x0;yz:=y1-y0;
  MOVE(xz,buffer^[0],2);
  MOVE(yz,buffer^[2],2);
  INC(xz);
  FOR yc:=0 TO yz DO BEGIN
    MoveTo(x0,yc+y0);
    GetXLine(buffer^[yc*xz+4],xz);
  END;
  (*FOR yc:=y0 TO y1 DO BEGIN
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
  END;*)
END;
FUNCTION GetMaxColor:LONGINT;
BEGIN END;
FUNCTION GetMaxMode:INTEGER; {not implemented}
BEGIN END;
FUNCTION GetModeName(ni0:INTEGER):STRING;
VAR s00:STRING[16];
    s01:STRING[64];
BEGIN
  STR(HI(vesainfo.version),s00);
  STR(LO(vesainfo.version),s01);
  s01:=vesainfo.signature+' '+s00+'.'+s01+': ';
  STR(info.xres,s00);
  s01:=s01+s00+' x ';
  STR(info.yres,s00);
  s01:=s01+s00+' x ';
  STR(info.bitsperpixel,s00);
  GetModeName:=s01+s00+' Bit';
END;
PROCEDURE GetModeRange(ni0:INTEGER;VAR ni1,ni2:INTEGER); {not implemented}
BEGIN END;
FUNCTION GetPaletteSize:INTEGER;
BEGIN END;
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
BEGIN
  {graphicresult:=0;
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
  END;}

  {SetVisualPage(0);}
END;
FUNCTION InstallUserDriver:INTEGER;
CONST pixels=640;
      lins=2880;
VAR cnt0:BYTE;
BEGIN
  pagetable.max:=(pixels DIV info.xres)*(lins DIV info.yres);
  IF pagetable.max>15 THEN pagetable.max:=15 ELSE DEC(pagetable.max);
  FOR cnt0:=0 TO pagetable.max DO BEGIN
    pagetable.sx[cnt0]:=(cnt0 MOD(pixels DIV info.xres))*info.xres;
    pagetable.sy[cnt0]:=(cnt0 DIV(pixels DIV info.xres))*info.yres;
  END;
END;
PROCEDURE Line2(x0,y0,x1,y1:INTEGER);
VAR xz,yz,wx,p:INTEGER;xe:BYTE;pln:WORD;m:SINGLE;
BEGIN
  {IF y0=y1 THEN BEGIN PutHorizontalLine(x0,x1,y0,actualcolor);EXIT;END
   ELSE IF x0=x1 THEN BEGIN VerticalLine(x0,y0,y1);EXIT;END;}
  xz:=x1-x0;yz:=y1-y0;
  IF ABS(xz)<ABS(yz) THEN BEGIN
    m:=xz/yz;
    IF y0>y1 THEN BEGIN yz:=y0;y0:=y1;y1:=yz;xz:=x0;x0:=x1;x1:=xz;END;
    FOR yz:=y0 TO y1 DO IF(yz>=0)AND(yz<=GETMAXY)THEN BEGIN
      xz:=TRUNC(m*(yz-y1))+x1;
      IF(xz>=0)AND(xz<=GETMAXX)THEN PutPixel(xz,yz,GETCOLOR);
    END;
  END ELSE BEGIN
    IF xz=0 THEN m:=1000 ELSE m:=yz/xz;
    IF x0>x1 THEN BEGIN yz:=y0;y0:=y1;y1:=yz;xz:=x0;x0:=x1;x1:=xz;END;
    FOR xz:=x0 TO x1 DO IF(xz>=0)AND(xz<=GETMAXX)THEN BEGIN
      yz:=TRUNC(m*(xz-x1))+y1;
      IF(yz>=0)AND(yz<=GETMAXY)THEN PutPixel(xz,yz,GETCOLOR);
    END;
  END;
END;
PROCEDURE LineRel(nx0,ny0:INTEGER); {not implemented}
BEGIN END;
PROCEDURE MoveRel(nx0,ny0:INTEGER); {not implemented}
BEGIN END;
PROCEDURE OutText(ns0:STRING); {not implemented}
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
  INC(xz);
  FOR yc:=0 TO yz DO BEGIN
    MoveTo(x0,yc+y0);
    PutXLine(buffer^[yc*xz+4],xz);
  END;
  (*FOR yc:=y0 TO y0+yz DO BEGIN
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
  END;*)
END;
FUNCTION RegisterBGIDriver(np0:POINTER):INTEGER; {not implemented}
BEGIN END;
PROCEDURE Sector(nx0,ny0:INTEGER;nw0,nw1,nw2,nw3:WORD); {not implemented}
BEGIN END;
PROCEDURE SetActivePage(w0:WORD);
BEGIN
  IF w0=activepage THEN EXIT;
  IF w0>pagetable.max THEN EXIT;
  SetWorkStart(pagetable.sx[w0],pagetable.sy[w0]);
  activepage:=w0;
END;
PROCEDURE SetAspectRatio(nw0,nw1:WORD); {not implemented}
BEGIN END;
PROCEDURE SetBkColor(nl0:LONGINT); {not implemented}
BEGIN END;
PROCEDURE SetFillStyle(nw0:WORD;l0:LONGINT);
BEGIN
  fillingcolor:=l0;
END;
PROCEDURE SetViewPort(nx0,ny0,nx1,ny1:INTEGER;nb0:BOOLEAN); {not implemented}
BEGIN END;
PROCEDURE SetVisualPage(w0:WORD);
BEGIN
  IF w0=visualpage THEN EXIT;
  IF w0>pagetable.max THEN EXIT;
  SetDispStart(pagetable.sx[w0],pagetable.sy[w0]);
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
(*  CASE colbits[memmode]OF
{    1:rgb:=r and 1;
    2:rgb:=r and 3;
    4:rgb:=r and 15;}
    8:RGB2LongInt:=r0;
    15:RGB2LongInt:=((r0 SHR 3)SHL 5+(g0 SHR 3))SHL 5+(b0 SHR 3);
    16:RGB2LongInt:=((r0 SHR 3)SHL 6+(g0 SHR 2))SHL 5+(b0 SHR 3);
    24:RGB2LongInt:=(LONGINT(r0)SHL 8+g0)SHL 8+b0;
  END;*)
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
  XLine(x0,y0,x1-x0+1);
END;
PROCEDURE PutHorizontalLine(x0,x1,y0:INTEGER;l0:LONGINT);
VAR l00,l01:LONGINT;
    w00,w01:WORD;
BEGIN
  SetColor(l0);
  XLine(x0,y0,x1-x0+1);
  {INC(x0,pagetable.sx[activepage]);
  INC(x1,pagetable.sx[activepage]);
  INC(y0,pagetable.sy[activepage]);
  CASE memmode OF
    _p8:BEGIN
      l00:=y0*bytes+x0;
      l01:=y0*bytes+x1;
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0),l0)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),l0);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],SUCC(WORD(l01)),l0);
      END;
    END;
    _p15,_p16:BEGIN
      l00:=y0*bytes+(x0 SHL 1);
      l01:=y0*bytes+(x1 SHL 1);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*2,l0)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),l0);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+2,l0);
      END;
    END;
    _p32:BEGIN
      l00:=y0*bytes+(x0 SHL 2);
      l01:=y0*bytes+(x1 SHL 2);
      SetBank(l00 SHR 16);
      IF l00 SHR 16=l01 SHR 16 THEN FILLCHAR(MEM[vseg:WORD(l00)],SUCC(x1-x0)*4,l0)
       ELSE BEGIN
        FILLCHAR(MEM[vseg:WORD(l00)],65536-WORD(l00),l0);
        SetBank(l01 SHR 16);
        FILLCHAR(MEM[vseg:0],WORD(l01)+4,l0);
      END;
    END;
  END;}
END;
FUNCTION GetGraphCardSpecs:STRING;
VAR s00:STRING[64];
    x,y,z:WORD;
BEGIN
  IF vesainfo.memory>1023 THEN BEGIN
    STR(vesainfo.memory DIV 1024,s00);
    s00:=s00+' MB';
  END ELSE BEGIN
    STR(vesainfo.memory,s00);
    s00:=s00+' kB';
  END;
  GetGraphCardSpecs:=s00;
END;
FUNCTION Pal2LongInt(b0:BYTE):LONGINT;
BEGIN
  Pal2LongInt:=RGB2LongInt(pal[b0,0]SHL 2,pal[b0,1]SHL 2,pal[b0,2]SHL 2);
END;
PROCEDURE CopyPage(source,dest:BYTE);
VAR buffer:ARRAY[0..2559]OF BYTE;
    yz0,yz1,yc:INTEGER;l00,l01:LONGINT;
BEGIN
  (*IF source=dest THEN EXIT;
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
  END;*)
END;
FUNCTION GetActivePage:WORD;
BEGIN
  GetActivePage:=activepage;
END;

BEGIN END.