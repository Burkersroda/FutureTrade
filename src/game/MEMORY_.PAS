{$G+}
Unit Memory;
{
  **************************************************************************
  ***   Die Memory - Unit  des Buches  PC Underground von  DATA BECKER   ***
  ***   Autor           : Boris Bertelsons                               ***
  ***   Erstellt        : 26.01.1994                                     ***
  ***   Letzte énderung : 18.03.1994                                     ***
  *** ------------------------------------------------------------------ ***
  ***  Die Unit stellt Routinen fÅr den Umgang mit dem Speicher zur      ***
  ***  VerfÅgung. Dies beinhaltet insbesondere Routinen zum Handling von ***
  ***  XMS und EMS !                                                     ***
  **************************************************************************
}

Interface

uses dos;

TYPE XMSHandle = word;

     EMSHandle = word;

     XMS_Copyblock = Record     { Wird fÅr die Kopier-Routinen benîtigt }
       Size     : longint;
       Q_Handle : Word;
       Q_Offset : pointer;
       Z_Handle : Word;
       Z_Offset : pointer;
     end;

     EMS_Header = Record        { Zur Erkennung des EMS }
       dummy   : array[0..9] of byte;
       Kennung : array[1..7] of char;
     end;

VAR XMS_Vorhanden   : boolean;  { TRUE, wenn XMS vorhanden ist }
    XMST            : pointer;  { Treiber - Einsprungadresse }
    XMS_Version     : word;     { Die Version des XMS-Treibers }
    XC              : XMS_Copyblock;
    EMS_Vorhanden   : boolean;  { TRUE, wenn EMS vorhanden }
    EMS_Version     : word;     { Die Nummer der EMS-Version. Dabei steht
                                  Vers.MAJ im Hi-Byte und VERS.MIN im
                                  Lo-Byte ! }
    EMS_Seiten_Frei : word;     { Die Anzahl der Freien EMS-Seiten }
    EMS_Seiten_Insg : word;     { Die Anzahl der insgesamt verfÅgbaren
                                  EMS-Seiten }


function  base_free : longint;
{
  Die Function liefert die Grî·e des maximal insgesamt verfÅgbaren
  Hauptspeichers in Bytes zurÅck
}

function  XMS_free  : longint;
{
  Die Function liefert die Grî·e des maximal insgesamt verfÅgbaren
  XMS-Speichers in Bytes zurÅck
}

Function Getmem_XMS(VAR H : XMSHandle; Size : longint) : byte;
{
 Die Function allociert einen Size Bytes gro·en Block im XMS. Dabei wird
 Size auf die nÑchste KB-Grenze aufgerundet. Die Nummer des Handels, unter
 dem der Block angesprochen werden kann, wird in H zurÅckgeliefert, und
 darf nicht verloren gehen, weil sonst der Block erst wieder durch ein
 Reset angesprochen werden kann. Konnte der Speicher allociert werden, so
 liefert die Function den Wert 0, sonst gilt die im Buch vorgestellte
 Fehlertabelle.
}

Function Freemem_XMS(H : XMSHandle) : byte;
{
 Die Function gibt einen Åber GETMEM_XMS belegten Speicherbereich im XMS
 wieder frei. Das Functions-Ergebnis gilt anhand der XMS-Fehlertabelle.
}

Function XMS_2_XMS(h1,h2 : XMSHandle; Size : Word) : byte;
{
 Diese Function kopiert im XMS von h1 in h2 die in Size Åbergebene
 Anzahl Bytes. Dabei mu· Size einen GERADEN Wert haben. FÅr das Functions-
 Ergebnis gilt oben gesagtes.
}

Function RAM_2_XMS(q : pointer; h : XMSHandle; Size : Word) : byte;
{
 Diese Function dient dazu, Daten aus dem Ram ins XMS zu kopieren.
 q ist ein Pointer auf die Quell-Daten im RAM. h ist das Handle, das
 Sie durch die Function GETMEM_XMS erhalten haben. Size ist die Grî·e
 des zu kopierenden Blocks in Byte. Auch hier gilt oben gesagtes fÅr
 die Grî·e des Blocks und das Functions-Ergebnis.
}

