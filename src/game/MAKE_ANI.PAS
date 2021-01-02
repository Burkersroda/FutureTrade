{$I-,N+,E+,G+,M 65520,0,400000}
uses graph,dos,crt,vgamouse,anivga;
type maus=record
          x,y:integer;
          b:byte;end;
     felder=record
            nm:string[8];
            idt:byte;end;
     Palette = ARRAY [0..255,0..2] OF BYTE;
     no1=array[0..14,0..63,0..63]of byte;
     no2=array[15..29,0..63,0..63]of byte;
     no3=array[30..44,0..63,0..63]of byte;
     no4=array[45..59,0..63,0..63]of byte;
     no5=array[60..63,0..63,0..63]of byte;
var soq,cmp:boolean;
    sl,el,farbt,rot,gruen,blau,apa,vaz:byte;
    i,j,hoe, br, si, bi,maxcol:integer;
    anz,pic,dirst,pf,mf,von,bis,schl,res, x, y, fz, vf:word;
    absch:longint;
    tlr:single;
    ziel,datei,voice:string[38];
    kenn:string[20];
    tf,vd:file;
    vbuf:array[1..3957]of byte;
    buf:ARRAY[1..4096]OF BYTE;
    pics:array[1..800]of string[8];
    rflg:array[1..2600]of felder;
    ms:maus;
    pal : Palette;
    f1:^no1;f2:^no2;f3:^no3;f4:^no4;f5:^no5;
procedure egavga_;external;
{$L egavga}
procedure mouse(ax:byte);
var reg:registers;
begin
  reg.ax:=ax;intr($33,reg);
  ms.x:=reg.cx;ms.y:=reg.dx;ms.b:=reg.bx;
end;
PROCEDURE SetVGAPalette256 (PalBuf : Palette);
VAR
  Reg : REGISTERS;
BEGIN
  Reg.ax := $1012;
  Reg.bx := 0;
  Reg.cx := 256;
  Reg.es := SEG (PalBuf);
  Reg.dx := OFS (PalBuf);
  INTR ($10, Reg);
END;
function info(idr,idg,idb:byte):byte;
begin
  if (idr>63) or (idg>63) or (idb>63) then exit;
  if idr>59 then info:=f5^[idr,idg,idb] else
  if idr>44 then info:=f4^[idr,idg,idb] else
  if idr>29 then info:=f3^[idr,idg,idb] else
  if idr>14 then info:=f2^[idr,idg,idb] else
  if idr>=0 then info:=f1^[idr,idg,idb];
end;
procedure cset(idr,idg,idb,code:byte);
begin
  if (idr>63) or (idg>63) or (idb>63) then exit;
  if idr>59 then f5^[idr,idg,idb]:=code else
  if idr>44 then f4^[idr,idg,idb]:=code else
  if idr>29 then f3^[idr,idg,idb]:=code else
  if idr>14 then f2^[idr,idg,idb]:=code else
  if idr>=0 then f1^[idr,idg,idb]:=code;
end;
procedure invert(x1,y1,x2,y2:integer);
var col1,col2:byte;
begin
  col1:=getpixel(x1,y1);col2:=getpixel(x2,y2);
  setcolor(col2);line(x1,y1,x1,y2);line(x1+1,y1,x2-1,y1);
  setcolor(col1);line(x1+1,y2,x2-1,y2);line(x2,y2,x2,y1);
end;
procedure box(x1,y1,x2,y2:integer);
begin
  setfillstyle(1,7);bar(x1+1,y1+1,x2-1,y2-1);
  setcolor(15);line(x1,y1,x1,y2);line(x1+1,y1,x2-1,y1);
  setcolor(8);line(x1+1,y2,x2-1,y2);line(x2,y2,x2,y1);
end;
procedure fbox(x1,y1,x2,y2:integer;st:string);
begin
  box(x1,y1,x2,y2);settextjustify(0,1);
  setcolor(15);outtextxy(x1+10,round((y1+y2)/2),st);
end;
function press(x1,y1,x2,y2:integer):boolean;
var inv:boolean;
begin
  press:=false;inv:=true;mouse(3);
  if (x1<=ms.x) and (x2>=ms.x) and (y1<=ms.y) and (y2>=ms.y) and (ms.b=1) then begin
    mouse(2);invert(x1,y1,x2,y2);mouse(1);
    repeat mouse(3);
      if (x1<=ms.x) and (x2>=ms.x) and (y1<=ms.y) and (y2>=ms.y) and (not inv) then
      begin inv:=true;mouse(2);invert(x1,y1,x2,y2);mouse(1);end else
      if ((x1>ms.x) or (x2<ms.x) or (y1>ms.y) or (y2<ms.y)) and inv then
      begin inv:=false;mouse(2);invert(x1,y1,x2,y2);mouse(1);end;
    until ms.b=0;
    mouse(2);if inv then begin invert(x1,y1,x2,y2);press:=true;end;mouse(1);
  end;
