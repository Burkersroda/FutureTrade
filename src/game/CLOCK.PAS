uses spx_clk,crt,dos;

var h,m,s,hund:Word;
    l1,l2,l3:LONGINT;

begin
  clrscr;
  gettime(h,m,s,hund);
  l1:=360000*h+6000*m+s*100+hund;
  l3:=getclock;
  repeat
    gettime(h,m,s,hund);
    l2:=360000*h+6000*m+s*100+hund-l1;
  until l2>=500;
  l3:=getclock-l3;
  WRITELN(l2/100:0:2,' Sekunden = ',l3,' Ticks -> ',TRUNC(l3/l2*4),' Ticks fr 25 fps');
  readkey;
end.