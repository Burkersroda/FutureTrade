USES CRT;
PROCEDURE Test(w1,w2:WORD);FAR;
BEGIN
  WRITELN(w1,' - ',w2);
END;

VAR s,o:WORD;
BEGIN
  ClrScr;
  s:=9;
  ASM
    MOV AX,s            { AX = SchleifenzÑhler }
   @mk1:                { Schleifenstart }
        PUSH AX         { AX im Stack speichern }
        PUSH AX         { AX als erstes Argument ablegen }
        MOV BX,s        { BX als AufrufzÑhler }
        SUB BX,AX
        PUSH BX         { BX als zweites Argument ablegen }
        CALL Test       { Funktion aufrufen }
        POP AX          { AX aus dem Stack zurÅckholen }
        DEC AX          { AX dekrementieren }
    JNZ @mk1            { falls AX<>0 Schleife fortfahren }
  END;
END.