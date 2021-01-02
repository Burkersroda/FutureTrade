USES DOS;

VAR buf:ARRAY[0..32767]OF BYTE;
    f:FILE;
    w0,w1:WORD;
    l0:LONGINT;

BEGIN
  l0:=0;
  ASSIGN(f,'GWS_LOGO.SND');
  RESET(f,1);
  REPEAT
    BLOCKREAD(f,buf,32768,w0);
    IF w0<>0 THEN
     FOR w1:=0 TO w0-1 DO BEGIN
      INC(l0);
      IF ABS(buf[w1]-buf[w1+1])>64 THEN BEGIN WRITE(l0:10,': ',buf[w1]-buf[w1+1]:4,'':5);
        READLN;END;
    END;
  UNTIL w0=0;
  CLOSE(f);
END.