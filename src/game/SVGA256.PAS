UNIT SVGA256;

INTERFACE

CONST
  VESAOK  = $004F;


TYPE
  VesaInfoTyp = Record
                  Signature  : Array[1..4] of Char;
                  Version    : Word;
                  OemsPtr    : Pointer;
                  Capability : Longint;
                  ModePtr    : Pointer;
                  Memory     : Word;
                  Reserved   : Array[1..236] of Byte;
                end;

  ModeInfoTyp = Record
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
                end;



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



IMPLEMENTATION


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



END.