Function XMS_2_Ram(d : pointer; h : XMSHandle; Size : Word) : byte;
{
 Diese Function dient dazu, Daten aus dem XMS ins Ram zu kopieren.
 d ist ein Pointer auf den Ziel-Bereich im RAM. h ist das Handle, das
 Sie durch die Function GETMEM_XMS erhalten haben. Size ist die Grî·e
 des zu kopierenden Blocks in Byte. Auch hier gilt oben gesagtes fÅr
 die Grî·e des Blocks und das Functions-Ergebnis.
}

Procedure Check_for_XMS;
{
 Die Procedure prÅft, ob XMS vorhanden ist, und initialisiert die von der
 Unit benîtigten Variablen. XMS_Vorhanden wird auf TRUE gesetzt, wenn ein
 XMS-Treiber vorhanden ist, die Versionsnummer des Treibers finden Sie in
 XMS_Version.
}

procedure Check_for_EMS;
{
 Die Procedure prÅft, ob EMS vorhanden ist, und initialisiert entsprechende
 Variablen
}

Function EMS_free  : longint;
{
 Die Function liefert die grî·e des freien EMS-Speichers in Bytes zurÅck.
}

Function EMS_Segment_ermitteln(VAR Segment : word) : byte;
{
 Diese Function ermittelt das Segment, ab dem das EMS im Hauptspeicher
 eingeblendet wird.
}

Function EMS_Ermittle_Seitenzahl : byte;
{
 Diese Function ermittelt, wieviele Seiten im EMS insgesamt zur VerfÅgung
 stehen, und wieviele davon noch frei sind. Die Werte werden in den globalen
 Variablen "EMS_Seiten_Insg" und "EMS_Seiten_frei" abgelegt.
}

Function Getmem_EMS(VAR H : EMSHandle; Size : longint) : byte;
{
 Diese Function allociert die angegebene Menge Speicher im EMS. Der
 Speicher ist dann Åber das Handle "H" ansprechbar. Bitte beachten Sie,
 da· die Function wenigstens eine Seite, also 16KB im EMS, allociert.
 Es sollten also mîglichst nur grî·ere Datenstrukturen im EMS ausgelagert
 werden.
}

Function Freemem_EMS(H : EMSHandle) : byte;
{
 Diese Function gibt den Åber Getmem_EMS belegten Speicher wieder frei.
}

Function EMS_Zuordnung(H : EMSHandle;PageSeite,EMSSeite : word) : byte;
{
 Mit dieser Funktion kînnen Sie die Zuordnung der EMS-Seiten fÅr das
 entsprechende Handle festlegen. Dabei kann PageSeite einen Wert von 0
 bis 3 einnehmen, und steht fÅr die Seitenposition, an der sie im RAM
 eingeblendet wird. EMSSeite ist die Seite im EMS, die eingeblendet
 werden soll. Wenn Sie also dem Handle EMSH an erster Stelle die Seite 7
 des EMS (interessant bei Blîcken > 64 KB !) zuweisen wollen, mÅ·en Sie
 die Function mit den Parametern (EMSH,0,7) aufrufen.
}

Function EMS_Sichere_Zuordnung(H : EMSHandle) : byte;
{
 Diese Function sichert die Åber EMS_Zuordnung eingestellte Ordnung der
 EMS-Pages fÅr das angegebene Handle vor VerÑnderungen.
}

Function EMS_Entsichere_Zuordnung(H : EMSHandle) : byte;
{
 Ein Åber EMS_Sichere_Zuordnung gesichertes Handle mu· zunÑchst mit dieser
 Function entsichert werden, bevor die Zuordnung verÑndert werden kann.
}

Function RAM_2_EMS(q : pointer; H : EMSHandle; Size : longint) : byte;
{
 Mit dieser Function kopieren Sie den angegebenen Block aus dem Ram ins
 EMS. Size bezeichnet die Grî·e in Bytes, q steht fÅr einen Pointer auf den
 Quellbereich und H ist das Åber Getmem_EMS ermittelte Handle.
}

Function EMS_2_RAM(q : pointer; H : EMSHandle; Size : longint) : byte;
{
 Analog zu RAM_2_EMS kopiert diese Function einen Speicherbereich aus dem
 Ram ins EMS.
}