end;
procedure dir;
var sr:searchrec;f:file;erk:array[1..3]of char;w1:word;st:string[12];
    ds:dirstr;ns:namestr;es:extstr;tmp:array[1..800]of string[8];
procedure bubblesort;
procedure sort(nr:word);
var cpic:string[8];
begin
  cpic:=pics[nr];pics[nr]:=pics[nr+1];pics[nr+1]:=cpic;
end;
var sorted:boolean;cpos,result:byte;snr:word;
begin
  if pic<2 then exit;
  repeat sorted:=false;
    for snr:=1 to pic-1 do begin cpos:=0;result:=0;
      repeat inc(cpos);
        if ord(pics[snr,cpos])<ord(pics[snr+1,cpos]) then result:=1 else
         if ord(pics[snr,cpos])>ord(pics[snr+1,cpos]) then result:=2;
      until (result>0) or (cpos=8);
      if result>1 then begin sort(snr);sorted:=true;end;
    end;
  until not sorted;
end;
begin
  findfirst('*.BMP',$3F,sr);pic:=0;
  while doserror=0 do begin assign(f,sr.name);reset(f,1);st:='';
    blockread(f,erk,2,w1);close(f);for w1:=1 to w1 do st:=st+erk[w1];
    if (st='BM') and (w1=2) then begin inc(pic);
      fsplit(sr.name,ds,ns,es);pics[pic]:=ns;end;findnext(sr);end;
  bubblesort;
end;
procedure prginfo;
var poi:pointer;si:word;
begin
  mouse(2);si:=imagesize(160,140,479,339);if maxavail<si then exit;
  getmem(poi,si);getimage(160,140,479,339,poi^);
  box(160,140,479,339);setcolor(8);settextjustify(1,1);
  outtextxy(320,160,'GoldenWorks SOFTWARE');
  outtextxy(320,200,'8Bit-VGA-Animation-Maker 1.1');
  setcolor(15);outtextxy(319,179,'Programmer-Tools I');
  outtextxy(318,158,'GoldenWorks SOFTWARE');
  outtextxy(318,198,'8Bit-VGA-Animation-Maker 1.1');
  outtextxy(319,319,'(c)1995 by Ronny Burkersroda');
  mouse(1);
  repeat until press(160,140,479,339);
  mouse(2);putimage(160,140,poi^,0);freemem(poi,si);mouse(1);
end;
procedure dirscreen;
var b1:byte;
begin
  mouse(2);box(130,20,149,229);box(130,230,149,439);
  setcolor(15);for b1:=0 to 5 do line(140+b1,120+b1,139-b1,120+b1);
  for b1:=0 to 5 do line(140+b1,345-b1,139-b1,345-b1);
  fbox(0,440,149,459,'Neuer Abschnitt');
  {fbox(50,440,99,459,'COD');fbox(100,440,149,459,'PAL');}
  mouse(1);
end;
procedure showdir;
var w1:word;
begin
  mouse(2);setfillstyle(1,7);bar(0,20,129,439);setcolor(15);settextjustify(0,2);
  for w1:=dirst*5+1 to dirst*5+40 do {case akt of
    0:}if w1<=pic then outtextxy(27,w1*10+20-dirst*50,pics[w1]);
    {1:if w1<=spr then outtextxy(27,w1*10+20-dirst*50,sprs[w1]);
    2:if w1<=pal then outtextxy(27,w1*10+20-dirst*50,pals[w1]);end;}mouse(1);
end;
procedure up;
begin
  if dirst>0 then dec(dirst);showdir;
end;
procedure down;
begin
  {case akt of 0:}if pic>dirst*5+40 then inc(dirst);
    {1:if spr>dirst*5+40 then inc(dirst);
    2:if pal>dirst*5+40 then inc(dirst);end;}showdir;
