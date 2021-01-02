unit procs;
interface
uses dos;
FUNCTION IsVGA:BOOLEAN;
implementation
FUNCTION IsVGA:BOOLEAN;
var regs:registers;
BEGIN
  WITH Regs DO BEGIN
    AX:=$1A00;
    Intr($10,Regs);
    IsVGA:=(AL=$1A) AND ( (BL=7) OR (BL=8) )
  END;
END;
end.