Function EMS_Handles_vergeben(Var Anzahl : word) : byte;
{
 Diese Function liefert Ihnen die Anzahl der bereits vergebenen EMS-Handles.
 Es kînnen maximal 256 Handles vergeben werden.
}

function XMS_lock(H : XMSHandle) : longint;
{
 Die Funktion sperrt einen XMS-Block gegen das Verschieben und liefert
 seine absolute Adresse
}

procedure XMS_unlock(H : XMSHandle);
{
 Die Procedure entsichert einen gegen Verschieben gesicherten XMS-Block
}


implementation

function base_free : longint;
begin;
  base_free := MemAvail;
end;

function XMS_free  : longint;
var xms_in_kb : word;
    xms_long: longint;
begin;
  asm
    mov ax,0800h                 { 8 = Freien Speicher Ermitteln }
    call dword ptr [XMST]
    mov xms_in_kb,dx
  end;
  xms_long := xms_in_kb;
  XMS_free := xms_long * 1024;
end;

Function Getmem_XMS(VAR H : XMSHandle; Size : longint) : byte;
var bsize : word;
    Fresult : byte;
    xmsh : word;
begin;
  bsize := (size DIV 1024) + 1;
  asm
    mov ax,0900h                 { 9 = Speicherbereich allocieren }
    mov dx,bsize
    call dword ptr [XMST]
    cmp ax,1
    jne @Fehler_GetmemXms
    mov xmsh,dx
    mov Fresult,0
    jmp @Ende_GetmemXms
@Fehler_GetmemXMS:
    mov Fresult,bl
@Ende_GetmemXms:
  end;
  h := xmsh;
  Getmem_Xms := Fresult;
end;

Function Freemem_XMS(H : XMSHandle) : byte;
var fresult : byte;
begin;
  asm                            { A = Speicherbereich deallocieren }
    mov ax,0a00h
    mov dx,h
    call dword ptr [XMST]
    cmp ax,1
    jne @Fehler_FreememXms
    mov Fresult,0
    jmp @Ende_FreememXms
@Fehler_FreememXms:
    mov Fresult,bl
@Ende_FreememXms:
  end;
end;

Function XMS_2_XMS(h1,h2 : XMSHandle; Size : Word) : byte;
VAR fresult : byte;
begin;
  XC.Size     := Size;    { Grî·e des Blocks in Byte }
  XC.Q_Handle := h1;      { Quell-Handle }
  XC.Q_Offset := nil;     { Quell-Offset, 0 = Blockanfang }
  XC.Z_Handle := h2;      { Ziel-Handle }
  XC.Z_Offset := nil;     { Ziel-Offset }
  asm
    mov si,offset XC
    mov ax,0B00h
    call dword ptr [XMST]
    cmp ax,1
    jne @Fehler_RAM2XMS
    mov fresult,0
    jmp @Ende_Ram2XMS
@Fehler_Ram2XMS:
    mov fresult,bl
@Ende_Ram2XMS:
  end;
end;

Function RAM_2_XMS(q : pointer; h : XMSHandle; Size : Word) : byte;
VAR fresult : byte;
begin;
  XC.Size     := Size;
  XC.Q_Handle := 0;              { 0 = RAM }
  XC.Q_Offset := q;
  XC.Z_Handle := h;
  XC.Z_Offset := nil;
  asm
    mov si,offset XC
    mov ax,0B00h
    call dword ptr [XMST]
    cmp ax,1
    jne @Fehler_RAM2XMS
    mov fresult,0
    jmp @Ende_Ram2XMS
@Fehler_Ram2XMS:
    mov fresult,bl
@Ende_Ram2XMS:
  end;
end;

Function XMS_2_Ram(d : pointer; h : XMSHandle; Size : Word) : byte;
VAR fresult : byte;
begin;
  XC.Size     := Size;
  XC.Q_Handle := h;
  XC.Q_Offset := nil;
  XC.Z_Handle := 0;              { 0 = RAM }
  XC.Z_Offset := d;
  asm
    mov si,offset XC
    mov ax,0B00h
    call dword ptr [XMST]
    cmp ax,1
    jne @Fehler_XMS2RAM
    mov fresult,0
    jmp @Ende_XMS2Ram
@Fehler_XMS2Ram:
    mov fresult,bl