end;
function input(xp,yp:integer;ast,st:string;ln:byte;gre:boolean):string;
var cur:byte;ho,mi,se,cs:word;nz,oz:longint;ch1,ch2:char;
begin
  mouse(2);bar(xp,yp,xp+length(ast)*8+(ln+1)*8,yp+8);setcolor(15);
  cur:=length(st);gettime(ho,mi,se,cs);oz:=ho*360000+mi*6000+se*100+cs;
  repeat outtextxy(xp,yp,ast+st);repeat gettime(ho,mi,se,cs);
    nz:=ho*360000+mi*6000+se*100+cs;if nz<oz+30 then
    rectangle(xp+cur*8+length(ast)*8,yp+8,xp+cur*8+6+length(ast)*8,yp+9) else
    bar(xp+cur*8+length(ast)*8,yp+8,xp+cur*8+6+length(ast)*8,yp+9);
    if nz>oz+60 then oz:=nz;until keypressed;
    ch1:=readkey;if ch1=#0 then ch2:=readkey else ch2:=#0;if gre then ch1:=upcase(ch1);
    if (ch2<>#0) or (ord(ch1)<30) or (cur<length(st)) then
    bar(xp,yp,xp+(length(st)+1)*8+7+length(ast)*8,yp+9)
    else bar(xp+cur*8+length(ast)*8,yp+8,xp+cur*8+7+length(ast)*8,yp+9);
    if (ch2=#0) and (ch1<>#13) then if (ch1=#9) and (length(st)>cur+7) then cur:=cur+8;
    if (ch1=#8) and (cur>0) then begin st:=copy(st,1,cur-1)+
    copy(st,cur+1,length(st)-cur);cur:=cur-1;end else if (ch1>#29) and (ln>length(st)) then
    begin st:=copy(st,1,cur)+ch1+copy(st,cur+1,length(st)-cur);cur:=cur+1;end;
    if (ch2=#75) and (cur>0) then cur:=cur-1;if (ch2=#77) and (cur<length(st)) then cur:=cur+1;
    if (ch2=#83) and (length(st)>0) then st:=copy(st,1,cur)+copy(st,cur+2,length(st)-cur);
    if (ch2=#71) then cur:=0;if (ch2=#79) then cur:=length(st);
  until (ch1=#13);outtextxy(xp,yp,ast+st);input:=st;mouse(1);
end;
procedure showbox;
var b1:word;
begin
  mouse(2);box(150,20,179,239);box(150,240,179,459);settextstyle(0,1,1);
  box(180,20,199,239);box(180,240,199,459);
  setcolor(15);settextjustify(1,1);outtextxy(164,129,'Eintragungen lîschen');
  outtextxy(164,349,'Alle Dateien Åbernehmen');settextstyle(0,0,1);
  for b1:=0 to 5 do line(190+b1,125+b1,189-b1,125+b1);
  for b1:=0 to 5 do line(190+b1,360-b1,189-b1,360-b1);mouse(1);
end;
procedure showit;
var b1:word;st:string;zwst:string[3];
begin
  mouse(2);for b1:=mf*5 to mf*5+19 do begin if b1<pf then begin inc(b1);
      case rflg[b1].idt of 0:st:='BMP-Bild: '+rflg[b1].nm;
        1:st:='nÑchster Abschnitt / neue Palette';end;dec(b1);end else st:='';
    fbox(200,(b1-mf*5)*22+20,639,(b1-mf*5)*22+41,st);
    if b1+1>pf then invert(200,(b1-mf*5)*22+20,639,(b1-mf*5)*22+41);end;
  mouse(1);
end;
procedure einst;
var nziel,nvoice:string[38];nkenn:string[20];ok,cancel,ncmp:boolean;
  Ps:PathStr;ds:DirStr;Ns:NameStr;Es:extStr;sr:searchrec;
begin
  mouse(2);setfillstyle(1,7);bar(200,101,439,118);bar(101,120,538,359);
  setfillstyle(9,7);bar(101,101,199,118);bar(440,101,538,118);
  settextjustify(1,1);setcolor(8);nziel:=ziel;nkenn:=kenn;nvoice:=voice;
  rectangle(100,100,539,360);line(101,119,538,119);setcolor(15);
  outtextxy(319,110,'E I N S T E L L U N G E N');ok:=false;
  outtextxy(320,110,'E I N S T E L L U N G E N');cancel:=false;
  fbox(100,360,319,379,'OK');fbox(320,360,539,379,'Schlie·en');
  settextjustify(0,2);setfillstyle(1,8);
  outtextxy(110,140,'Ziel:');bar(210,137,529,151);outtextxy(215,140,ziel);
  outtextxy(110,180,'Kennung:');bar(210,177,529,191);outtextxy(215,180,kenn);
  outtextxy(110,220,'Kompression:');rectangle(220,220,227,227);
  outtextxy(110,260,'Voice-Datei:');bar(210,257,529,271);outtextxy(215,260,voice);
  if cmp then begin line(221,221,226,226);line(221,226,226,221);end;
  ncmp:=cmp;mouse(1);
  repeat
    mouse(3);if (ms.b=1) and (ms.x>199) and (ms.x<530) then
     if (ms.y>136) and (ms.y<152) then begin mouse(2);
      nziel:=input(215,140,'',nziel,38,true);
      ps:=nziel;fsplit(ps,ds,ns,es);nziel:=ds+ns+es;
      bar(210,137,529,151);outtextxy(215,140,nziel);mouse(1);end else
     if (ms.y>176) and (ms.y<192) then begin mouse(2);
      nkenn:=input(215,180,'',nkenn,20,false);mouse(1);end else
     if (ms.y>256) and (ms.y<272) then begin mouse(2);
      nvoice:=input(215,260,'',nvoice,38,true);
      ps:=nvoice;fsplit(ps,ds,ns,es);nvoice:=ds+ns+es;
      findfirst(nvoice,$3F,sr);if doserror<>0 then nvoice:='' else
      nvoice:=ds+sr.name;bar(210,257,529,271);outtextxy(215,260,voice);mouse(1);end;
     if press(100,360,319,379) then ok:=true;
     if press(320,360,539,379) then cancel:=true;
     if press(220,220,227,227) then begin if ncmp then ncmp:=false else ncmp:=true;
       if ncmp then setcolor(15) else setcolor(7);mouse(2);line(221,221,226,226);
       line(221,226,226,221);mouse(1);setcolor(15);end;
  until ok or cancel;
  if ok then begin kenn:=nkenn;ziel:=nziel;cmp:=ncmp;nvoice:=voice;end;
  mouse(2);dirscreen;showdir;showbox;showit;mouse(1);
end;
procedure up_list;
begin
  if mf=0 then exit;dec(mf);showit;
end;
procedure down_list;
begin
  if (mf*5>pf-19) or (pf<19) then exit;inc(mf);showit;
end;
procedure load;
var ok,cancel:boolean;ndatei:string[12];Ps:PathStr;ds:DirStr;Ns:NameStr;Es:extStr;
  f:file of byte;tmp:array[1..1024]of byte;w1,w2:word;b1,b2:byte;
begin
  mouse(2);setfillstyle(1,7);bar(250,301,389,318);bar(201,320,438,369);
  setfillstyle(9,7);bar(201,301,279,318);bar(438,301,360,318);
  settextjustify(1,1);setcolor(8);ndatei:=datei;
  rectangle(200,300,439,370);line(201,319,438,319);setcolor(15);
  outtextxy(319,310,'L A D E N');ok:=false;
  outtextxy(320,310,'L A D E N');cancel:=false;
  fbox(200,370,319,389,'OK');fbox(320,370,439,389,'Schlie·en');
  settextjustify(0,2);setfillstyle(1,8);
  outtextxy(210,340,'Datei:');bar(300,337,429,351);outtextxy(305,340,ndatei);
  mouse(1);repeat
    mouse(3);if (ms.b=1) and (ms.x>299) and (ms.x<430) then
     if (ms.y>336) and (ms.y<352) then begin mouse(2);
       ndatei:=input(305,340,'',ndatei,12,true);
       ps:=ndatei;fsplit(ps,ds,ns,es);ndatei:=ns+es;
       bar(300,337,429,351);outtextxy(305,340,ndatei);mouse(1);end;
     if press(200,370,319,389) then ok:=true;
     if press(320,370,439,389) then cancel:=true;
  until ok or cancel;if ok then begin datei:=ndatei;
    assign(f,datei);reset(f);if ioresult=0 then begin read(f,b1);kenn:='';
      for b1:=1 to b1 do begin read(f,b2);kenn:=kenn+chr(b2);end;read(f,b1);
      ziel:='';for b1:=1 to b1 do begin read(f,b2);ziel:=ziel+chr(b2);end;
      read(f,b1);read(f,b2);pf:=longint(b1)*256+b2;read(f,b1);
      if b1>127 then begin inc(b1,128);cmp:=true;end else cmp:=false;
      voice:='';for b1:=1 to b1 do begin read(f,b2);voice:=voice+chr(b2);end;
      for pf:=1 to pf do begin read(f,b1);rflg[pf].idt:=b1;read(f,b1);rflg[pf].nm:='';
        for b1:=1 to b1 do begin read(f,b2);rflg[pf].nm:=rflg[pf].nm+chr(b2);end;end;
      close(f);end;end;
  mouse(2);showit;dirscreen;showbox;mouse(1);
end;
procedure save;
var ok,cancel:boolean;ndatei:string[12];Ps:PathStr;ds:DirStr;Ns:NameStr;Es:extStr;
  f:file;tmp:array[1..1024]of byte;w1,w2:word;
begin
  mouse(2);setfillstyle(1,7);bar(250,301,389,318);bar(201,320,438,369);
  setfillstyle(9,7);bar(201,301,249,318);bar(438,301,390,318);
  settextjustify(1,1);setcolor(8);ndatei:=datei;
  rectangle(200,300,439,370);line(201,319,438,319);setcolor(15);
  outtextxy(319,310,'S P E I C H E R N');ok:=false;
  outtextxy(320,310,'S P E I C H E R N');cancel:=false;
  fbox(200,370,319,389,'OK');fbox(320,370,439,389,'Schlie·en');
  settextjustify(0,2);setfillstyle(1,8);
  outtextxy(210,340,'Datei:');bar(300,337,429,351);outtextxy(305,340,ndatei);
  mouse(1);repeat
    mouse(3);if (ms.b=1) and (ms.x>299) and (ms.x<430) then
     if (ms.y>336) and (ms.y<352) then begin mouse(2);
       ndatei:=input(305,340,'',ndatei,12,true);
       ps:=ndatei;fsplit(ps,ds,ns,es);ndatei:=ns+es;
       bar(300,337,429,351);outtextxy(305,340,ndatei);mouse(1);end;
     if press(200,370,319,389) then ok:=true;
     if press(320,370,439,389) then cancel:=true;
  until ok or cancel;if ok then begin datei:=ndatei;
    assign(f,datei);rewrite(f,1);tmp[1]:=length(kenn);
    for w1:=1 to length(kenn) do tmp[w1+1]:=ord(kenn[w1]);
    w2:=length(kenn)+2;tmp[w2]:=length(ziel);
    for w1:=1 to length(ziel) do tmp[w1+w2]:=ord(ziel[w1]);
    inc(w2,length(ziel)+2);tmp[w2-1]:=hi(pf);tmp[w2]:=lo(pf);
    tmp[w2+1]:=length(voice);if cmp then inc(tmp[w2+1],128);
    for w1:=1 to length(voice) do tmp[w1+w2+1]:=ord(voice[w1]);
    inc(w2,length(voice)+1);blockwrite(f,tmp,w2,w1);w2:=0;
    for pf:=1 to pf do begin tmp[1]:=rflg[pf].idt;tmp[2]:=length(rflg[pf].nm);
      w1:=0;for w1:=1 to length(rflg[pf].nm) do tmp[2+w1]:=ord(rflg[pf].nm[w1]);
      blockwrite(f,tmp,2+w1,w2);end;
    close(f);end;
  mouse(2);showit;mouse(1);
end;
procedure delete;
begin
  for pf:=1 to pf do begin rflg[pf].nm:='';rflg[pf].idt:=0;
    {rflg[pf].x:=0;rflg[pf].y:=0;}end;pf:=0;mf:=0;showit;
end;
procedure maybe;
var w1:word;
begin
  w1:=pf;repeat inc(pf);rflg[pf].nm:=pics[pf-w1];
    rflg[pf].idt:=0;until (pf-w1=pic) or (pf>=2600);
  showit;
end;
procedure wvd;
var w1,w2,w3,w4:word;
begin
  mouse(3);
  w2:=0;for w1:=1 to 40 do if (ms.y>w1*10+19) and (ms.y<w1*10+30) then w2:=w1;
  inc(w2,dirst*5);{case akt of 0:}if w2>pic then w2:=0;{1:if w2>spr then w2:=0;
    2:if w2>pal then w2:=0;end;}if w2=0 then exit;
  mousedefine(mbox);repeat if press(130,20,149,229) then up else
     if press(130,230,149,439) then down;
    if press(180,20,199,239) then up_list else
    if press(180,240,199,459) then down_list;mouse(3);
  until ((ms.b=1) and (ms.x>199) and (ms.y>19) and (ms.y<460)) or (ms.b>1);
  mousedefine(arrow);if (ms.b=1) then begin w3:=0;
    for w1:=1 to 20 do if (ms.y>w1*22-3) and (ms.y<w1*22+19) then w3:=w1;
    inc(w3,mf*5);if pf>=w3 then for w4:=pf+1 downto w3 do rflg[w4+1]:=rflg[w4];
    rflg[w3].idt:=0;if pf<2600 then inc(pf);
    {case akt of 0:}rflg[w3].nm:=pics[w2];
      {1:rflg[w3].nm:=sprs[w2];2:rflg[w3].nm:=pals[w2];end;}showit;
  end;repeat mouse(3);until ms.b=0;
end;
procedure wvf;
var w1,w2,w3:word;nm:string[8];id:byte;
begin
  repeat mouse(3);until ms.b=0;
  if (ms.x<200) or (ms.y<20) or (ms.y>459) then exit;
  w2:=0;for w1:=1 to 20 do if (ms.y>w1*22-3) and (ms.y<w1*22+19) then w2:=w1;
  inc(w2,mf*5);if (w2>pf) or (w2=0) then exit;nm:=rflg[w2].nm;id:=rflg[w2].idt;
  dec(pf);for w3:=w2 to pf do rflg[w3]:=rflg[w3+1];showit;
  mousedefine(mbox);repeat if press(180,20,199,239) then up_list else
    if press(180,240,199,459) then down_list;mouse(3);
  until ((ms.b=1) and (ms.x>199) and (ms.y>19) and (ms.y<460)) or (ms.b>1);
  mousedefine(arrow);if (ms.b=1) and (ms.x>199) then begin w2:=0;
    for w1:=1 to 20 do if (ms.y>w1*22-3) and (ms.y<w1*22+19) then w2:=w1;
    inc(w2,mf*5);if pf>=w2 then for w3:=pf+1 downto w2 do rflg[w3+1]:=rflg[w3];
    rflg[w2].idt:=id;if pf<2600 then inc(pf);rflg[w2].nm:=nm;showit;
  end;repeat mouse(3);until ms.b=0;
end;
procedure nabschn;
var w1,w2,w3,w4:word;
begin
  mouse(3);
  mousedefine(mbox);repeat
    if press(180,20,199,239) then up_list else
    if press(180,240,199,459) then down_list;mouse(3);
  until ((ms.b=1) and (ms.x>199) and (ms.y>19) and (ms.y<460)) or (ms.b>1);
  mousedefine(arrow);if (ms.b=1) then begin w3:=0;
    for w1:=1 to 20 do if (ms.y>w1*22-3) and (ms.y<w1*22+19) then w3:=w1;
    inc(w3,mf*5);if pf>=w3 then for w4:=pf+1 downto w3 do rflg[w4+1]:=rflg[w4];
    rflg[w3].idt:=1;if pf<2600 then inc(pf);
    rflg[w3].nm:='';showit;
  end;repeat mouse(3);until ms.b=0;
end;
procedure reduce;
procedure redufarben(flnm:string);
var f:file;st:string;
begin
  ASSIGN (f, flnm+'.BMP');
  RESET (f, 1);
  BLOCKREAD (f, buf, 54, res);
  br := buf [19] + buf [20] * 256;
  hoe := buf [23] + buf [24] * 256;
  farbt := buf [29];
  IF (farbt<>24) or (hoe>200) or (br>320) THEN begin close(f);exit;end;
  bi:=br*hoe*3;
  si:=FILESIZE(f)-54-bi;
  j:=TRUNC(si/hoe);
  setfillstyle(1,0);setcolor(15);
  bar(0,100,639,119);
  outtextxy(0,100,'Farben:');
  outtextxy(0,110,'Erledigt:    %');
  FOR y:=100+round(hoe/2) DOWNTO 101-round(hoe/2) DO BEGIN
    BLOCKREAD (f, buf, br*3, res);
    if (y<=el) and (y>=sl) then
     FOR x := 1 TO br DO begin rot:=round(trunc(trunc(buf[(x-1)*3+1]/4)/tlr)*tlr);
      gruen:=round(trunc(trunc(buf[(x-1)*3+2]/4)/tlr)*tlr);
      blau:=round(trunc(trunc(buf[(x-1)*3+3]/4)/tlr)*tlr);
      if info(rot,gruen,blau)=0 then BEGIN cset(rot,gruen,blau,1);inc(fz);END;end;
    bar(64,100,112,109);bar(80,110,102,119);str(fz,st);outtextxy(64,100,st);
    str(round((201-y)/2/(bis-von+1)+(schl-von)/(bis-von+1)*100),st);
    outtextxy(103-length(st)*8,110,st);
    IF j <> 0 THEN BLOCKREAD (f, buf, j, res);
  END;
  close(f);
end;
var wahl:byte;tl:single;fktr:string;
begin
  fktr:='1.0';
  repeat
    setcolor(15);setfillstyle(1,0);fz:=1;cset(0,0,0,1);settextjustify(0,2);
    repeat
      fktr:=input(0,20,'Faktor (>0): ',fktr,10,true);
      val(fktr,tl,i);
    until (tl>0) and (i=0);
    tlr:=vf/(MaxCol+1)/tl;
    for res:=0 to 63 do for x:=0 to 63 do for y:=0 to 63 do cset(res,x,y,0);
    for schl:=von to bis do redufarben(rflg[schl].nm);
    if fz<MaxCol then begin
      fbox(0,130,39,149,'OK');fbox(40,130,149,149,'Wiederholen');
      mouse(1);wahl:=0;repeat
        if press(0,130,39,149) then wahl:=1;
        if press(40,130,149,149) then wahl:=2;
      until wahl>0;mouse(2);setfillstyle(1,0);bar(0,130,149,149);
    end else wahl:=1;
  until (fz<=MaxCol) and (wahl=1);
end;
procedure richtig;
var Ps:PathStr;ds:DirStr;Ns:NameStr;Es:ExtStr;
begin
  ps:=ziel;fsplit(ps,ds,ns,es);ziel:=ns+es;
  ps:=datei;fsplit(ps,ds,ns,es);datei:=ns+es;
end;
procedure allefarben(flnm:string);
var f:file;st:string;
begin
  ASSIGN (f, flnm+'.BMP');
  RESET (f, 1);
  BLOCKREAD (f, buf, 54, res);
  br := buf [19] + buf [20] * 256;
  hoe := buf [23] + buf [24] * 256;
  farbt := buf [29];
  IF (farbt <> 24) or (hoe>200) or (br>320) THEN begin close(f);exit;end;
  bi := br * hoe * 3;
  si := FILESIZE (f) - 54 - bi;
  j := TRUNC (si / hoe);
  setfillstyle(1,0);setcolor(15);
  bar(0,100,639,119);
  outtextxy(0,100,'Farben:');
  outtextxy(0,110,'Erledigt:    %');
  FOR y:=100+round(hoe/2) DOWNTO 101-round(hoe/2) DO BEGIN
    BLOCKREAD (f, buf, br*3, res);
    if (y<=el) and (y>=sl) then
     FOR x := 1 TO br DO begin rot:=trunc(buf[(x-1)*3+1]/4);
      gruen:=trunc(buf[(x-1)*3+2]/4);blau:=trunc(buf[(x-1)*3+3]/4);
      if info(rot,gruen,blau)=0 then BEGIN cset(rot,gruen,blau,1);inc(fz);END;end;
    bar(64,100,112,109);bar(80,110,102,119);str(fz,st);outtextxy(64,100,st);
    str(round((201-y)/2/(bis-von+1)+(schl-von)/(bis-von+1)*100),st);
    outtextxy(103-length(st)*8,110,st);
    IF j <> 0 THEN BLOCKREAD (f, buf, j, res);
  END;
  close(f);
end;
procedure makeani(flnm:string);
var f:file;exw:word;
begin
  ASSIGN (f, flnm+'.BMP');
  RESET (f, 1);
  BLOCKREAD (f, buf, 54, res);
  br := buf [19] + buf [20] * 256;
  hoe := buf [23] + buf [24] * 256;
  farbt := buf [29];
  IF (farbt <> 24) or (hoe>200) or (br>320) THEN begin close(f);exit;end;
  bi := br * hoe * 3;
  si := FILESIZE (f) - 54 - bi;
  j := TRUNC (si / hoe);
  FOR y:=100+round(hoe/2) DOWNTO 101-round(hoe/2) DO BEGIN
    BLOCKREAD (f, buf, br*3, res);
    if (y<=el) and (y>=sl) then
     FOR x := 1 TO br DO begin rot:=round(trunc(trunc(buf[(x-1)*3+1]/4)/tlr)*tlr);
      gruen:=round(trunc(trunc(buf[(x-1)*3+2]/4)/tlr)*tlr);
      blau:=round(trunc(trunc(buf[(x-1)*3+3]/4)/tlr)*tlr);
      pageputvgapixel(x+159-round(br/2),y-1,info(rot,gruen,blau),apa);end;
    IF j <> 0 THEN BLOCKREAD (f, buf, j, res);
  END;close(f);buf[1]:=2;blockwrite(tf,buf,1,res);j:=1;
  if vaz=0 then begin if voice<>'' then begin blockread(vd,vbuf,3957,res);
      if res<3957 then begin voice:='';close(vd);end;end else fillchar(vbuf,3957,128);
    blockwrite(tf,vbuf,3957,res);end;inc(vaz);if vaz=9 then vaz:=0;
  for vf:=1 to 4 do for x:=0 to 79 do begin si:=pagegetvgapixel(x*4+vf-1,sl-1,apa);
    exw:=1;buf[1]:=1;if cmp then for y:=sl+1 to el+1 do begin
      if y<=el then bi:=pagegetvgapixel(x*4+vf-1,y-1,apa) else bi:=10000;
      inc(j);if bi<>si then begin buf[exw+1]:=si;
        buf[exw+2]:=j-1;si:=bi;j:=1;inc(exw,2);end;end;
    if (not cmp) or (exw>=el-sl+1) then begin buf[1]:=2;exw:=1;
      for y:=sl-1 to el-1 do begin inc(exw);buf[exw]:=pagegetvgapixel(x*4+vf-1,y,apa);end;end;
    blockwrite(tf,buf,exw,res);
  end;
end;
var st:string;
begin
  if registerbgidriver(@egavga_)<0 then halt(255);{akt:=0;}dirst:=0;anz:=0;pic:=0;cmp:=true;
  datei:='ANIMLIST.XXX';i:=9;j:=2;initgraph(i,j,'');box(0,0,639,19);voice:='';
  setcolor(8);outtextxy(18,7,'[GoldenWorks'' Programmer-Tools I]     * * *    8Bit-VGA-Animation-Maker 1.1');
  setcolor(15);outtextxy(16,5,'[GoldenWorks'' Programmer-Tools I]     * * *    8Bit-VGA-Animation-Maker 1.1');
  fbox(0,460,99,479,'START');fbox(100,460,199,479,'LADEN');fbox(200,460,299,479,'SPEICHERN');
  fbox(300,460,539,479,'EINSTELLUNGEN');fbox(540,460,639,479,'EXIT');
  dir;dirscreen;showdir;delete;richtig;maybe;kenn:='';ziel:='A.ANI';richtig;
  showbox;mouse(0);mouse(1);mousedefine(arrow);vaz:=0;
  repeat mouse(3);if (ms.b=1) and (ms.x>199) and (ms.y>19) and (ms.y<460) then wvf;
    if press(0,440,149,459) then nabschn;
    if press(130,20,149,229) then up else if press(130,230,149,439) then down;
    if press(180,20,199,239) then up_list else
    if press(180,240,199,459) then down_list;
    if press(0,0,639,19) then prginfo;
    if press(300,460,539,479) then einst;
    if press(0,20,129,439) then wvd;
    if press(100,460,199,479) then load;
    if press(200,460,299,479) then save;
    if press(150,20,179,239) then delete;
    if press(150,240,179,459) then maybe;
    soq:=press(0,460,99,479);if soq and (pf=0) then soq:=false;
  until press(540,460,639,479) or soq;
  mouse(2);closegraph;
  if soq then begin
    absch:=sizeof(no1)+sizeof(no2)+sizeof(no3)+sizeof(no4)+sizeof(no5);
    if memavail<absch then begin writeln('Es werden noch ',round((absch-memavail)/1024),
       'kB konventioneller Speicher benîtigt!');halt(1);end;
    mf:=0;new(f1);new(f2);new(f3);new(f4);new(f5);
    st:='GWS-Ani 1.0'+chr($0D)+chr($0A)+chr($1A)+chr($1A);assign(tf,ziel);rewrite(tf,1);
    if ioresult<>0 then begin writeln('Zieldatei kann nicht erstellt werden!');halt(2);end;
    for farbt:=1 to length(st) do buf[farbt]:=ord(st[farbt]);apa:=farbt;
    for farbt:=1+farbt to length(kenn)+farbt do buf[farbt]:=ord(kenn[farbt-apa]);
    blockwrite(tf,buf,farbt,res);assign(vd,voice);reset(vd,1);
    if ioresult<>0 then voice:='' else if voice<>'' then blockread(vd,vbuf,45,res);
    repeat inc(mf);von:=mf;fz:=0;
      while (mf<=pf) and (rflg[mf].idt=0) do inc(mf);bis:=mf-1;
      i:=9;j:=2;initgraph(i,j,'');
      setcolor(15);setfillstyle(1,0);settextjustify(0,2);
      repeat
        st:=input(0,0,'Max. Farbanzahl (2-255): ','255',3,true);
        val(st,MaxCol,i);
      until (MaxCol>0) and (MaxCol<256) and (i=0);
      repeat
        st:=input(0,40,'Startlinie (1-200): ','21',3,true);
        val(st,SL,i);
      until (SL>0) and (SL<201) and (i=0);
      repeat
        str(SL,st);
        st:=input(0,50,'Endlinie ('+st+'-200): ','180',3,true);
        val(st,EL,i);
      until (EL>=SL) and (EL<201) and (i=0);
      for res:=0 to 63 do for x:=0 to 63 do for y:=0 to 63 do cset(res,x,y,0);
      for schl:=von to bis do allefarben(rflg[schl].nm);
      vf:=fz;if fz>=MaxCol then reduce else tlr:=1;
      pal[0,0]:=0;pal[0,1]:=0;pal[0,2]:=0;cset(0,0,0,0);fz:=1;
      for vf:=0 to 63 do for x:=0 to 63 do for y:=0 to 63 do
       if info(vf,x,y)=1 then begin pal[fz,0]:=y;pal[fz,1]:=x;pal[fz,2]:=vf;
        cset(vf,x,y,fz);inc(fz);end;buf[1]:=1;buf[2]:=sl;buf[3]:=el;
      for vf:=1 to 255 do begin buf[vf*3+1]:=pal[vf,0];
        buf[vf*3+2]:=pal[vf,1];buf[vf*3+3]:=pal[vf,2];end;
      blockwrite(tf,buf,768,res);
      closegraph;INITVGA;apa:=0;setvgapalette256(pal);screen(apa);
      for schl:=von to bis do makeani(rflg[schl].nm);
      closeroutines;
    until (mf>pf);
    close(tf);if voice<>'' then close(vd);
    dispose(f1);dispose(f2);dispose(f3);dispose(f4);dispose(f5);
  end;
end.