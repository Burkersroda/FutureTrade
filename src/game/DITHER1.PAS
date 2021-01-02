USES CRT;
CONST width=31;
      range=0.6;
TYPE counter_type=ARRAY[0..width,0..width,0..2]OF BYTE;
VAR feld:ARRAY[0..width,0..width]OF BYTE;
    counter:counter_type;
    x,y,swapper,inc_byte:BYTE;
    datei:TEXT;

BEGIN
  FILLCHAR(counter,SQR(width+1)*3,0);
  RANDOMIZE;
  CLRSCR;

  FOR inc_byte:=0 TO 1 DO BEGIN
    FILLCHAR(feld,SQR(width+1),0);
    FOR y:=0 TO width DO FOR x:=0 TO width DO
     IF RANDOM(width+1)/(SQR(SQRT(x+1)+SQRT(y+1)))>=range THEN feld[x,width-y]:=2;
     {IF RANDOM(width+1)/(x+y+1)>=range THEN feld[x,width-y]:=2;}
    FOR y:=0 TO width DO FOR x:=0 TO width DO
     IF RANDOM(width+1)/(SQR(SQRT(x+1)+SQRT(y+1)))>=range THEN INC(feld[x,y]);
     {IF RANDOM(width+1)/(x+y+1)>=range THEN INC(feld[x,y]);}
    swapper:=0;
    FOR y:=0 TO width DO FOR x:=0 TO width DO IF feld[x,y]=3 THEN BEGIN
      DEC(feld[x,y],swapper+1);
      swapper:=1-swapper;
    END;
    FOR y:=0 TO width DO FOR x:=0 TO width DO INC(counter[x,y,feld[x,y]]);
  END;

  FOR y:=0 TO width DO FOR x:=0 TO width DO BEGIN
    IF(counter[x,y,0]>=counter[x,y,1])AND(counter[x,y,0]>counter[x,y,2])THEN feld[x,y]:=0;
    IF(counter[x,y,1]>=counter[x,y,0])AND(counter[x,y,1]>counter[x,y,2])THEN feld[x,y]:=1;
    IF(counter[x,y,2]>=counter[x,y,0])AND(counter[x,y,2]>counter[x,y,1])THEN feld[x,y]:=2;
  END;

  ASSIGN(datei,'DITHER.PAS');
  REWRITE(datei);
  WRITELN(datei,'CONST dither_map:ARRAY[0..',width,',0..',width,']OF BYTE=(');
  FOR y:=0 TO width DO BEGIN
    WRITE(datei,'  (');
    FOR x:=0 TO width DO BEGIN
      WRITE(feld[x,y],' ');
      WRITE(datei,feld[x,y]);
      IF x<width THEN WRITE(datei,',');
    END;
    WRITELN;
    IF y<width THEN WRITELN(datei,'),')
     ELSE WRITELN(datei,'));');
  END;
  CLOSE(datei);
END.