@Ende_XMS2Ram:
  end;
end;

Procedure Check_for_XMS; assembler;
  asm
    mov ax,4300h              { PrÅfen, ob Treiber Installiert }
    int 2Fh
    cmp al,80h
    jne @Kein_XMSTreiber
    mov ax,4310h              { Einsprungadresse des Treibers ermitteln }
    int 2Fh
    mov word ptr XMST + 2,es
    mov word ptr XMST + 0,bx
    xor ax,ax                 { Versionsnummer ermitteln }
    call dword ptr [XMST]
    cmp  ax,0200h
    jb   @Kein_XMSTreiber     { Wenn Version < 2.0 dann Abbrechen ! }
    mov  XMS_Version,ax
    mov  XMS_Vorhanden,0
@Kein_XMSTreiber:
    mov XMS_Vorhanden,1
@Ende_XMS_Check:
end;

procedure Check_for_EMS;
var emsseg : word;
    emsptr : pointer;
    emshead : EMS_Header;
begin;
  asm
    mov ax,3567h
    int 21h
    mov emsseg,es
  end;
  move(ptr(emsseg,0)^,emshead,17);
  if emshead.Kennung = 'EMMXXXX' then begin;
    EMS_Vorhanden := true;
    asm
      mov ah,40h                 { EMS-Treiber Status ermitteln }
      int 67h
      cmp ah,0
      jne @EMS_Vers_Fehler
      mov ah,46h                 { EMS - Version ermitteln }
      int 67h
      cmp ah,0
      jne @EMS_Vers_Fehler
      mov bl,al
      shr al,4
      mov bh,al   { bh = Vers.maj }
      or  bl,0Fh  { bl = Vers.min }
      mov EMS_Version,bx
      jmp @EMS_Vers_Ende
@EMS_Vers_Fehler:
      mov EMS_Vorhanden,1
@EMS_Vers_Ende:
    end;
  end else begin;
    EMS_Vorhanden := false;
  end;
end;

Function EMS_Segment_ermitteln(VAR Segment : word) : byte;
VAR hseg : word;
    fergebnis : byte;
begin;
  asm
    mov ah,41h
    int 67h
    cmp ah,0
    jne @EMS_Segerm_Fehler
    mov hseg,bx
    mov fergebnis,0
    jmp @EMS_Segerm_Ende
@EMS_Segerm_Fehler:
    mov fergebnis,ah
@EMS_Segerm_Ende:
  end;
  Segment := hseg;
  EMS_Segment_ermitteln := fergebnis;
end;

Function EMS_Ermittle_Seitenzahl : byte;
var fergebnis : byte;
begin;
  asm
    mov ah,42h
    int 67h
    cmp ah,0
    jne @EMS_ErmSeiten_Fehler
    mov EMS_Seiten_Frei,bx
    mov EMS_Seiten_Insg,dx
    mov fergebnis,0
    jmp @EMS_ErmSeiten_Ende
@EMS_ErmSeiten_Fehler:
    mov fergebnis,ah
@EMS_ErmSeiten_Ende:
  end;
  EMS_Ermittle_Seitenzahl := fergebnis;
end;

function EMS_free  : longint;
var    hilfe : longint;
begin;
  EMS_Ermittle_Seitenzahl;
  hilfe := EMS_Seiten_Frei;
  EMS_free := hilfe SHL 14;
end;

Function Getmem_EMS(VAR H : EMSHandle; Size : longint) : byte;
var Fergebnis : byte;
    ESeiten : word;
    Hhandle : word;
begin;
  ESeiten := (Size DIV 16384) + 1;
  asm
    mov ah,43h
    mov bx,ESeiten
    int 67h
    cmp ah,0
    jne @Getmem_Ems_Fehler
    mov Hhandle,dx
    mov fergebnis,0
    jmp @Getmem_Ems_Ende
@Getmem_Ems_Fehler:
    mov Fergebnis,ah
@Getmem_Ems_Ende:
  end;
  H := Hhandle;
  Getmem_EMS := Fergebnis;
end;

Function Freemem_EMS(H : EMSHandle) : byte;
var Fergebnis : byte;
begin;
  asm
    mov ah,45h
    mov dx,H
    int 67h
    mov Fergebnis,ah
  end;
  Freemem_EMS := Fergebnis;
