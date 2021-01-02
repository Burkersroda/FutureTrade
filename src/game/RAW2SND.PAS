USES DOS;
CONST erk:STRING[6]='SOUND'#$1A;
VAR s,t:FILE;
    b:ARRAY[1..32000]OF BYTE;
    l:LONGINT;
    w,m:WORD;
    sr:SEARCHREC;
    dir:DirStr;name:NameStr;ext:ExtStr;
    st:STRING;
BEGIN
  WRITELN;
  IF PARAMCOUNT=0 THEN BEGIN
    WRITELN('RAW2SND[.EXE] Quelldatei [Frequenz [0=mono|1=stereo]]');
    WRITELN;
    HALT;
  END;
  FINDFIRST(PARAMSTR(1),$20,sr);
  IF DOSERROR<>0 THEN BEGIN
    FINDFIRST(PARAMSTR(1)+'.RAW',$20,sr);
    IF DOSERROR<>0 THEN BEGIN
      WRITELN(PARAMSTR(1)+' konnte nicht gefunden werden!');
      HALT(1);
    END;
  END;
  FSPLIT(PARAMSTR(1),dir,name,ext);
  st:=dir;
  IF(st<>'')AND(st[LENGTH(st)]<>'\')THEN st:=st+'\';
  ASSIGN(s,st+sr.name);RESET(s,1);
  IF IORESULT<>0 THEN BEGIN
    WRITELN(st+sr.name+' konnte nicht ge”ffnet werden!');
    HALT(2);
  END;
  FSPLIT(sr.name,dir,name,ext);
  ASSIGN(t,st+name+'.SND');REWRITE(t,1);
  IF IORESULT<>0 THEN BEGIN
    CLOSE(s);
    WRITELN(st+name+'.SND konnte nicht erstellt werden!');
    HALT(3);
  END;
  WRITELN('Quelldatei: '+st+sr.name);
  WRITELN('Zieldatei: '+st+name+'.SND');
  VAL(PARAMSTR(2),m,w);
  IF(w<>0)OR(m=0)THEN l:=22050 ELSE l:=m;
  VAL(PARAMSTR(3),m,w);
  IF(w<>0)OR(m=0)THEN m:=0 ELSE m:=1;
  WRITE('Frequenz: ',l,'Hz ');
  IF m=1 THEN INC(l,l);
  IF m=0 THEN WRITELN('Mono') ELSE WRITELN('Stereo');
  BLOCKWRITE(t,erk[1],6,w);BLOCKWRITE(t,WORD(l),2,w);
  BLOCKWRITE(t,BYTE(m),1,w);
  l:=0;
  WHILE w>0 DO BEGIN
    BLOCKREAD(s,b,16382,w);
    IF EOF(s) THEN b[w]:=128;
    BLOCKWRITE(t,b,w,w);
    INC(l,w);
  END;
  WRITELN(l,' Bytes konvertiert');
  WRITELN;
  CLOSE(s);CLOSE(t);
END.