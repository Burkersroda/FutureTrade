unit modexlib;                  {Header fÅr modexlib.asm}
Interface
Var
  Vscreen:Pointer;              {Zeiger auf Quellbereich fÅr p13_2_modex}
  vpage:Word;                   {Offset der aktuell unsichtbaren Seite}
  palette:Array[0..256*3-1] of Byte; {VGA - Palette}

  Procedure Init_ModeX;         {ModeX einschalten}
  Procedure Enter400;           {von Mode X nach 400-Zeilen schalten}
  {Procedure Double;             {virtuelle horiz. Auflîsung von 640 ein}

  Procedure P13_2_ModeX(start,pic_size:word);  {Bild auf Mode X - Screen kop.}
  Procedure CopyScreen(Ziel,Quelle:Word);  {Quell-Seite nach Ziel-Seite kop.}
  Procedure Copy_Block(Ziel,Quelle,Breite,Hoehe:Word);
                                {kopiert Block von Quell-Offset nach Ziel}
  Procedure ClrX(pmask:byte);   {Mode X - Bildschirm lîschen}

  {Procedure Split(Row:Byte);    {Screen-Splitting in Zeile Row}
  {Procedure Squeeze;            {Bild zusammenfahren von oben und unten}
  Procedure SetStart(t:Word);   {Startadresse des sichtbaren Bilds setzen}
  Procedure Switch;             {zwischen Seite 0 und 1 hin und herschalten}

  Procedure WaitRetrace;        {wartet auf Vertikal-Retrace}
  {Procedure SetPal;             {kopiert Palette in VGA-DAC}
  {Procedure GetPal;             {liest Palette aus VGA-DAC aus}

  {Procedure Fade_Out;           {blendet Bild aus}
  {Procedure Fade_To(Zielpal:Array of Byte; Schritt:Byte);
                                {blendet von Palette nach Zielpal}
  {Procedure Pal_Rot(Start,Ziel:Word);
                                {Rotiert Palettenteil um 1,
                                 wenn Start>Ziel nach oben, sonst unten}


{interne Prozeduren:}
  Procedure Screen_Off;         {schaltet Bildschirm aus}
  Procedure Screen_On;          {schaltet Bildschirm wieder ein}
  Procedure CRTC_Unprotect;     {ermîglicht Zugriff auf Horizontal-Timing}
  Procedure CRTC_Protect;       {verbietet Zugriff wieder}

  Procedure Init_Mode13;        {schaltet Mode 13h ein}
  Procedure Show_Pic13;         {Kopiert VScreen auf Mode 13h}

  Procedure Make_bw(Var WorkPal:Array of Byte); {Palette auf schwarz/wei·}
  PROCEDURE ClearDeviceX;

Implementation
  Procedure Init_ModeX;external;
  Procedure Enter400;external;
  {Procedure Double;external;}

  Procedure P13_2_ModeX;external;
  Procedure CopyScreen;external;
  Procedure Copy_Block;external;
  Procedure ClrX;external;

  {Procedure Split;external;
  Procedure Squeeze;external;}
  Procedure SetStart;external;
  Procedure Switch;external;

  Procedure WaitRetrace;external;
  {Procedure SetPal;external;
  Procedure GetPal;external;

  Procedure Fade_Out;external;
  Procedure Fade_To;external;
  Procedure Pal_Rot;external;}
  {$l modexlib}

Procedure Screen_Off;
Begin
  Port[$3c4]:=1;                {Register 1 des TS (TS Mode) selektieren}
  Port[$3c5]:=Port[$3c5] or 32; {Bit 5 (Screen Off) setzen}
End;
Procedure Screen_On;
Begin
  Port[$3c4]:=1;                {Register 1 des TS (TS Mode) selektieren}
  Port[$3c5]:=Port[$3c5] and not 32;  {Bit 5 (Screen Off lîschen}
End;
Procedure CRTC_UnProtect;
Begin
  Port[$3d4]:=$11;              {Register 11h des CRTC (Vertical Sync End)}
  Port[$3d5]:=Port[$3d5] and not $80  {Bit 7 (Protection Bit) lîschen}
End;
Procedure CRTC_Protect;
Begin
  Port[$3d4]:=$11;              {Register 11h des CRTC (Vertical Sync End)}
  Port[$3d5]:=Port[$3d5] or $80 {Bit 7 (Protection Bit) setzen}
End;
Procedure Init_Mode13;assembler;
asm
  mov ax,13h
  int 10h
End;
Procedure Show_Pic13;           {Kopiert VScreen auf Mode 13h}
Begin
  Move(Vscreen^,Ptr($a000,0)^,64000);
End;
Procedure Make_bw;              {Palette nach schwarz/wei· reduzieren}
Var i,sum:Word;                 {Wertung: 30% rot, 59% grÅn, 11% blau}
Begin
  For i:=0 to 255 do Begin
    Sum:=Round(WorkPal[i*3]*0.3 + WorkPal[i*3+1]*0.59 + WorkPal[i*3+2]*0.11);
    FillChar(WorkPal[i*3],3,Sum); {Werte eintragen}
  End;
End;

PROCEDURE ClearDeviceX;
VAR buf:ARRAY[0..7999]OF BYTE;
    cnt:BYTE;
BEGIN
   FILLCHAR(buf,8000,0);
   vscreen:=ADDR(buf);
   FOR cnt:=0 TO 7 DO P13_2_ModeX(cnt*8000,8000);
END;

Begin
End.