end;

Function EMS_Zuordnung(H : EMSHandle;PageSeite,EMSSeite : word) : byte;
VAR Fergebnis : byte;
begin;
  asm
    mov ah,44h
    mov al,byte ptr PageSeite
    mov bx,EMSSeite
    mov dx,H
    int 67h
    mov Fergebnis,ah
  end;
  EMS_Zuordnung := Fergebnis;
end;

Function EMS_Sichere_Zuordnung(H : EMSHandle) : byte;
VAR Fergebnis : byte;
begin;
  asm
    mov ah,47h
    mov dx,H
    int 67h
    mov Fergebnis,ah
  end;
  EMS_Sichere_Zuordnung := Fergebnis;
end;

Function EMS_Entsichere_Zuordnung(H : EMSHandle) : byte;
VAR Fergebnis : byte;
begin;
  asm
    mov ah,48h
    mov dx,H
    int 67h
    mov Fergebnis,ah
  end;
  EMS_Entsichere_Zuordnung := Fergebnis;
end;

Function RAM_2_EMS(q : pointer; H : EMSHandle; Size : longint) : byte;
VAR fergebnis : byte;
    EMSseg    : word;
    hp        : ^byte;
    li        : word;
begin;
  EMS_Segment_ermitteln(EMSseg);
  hp := q;
  if Size > 16384 then begin;
    { Mehr al eine Page erforderlich }
    for li := 0 to (Size SHR 14)-1 do begin;
      EMS_Zuordnung(H,0,li);
      move(hp^,ptr(EMSseg,0)^,16384);
      dec(Size,16384);
      inc(hp,16384);
    end;
    EMS_Zuordnung(H,0,li+1);
    move(hp^,ptr(EMSseg,0)^,16384);
    dec(Size,16384);
    inc(hp,16384);
  end else begin;
    EMS_Zuordnung(H,0,0);
    move(hp^,ptr(EMSseg,0)^,16384);
    dec(Size,16384);
    inc(hp,16384);
  end;
end;

Function EMS_2_RAM(q : pointer; H : EMSHandle; Size : longint) : byte;
VAR fergebnis : byte;
    EMSseg    : word;
    hp        : ^byte;
    li        : word;
begin;
  EMS_Segment_ermitteln(EMSseg);
  hp := q;
  if Size > 16384 then begin;
    { Mehr al eine Page erforderlich }
    for li := 0 to (Size SHR 14)-1 do begin;
      EMS_Zuordnung(H,0,li);
      move(ptr(EMSseg,0)^,hp^,16384);
      dec(Size,16384);
      inc(hp,16384);
    end;
    EMS_Zuordnung(H,0,li+1);
    move(ptr(EMSseg,0)^,hp^,16384);
    dec(Size,16384);
    inc(hp,16384);
  end else begin;
    EMS_Zuordnung(H,0,0);
    move(ptr(EMSseg,0)^,hp^,16384);
    dec(Size,16384);
    inc(hp,16384);
  end;
end;

Function EMS_Seiten_belegt(H : EMSHandle;var Seiten : word) : byte;
var fergebnis : byte;
    Hs : word;
begin;
  asm
    mov ah,4Ch
    mov dx,H
    int 67h
    mov HS,bx
    mov fergebnis,ah
  end;
  Seiten := Hs;
  EMS_Seiten_belegt := Fergebnis;
end;

Function EMS_Handles_vergeben(Var Anzahl : word) : byte;
Var Fergebnis : byte;
    Han       : word;
begin;
  asm
    mov ah,4Bh
    int 67h
    mov Han,bx
    mov Fergebnis,ah
  end;
  Anzahl := Han;
  EMS_Handles_vergeben := Fergebnis;
end;

function XMS_lock(H : XMSHandle) : longint; assembler;
asm;
  mov ax,0c00h
  mov dx,h
  call dword ptr [XMST]
  mov ax,bx
end;

procedure XMS_unlock(H : XMSHandle); assembler;
asm;
  mov ax,0d00h
  mov dx,h
  call dword ptr [XMST]
end;


begin;
  Check_for_XMS;
  Check_for_EMS;
end.










