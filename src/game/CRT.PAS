USES crtn;
VAR code:WORD;

BEGIN
  REPEAT
    code:=READKEY;
    WRITELN(HI(code),':',LO(code));
  UNTIL LO(code)=27;
END.