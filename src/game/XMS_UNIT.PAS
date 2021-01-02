{$G+,S-}
UNIT XMS_Unit;
{       SMIX is Copyright 1995 by Ethan Brodsky.  All rights reserved.       }
INTERFACE

{Initialization}
FUNCTION XMSInstalled:BOOLEAN;
PROCEDURE XMSInit;

{Informational}
FUNCTION XMSGetVersion:WORD;
FUNCTION XMSGetFreeMem:WORD;

{Allocation and deallocation}
FUNCTION XMSAllocate(VAR handle:WORD;size:WORD):BOOLEAN;
FUNCTION XMSReallocate(handle:WORD;newsize:WORD):BOOLEAN;
FUNCTION XMSFree(handle:WORD):BOOLEAN;

{Memory moves}
TYPE PMoveParams=^TMoveParams;
     TMoveParams=
       RECORD
         length      :LONGINT;  {Length must be a multiple of two}
         sourcehandle:WORD;
         sourceoffset:LONGINT;
         desthandle  :WORD;
         destoffset  :LONGINT;
       END;

FUNCTION XMSMove(params:PMoveParams):BOOLEAN;
PROCEDURE RAM2XMS(source:POINTER;xmshandle:WORD;size,position:LONGINT);
PROCEDURE XMS2RAM(destination:POINTER;xmshandle:WORD;size,position:LONGINT);

IMPLEMENTATION

VAR xmsdriver:POINTER;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

FUNCTION XMSInstalled:BOOLEAN;ASSEMBLER;
ASM
   mov    ax, 4300h
   int    2Fh
   cmp    al, 80h
   jne    @NoXMSDriver
   mov    al, TRUE
   jmp    @Done
   @NoXMSDriver:
   mov    al, FALSE
   @Done:
END;

{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}

PROCEDURE XMSInit;assembler;
      asm
        mov    ax, 4310h
        int    2Fh
        mov    word ptr [XMSDriver], bx
        mov    word ptr [XMSDriver+2], es
      end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

FUNCTION XMSGetVersion:WORD;assembler;
      asm
        mov    ah, 00h
        call   XMSDriver
      end;

{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}

FUNCTION XMSGetFreeMem:WORD;assembler;
      asm
        mov    ah, 08h
        call   XMSDriver
        mov    ax, dx
      end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

FUNCTION XMSAllocate(VAR handle:WORD;size:WORD):BOOLEAN;assembler;
      asm
        mov    ah, 09h
        mov    dx, Size
        call   XMSDriver
        les    di, Handle
        mov    es:[di], dx
      end;

{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}

FUNCTION XMSReallocate(handle:WORD;newsize:WORD):BOOLEAN;assembler;
      asm
        mov    ah, 0Fh
        mov    bx, NewSize
        mov    dx, Handle
        call   XMSDriver
      end;

{ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ}

FUNCTION XMSFree(handle:WORD):BOOLEAN;assembler;
      asm
        mov    ah, 0Ah
        mov    dx, Handle
        call   XMSDriver
      end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

FUNCTION XMSMove(params:PMoveParams):BOOLEAN;assembler;
      asm
        push   ds
        mov    ax, ds
        mov    es, ax
        mov    ah, 0Bh
        lds    si, Params
        call   es:XMSDriver
        pop    ds
      end;

{ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ}

PROCEDURE RAM2XMS(source:POINTER;xmshandle:WORD;size,position:LONGINT);
VAR moveparams:TMoveParams;
BEGIN
  IF xmshandle=0 THEN EXIT;
  moveparams.sourcehandle:=0;
  moveparams.sourceoffset:=LONGINT(ADDR(source^));
  moveparams.desthandle:=xmshandle;
  moveparams.destoffset:=position;
  moveparams.length:=size;
  XMSMove(@MoveParams);
END;

PROCEDURE XMS2RAM(destination:POINTER;xmshandle:WORD;size,position:LONGINT);
VAR moveparams:TMoveParams;
BEGIN
  IF xmshandle=0 THEN EXIT;
  moveparams.sourcehandle:=xmshandle;
  moveparams.sourceoffset:=position;
  moveparams.desthandle:=0;
  moveparams.destoffset:=LONGINT(ADDR(destination^));;
  moveparams.length:=size;
  XMSMove(@MoveParams);
END;


END.
