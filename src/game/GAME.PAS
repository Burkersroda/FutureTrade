{$O+,F+,N+,E+,G+,S-}

UNIT Game;
{  Game-Unit for FutureTrade        }
{  (c)1996-99 by Ronny Burkersroda  }

INTERFACE USES vars,vesa,subs,effects,dos,xms_unit,smix,spx_clk,crtn,sub_mml,
               sub_draw,sub_ctrl,sub_text,sub_map,sub_disk,cdrom;

PROCEDURE PlayGame;

IMPLEMENTATION

PROCEDURE PlayGame;
VAR xp,yp,xap,yap,i0:INTEGER;azoom,pb,cf:BYTE;st,s1:STRING;
    ctof:RECORD
      n:BYTE;
      x,y:INTEGER;
    END;
    ware:ARRAY[1..2]OF LONGINT;
PROCEDURE MapXY2ScrXY(x0,y0:BYTE;VAR p0:point);
BEGIN
   p0.x:=((INTEGER(x0)-INTEGER(xp)-INTEGER(y0)+INTEGER(yp))*20+(GETMAXX+1) DIV 2*zoom)DIV zoom;
   p0.y:=(((INTEGER(y0)-INTEGER(yp)+INTEGER(x0)-INTEGER(xp))*10+(GETMAXY+1) DIV 2*zoom)-map[0]^[x0,y0])DIV zoom;
END;
PROCEDURE Waren(stw:BYTE);
BEGIN
  IF stw>20 THEN BEGIN ware[2]:=4194304;
    CASE mapx^.ft[stw-20] OF 0:ware[1]:=16777216;
      1:ware[1]:=131072;
      2:ware[1]:=16384;
      3:ware[1]:=8454533{1+256+4+128+65536+8388608};
      4:BEGIN ware[1]:=4194304;ware[2]:=0;END;
      5:BEGIN ware[1]:=35913728{2097152+262144+33554432};
        INC(ware[2],4160);END;
      6:ware[1]:=2048;
      7:ware[1]:=4192{32+64+4096};
      8:BEGIN ware[1]:=40960{8192+32768};INC(ware[2],64);END;
      9:BEGIN ware[1]:=538{2+16+8+512};
        INC(ware[2],1789312{524288+1024+131072+16384+128+256+1048576+2048+65536});END;
      10:BEGIN ware[1]:=525312{524288+1024};
        INC(ware[2],8454149{1+4+65536+8388608});END;
  END;END ELSE
   IF(mapx^.tt[stw]AND 2=2)OR(stw=mapx^.it)THEN BEGIN
      ware[1]:=67108863;ware[2]:=62914559;END ELSE BEGIN
    ware[1]:=0;ware[2]:=40155232;
    IF mapx^.tt[stw] AND 1=1 THEN BEGIN
      ware[1]:=ware[1] OR 9977988;ware[2]:=ware[2] OR 9977988;END;
    IF mapx^.tt[stw] AND 4=4 THEN BEGIN
      ware[1]:=ware[1] OR 26;ware[2]:=ware[2] OR 1573120;END;
    IF mapx^.tt[stw] AND 8=8 THEN BEGIN
      ware[1]:=ware[1] OR 16777345;ware[2]:=ware[2] OR 16778240;END;
    IF mapx^.tt[stw] AND 16=16 THEN ware[1]:=ware[1] OR 40960;
    IF mapx^.tt[stw] AND 32=32 THEN ware[1]:=ware[1] OR 4192;
    IF mapx^.tt[stw] AND 64=64 THEN BEGIN
      ware[1]:=ware[1] OR 35913728;ware[2]:=ware[2] OR 520;END;
    IF mapx^.tt[stw] AND 128=128 THEN BEGIN
      ware[1]:=ware[1] OR 16842770;ware[2]:=ware[2] OR 1043;END;
  END;
END;
FUNCTION Timing:BOOLEAN;
VAR x0,y0:WORD;minus:SINGLE;
BEGIN
  Timing:=FALSE;
  INC(stime.ev,ttime DIV 50);
  IF active AND 19=0THEN BEGIN geld:=geld-2*ttime DIV 50;active:=active OR 64;END;
  DEC(ttime,ttime-ttime DIV 50);
  IF stime.ev MOD 7=0 THEN BEGIN active:=active OR 32;
    FOR b1:=1 TO mapx^.tc DO FOR l1:=0 TO 25 DO BEGIN
      mapx^.pr[b1,l1]:=mapx^.pr[b1,l1]*(RANDOM(110)/4000+0.9875);
      IF mapx^.pr[b1,l1]<GetPrice[l1]*0.8 THEN mapx^.pr[b1,l1]:=mapx^.pr[b1,l1]*1.05;
      IF mapx^.pr[b1,l1]>GetPrice[l1]*1.25 THEN mapx^.pr[b1,l1]:=mapx^.pr[b1,l1]*0.95;
    END;
  END;
  Mouse(2);
  IF stime.ev>99 THEN BEGIN INC(stime.gt,stime.ev DIV 100);
    DEC(stime.ev,stime.ev DIV 100*100);
    {IF stime.gt>=deathline THEN death:=TRUE;}
  END;
  PUTIMAGE(269,463,tbkgr^,0);
  GreenBar(269,463,370,475);
  OutBTxt((GETMAXX+1) DIV 2-49,GETMAXY-14,TimeString,248);
  Mouse(1);
  IF(stime.gt>2)AND(RANDOM(30-mapx^.itst*3)=3)THEN BEGIN b2:=0;
    IF mapx^.itst<5 THEN BEGIN
      IF mapx^.itst=0 THEN BEGIN b2:=1;
        Timing:=TRUE;
        XMS2RAM(map[1],xms[1],62500,125000);
        map[1]^[mapx^.tx[mapx^.it],mapx^.ty[mapx^.it]]:=14;
        map[1]^[mapx^.tx[mapx^.it],mapx^.ty[mapx^.it]-1]:=15;
        RAM2XMS(map[1],xms[1],62500,125000);
        FOR b1:=3 DOWNTO 1 DO news^[b1+1]:=news^[b1];
        IF b2<>0 THEN news^[1].st:='FREIE STADT '+mapx^.tn[mapx^.it]+' GEGRöNDET';
        news^[1].dt:=stime.gt;news^[1].ev:=stime.ev;
        IF sts=124 THEN active:=active OR 128;
        IF exist_SB THEN BEGIN
          IF soundbyte AND 16=16 THEN BEGIN
            StopSound(3);
            FreeSound(sounds[4]);
          END;
          IF LoadSound(sounds[4],'NACHRCHT')THEN soundbyte:=soundbyte OR 16;
        END;
        IF soundbyte AND 16=16 THEN StartSound(sounds[4],3,FALSE);
      END;
      INC(mapx^.itst);
    END;
  END;
  FOR b1:=1 TO 20 DO
   IF vertr^[b1].gd*100+vertr^[b1].ev<stime.gt*100+stime.ev THEN BEGIN
    vertr^[b1].s:=128;vertr^[b1].t:=0;
    IF vertr^[b1].db AND 128=128 THEN BEGIN
      IF vertr^[b1].s=0 THEN b2:=4 ELSE b2:=2;
      minus:=vertr^[b1].pr DIV b2-vertr^[b1].cc*GetPrice[vertr^[b1].db-128];
      geld:=geld-minus;
      INC(trk.c[vertr^[b1].db-128],vertr^[b1].cc);
      FOR b2:=3 DOWNTO 1 DO news^[b2+1]:=news^[b2];
      STR(minus:0:2,news^[1].st);
      news^[1].st:='VERTRAG WURDE NICHT ERFöLLT. STRAFKOSTEN: '+news^[1].st+pdol;
      news^[1].dt:=stime.gt;news^[1].ev:=stime.ev;
      IF sts=124 THEN active:=active OR 128;
      vertr^[b1].db:=0;
      IF(sts=3)OR(sts=4)OR(sts=6)OR(sts=7)THEN active:=active OR 128;
      IF sts=7 THEN sts:=250;
      IF exist_SB THEN BEGIN
        IF soundbyte AND 16=16 THEN BEGIN
          StopSound(3);
          FreeSound(sounds[4]);
        END;
        IF LoadSound(sounds[4],'NACHRCHT')THEN soundbyte:=soundbyte OR 16;
      END;
      IF soundbyte AND 16=16 THEN StartSound(sounds[4],3,FALSE);
    END;
  END;
  IF RANDOM(4)=2 THEN BEGIN
    IF(sts=4)OR(sts=6)OR(sts=7)THEN active:=active OR 128;
    b1:=1;
    WHILE((vertr^[b1].s<>0)AND(vertr^[b1].s<>128))OR(vertr^[b1].t<>0)OR(vertr^[b1].db<>0)DO INC(b1);
    IF b1=21 THEN b1:=RANDOM(20)+1
     ELSE IF RANDOM(3)=1 THEN b1:=RANDOM(b1-1)+1;
    IF vertr^[b1].db AND 128=0 THEN BEGIN
      REPEAT
        FILLCHAR(vertr^[b1],12,0);
        b2:=0;FOR b3:=1 TO mapx^.fc DO IF mapx^.ft[b3]=9 THEN b2:=1;
        CASE RANDOM(13) OF
          0..2:vertr^[b1].s:=0;
          3..5:REPEAT
            vertr^[b1].s:=RANDOM(mapx^.tc)+1;
          UNTIL(vertr^[b1].s<>mapx^.it)OR(mapx^.itst<>0);
          6..8:vertr^[b1].s:=RANDOM(mapx^.fc)+21;
          9,10:IF(b2=1)OR(mapx^.itst<>0)THEN BEGIN
            vertr^[b1].s:=0;
            vertr^[b1].t:=128;
            vertr^[b1].co:=RANDOM(10)+1;
            vertr^[b1].pr:=vertr^[b1].co*(RANDOM(201)+400);
          END ELSE b2:=2;
          11,12:BEGIN
            vertr^[b1].s:=0;
            vertr^[b1].t:=0;
            vertr^[b1].db:=0;
          END;
        END;
      UNTIL b2<>2;
      b2:=0;
      IF vertr^[b1].s<>128 THEN REPEAT
        IF vertr^[b1].t<>128 THEN BEGIN
          IF vertr^[b1].s<>0 THEN BEGIN
            Waren(vertr^[b1].s);
            REPEAT vertr^[b1].db:=RANDOM(26);
            UNTIL ware[1]AND(LONGINT(1)SHL vertr^[b1].db)>0;
          END;
          REPEAT vertr^[b1].t:=RANDOM(mapx^.tc)+1;
          UNTIL((mapx^.it<>vertr^[b1].t)OR(mapx^.itst<>0))AND(vertr^[b1].t<>vertr^[b1].s);
          Waren(vertr^[b1].t);
          IF vertr^[b1].s=0 THEN REPEAT vertr^[b1].db:=RANDOM(26);
          UNTIL ware[2]AND(LONGINT(1)SHL vertr^[b1].db)>0;
          IF ware[2]AND(LONGINT(1)SHL vertr^[b1].db)>0THEN BEGIN
            b2:=1;vertr^[b1].co:=ROUND(SQRT(RANDOM(36100)+3900));
            IF vertr^[b1].s=0 THEN vertr^[b1].pr:=ROUND((RANDOM(50)+110)*GetPrice[vertr^[b1].db]*vertr^[b1].co/100)
             ELSE BEGIN
              IF vertr^[b1].s<21 THEN BEGIN
                x0:=mapx^.tx[vertr^[b1].s];y0:=mapx^.ty[vertr^[b1].s];
              END ELSE BEGIN
                x0:=mapx^.fx[vertr^[b1].s-20];y0:=mapx^.fy[vertr^[b1].s-20];
              END;
              vertr^[b1].pr:=ROUND((RANDOM(50)+50)*vertr^[b1].co
               *Entfernung(x0,y0,mapx^.tx[vertr^[b1].t],mapx^.ty[vertr^[b1].t])/2500);
            END;
          END;
        END ELSE BEGIN
          FOR b3:=1TO mapx^.fc DO IF(mapx^.ft[b3]=9)AND(RANDOM(4)=2)
           THEN BEGIN vertr^[b1].s:=b3+20;b2:=1;END;
          IF(b2=0)AND(RANDOM(2)=0)AND(mapx^.itst<>0)THEN BEGIN
            vertr^[b1].s:=mapx^.it;b2:=1;END
        END;
      UNTIL b2=1;
      vertr^[b1].gd:=ROUND(SQRT(RANDOM(7)+1))-1;vertr^[b1].ev:=RANDOM(95)+5;
      IF vertr^[b1].s=0 THEN vertr^[b1].pr:=ROUND(vertr^[b1].pr*SQRT(SQRT(100/(vertr^[b1].gd*100+vertr^[b1].ev))))
       ELSE IF vertr^[b1].t<>128 THEN vertr^[b1].pr:=ROUND(vertr^[b1].pr*SQRT(1000/(vertr^[b1].gd*100+vertr^[b1].ev)));
      INC(vertr^[b1].gd,stime.gt);INC(vertr^[b1].ev,stime.ev);
      IF vertr^[b1].ev>99 THEN BEGIN INC(vertr^[b1].gd);DEC(vertr^[b1].ev,100);END;
    END;
  END;
END;
PROCEDURE AntiAliasingLine(x0,y0,x1,y1:INTEGER;color:BYTE);
VAR cnt,xd,yd:INTEGER;value:SINGLE;value1,value2:BYTE;
BEGIN
  xd:=x1-x0;
  yd:=y1-y0;
  IF ABS(xd)>ABS(yd)THEN BEGIN
    IF(x0>x1)THEN BEGIN
      cnt:=x1;x1:=x0;x0:=cnt;
      cnt:=y1;y1:=y0;y0:=cnt;
      xd:=-xd;yd:=-yd;
    END;
    FOR cnt:=0 TO xd DO BEGIN
      x1:=cnt+x0;
      value:=cnt/(xd+1)*yd+y0;
      y1:=TRUNC(value);
      value:=FRAC(value);
      value1:=color+TRUNC((1-value)*6);
      value2:=color+TRUNC(value*6);
      IF(GetPixel(x1,y1)<value1)THEN PutPixel(x1,y1,value1);
      IF(GetPixel(x1,y1+1)<value2)THEN PutPixel(x1,y1+1,value2);
    END;
  END ELSE BEGIN
    IF(y0>y1)THEN BEGIN
      cnt:=x1;x1:=x0;x0:=cnt;
      cnt:=y1;y1:=y0;y0:=cnt;
      xd:=-xd;yd:=-yd;
    END;
    FOR cnt:=0 TO yd DO BEGIN
      y1:=cnt+y0;
      value:=cnt/(yd+1)*xd+x0;
      x1:=TRUNC(value);
      value:=FRAC(value);
      value1:=color+TRUNC((1-value)*6);
      value2:=color+TRUNC(value*6);
      IF(GetPixel(x1,y1)<value1)THEN PutPixel(x1,y1,value1);
      IF(GetPixel(x1+1,y1)<value2)THEN PutPixel(x1+1,y1,value2);
    END;
  END;
END;
PROCEDURE ControlEnemyState;
VAR b0,old_town:BYTE;
BEGIN
  IF enemy.staytime>=enemy.endtime THEN BEGIN
    old_town:=enemy.last_town;
    enemy.last_town:=enemy.actual_town;
    enemy.actual_town:=0;
    WHILE enemy.actual_town=0 DO BEGIN
      FOR b0:=1 TO road^.sc DO IF(road^.p1[b0]=enemy.last_town)OR(road^.p2[b0]=enemy.last_town)THEN BEGIN
        IF(road^.p1[b0]=enemy.last_town)AND(RANDOM(5)=1)THEN enemy.actual_town:=road^.p2[b0]
         ELSE IF(road^.p2[b0]=enemy.last_town)AND(RANDOM(5)=1)THEN enemy.actual_town:=road^.p1[b0];
        IF enemy.actual_town=old_town THEN BEGIN
          FOR b0:=1 TO road^.sc DO IF(road^.p1[b0]=enemy.last_town)OR(road^.p2[b0]=enemy.last_town)THEN BEGIN
            IF(road^.p1[b0]=enemy.last_town)AND(road^.p2[b0]<>old_town)THEN enemy.actual_town:=road^.p2[b0]
             ELSE IF(road^.p2[b0]=enemy.last_town)AND(road^.p1[b0]<>old_town)THEN enemy.actual_town:=road^.p1[b0];
          END;
        END;
        IF(road^.p1[b0]=trk.d)AND(road^.p1[b0]=enemy.last_town)THEN BEGIN
          enemy.actual_town:=trk.s;
          BREAK;
        END;
        IF(road^.p2[b0]=trk.d)AND(road^.p2[b0]=enemy.last_town)THEN BEGIN
          enemy.actual_town:=trk.s;
          BREAK;
        END;
        IF(road^.p1[b0]=trk.s)AND(road^.p1[b0]=enemy.last_town)THEN BEGIN
          enemy.actual_town:=trk.d;
          BREAK;
        END;
        IF(road^.p2[b0]=trk.s)AND(road^.p2[b0]=enemy.last_town)THEN BEGIN
          enemy.actual_town:=trk.d;
          BREAK;
        END;
        IF((road^.p2[b0]=trk.s)AND(road^.p1[b0]=enemy.last_town))
         OR((road^.p1[b0]=trk.s)AND(road^.p2[b0]=enemy.last_town))
         THEN enemy.actual_town:=trk.s;
        IF((road^.p2[b0]=trk.d)AND(road^.p1[b0]=enemy.last_town))
         OR((road^.p1[b0]=trk.d)AND(road^.p2[b0]=enemy.last_town))
         THEN enemy.actual_town:=trk.d;
      END;
      IF(enemy.actual_town=mapx^.it)AND(mapx^.itst=0)THEN enemy.actual_town:=0;
    END;
    enemy.sx:=enemy.tx;
    enemy.sy:=enemy.ty;
    IF enemy.actual_town>20 THEN BEGIN
      enemy.tx:=mapx^.fx[enemy.actual_town-20];
      enemy.ty:=mapx^.fy[enemy.actual_town-20];
    END ELSE BEGIN
      enemy.tx:=mapx^.tx[enemy.actual_town];
      enemy.ty:=mapx^.ty[enemy.actual_town];
    END;
    enemy.distance:=Entfernung(enemy.sx,enemy.sy,enemy.tx,enemy.ty)*4;
    enemy.position:=0;
    enemy.endtime:=0;
  END;
END;
PROCEDURE DrawSprites;
VAR percent_enemy,percent_truck,xz,yz:SINGLE;
    b0:BYTE;
    p1,p2:point;
    flag:BOOLEAN;
    backgr:vehiclebackground;
BEGIN
  IF enemy.position>enemy.distance THEN BEGIN
    enemy.staytime:=0;
    enemy.endtime:=RANDOM(75)+25;
    enemy.position:=enemy.distance;
  END ELSE IF enemy.endtime<>0 THEN ControlEnemyState;
  IF((drawedpos=trk.pos)OR(active AND 2=0))AND(drawedpos_enemy=enemy.position)THEN EXIT;
  percent_enemy:=enemy.position/enemy.distance;
  IF trk.dis=0 THEN percent_truck:=1
   ELSE percent_truck:=trk.pos/trk.dis;
  IF(active AND 2=2)AND(((enemy.last_town=trk.d)AND(enemy.actual_town=trk.s))
   OR((enemy.last_town=trk.s)AND(enemy.actual_town=trk.d)))THEN BEGIN
    IF(enemy.last_town=trk.d)AND(enemy.actual_town=trk.s)THEN xz:=1-percent_enemy
     ELSE xz:=percent_enemy;
    IF(percent_truck>=xz-0.02)AND(percent_truck<=xz+0.02)
     AND(cheats AND 4=0)THEN BEGIN
      death:=TRUE;
      EXIT;
    END;
  END;
  xz:=INTEGER(enemy.tx-enemy.sx)*percent_enemy+enemy.sx;
  yz:=INTEGER(enemy.ty-enemy.sy)*percent_enemy+enemy.sy;
  p1.x:=TRUNC((xz-xap-yz+yap)*20+(GETMAXX+1)DIV 2*azoom)DIV azoom;
  p1.y:=TRUNC((yz-yap+xz-xap)*10+(GETMAXY+1)DIV 2*azoom-map[0]^[ROUND(xz),ROUND(yz)])DIV azoom;
  xz:=INTEGER(trk.tx-trk.sx)*percent_truck+trk.sx;
  yz:=INTEGER(trk.ty-trk.sy)*percent_truck+trk.sy;
  p2.x:=TRUNC((xz-xap-yz+yap)*20+(GETMAXX+1)DIV 2*azoom)DIV azoom;
  p2.y:=TRUNC((yz-yap+xz-xap)*10+(GETMAXY+1)DIV 2*azoom-map[0]^[ROUND(xz),ROUND(yz)])DIV azoom;
  flag:=FALSE;
  IF enemy.backgr_x<>65535 THEN BEGIN
    WaitRetrace;
    Mouse(2);
    PutImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr,0);
    IF trk.px=65535 THEN Mouse(1);
    enemy.backgr_x:=65535;
    flag:=TRUE;
  END;
  IF trk.px<>65535 THEN BEGIN
    IF NOT flag THEN BEGIN
      WaitRetrace;
      Mouse(2);
    END;
    PutImage(trk.px-10,trk.py-10,trk.backgr,0);
    Mouse(1);
    trk.px:=65535;
  END;
  IF((p1.x<40)OR(p1.x>GETMAXX-40)OR(p1.y<10)OR(p1.y>GETMAXY-10))
   AND((p2.x<40)OR(p2.x>GETMAXX-40)OR(p2.y<10)OR(p2.y>GETMAXY-10))THEN EXIT;
  IF(p2.x>=40)AND(p2.x<=GETMAXX-40)AND(p2.y>=10)AND(p2.y<=GETMAXY-10)THEN BEGIN
    trk.px:=p2.x;
    trk.py:=p2.y;
    Mouse(2);
    GetImage(trk.px-10,trk.py-10,trk.px+9,trk.py+9,backgr);
    trk.backgr:=backgr;
    IF percent_truck<1 THEN BEGIN
      FOR p2.y:=0 TO 4 DO FOR p2.x:=0 TO ROUND(COS(p2.y/10*Pi)*4)DO BEGIN
        backgr.c[9-p2.x,9-p2.y]:=zpal[backgr.c[9-p2.x,9-p2.y]];
        backgr.c[10+p2.x,9-p2.y]:=zpal[backgr.c[10+p2.x,9-p2.y]];
        backgr.c[9-p2.x,10+p2.y]:=zpal[backgr.c[9-p2.x,10+p2.y]];
        backgr.c[10+p2.x,10+p2.y]:=zpal[backgr.c[10+p2.x,10+p2.y]];
      END;
      FOR b1:=0 TO 4 DO FOR p2.y:=0 TO b1 DO
       FOR p2.x:=0 TO ROUND(COS(p2.y/((b1+1)*2)*Pi)*b1)DO BEGIN
        INC(backgr.c[9-p2.x,9-p2.y],2);
        INC(backgr.c[10+p2.x,9-p2.y],2);
        INC(backgr.c[9-p2.x,10+p2.y],2);
        INC(backgr.c[10+p2.x,10+p2.y],2);
      END;
      PutImage(trk.px-10,trk.py-10,backgr,0);
    END;
    Mouse(1);
    drawedpos:=trk.pos;
  END;
  IF(p1.x>=40)AND(p1.x<=GETMAXX-40)AND(p1.y>=10)AND(p1.y<=GETMAXY-10)THEN BEGIN
    enemy.backgr_x:=p1.x;
    enemy.backgr_y:=p1.y;
    Mouse(2);
    GetImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr_x+9,enemy.backgr_y+9,backgr);
    enemy.backgr:=backgr;
    p1.y:=4;
    WHILE p1.y<7 DO BEGIN
      p1.x:=0;
      WHILE p1.x<360 DO BEGIN
        p2.x:=ROUND(SIN(p1.x/180*Pi)*(p1.y-0.5)+10);
        p2.y:=ROUND(COS(p1.x/180*Pi)*(p1.y-0.5)+10);
        IF p1.y MOD 2=1 THEN backgr.c[p2.x,p2.y]:=252
         ELSE BEGIN
          b0:=backgr.c[p2.x,p2.y];
          IF b0<236 THEN backgr.c[p2.x,p2.y]:=zpal[b0];
        END;
        INC(p1.x,10);
      END;
      INC(p1.y);
    END;
    FOR p2.x:=9 TO 11 DO FOR p2.y:=3 TO 17 DO BEGIN
      IF(p2.x=10)AND(p2.y>3)AND(p2.y<17)THEN BEGIN
        backgr.c[p2.x,p2.y]:=252;
        backgr.c[p2.y,p2.x]:=252;
      END ELSE BEGIN
        b0:=backgr.c[p2.x,p2.y];
        IF b0<236 THEN backgr.c[p2.x,p2.y]:=zpal[b0];
        b0:=backgr.c[p2.y,p2.x];
        IF b0<236 THEN backgr.c[p2.y,p2.x]:=zpal[b0];
      END;
    END;
    PutImage(enemy.backgr_x-10,enemy.backgr_y-10,backgr,0);
    Mouse(1);
  END;
END;
PROCEDURE PoE(drawit:BOOLEAN);
VAR xz,yz,percent:SINGLE;
    p1,p2:point;
    backgr:vehiclebackground;
    b0:BYTE;
BEGIN
  IF enemy.position>enemy.distance THEN BEGIN
    enemy.staytime:=0;
    enemy.endtime:=RANDOM(75)+25;
    enemy.position:=enemy.distance;
  END ELSE IF enemy.endtime<>0 THEN ControlEnemyState;
  IF NOT drawit OR(enemy.position=drawedpos_enemy)OR(active_sm_name<>0)THEN EXIT;
  percent:=enemy.position/enemy.distance;
  xz:=INTEGER(enemy.tx-enemy.sx)*percent+enemy.sx;
  yz:=INTEGER(enemy.ty-enemy.sy)*percent+enemy.sy;
  p1.x:=TRUNC((xz-yz)/smapdivx)+smapaddx;
  p1.y:=TRUNC((xz+yz)/smapdivy)+smapaddy;
  WaitRetrace;
  Mouse(2);
  IF(enemy.backgr_x<>65535)THEN PutImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr,0);
  enemy.backgr_x:=p1.x;enemy.backgr_y:=p1.y;
  GetImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr_x+9,enemy.backgr_y+9,backgr);
  enemy.backgr:=backgr;
  backgr.c[10,9]:=252;
  backgr.c[10,10]:=255;
  backgr.c[10,11]:=252;
  backgr.c[9,10]:=252;
  backgr.c[11,10]:=252;
  PutImage(enemy.backgr_x-10,enemy.backgr_y-10,backgr,0);
  Mouse(1);
END;
PROCEDURE InTown(town:BYTE);
VAR wo0:WORD;ctf2,ctf3,scrollpos,oldcrt,newcrt:BYTE;
    oldtw,newtw:BYTE;roads:RECORD t,r:ARRAY[1..20]OF BYTE;a:BYTE;END;
    sgl:SINGLE;menge:INTEGER;
    st8:STRING[8];
    li0:LONGINT;
PROCEDURE IB;
BEGIN
  CASE mapx^.ft[town-20] OF
    0:BEGIN
      st:='Mine';
      st8:='BERGWERK';
    END;
    1..3:BEGIN
      st:='Bergwerk'+st;
      st8:='BERGWERK';
    END;
    4:BEGIN
      st:='Wasserpumpstation'+st;
      st8:='PUMPSTAT';
    END;
    5:BEGIN
      st:='Genu·mittelfabrik'+st;
      st8:='PLANTAGE';
    END;
    6:BEGIN
      st:='Hanfplantage'+st;
      st8:='PLANTAGE';
    END;
    7:BEGIN
      st:='Farm'+st;
      st8:='FARM';
    END;
    8:BEGIN
      st:='Ranch'+st;
      st8:='RANCH';
    END;
    9:BEGIN
      st:='Industrie'+st;
      st8:='GÅTERIND';
    END;
    10:BEGIN
      st:='Schmelzwerk'+st;
      st8:='SCHMELZW';
    END;
  END;
END;
PROCEDURE City;
VAR wo0:WORD;
BEGIN
  WITH tip DO IF xpos<>-1 THEN BEGIN
    PutImage(xpos,ypos,backgr[0],0);
    PutImage(xpos,ypos+9,backgr[1],0);
  END;
  OutPic(pal,4,0,255);
  StopSound(2);
  IF trk.px<>65535 THEN PutImage(trk.px-10,trk.py-10,trk.backgr,0);
  PUTIMAGE(269,463,tbkgr^,0);
  IF enemy.backgr_x<>65535 THEN PutImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr,0);
  FOR b1:=0 TO 4 DO BEGIN
    GETIMAGE(0,WORD(b1)*96,GETMAXX,WORD(b1)*96+95,page^);
    RAM2XMS(page,xms[1],61444,475516+LONGINT(b1)*61444);
  END;
  SetActivePage(1-GetActivePage);
  SetColor(0);
  BAR(0,0,GETMAXX,GETMAXY);
  SetVisualPage(GetActivePage);
  IF town<21 THEN IF mapx^.tt[town] AND 2=0 THEN BEGIN
    st:='Raumhafen';
    st8:='RAUMHAFN';
    IF mapx^.it=town THEN BEGIN
      STR(mapx^.itst,st);
      st:='Freie Stadt.'+st;
      st8:='STADT';
    END ELSE IF mapx^.tt[town] AND 1=0 THEN BEGIN
      li0:=(stime.gt+4760)*100+stime.ev;
      STR((li0-li0 DIV 12*12)DIV 6+1,st);
      st:='Stadt.'+st;
      st8:='STADT';
    END;
  END ELSE BEGIN st:='Hauptstadt.';
    IF mapx^.tt[town]AND 128=128 THEN st:=st+'2' ELSE st:=st+'1';
    st8:='RAUMHAFN';
  END ELSE BEGIN
    st:='';IB;
  END;
  IF exist_SB AND(st8<>'')THEN BEGIN
    IF LoadSound(sounds[3],st8)THEN soundbyte:=soundbyte OR 8;
  END;
  IF soundbyte AND 8=8 THEN StartSound(sounds[3],2,TRUE);
  LoadMMLtrack(0,0,0,'scr.'+st,235);OutPic(pal,255,0,255);
  GetCFOriginals(TRUE);
  IF town<21 THEN BEGIN IF st[LENGTH(st)]<#65 THEN st:=COPY(st,1,LENGTH(st)-2);
    wo0:=320-(LENGTH(st)*9)DIV 2;OutBTxt(wo0+16383,10,st,255);
    OutBTxt(wo0+16385,10,st,255);OutBTxt(wo0+16384,9,st,255);
    OutBTxt(wo0+16384,11,st,255);OutBTxt(wo0,10,st,248);
    OutText(319,21,mapx^.tn[town],237,2,17);OutText(321,21,mapx^.tn[town],237,2,17);
    OutText(320,20,mapx^.tn[town],237,2,17);OutText(320,22,mapx^.tn[town],237,2,17);
    OutText(320,21,mapx^.tn[town],244,2,2);
  END ELSE BEGIN STR(ORD(mapx^.tn[1,2])+ORD(mapx^.tn[2,1])-128,s1);
    STR(town-20,st);IF st[0]=#1 THEN st:='0'+st;IF s1[0]=#1 THEN s1:='0'+s1;
    st:='INDUSTRIE (ID-NR. '+s1+'-'+st+')';
    OutBTxt(16384+211,10,st,255);OutBTxt(16384+213,10,st,255);
    OutBTxt(16384+212,9,st,255);OutBTxt(16384+212,11,st,255);
    OutBTxt(212,10,st,248);st:='';ID(st,town-20);
    OutText(319,21,st,237,2,17);OutText(321,21,st,237,2,17);
    OutText(320,20,st,237,2,17);OutText(320,22,st,237,2,17);
    OutText(320,21,st,244,2,2);
  END;
  FILLCHAR(pal[255],3,63);
  InPic(pal,4,0,255);
  FOR b1:=0 TO 3 DO BEGIN
    {FOR wo0:=0 TO 49 DO BEGIN
      GETIMAGE(40,wo0*2+50+b1*100,599,wo0*2+50+b1*100,page^[wo0*1128]);
      GETIMAGE(40,449-wo0*2-b1*100,599,449-wo0*2-b1*100,page^[wo0*1128+564]);
    END;}
    GETIMAGE(40,WORD(b1)*100+50,599,WORD(b1)*100+149,page^);
    RAM2XMS(page,xms[1],56004,251500+LONGINT(b1)*56004);
  END;
  IF active AND 4=0 THEN BEGIN sts:=255;ClickField(33024);END
   ELSE BEGIN sts:=0;ClickField(64768);END;
  tip.time:=0;
  tip.xpos:=-1;
  ms.arrow:=FALSE;
END;
PROCEDURE SmallMap;
VAR x0,y0,x1,y1:INTEGER;
BEGIN
  SETCOLOR(244);
  FOR b2:=1 TO road^.sc DO IF(mapx^.itst<>0)OR
   ((road^.p1[b2]<>mapx^.it)AND(road^.p2[b2]<>mapx^.it))THEN BEGIN
    IF road^.p1[b2]>20 THEN
     BEGIN x0:=mapx^.fx[road^.p1[b2]-20];y0:=mapx^.fy[road^.p1[b2]-20];END
     ELSE BEGIN x0:=mapx^.tx[road^.p1[b2]];y0:=mapx^.ty[road^.p1[b2]];END;
    IF road^.p2[b2]>20 THEN
     BEGIN x1:=mapx^.fx[road^.p2[b2]-20];y1:=mapx^.fy[road^.p2[b2]-20];END
     ELSE BEGIN x1:=mapx^.tx[road^.p2[b2]];y1:=mapx^.ty[road^.p2[b2]];END;
    AntiAliasingLine(TRUNC((x0-y0)/smapdivx)+smapaddx,TRUNC((x0+y0)/smapdivy)+smapaddy,
     TRUNC((x1-y1)/smapdivx)+smapaddx,TRUNC((x1+y1)/smapdivy)+smapaddy,240);
  END;
  SETCOLOR(255);
  IF town>20 THEN BEGIN x0:=mapx^.fx[town-20];y0:=mapx^.fy[town-20];END
   ELSE BEGIN x0:=mapx^.tx[town];y0:=mapx^.ty[town];END;
  x1:=TRUNC((x0-y0)/smapdivx)+smapaddx;
  y1:=TRUNC((x0+y0)/smapdivy)+smapaddy;
  LINE(x1-2,y1,x1+2,y1);
  LINE(x1,y1-2,x1,y1+2);
  FOR b2:=1 TO 40 DO BEGIN
    IF b2<21 THEN BEGIN x1:=mapx^.tx[b2];y1:=mapx^.ty[b2];END
     ELSE BEGIN x1:=mapx^.fx[b2-20];y1:=mapx^.fy[b2-20];END;
    x0:=TRUNC((x1-y1)/smapdivx)+smapaddx;y0:=TRUNC((x1+y1)/smapdivy)+smapaddy;
    GETIMAGE(x0-2,y0-2,x0+2,y0+2,tile^[b2]);
  END;
END;
PROCEDURE GrScr(alles:BOOLEAN);
VAR w0:WORD;
BEGIN
  FOR b1:=0 TO 3 DO BEGIN
    XMS2RAM(page,xms[1],64000,251500+LONGINT(b1)*56004);
    IF alles OR (b1<>3)THEN w0:=56003 ELSE w0:=33043;
    FOR w0:=4 TO w0 DO page^[w0]:=zpal[page^[w0]];
    PUTIMAGE(40,WORD(b1)*100+50,page^,0);
    {FOR y0:=0 TO 49 DO BEGIN
      FOR x0:=4 TO 563 DO BEGIN
        IF(y0<30)OR(b1<3)OR alles THEN page^[x0+y0*1128]:=zpal[page^[x0+y0*1128]];
        IF(y0>20)OR(b1>0)OR alles THEN page^[x0+y0*1128+564]:=zpal[page^[x0+y0*1128+564]];
      END;
      PUTIMAGE(40,y0*2+50+b1*100,page^[y0*1128],0);
      PUTIMAGE(40,449-y0*2-b1*100,page^[y0*1128+564],0);
    END;}
  END;
END;
PROCEDURE PutCross(tilenr,col:BYTE);
VAR x0,y0,x1:INTEGER;
BEGIN
  IF enemy.backgr_x<>65535 THEN BEGIN
    PutImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr,0);
    enemy.backgr_x:=65535;
  END;
  IF tilenr>20 THEN BEGIN x1:=mapx^.fx[tilenr-20];y0:=mapx^.fy[tilenr-20];END
   ELSE BEGIN x1:=mapx^.tx[tilenr];y0:=mapx^.ty[tilenr];END;
  x0:=TRUNC((x1-y0)/smapdivx)+smapaddx;y0:=TRUNC((x1+y0)/smapdivy)+smapaddy;
  IF col=0 THEN PUTIMAGE(x0-2,y0-2,tile^[tilenr],0)
   ELSE BEGIN IF col=128 THEN col:=247 ELSE col:=253;
    SETCOLOR(col);
    PUTPIXEL(x0,y0,col);
    RECTANGLE(x0-2,y0-2,x0+2,y0+2);
  END;
END;
PROCEDURE ShowTownOnSmallMap;
VAR y0:INTEGER;col,pos,nr:BYTE;
BEGIN
  pos:=mapx^.tc+mapx^.fc;
  y0:=0;
  b1:=0;
  FOR pos:=1 TO pos DO IF(pos<>mapx^.it)OR(mapx^.itst<>0)THEN BEGIN
    IF(ms.x>=50)AND(ms.x<=259)AND(ms.y>=y0*8+84)AND(ms.y<=y0*8+90)THEN b1:=pos;
    INC(y0);
  END;
  IF b1<>b2 THEN BEGIN
    y0:=0;
    Mouse(2);
    FOR pos:=1 TO pos DO IF(pos<>mapx^.it)OR(mapx^.itst<>0)THEN BEGIN
      IF pos<=mapx^.tc THEN nr:=pos
       ELSE nr:=pos-mapx^.tc+20;
      IF pos=b1 THEN BEGIN
        col:=253;
        PutCross(nr,1);
        b3:=nr;
      END ELSE IF pos=b2 THEN BEGIN
        IF ODD(y0) THEN col:=244 ELSE col:=247;
        PutCross(nr,0);
      END ELSE col:=0;
      IF col<>0 THEN BEGIN
        IF pos<=mapx^.tc THEN st:=mapx^.tn[pos]
         ELSE BEGIN
          STR(pos-mapx^.tc,st);
          IF pos-mapx^.tc<10 THEN st:='0'+st;
          st:=st+': ';
          ID(st,pos-mapx^.tc);
        END;
        IF LENGTH(st)>14 THEN st:=COPY(st,1,13)+'.';
        OutSTxt(55,y0*8+85,st,col);
        IF pos<=mapx^.tc THEN BEGIN
          sgl:=mapx^.pr[pos,ctf3];
          Waren(pos);
        END ELSE BEGIN
          sgl:=GetPrice[ctf3];
          Waren(pos-mapx^.tc+20);
        END;
        IF ware[1]AND(LONGINT(1)SHL ctf3)>0THEN BEGIN
          STR(sgl:7:2,st);
          Dot2Comma(st);
        END ELSE st:='-';
        OutSTxt(259-LENGTH(st)*6,y0*8+85,st,col);
        IF ware[2]AND(LONGINT(1)SHL ctf3)>0THEN BEGIN
          IF pos<=mapx^.tc THEN STR(sgl*(0.98-mapx^.gs[pos]/10000):8:2,st)
           ELSE STR(sgl*1.1:8:2,st);
          Dot2Comma(st);
        END ELSE st:='-';
        OutSTxt(199-LENGTH(st)*6,y0*8+85,st,col);
      END;
      INC(y0);
    END;
    Mouse(1);
  END;
  b2:=b1;
END;
PROCEDURE WarePrices(tof:BOOLEAN);
VAR y0:INTEGER;col,pos:BYTE;
BEGIN
  Mouse(2);
  IF tof THEN BEGIN
    CopyPage(GetActivePage,1-GetActivePage);
    SetActivePage(1-GetActivePage);
    SetVisualPage(1-GetActivePage);
    GrScr(TRUE);
    st:=GetWare[ctf3];
    OutText(45,52,'PREISöBERSICHT: '+st,240,4,1.5);
    OutSTxt(55,77,'ORT',250);
    OutSTxt(163,77,'ANKAUF',250);
    OutSTxt(217,77,'VERKAUF',250);
    GreenBar(270,84,589,403);
    SmallMap;
  END;
  pos:=mapx^.tc+mapx^.fc;
  y0:=0;
  FOR pos:=1 TO pos DO IF(pos<>mapx^.it)OR(mapx^.itst<>0)THEN BEGIN
    IF ODD(y0) THEN col:=244 ELSE col:=247;
    SETCOLOR(238);
    IF pos<=mapx^.tc THEN st:=mapx^.tn[pos]
     ELSE BEGIN
      STR(pos-mapx^.tc,st);
      IF pos-mapx^.tc<10 THEN st:='0'+st;
      st:=st+': ';
      ID(st,pos-mapx^.tc);
    END;
    IF LENGTH(st)>14 THEN st:=COPY(st,1,13)+'.';
    BAR(50,y0*8+84,259,y0*8+90);
    OutSTxt(55,y0*8+85,st,col);
    IF pos<=mapx^.tc THEN BEGIN
      sgl:=mapx^.pr[pos,ctf3];
      Waren(pos);
    END ELSE BEGIN
      sgl:=GetPrice[ctf3];
      Waren(pos-mapx^.tc+20);
    END;
    IF ware[1]AND(LONGINT(1)SHL ctf3)>0THEN BEGIN
      STR(sgl:7:2,st);
      Dot2Comma(st);
    END ELSE st:='-';
    OutSTxt(259-LENGTH(st)*6,y0*8+85,st,col);
    IF ware[2]AND(LONGINT(1)SHL ctf3)>0THEN BEGIN
      IF pos<=mapx^.tc THEN STR(sgl*(0.98-mapx^.gs[pos]/10000):8:2,st)
       ELSE STR(sgl*1.1:8:2,st);
      Dot2Comma(st);
    END ELSE st:='-';
    OutSTxt(199-LENGTH(st)*6,y0*8+85,st,col);
    INC(y0);
  END;
  SetVisualPage(GetActivePage);
  IF active AND 4=0 THEN Clickfield(cfeld AND NOT 192) ELSE
    Clickfield((cfeld AND NOT 8312)OR 56448);
  Mouse(1);
  sts:=123;
  b2:=0;
  b3:=0;
END;
PROCEDURE WareLineOut(y0:INTEGER;x0:BYTE);
BEGIN
  OutBTxt(55,y0*12+91,GetWare[y0],x0);
  IF ctf2<21THEN sgl:=mapx^.pr[ctf2,y0]ELSE sgl:=GetPrice[y0];
  IF ware[1]AND(LONGINT(1)SHL y0)>0THEN BEGIN
    STR(sgl:7:2,st);Dot2Comma(st);st:=st+pdol;
  END ELSE st:='-';
  OutBTxt(587-LENGTH(st)*9,y0*12+91,st,x0);
  IF ware[2]AND(LONGINT(1)SHL y0)>0THEN BEGIN
    IF ctf2<21THEN STR(sgl*(0.98-mapx^.gs[ctf2]/10000):8:2,st)ELSE STR(sgl*1.1:8:2,st);
    Dot2Comma(st);st:=st+pdol;
  END ELSE st:='-';
  OutBTxt(448-LENGTH(st)*9,y0*12+91,st,x0);
END;
PROCEDURE CheckWareChosen;
BEGIN
  b1:=255;
  IF(ms.x>=50)AND(ms.x<=589)THEN
   FOR b2:=0 TO 25DO IF(ms.y>=WORD(b2)*12+90)AND(ms.y<=WORD(b2)*12+101)THEN b1:=b2;
  IF b1<>ctf3 THEN BEGIN
    Mouse(2);
    IF ctf3<>255 THEN BEGIN
      IF ODD(ctf3) THEN b2:=244 ELSE b2:=247;
      WareLineOut(ctf3,b2);
    END;
    ctf3:=b1;
    IF ctf3<>255 THEN WareLineOut(ctf3,253);
    Mouse(1);
  END;
END;
PROCEDURE Prices(tof:BOOLEAN);
VAR x0,y0:INTEGER;
BEGIN
  Mouse(2);
  IF tof THEN BEGIN
    CopyPage(GetActivePage,1-GetActivePage);
    SetActivePage(1-GetActivePage);
    SetVisualPage(1-GetActivePage);
    GrScr(FALSE);
  END;
  Waren(ctf2);
  IF(ctf2<21)AND tof THEN BEGIN st:=TypeName(ctf2);
    IF(mapx^.tt[ctf2] AND 3=1)AND(mapx^.it<>ctf2)THEN st:='DES '+st+'S'ELSE st:='DER '+st;
    IF mapx^.it=ctf2 THEN st:=COPY(st,1,9)+'N'+COPY(st,10,6);
    st:=st+' "'+mapx^.tn[ctf2]+'"';
  END ELSE IF tof THEN BEGIN st:='';ID(st,ctf2-20);
    CASE mapx^.ft[ctf2-20] OF 0,1,3,10:st:='DES '+st+'S';
      2,4,5,6,7,8,9:st:='DER '+st;
    END;
    s1:=TypeName(ctf2);st:=st+' '+s1;
  END;
  IF tof THEN BEGIN OutText(45,52,'PREISöBERSICHT '+st,240,4,1.5);
  END;
  IF tof THEN BEGIN GrBar(40,410,309,449,'ORT WéHLEN');
    GrBar(310,410,599,449,'NACHRICHTEN ANSEHEN');
    OutBTxt(55,78,'WARENBEZEICHNUNG',250);
    OutBTxt(340,78,'ANKAUFSPREIS',250);
    OutBTxt(470,78,'VERKAUFSPREIS',250);
  END;
  FOR y0:=0TO 25DO BEGIN IF ODD(y0) THEN x0:=244 ELSE x0:=247;
    SETCOLOR(238);
    BAR(50,y0*12+90,589,y0*12+100);
    WareLineOut(y0,x0);
  END;
  SetVisualPage(GetActivePage);
  IF active AND 4=0 THEN Clickfield(cfeld AND NOT 192) ELSE
    Clickfield((cfeld AND NOT 8312)OR 56448);
  Mouse(1);
  ctf3:=255;
  sts:=127;
END;
PROCEDURE Truck(what:BYTE);
VAR x0,y0:INTEGER;
BEGIN
  Mouse(2);
  IF what=1 THEN BEGIN
    CopyPage(GetActivePage,1-GetActivePage);
    SetActivePage(1-GetActivePage);
    SetVisualPage(1-GetActivePage);
    GrScr(TRUE);
    OutText(45,52,'öBERSICHT',240,4,1.5);
    OutBTxt(55,78,'BEZEICHNUNG',250);
    OutBTxt(251,78,'LADUNG',250);
    FOR y0:=0TO 25DO BEGIN IF ODD(y0) THEN x0:=244 ELSE x0:=247;
      SETCOLOR(238);
      BAR(50,y0*12+90,309,y0*12+100);
      OutBTxt(55,y0*12+91,GetWare[y0],x0);
      IF trk.c[y0]>0THEN BEGIN STR(trk.c[y0],st);st:=st+tradeunits;END ELSE st:='-';
      OutBTxt(305-LENGTH(st)*9,y0*12+91,st,x0);
    END;
    SETCOLOR(238);BAR(50,414,309,424);
    OutBTxt(55,415,'FREIER FRACHTRAUM',247);
    SETCOLOR(238);BAR(50,426,309,436);
    OutBTxt(55,427,'GESAMTER FRACHTRAUM',244);
    STR(trk.f,st);
    OutBTxt(278-LENGTH(st)*9,415,st+tradeunits,247);
    STR(trk.m,st);
    OutBTxt(278-LENGTH(st)*9,427,st+tradeunits,244);
  END;
  OutBTxt(428,78,'KAPITAL',250);
  SETCOLOR(238);BAR(330,90,589,112);
  STR(geld:0:2,st);Dot2Comma(st);
  active:=active AND NOT 64;
  OutText(459,92,st+pdol,240,2,1.5);
  IF(what=4)AND(scrollpos>0)THEN DEC(scrollpos);
  IF(what=5)AND(scrollpos<10)THEN INC(scrollpos);
  REPEAT
    IF(what=1)OR(what>=3)THEN BEGIN
      active:=active AND NOT 128;
      SETCOLOR(243);
      OutBTxt(424,136,'VERTRéGE',250);
      SETCOLOR(238);BAR(330,148,589,436);
      y0:=142-scrollpos*25;
      FOR b1:=1TO 20DO IF vertr^[b1].db AND 128=128 THEN BEGIN
        IF vertr^[b1].t<>128 THEN st:=GetWare[vertr^[b1].db-128]ELSE BEGIN st:='UMBAU';s1:='IN';END;
        IF vertr^[b1].s=0 THEN s1:='FöR' ELSE IF vertr^[b1].t<>128 THEN s1:='VON';
        st:=st+' '+s1+' ';
        IF vertr^[b1].s<>0 THEN BEGIN
          IF vertr^[b1].s<21 THEN s1:=mapx^.tn[vertr^[b1].s]ELSE s1:=TypeName(vertr^[b1].s);
        END ELSE s1:=mapx^.tn[vertr^[b1].t];
        st:=st+s1;
        IF(vertr^[b1].s<>0)AND(vertr^[b1].t<>128)THEN st:=st+' NACH '+mapx^.tn[vertr^[b1].t];
        STR((vertr^[b1].gd+4760)/100:0:2,s1);
        st:=st+' BIS '+s1+':';
        STR(vertr^[b1].ev,s1);IF s1[0]=#1THEN s1:='0'+s1;
        st:=st+s1+' ST (';
        STR(vertr^[b1].pr,s1);
        st:=st+s1+pdol+') ';
        IF(y0>150)AND(y0<420)THEN LINE(334,y0+8,585,y0+8);
        REPEAT b2:=28;
          IF LENGTH(st)>28 THEN WHILE st[b2]<>' 'DO DEC(b2);
          s1:=COPY(st,1,b2-1);st:=COPY(st,b2+1,LENGTH(st)-b2);
          INC(y0,12);
          IF(y0>150)AND(y0<420)THEN OutBTxt(334,y0,s1,247);
        UNTIL st='';b2:=LENGTH(s1);
        STR(vertr^[b1].cc,st);STR(vertr^[b1].co,s1);
        st:=st+'/'+s1;
        IF b2>28-LENGTH(st)THEN INC(y0,12);
        IF(y0>150)AND(y0<420)THEN OutBTxt(586-LENGTH(st)*9,y0,st,254);
        INC(y0,4);
      END;
      wo0:=y0;
    END;
    IF wo0>420-scrollpos*25 THEN b1:=48 ELSE b1:=0;
    IF(b1=0)AND(scrollpos>0)THEN BEGIN scrollpos:=0;b1:=128;END;
  UNTIL(b1<>128);
  SetVisualPage(GetActivePage);
  Clickfield(((cfeld AND NOT 1144)OR 63872)OR b1);
  Mouse(1);
  sts:=3;
END;
PROCEDURE Names(what:BYTE);
BEGIN
  IF(ms.x>49)AND(ms.x<250)THEN newtw:=(ms.y-90)DIV 12+1 ELSE newtw:=0;
  IF(ms.f=1)AND(ms.b=0)AND(what=3)AND(newtw<=mapx^.tc)AND(newtw>0)THEN BEGIN
    PutCross(ctf3,0);
    ctf3:=newtw;
    IF(mapx^.itst=0)AND(newtw>=mapx^.it)THEN INC(ctf3);
    INC(what,2);
  END;
  IF(ms.f=1)AND(ms.b=0)AND(what=4)AND(newtw<=mapx^.fc)AND(newtw>0)THEN BEGIN
    PutCross(ctf3,0);
    ctf3:=newtw+20;
    INC(what,2);
  END;
  IF((ctf3=newtw)AND(what=3))OR((ctf3=newtw+20)AND(what=4))THEN PutCross(ctf3,129)ELSE PutCross(ctf3,128);
  IF what>2 THEN BEGIN
    IF(newtw=oldtw)AND(what<5)THEN EXIT;
    drawedpos_enemy:=0;
    PoE(TRUE);
    Mouse(2);
  END;
  IF(what>4)OR(what<3)THEN BEGIN
    SETCOLOR(238);
    BAR(50,385,249,439);
    IF ctf3<21 THEN st:=mapx^.tn[ctf3]
     ELSE BEGIN st:='';ID(st,ctf3-20);END;
    OutText(150,393,st,240,2,1.5);
    st:=TypeName(ctf3);
    OutBTxt(150-TRUNC(LENGTH(st)*4.5),420,st,245);
  END;
  IF(what=1)OR(what=3)OR(what=5)THEN BEGIN
    b1:=0;
    FOR b3:=1 TO mapx^.tc DO IF(b3<>mapx^.it)OR(mapx^.itst<>0)THEN BEGIN
      IF what=1 THEN BEGIN SETCOLOR(238);BAR(50,b1*12+90,249,b1*12+100);END;
      IF b3=ctf3 THEN b2:=247 ELSE b2:=243;
      IF newtw=b1+1 THEN b2:=253;
      IF(what<>3)OR(newtw=b1+1)OR(oldtw=b1+1)THEN OutBTxt(150-ROUND(LENGTH(mapx^.tn[b3])*4.5),b1*12+91,mapx^.tn[b3],b2);
      IF newtw=b1+1 THEN b2:=129 ELSE b2:=0;
      IF(what<>3)OR(newtw=b1+1)OR(oldtw=b1+1)THEN PutCross(b3,b2);
      INC(b1);
    END;
  END ELSE FOR b3:=1 TO mapx^.fc DO BEGIN
    IF what=2 THEN BEGIN BAR(50,(b3-1)*12+90,249,(b3-1)*12+100);SETCOLOR(238);END;
    STR(b3,s1);st:='';ID(st,b3);
    IF b3<10 THEN s1:='0'+s1;st:=s1+': '+st;
    IF b3+20=ctf3 THEN b2:=247 ELSE b2:=243;
    IF newtw=b3 THEN b2:=253;
    IF(what<>4)OR(newtw=b3)OR(oldtw=b3)THEN OutBTxt(150-ROUND(LENGTH(st)*4.5),(b3-1)*12+91,st,b2);
    IF b3=newtw THEN b2:=129 ELSE b2:=0;
    IF(what<>4)OR(newtw=b3)OR(oldtw=b3)THEN PutCross(b3+20,b2);
  END;
  IF what>2 THEN BEGIN
    Mouse(1);
    oldtw:=newtw;
  END;
END;
PROCEDURE ChooseCity(what:BYTE);
BEGIN
  Mouse(2);
  CopyPage(GetActivePage,1-GetActivePage);
  SetActivePage(1-GetActivePage);
  SetVisualPage(1-GetActivePage);
  GrScr(TRUE);
  sts:=127-what;
  ms.f:=0;
  oldtw:=0;
  newtw:=0;
  IF what=1 THEN st:='STADT' ELSE st:='INDUSTRIE';
  OutText(45,52,st+' WéHLEN',240,4,1.5);
  IF what=1 THEN st:='NAME' ELSE st:='ID: BEZEICHNUNG';
  OutBTxt(150-ROUND(LENGTH(st)*4.5),78,st,250);
  GreenBar(270,84,589,403);
  SmallMap;
  enemy.backgr_x:=65535;
  drawedpos_enemy:=0;
  Names(what);
  SetVisualPage(GetActivePage);
  Clickfield(cfeld OR 192 OR 16);
  Mouse(1);
END;
PROCEDURE Headlines;
VAR y0:BYTE;st1:STRING[5];st2:STRING[2];
BEGIN
  active:=active AND NOT 128;
  FOR y0:=1 TO 4 DO BEGIN
    SETCOLOR(238);
    BAR(80,WORD(y0)*80+45,559,WORD(y0)*80+72);
    BAR(269,WORD(y0)*80+74,370,WORD(y0)*80+84);
    OutText(320,WORD(y0)*80+49,news^[y0].st,240,6,2);
    STR((news^[y0].dt+4760)/100:0:2,st1);STR(news^[y0].ev,st2);
    IF LENGTH(st2)=1 THEN st2:='0'+st2;
    OutBTxt(271,WORD(y0)*80+75,st1+':'+st2+' ST',245);
  END;
END;
PROCEDURE ShowNews;
BEGIN
  Mouse(2);
  CopyPage(GetActivePage,1-GetActivePage);
  SetActivePage(1-GetActivePage);
  SetVisualPage(1-GetActivePage);
  GrScr(TRUE);
  sts:=124;
  ms.f:=0;
  OutText(320,56,'INTERNET NEWS - HI-ECO-LE EDITION',240,6,1.5);
  OutText(320,78,'PERSôNLICHE KURZMITTEILUNGEN',240,6,1.5);
  Headlines;
  SetVisualPage(GetActivePage);
  Clickfield(cfeld OR 128);
  Mouse(1);
END;
FUNCTION CheckSmallMapNames:BYTE;
VAR b2,b1:BYTE;x0,y0,x1,y1:INTEGER;
BEGIN
  CheckSmallMapNames:=0;
  b2:=0;
  b1:=0;
  FOR b2:=1 TO 40 DO IF((b2<21)AND(b2<=mapx^.tc))OR((b2>20)AND(b2<=mapx^.fc+20))THEN BEGIN
    IF b2<21 THEN BEGIN x1:=mapx^.tx[b2];y1:=mapx^.ty[b2];END
     ELSE BEGIN x1:=mapx^.fx[b2-20];y1:=mapx^.fy[b2-20];END;
    x0:=TRUNC((x1-y1)/smapdivx)+smapaddx;
    y0:=TRUNC((x1+y1)/smapdivy)+smapaddy;
    IF(ms.x>x0-3)AND(ms.x<x0+3)AND(ms.y>y0-3)AND(ms.y<y0+3)THEN b1:=b2;
  END;
  IF b1<>active_sm_name THEN BEGIN
    IF b1<21 THEN st:=mapx^.tn[b1] ELSE BEGIN
      STR(b1-20,st);
      st:=st+': ';
      ID(st,b1-20);
    END;
    IF b1<21 THEN BEGIN x1:=mapx^.tx[b1];y1:=mapx^.ty[b1];END
     ELSE BEGIN x1:=mapx^.fx[b1-20];y1:=mapx^.fy[b1-20];END;
    x0:=TRUNC((x1-y1)/smapdivx)+smapaddx;
    y0:=TRUNC((x1+y1)/smapdivy)+smapaddy;
    Mouse(2);
    IF active_sm_name<>0 THEN BEGIN
      PutImage(old_tile.x,old_tile.y,old_tile.b,1);
      active_sm_name:=0;
    END;
    IF b2<>0 THEN BEGIN
      old_tile.x:=x0-LENGTH(st)*3;
      old_tile.y:=y0-7;
      IF enemy.backgr_x<>65535 THEN PutImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr,0);
      GetImage(old_tile.x,old_tile.y,x0+LENGTH(st)*3,old_tile.y+4,old_tile.b);
      OutSTxt(old_tile.x,old_tile.y,st,255);
      enemy.backgr_x:=65535;
      drawedpos_enemy:=0;
    END;
    Mouse(1);
    active_sm_name:=b1;
  END;
END;
PROCEDURE Targets(what:BYTE);
VAR x0,y0,x1,y1:INTEGER;
BEGIN
  IF(ms.x>49)AND(ms.x<250)THEN newtw:=(ms.y-90)DIV 12+1 ELSE newtw:=0;
  IF(ms.f=1)AND(ms.b=0)AND(newtw<=roads.a)AND(newtw>0)THEN BEGIN
    ctf3:=newtw;
    INC(what);
  END;
  IF what>1 THEN BEGIN
    IF(newtw=oldtw)AND(what<3)THEN EXIT;
    Mouse(2);
  END;
  IF(what>2)OR(what=1)THEN BEGIN
    IF road^.p1[roads.r[ctf3]]>20 THEN
     BEGIN x0:=mapx^.fx[road^.p1[roads.r[ctf3]]-20];y0:=mapx^.fy[road^.p1[roads.r[ctf3]]-20];END
     ELSE BEGIN x0:=mapx^.tx[road^.p1[roads.r[ctf3]]];y0:=mapx^.ty[road^.p1[roads.r[ctf3]]];END;
    IF road^.p2[roads.r[ctf3]]>20 THEN
     BEGIN x1:=mapx^.fx[road^.p2[roads.r[ctf3]]-20];y1:=mapx^.fy[road^.p2[roads.r[ctf3]]-20];END
     ELSE BEGIN x1:=mapx^.tx[road^.p2[roads.r[ctf3]]];y1:=mapx^.ty[road^.p2[roads.r[ctf3]]];END;
    trk.dis:=Entfernung(x0,y0,x1,y1)*4;
    IF road^.p1[roads.r[ctf3]]=town THEN BEGIN
      trk.sx:=x0;trk.sy:=y0;trk.tx:=x1;trk.ty:=y1;
      trk.d:=road^.p2[roads.r[ctf3]];
      trk.s:=town;
    END ELSE BEGIN trk.sx:=x1;trk.sy:=y1;trk.tx:=x0;trk.ty:=y0;
      trk.d:=road^.p1[roads.r[ctf3]];
      trk.s:=town;
    END;
    SETCOLOR(238);
    BAR(50,365,249,439);
    IF roads.t[ctf3]<21 THEN st:=mapx^.tn[roads.t[ctf3]]
     ELSE BEGIN st:='';ID(st,roads.t[ctf3]-20);END;
    OutText(150,373,st,240,2,1.5);
    IF roads.t[ctf3]<21 THEN BEGIN
      IF mapx^.tt[roads.t[ctf3]] AND 2=0 THEN BEGIN st:='RAUMHAFEN';
        IF mapx^.it=roads.t[ctf3] THEN st:='FREIE STADT' ELSE
         IF mapx^.tt[roads.t[ctf3]] AND 1=0 THEN st:='STADT';
      END ELSE st:='HAUPTSTADT';
    END ELSE BEGIN
      STR(ORD(mapx^.tn[1,2])+ORD(mapx^.tn[2,1])-128,s1);
      STR(roads.t[ctf3]-20,st);IF st[0]=#1 THEN st:='0'+st;IF s1[0]=#1 THEN s1:='0'+s1;
      st:='ID-NR. '+s1+'-'+st;
    END;
    OutBTxt(150-TRUNC(LENGTH(st)*4.5),400,st,245);
    STR(trk.dis,st);
    st:='ENTFERNUNG: '+st+' KM';
    OutBTxt(150-TRUNC(LENGTH(st)*4.5),420,st,245);
  END;
  IF enemy.backgr_x<>65535 THEN BEGIN
    PutImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr,0);
    enemy.backgr_x:=65535;
  END;
  FOR b3:=1 TO roads.a DO BEGIN
    IF what=1 THEN BEGIN SETCOLOR(238);BAR(50,(b3-1)*12+90,249,(b3-1)*12+100);END;
    IF roads.t[b3]<21 THEN st:=mapx^.tn[roads.t[b3]]
     ELSE BEGIN STR(roads.t[b3]-20,s1);st:='';ID(st,roads.t[b3]-20);
      IF roads.t[b3]<30 THEN s1:='0'+s1;st:=s1+': '+st;
    END;
    IF b3=ctf3 THEN b2:=247 ELSE b2:=243;
    IF newtw=b3 THEN b2:=253;
    IF(what<>2)OR(newtw=b3)OR(oldtw=b3)THEN OutBTxt(150-ROUND(LENGTH(st)*4.5),(b3-1)*12+91,st,b2);
    IF(what<>2)OR(newtw=b3)OR(oldtw=b3)THEN BEGIN
      IF b3=ctf3 THEN b2:=251 ELSE b2:=244;
      IF b3=newtw THEN b2:=253;
      SETCOLOR(b2);
      IF road^.p1[roads.r[b3]]>20 THEN
       BEGIN x0:=mapx^.fx[road^.p1[roads.r[b3]]-20];y0:=mapx^.fy[road^.p1[roads.r[b3]]-20];END
       ELSE BEGIN x0:=mapx^.tx[road^.p1[roads.r[b3]]];y0:=mapx^.ty[road^.p1[roads.r[b3]]];END;
      IF road^.p2[roads.r[b3]]>20 THEN
       BEGIN x1:=mapx^.fx[road^.p2[roads.r[b3]]-20];y1:=mapx^.fy[road^.p2[roads.r[b3]]-20];END
       ELSE BEGIN x1:=mapx^.tx[road^.p2[roads.r[b3]]];y1:=mapx^.ty[road^.p2[roads.r[b3]]];END;
      LINE(TRUNC((x0-y0)/smapdivx)+smapaddx,TRUNC((x0+y0)/smapdivy)+smapaddy,
       TRUNC((x1-y1)/smapdivx)+smapaddx,TRUNC((x1+y1)/smapdivy)+smapaddy);
      SETCOLOR(255);
      IF town>20 THEN BEGIN x0:=mapx^.fx[town-20];y0:=mapx^.fy[town-20];END
      ELSE BEGIN x0:=mapx^.tx[town];y0:=mapx^.ty[town];END;
      x1:=TRUNC((x0-y0)/smapdivx)+smapaddx;
      y1:=TRUNC((x0+y0)/smapdivy)+smapaddy;
      LINE(x1-2,y1,x1+2,y1);
      LINE(x1,y1-2,x1,y1+2);
    END;
  END;
  IF what>1 THEN BEGIN
    Mouse(1);
    PoE(TRUE);
    oldtw:=newtw;
  END;
END;
PROCEDURE ChooseTarget;
VAR x0,y0,x1,y1:INTEGER;
BEGIN
  roads.a:=0;
  FOR x0:=1 TO mapx^.tc DO FOR x1:=1 TO road^.sc DO IF((mapx^.itst<>0)OR
   ((road^.p1[x1]<>mapx^.it)AND(road^.p2[x1]<>mapx^.it)))AND
   (((road^.p1[x1]=town)AND(road^.p2[x1]=x0))OR
   ((road^.p2[x1]=town)AND(road^.p1[x1]=x0)))AND(roads.a<20)THEN BEGIN
    INC(roads.a);roads.t[roads.a]:=x0;roads.r[roads.a]:=x1;
  END;
  FOR x0:=21 TO mapx^.fc+20 DO FOR x1:=1 TO road^.sc DO IF((mapx^.itst<>0)OR
   ((road^.p1[x1]<>mapx^.it)AND(road^.p2[x1]<>mapx^.it)))AND
   (((road^.p1[x1]=town)AND(road^.p2[x1]=x0))OR
   ((road^.p2[x1]=town)AND(road^.p1[x1]=x0)))AND(roads.a<20)THEN BEGIN
    INC(roads.a);roads.t[roads.a]:=x0;roads.r[roads.a]:=x1;
  END;
  Mouse(2);
  CopyPage(GetActivePage,1-GetActivePage);
  SetActivePage(1-GetActivePage);
  SetVisualPage(1-GetActivePage);
  GrScr(TRUE);
  GreenBar(270,84,584,403);
  sts:=1;
  ctf3:=1;
  ms.f:=0;
  oldtw:=0;
  newtw:=0;
  trk.px:=65535;
  enemy.backgr_x:=65535;
  OutText(45,52,'ZIELORT WéHLEN',240,4,1.5);
  OutBTxt(69,78,'NAME / BEZEICHNUNG',250);
  SmallMap;
  enemy.backgr_x:=65535;
  drawedpos_enemy:=0;
  Targets(1);
  SetVisualPage(GetActivePage);
  Clickfield((cfeld OR 62656)AND NOT 2104);
  Mouse(1);
END;
PROCEDURE TradeWare(what:BYTE);
VAR x0,y0:INTEGER;newcf:WORD;newpage:BYTE;
BEGIN
  Waren(town);
  newcf:=0;
  IF(ms.x>49)AND(ms.x<177)THEN newtw:=(ms.y-90)DIV 12+1 ELSE
   IF(ms.x>462)AND(ms.x<590)THEN newtw:=(ms.y-90)DIV 12+128 ELSE newtw:=0;
  IF(newtw<128)AND(newtw>26)THEN newtw:=0 ELSE IF newtw>153 THEN newtw:=0;
  IF(ms.f=1)AND(ms.b=0)AND(what=2)AND(newtw<>0)AND(newtw<>ctf3)THEN BEGIN ctf3:=newtw;what:=4;menge:=0;END;
  IF(what>1)AND(what<5)THEN BEGIN
    IF(what=2)AND(newtw=oldtw)THEN EXIT;
    Mouse(2);
  END;
  FOR y0:=0 TO 25 DO BEGIN
    IF(what=1)AND(ctf3=0)AND(ware[1]AND(LONGINT(1)SHL y0)>0)THEN ctf3:=y0+1;
    IF(what=1)AND(ctf3<128)AND(ware[2]AND(LONGINT(1)SHL y0)>0)AND(trk.c[y0]>0)THEN ctf3:=y0+128;
    IF what=1 THEN BEGIN
      SETCOLOR(238);
      BAR(50,y0*12+90,176,y0*12+100);
      BAR(463,y0*12+90,589,y0*12+100);
    END;
    st:=GetWare[y0];
    IF ware[1]AND(LONGINT(1)SHL y0)>0THEN x0:=254 ELSE x0:=252;
    IF(ctf3<128)AND(ctf3=y0+1)THEN x0:=247;
    IF(newtw<128)AND(newtw=y0+1)THEN x0:=253;
    OutBTxt(113-TRUNC(LENGTH(st)*4.5),y0*12+91,st,x0);
    IF(ware[2]AND(LONGINT(1)SHL y0)>0)AND(trk.c[y0]>0)THEN x0:=254 ELSE x0:=252;
    IF(ctf3>127)AND(ctf3=y0+128)THEN x0:=247;
    IF(newtw>127)AND(newtw=y0+128)THEN x0:=253;
    OutBTxt(526-TRUNC(LENGTH(st)*4.5),y0*12+91,st,x0);
  END;
  IF(what<>2)AND(what<>5)AND(what<>6)THEN BEGIN
    SETCOLOR(238);
    BAR(186,90,453,149);
    IF ctf3<128 THEN st:=GetWare[ctf3-1] ELSE st:=GetWare[ctf3-128];
    s1:='';
    IF ctf3<128 THEN BEGIN IF ware[1]AND(LONGINT(1)SHL(ctf3-1))>0THEN st:=st+' KAUFEN'
     ELSE s1:='- NICHT GEHANDELT -';
    END ELSE BEGIN IF(ware[2]AND(LONGINT(1)SHL(ctf3-128))>0)AND(trk.c[ctf3-128]>0)THEN st:=st+' VERKAUFEN'
     ELSE IF trk.c[ctf3-128]>0 THEN s1:='- NICHT GEHANDELT -' ELSE s1:='- NICHT GELADEN -';
    END;
    IF s1='' THEN BEGIN newcf:=(cfeld OR 60856)AND NOT 4096;
      IF ctf3<128 THEN x0:=1 ELSE x0:=128;
      IF town<21THEN sgl:=mapx^.pr[town,ctf3-x0]ELSE sgl:=GetPrice[ctf3-x0];
      IF ctf3>127THEN IF town<21THEN sgl:=sgl*(0.98-mapx^.gs[ctf2]/10000)ELSE sgl:=sgl*1.1;
      STR(sgl:0:2,s1);Dot2Comma(s1);s1:=s1+pdol;
      s1:='PREIS: '+s1;
    END ELSE BEGIN sgl:=0;newcf:=(cfeld OR 60800)AND NOT 4216;END;
    OutText(320,99,st,240,2,1.5);
    OutBTxt(320-TRUNC(LENGTH(s1)*4.5),128,s1,245);
  END;
  IF(what=1)OR(what=5)OR(what=4)THEN BEGIN
    CopyPage(GetActivePage,1-GetActivePage);
    SetActivePage(1-GetActivePage);
    SetVisualPage(1-GetActivePage);
    SETCOLOR(238);
    BAR(186,210,453,284);
    OutBTxt(227,220,'MENGE:',245);
    OutBTxt(236,235,'SOLL:',245);
    IF sgl>0 THEN BEGIN
      IF ctf3<128 THEN s1:='- KOSTEN:' ELSE s1:='+ GEWINN:';
      OutBTxt(200,250,s1,245);
    END;
    OutBTxt(200,265,'=  HABEN:',245);
    STR(menge,st);
    OutBTxt(412-LENGTH(st)*9,220,st+tradeunits,245);
    active:=active AND NOT 64;
    STR(geld:0:2,st);Dot2Comma(st);
    OutBTxt(412-LENGTH(st)*9,235,st+pdol,245);
    IF sgl>0 THEN BEGIN
      STR(menge*sgl:0:2,st);Dot2Comma(st);
      OutBTxt(412-LENGTH(st)*9,250,st+pdol,245);
    END;
    IF ctf3<128 THEN STR(geld-menge*sgl:0:2,st)ELSE STR(geld+menge*sgl:0:2,st);
    Dot2Comma(st);
    OutBTxt(412-LENGTH(st)*9,265,st+pdol,245);
    SetVisualPage(GetActivePage);
  END;
  IF(what=1)OR(what=6)THEN BEGIN
    SETCOLOR(238);
    BAR(186,341,453,400);
    STR(trk.m,s1);
    STR(trk.f,st);
    s1:='GESAMT: '+s1+tradeunits;
    st:='FREI: '+st+tradeunits;
    OutText(320,350,st,240,2,1.5);
    OutBTxt(320-TRUNC(LENGTH(s1)*4.5),379,s1,245);
  END;
  IF newcf<>0 THEN ClickField(newcf);
  IF((what=2)AND(newtw<>oldtw))OR((what>2)AND(what<5))THEN BEGIN
    Mouse(1);
    oldtw:=newtw;
  END;
END;
PROCEDURE Trader;
VAR wo0:WORD;
BEGIN
  menge:=0;
  sts:=2;
  Mouse(2);
  CopyPage(GetActivePage,1-GetActivePage);
  SetActivePage(1-GetActivePage);
  SetVisualPage(1-GetActivePage);
  GrScr(TRUE);
  ctf3:=0;
  oldtw:=0;
  newtw:=0;
  OutText(45,52,'HéNDLER',240,4,1.5);
  OutBTxt(90,78,'LAGER',250);
  OutBTxt(503,78,'TRUCK',250);
  OutBTxt(261,78,'INFORMATIONEN',250);
  OutBTxt(284,198,'RECHNUNG',250);
  OutBTxt(280,329,'FRACHTRAUM',250);
  SetVisualPage(GetActivePage);
  TradeWare(1);
  Mouse(1);
END;
PROCEDURE ContractView(what:BYTE);
BEGIN
  active:=active AND NOT 128;
  IF what<3 THEN BEGIN
    IF(ctf3=0)OR(vertr^[ctf3].s=128)OR(vertr^[ctf3].t=0)OR(vertr^[ctf3].db>127)
     OR(stime.gt*100+stime.ev>vertr^[ctf3].gd*100+vertr^[ctf3].ev)THEN ctf3:=1;
    WHILE((vertr^[ctf3].s=128)OR(vertr^[ctf3].t=0)OR(vertr^[ctf3].db>127))AND(ctf3<21)DO INC(ctf3);
    IF ctf3=21 THEN ctf3:=0;
  END;
  IF what>2 THEN ctf3:=newcrt;
  IF(ctf3<>0)AND(vertr^[ctf3].s=newtw)AND(vertr^[ctf3].t=oldtw)
   AND(wo0=vertr^[ctf3].db)AND(menge=vertr^[ctf3].co)THEN EXIT;
  IF(what=2)OR(what=4)THEN Mouse(2);
  SETCOLOR(238);
  BAR(50,110,267,339);
  IF ctf3=0 THEN BEGIN OutBTxt(136,214,'KEINE',244);OutBTxt(123,226,'AUFTRéGE',244);
    IF what<3 THEN BEGIN
      FOR b1:=1 TO 40 DO PutCross(b1,0);
      IF enemy.backgr_x<>65535 THEN PutImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr,0);
      SmallMap;
      enemy.backgr_x:=65535;
      drawedpos_enemy:=0;
    END;
    ClickField((cfeld OR 48512)AND NOT 16504);
    IF(what=2)OR(what=4)THEN Mouse(1);EXIT;END;
  IF(vertr^[ctf3].s<>0)AND(vertr^[ctf3].t<>128)THEN st:='TRANSPORT'ELSE
   IF vertr^[ctf3].t=128THEN st:='TRUCK-UMBAU'ELSE st:='ERWERB';
  OutBTxt(55,130,'TYP:',244);
  OutBTxt(263-LENGTH(st)*9,130,st,247);
  s1:='';
  IF(vertr^[ctf3].s<>0)AND(vertr^[ctf3].t<>128)THEN BEGIN st:='VON:';s1:='NACH:';END ELSE
   IF vertr^[ctf3].t=128 THEN BEGIN st:='IN:';
  END ELSE st:='FöR:';
  OutBTxt(55,166,st,244);OutBTxt(55,202,s1,244);
  IF vertr^[ctf3].s<>0THEN BEGIN
    IF vertr^[ctf3].s<21THEN BEGIN st:=mapx^.tn[vertr^[ctf3].s];b1:=254;END
     ELSE BEGIN st:='';ID(st,vertr^[ctf3].s-20);b1:=252;END;
    OutBTxt(263-LENGTH(st)*9,166,st,255);
    st:=TypeName(vertr^[ctf3].s);
    OutBTxt(263-LENGTH(st)*9,178,st,b1);
  END;
  IF vertr^[ctf3].t<>128 THEN BEGIN
    IF vertr^[ctf3].t<21 THEN BEGIN st:=mapx^.tn[vertr^[ctf3].t];b2:=254;END
     ELSE BEGIN st:='';ID(st,vertr^[ctf3].t-20);b2:=252;END;
    IF vertr^[ctf3].s<>0 THEN b1:=202 ELSE b1:=166;
    OutBTxt(263-LENGTH(st)*9,b1,st,253);
    st:=TypeName(vertr^[ctf3].t);
    OutBTxt(263-LENGTH(st)*9,b1+12,st,b2);
    OutBTxt(55,b1+36,'WARE:',244);
    OutBTxt(263-LENGTH(GetWare[vertr^[ctf3].db AND NOT 128])*9,b1+36,GetWare[vertr^[ctf3].db AND NOT 128],247);
    OutBTxt(55,b1+60,'ANZAHL:',244);STR(vertr^[ctf3].co,st);st:=st+tradeunits;
    OutBTxt(263-LENGTH(st)*9,b1+60,st,247);
    OutBTxt(55,b1+84,'BEZAHLUNG:',244);STR(vertr^[ctf3].pr/1:0:2,st);Dot2Comma(st);
    st:=st+pdol;OutBTxt(263-LENGTH(st)*9,b1+84,st,247);
    OutBTxt(55,b1+108,'ZEITGRENZE:',244);
    STR((vertr^[ctf3].gd+4760)/100:0:2,st);
    STR(vertr^[ctf3].ev,s1);IF s1[0]=#1THEN s1:='0'+s1;
    st:=st+':'+s1+' ST';
    OutBTxt(263-LENGTH(st)*9,b1+108,st,247);
  END ELSE BEGIN
    OutBTxt(55,202,'FRACHTRAUM:',244);
    STR(vertr^[ctf3].co:3,st);
    st:='+ '+st+tradeunits;
    OutBTxt(263-LENGTH(st)*9,202,st,247);
    STR(trk.m+vertr^[ctf3].co:3,st);
    st:='= '+st+tradeunits;
    OutBTxt(263-LENGTH(st)*9,214,st,247);
    OutBTxt(55,238,'KOSTEN:',244);STR(vertr^[ctf3].pr/1:0:2,st);Dot2Comma(st);
    st:=st+pdol;OutBTxt(263-LENGTH(st)*9,238,st,247);
    OutBTxt(55,262,'ZEITGRENZE:',244);
    STR((vertr^[ctf3].gd+4760)/100:0:2,st);
    STR(vertr^[ctf3].ev,s1);IF s1[0]=#1THEN s1:='0'+s1;
    st:=st+':'+s1+' ST';
    OutBTxt(263-LENGTH(st)*9,262,st,247);
  END;
  IF what<3 THEN BEGIN
    FOR b3:=1 TO 20 DO IF(b3<>mapx^.it)OR(mapx^.itst<>0)THEN BEGIN
      IF vertr^[ctf3].s=b3 THEN b2:=128 ELSE b2:=0;
      IF vertr^[ctf3].t=b3 THEN b2:=129;
      PutCross(b3,b2);
    END;
    FOR b3:=1 TO 20 DO BEGIN
      IF vertr^[ctf3].s=b3+20 THEN b2:=128 ELSE b2:=0;
      PutCross(b3+20,b2);
    END;
  END;
  IF what<=2 THEN ClickField((cfeld OR 48624)AND NOT 16392);
  IF(what=2)OR(what=4)THEN Mouse(1);
  newtw:=vertr^[ctf3].s;oldtw:=vertr^[ctf3].t;
  wo0:=vertr^[ctf3].db;menge:=vertr^[ctf3].co;
END;
PROCEDURE Contracts;
BEGIN
  newtw:=0;
  oldtw:=0;
  ctf3:=0;
  Mouse(2);
  b2:=0;
  FOR b1:=1 TO 20 DO IF vertr^[b1].db AND 128=128 THEN BEGIN
    IF(vertr^[b1].s=town)AND(vertr^[b1].t<>128)AND(trk.f>0)AND(vertr^[b1].co>0)THEN b2:=b2 OR 1;
    IF(vertr^[b1].t=town)AND(((vertr^[b1].s=0)AND(trk.c[vertr^[b1].db-128]>0))
     OR(vertr^[b1].cc>0))THEN b2:=b2 OR 2;
    IF(vertr^[b1].s=town)AND(vertr^[b1].t=128)AND(vertr^[b1].pr<=geld)THEN b2:=b2 OR 4;
  END;
  CopyPage(GetActivePage,1-GetActivePage);
  SetActivePage(1-GetActivePage);
  SetVisualPage(1-GetActivePage);
  IF b2=0 THEN BEGIN
    GrScr(TRUE);
    sts:=4;
  END ELSE BEGIN
    GrScr(FALSE);
    sts:=6;
    CASE b2 OF 1:st:='BELADEN';
      2:st:='ENTLADEN';
      3:st:='BE- ODER ENTLADEN';
      4:st:='ERWEITERN';
      5:st:='BELADEN ODER ERWEITERN';
      6:st:='ENTLADEN ODER ERWEITERN';
      7:st:='BE-, ENTLADEN ODER ERWEITERN';
    END;
    GrBar(40,410,599,449,'TRUCK '+st);
  END;
  OutText(45,52,'AUFTRAGSANGEBOTE',240,4,1.5);
  GreenBar(270,84,589,403);
  SmallMap;
  enemy.backgr_x:=65535;
  drawedpos_enemy:=0;
  SetVisualPage(GetActivePage);
  ContractView(1);
  Mouse(1);
END;
PROCEDURE ContractList;
VAR by0:BYTE;wo1:WORD;
BEGIN
  SETCOLOR(243);
  OutBTxt(424,100,'VERTRéGE',250);
  SETCOLOR(243);
  FOR by0:=0 TO 5 DO RECTANGLE(331,111+by0*51,588,160+by0*51);
  wo1:=0;
  FOR b1:=1TO 20DO IF(l1 AND (LONGINT(1)SHL b1)>0)AND(wo1<6)THEN BEGIN
    SETCOLOR(238);
    BAR(332,112+wo1*51,587,159+wo1*51);
    IF vertr^[b1].t<>128 THEN st:=GetWare[vertr^[b1].db-128]ELSE BEGIN st:='UMBAU';s1:='IN';END;
    IF vertr^[b1].s=0 THEN s1:='FöR' ELSE IF vertr^[b1].t<>128 THEN s1:='VON';
    st:=st+' '+s1+' ';
    IF vertr^[b1].s<>0 THEN BEGIN
      IF vertr^[b1].s<21 THEN s1:=mapx^.tn[vertr^[b1].s]ELSE s1:=TypeName(vertr^[b1].s);
    END ELSE s1:=mapx^.tn[vertr^[b1].t];
    st:=st+s1;
    IF(vertr^[b1].s<>0)AND(vertr^[b1].t<>128)THEN st:=st+' NACH '+mapx^.tn[vertr^[b1].t];
    STR((vertr^[b1].gd+4760)/100:0:2,s1);
    st:=st+' BIS '+s1+':';
    STR(vertr^[b1].ev,s1);IF s1[0]=#1THEN s1:='0'+s1;
    st:=st+s1+' ST (';
    STR(vertr^[b1].pr,s1);
    st:=st+s1+pdol+') ';
    by0:=0;
    REPEAT b2:=28;
      IF LENGTH(st)>28 THEN WHILE st[b2]<>' 'DO DEC(b2);
      s1:=COPY(st,1,b2-1);st:=COPY(st,b2+1,LENGTH(st)-b2);
      OutBTxt(334,113+wo1*51+by0*12,s1,247);
      INC(by0);
    UNTIL st='';b2:=LENGTH(s1);
    STR(vertr^[b1].cc,st);STR(vertr^[b1].co,s1);
    IF vertr^[b1].t=128 THEN st:='+'+s1
     ELSE IF vertr^[b1].s=0 THEN st:='<'+s1+'>'
     ELSE st:=st+'/'+s1;
    OutBTxt(586-LENGTH(st)*9,113+wo1*51+36,st,254);
    IF b1=newcrt THEN BEGIN
      oldcrt:=b1;
      SETCOLOR(238);
      BAR(50,365,267,416);
      IF(newtw<>0)AND(oldtw<>128)THEN BEGIN
        IF(newtw=town)AND(menge>0)THEN BEGIN
          IF menge>trk.f THEN menge:=trk.f;
          STR(menge,st);
          st:='TRUCK MIT '+st+tradeunits+' BELADEN';
        END ELSE IF(oldtw=town)AND(vertr^[oldcrt].cc>0)THEN BEGIN
          STR(vertr^[oldcrt].cc,st);
          st:=st+tradeunits+' VOM TRUCK LADEN';
        END;
      END ELSE IF newtw=0 THEN BEGIN
        menge:=trk.c[vertr^[oldcrt].db-128];
        IF menge>vertr^[oldcrt].co THEN menge:=vertr^[oldcrt].co;
        STR(menge,st);
        st:=st+tradeunits+' VOM TRUCK LADEN';
      END ELSE IF oldtw=128 THEN BEGIN
        IF geld<vertr^[oldcrt].pr THEN BEGIN
          menge:=0;
          st:='ZU WENIG GELD';
        END ELSE st:='TRUCK AUSBAUEN';
      END;
      OutText(159,380,st,240,2,1.5);
    END;
    INC(wo1);
  END;
END;
PROCEDURE ContractPass;
VAR wo0:WORD;
BEGIN
  menge:=0;
  sts:=7;
  Mouse(2);
  CopyPage(GetActivePage,1-GetActivePage);
  SetActivePage(1-GetActivePage);
  SetVisualPage(1-GetActivePage);
  GrScr(TRUE);
  SETCOLOR(238);
  BAR(330,110,589,416);
  ctf3:=1;
  WHILE((vertr^[ctf3].s<>town)AND(vertr^[ctf3].t<>town))OR(vertr^[ctf3].db<128)AND(ctf3<21)DO INC(ctf3);
  l1:=0;
  newcrt:=0;
  oldcrt:=0;
  IF ctf3=21 THEN ctf3:=0
   ELSE FOR wo0:=ctf3 TO 20 DO IF vertr^[wo0].db AND 128=128 THEN BEGIN
    IF((vertr^[wo0].s=town)AND(((vertr^[wo0].t<>128)AND(trk.f>0)AND(vertr^[wo0].co>0))
    OR((vertr^[wo0].t=128)AND(vertr^[wo0].pr<=geld))))
    OR((vertr^[wo0].t=town)AND(((vertr^[wo0].s=0)AND(trk.c[vertr^[wo0].db-128]>0))
    OR(vertr^[wo0].cc>0)))THEN BEGIN
      INC(l1,ROUND(EXP(LN(2)*wo0)));
      IF newcrt=0 THEN newcrt:=wo0;
    END;
  END;
  OutText(45,52,'TRUCK-OPTIONEN',240,4,1.5);
  ContractView(3);
  ContractList;
  SetVisualPage(GetActivePage);
  ClickField(cfeld OR 112);
  Mouse(1);
END;
PROCEDURE LoadTruck;
BEGIN
  FILLCHAR(roads,SIZEOF(roads),0);
  FOR b1:=1 TO 20 DO IF(vertr^[b1].s=town)OR((vertr^[b1].t=town)AND(vertr^[b1].cc<>0))
   THEN BEGIN INC(roads.a);roads.r[roads.a]:=b1;END;
  IF roads.a=0THEN Truck(1)ELSE BEGIN
    newtw:=0;
    oldtw:=0;
    ctf3:=0;
    sts:=5;
  END;
END;
VAR mappage:BYTE;poi0,poi1:point;
BEGIN
  trk.dis:=0;
  active:=active OR 16;
  Mouse(2);
  active:=(active OR 1)AND NOT 2;
  mappage:=GetActivePage;
  ClickField(0);
  City;
  ctf2:=town;
  Mouse(1);
  active:=active AND NOT 16;
  REPEAT Mouse(3);
    IF(sts=4)OR(sts=6)OR(sts=1)OR(sts=126)OR(sts=125)OR(sts=123)THEN BEGIN
      PoE(TRUE);
      CheckSmallMapNames;
    END ELSE PoE(FALSE);
    IF savepic THEN SavePicture;
    IF(cdtimecounter>13104)AND cdmusic AND(cd_rom<>'')THEN BEGIN
      CD_Stop;
      CD_Play(5);
      cdtimecounter:=0;
    END;
    IF ttime>49 THEN BEGIN
      IF Timing AND((sts=4)OR(sts=6)OR(sts=1)OR(sts=126)OR(sts=125))THEN BEGIN
        Mouse(2);
        FOR b1:=1 TO 40 DO PutCross(b1,0);
        IF enemy.backgr_x<>65535 THEN PutImage(enemy.backgr_x-10,enemy.backgr_y-10,enemy.backgr,0);
        SmallMap;
        enemy.backgr_x:=65535;
        drawedpos_enemy:=0;
        Mouse(1);
      END;
      IF((sts=4)OR(sts=6)OR(sts=7))AND(active AND 128=128)THEN ContractView(2+sts DIV 7*2);
      IF(sts=3)AND(active AND 128=128)THEN Truck(3);
      IF(sts=124)AND(active AND 128=128)THEN Headlines;
    END;
    cf:=ClickedField;
    CASE sts OF 255:Prices(TRUE);
      254:ChooseTarget;
      253:Prices(FALSE);
      252:Trader;
      251:BEGIN TradeWare(3);sts:=2;END;
      250:Contracts;
      249:ContractPass;
      248:WarePrices(FALSE);
    END;
    IF active AND 64=64 THEN BEGIN
      IF sts=2 THEN BEGIN
        Mouse(2);
        WHILE(geld-menge*sgl<0)AND(menge>0)DO DEC(menge);
        TradeWare(5);
        IF menge=0 THEN ClickField(cfeld AND NOT 64)
         ELSE ClickField(cfeld OR 64);
        Mouse(1);
      END;
      IF sts=3 THEN Truck(2);
    END;
    IF(sts=2)AND((cf=19)OR(cf=20)OR(cf=21)OR(cf=22)OR(cf=35)OR(cf=36)OR(cf=37)OR(cf=38))THEN BEGIN
      IF cf=20THEN INC(menge)ELSE IF cf=36THEN INC(menge,5);
      IF cf=21THEN DEC(menge)ELSE IF cf=37THEN DEC(menge,5);
      IF cf=19THEN menge:=255;
      IF ctf3<128 THEN WHILE((geld-menge*sgl<0)OR(menge>trk.f))AND(menge>0)DO DEC(menge)
       ELSE WHILE menge>trk.c[ctf3-128]DO DEC(menge);
      IF(menge<0)OR(cf=35)THEN menge:=0;
      IF(cf=22)OR(cf=38)THEN BEGIN
        IF ctf3<128 THEN BEGIN geld:=geld-menge*sgl;
          INC(trk.c[ctf3-1],menge);
          DEC(trk.f,menge);
          IF active AND 1=1 THEN INC(ttime);
        END ELSE BEGIN geld:=geld+menge*sgl;
          DEC(trk.c[ctf3-128],menge);
          INC(trk.f,menge);
          IF active AND 1=1 THEN INC(ttime);
        END;
        ctf3:=0;menge:=0;ms.f:=0;ms.b:=0;
        Mouse(2);TradeWare(1);Mouse(1);
      END ELSE BEGIN
        Mouse(2);
        TradeWare(5);
        IF menge=0 THEN ClickField(cfeld AND NOT 64)
         ELSE ClickField(cfeld OR 64);
        Mouse(1);
      END;
    END;
    IF(sts=7)AND((cf=20)OR(cf=21)OR(cf=36)OR(cf=37))THEN BEGIN
      IF(cf=20)OR(cf=36)THEN BEGIN
        REPEAT INC(newcrt);
          IF newcrt>20 THEN newcrt:=1;
        UNTIL l1 AND ROUND(EXP(LN(2)*newcrt))>0;
        ContractView(4);
      END ELSE BEGIN
        REPEAT DEC(newcrt);
          IF newcrt<1 THEN newcrt:=20;
        UNTIL l1 AND ROUND(EXP(LN(2)*newcrt))>0;
        ContractView(4);
      END;
      ContractList;
    END ELSE IF(sts=7)AND((cf=22)OR(cf=38))THEN BEGIN
      IF(newtw<>0)AND(oldtw<>128)THEN BEGIN
        IF(newtw=town)AND(menge>0)THEN BEGIN
          INC(vertr^[oldcrt].cc,menge);
          DEC(vertr^[oldcrt].co,menge);
          DEC(trk.f,menge);
          sts:=250;
          IF active AND 1=1 THEN INC(ttime);
        END ELSE IF(oldtw=town)AND(vertr^[oldcrt].cc>0)THEN BEGIN
          INC(trk.f,vertr^[oldcrt].cc);
          vertr^[oldcrt].cc:=0;
          IF vertr^[oldcrt].co=0 THEN BEGIN
            vertr^[oldcrt].s:=0;
            vertr^[oldcrt].t:=0;
            vertr^[oldcrt].db:=0;
            geld:=geld+vertr^[oldcrt].pr;
            FOR b2:=3 DOWNTO 1 DO news^[b2+1]:=news^[b2];
            STR(vertr^[oldcrt].pr,news^[1].st);
            news^[1].st:='VERTRAG ERFOLGREICH ERFöLLT. EINNAHMEN: '+news^[1].st+pdol;
            news^[1].dt:=stime.gt;news^[1].ev:=stime.ev;
            IF sts=124 THEN active:=active OR 128;
            IF active AND 1=1 THEN INC(ttime);
            IF exist_SB THEN BEGIN
              IF soundbyte AND 16=16 THEN BEGIN
                StopSound(3);
                FreeSound(sounds[4]);
              END;
              IF LoadSound(sounds[4],'GEWINN')THEN soundbyte:=soundbyte OR 16;
            END;
            IF soundbyte AND 16=16 THEN StartSound(sounds[4],3,FALSE);
          END;
          sts:=250;
        END;
      END ELSE IF(newtw=0)AND(menge>0)THEN BEGIN
        DEC(vertr^[oldcrt].co,menge);
        DEC(trk.c[vertr^[oldcrt].db-128],menge);
        INC(trk.f,menge);
        IF vertr^[oldcrt].co=0 THEN BEGIN
          vertr^[oldcrt].s:=0;
          vertr^[oldcrt].t:=0;
          vertr^[oldcrt].db:=0;
          geld:=geld+vertr^[oldcrt].pr;
          FOR b2:=3 DOWNTO 1 DO news^[b2+1]:=news^[b2];
          STR(vertr^[oldcrt].pr,news^[1].st);
          news^[1].st:='VERTRAG ERFOLGREICH ERFöLLT. EINNAHMEN: '+news^[1].st+pdol;
          news^[1].dt:=stime.gt;news^[1].ev:=stime.ev;
          IF sts=124 THEN active:=active OR 128;
          IF active AND 1=1 THEN INC(ttime);
          IF exist_SB THEN BEGIN
            IF soundbyte AND 16=16 THEN BEGIN
              StopSound(3);
              FreeSound(sounds[4]);
            END;
            IF LoadSound(sounds[4],'GEWINN')THEN soundbyte:=soundbyte OR 16;
          END;
          IF soundbyte AND 16=16 THEN StartSound(sounds[4],3,FALSE);
        END;
        sts:=250;
      END ELSE IF(oldtw=128)AND(geld>=vertr^[oldcrt].pr)THEN BEGIN
        geld:=geld-vertr^[oldcrt].pr;
        INC(trk.f,menge);
        INC(trk.m,menge);
        IF trk.m>100 THEN trk.m:=100;
        vertr^[oldcrt].s:=0;
        vertr^[oldcrt].t:=0;
        vertr^[oldcrt].db:=0;
        sts:=250;
        IF active AND 1=1 THEN INC(ttime);
      END;
    END;
    IF((sts=4)OR(sts=6))AND(((cf>19)AND(cf<23))OR((cf>35)AND(cf<39)))THEN BEGIN
      IF(cf=20)OR(cf=36)THEN REPEAT IF ctf3=20 THEN ctf3:=1 ELSE INC(ctf3);
      UNTIL(vertr^[ctf3].s<>128)AND(vertr^[ctf3].t<>0)AND(vertr^[ctf3].db<128);
      IF(cf=21)OR(cf=37)THEN REPEAT IF ctf3=1 THEN ctf3:=20 ELSE DEC(ctf3);
      UNTIL(vertr^[ctf3].s<>128)AND(vertr^[ctf3].t<>0)AND(vertr^[ctf3].db<128);
      IF cf=22 THEN vertr^[ctf3].db:=vertr^[ctf3].db OR 128;
      IF(cf=22)AND((vertr^[ctf3].s=town)OR(vertr^[ctf3].t=town))THEN sts:=250
       ELSE ContractView(2);
    END;
    IF(sts=3)AND(cf=21)THEN Truck(4);
    IF(sts=3)AND(cf=20)THEN Truck(5);
    IF cf=42THEN BEGIN scrollpos:=0;LoadTruck;END;
    IF cf=26THEN BEGIN scrollpos:=0;Truck(1);END;
    IF(cf=30)OR(cf=46)THEN sts:=250;
    IF((cf=20)OR(cf=36))AND((sts=125)OR(sts=126))THEN ChooseCity(sts-124);
    IF(cf=22)OR(cf=38)THEN CASE sts OF
      125,126:BEGIN ctf2:=ctf3;sts:=255;END;
      1:BEGIN active:=(active OR 2)AND NOT 1;
        town:=roads.t[ctf3];
        trk.pos:=0;
        geld:=geld-trk.dis DIV(250 DIV trk.m)-5;
      END;
    END;
    IF(sts=127)AND Click(40,410,309,449,7)THEN BEGIN
      ctf3:=ctf2;
      ChooseCity(1);
    END;
    IF(sts=127)AND Click(310,410,599,449,7)THEN ShowNews;
    IF(sts=6)AND Click(40,410,599,449,7)THEN sts:=249;
    IF sts=1 THEN Targets(2);
    IF sts=126 THEN Names(3);
    IF sts=125 THEN Names(4);
    IF sts=127 THEN CheckWareChosen;
    IF sts=123 THEN BEGIN
      ShowTownOnSmallMap;
      IF(ms.f=1)AND(ms.b=0)AND(b3<>0)THEN BEGIN
        ctf2:=b3;
        sts:=255;
      END;
    END;
    IF(sts=127)AND(ms.f=1)AND(ms.b=0)AND(ctf3<>255)THEN WarePrices(TRUE);
    IF sts=2 THEN BEGIN
      TradeWare(2);
      IF(menge=0)AND(cfeld AND 64=64)THEN BEGIN
        Mouse(2);
        Clickfield(cfeld AND NOT 64);
        Mouse(1);
      END;
    END;
    IF active AND 32=32 THEN BEGIN active:=active AND NOT 32;
      CASE sts OF
        127:sts:=253;
        123:sts:=248;
        2:sts:=251;
      END;
    END;
    IF(cf=29)OR(cf=45)THEN sts:=255;
    IF(cf=27)OR(cf=43)THEN sts:=254;
    IF(cf=28)OR(cf=44)THEN sts:=252;
    IF(cf=23)OR(cf=39)THEN IF(sts=127)OR((sts>0)AND(sts<5))OR(sts=6)THEN BEGIN
      Mouse(2);
      FOR b1:=0 TO 3 DO BEGIN
        XMS2RAM(page,xms[1],64000,251500+LONGINT(b1)*56004);
        PUTIMAGE(40,WORD(b1)*100+50,page^,0);
      END;
      ClickField(64768);Mouse(1);sts:=0;
    END ELSE IF(sts>122)AND(sts<127)THEN sts:=255 ELSE IF sts=7 THEN sts:=250;
    IF(cf=31)OR(cf=47)THEN BEGIN
      MOUSE(2);
      active:=active OR 16;
      ClickField(cfeld AND NOT 32768);
      active:=active XOR 1;
      ClickField(cfeld OR 32768);
      MOUSE(1);
      active:=active AND NOT 16;
    END;
  UNTIL(cf=24)OR(cf=40)OR(active AND 2=2)OR(geld<min_geld)OR(geld>=max_geld)OR(death);
  Mouse(2);
  ClickField(0);
  OutPic(pal,4,0,255);
  mappage:=1-GetActivePage;
  SetActivePage(mappage);
  FOR li0:=0 TO 4 DO BEGIN
    XMS2RAM(page,xms[1],61444,475516+li0*61444);
    PUTIMAGE(0,li0*96,page^,0);
  END;
  SetVisualPage(mappage);
  MapPal;
  IF town>20 THEN BEGIN poi0.x:=mapx^.fx[town-20];poi0.y:=mapx^.fy[town-20];END
   ELSE BEGIN poi0.x:=mapx^.tx[town];poi0.y:=mapx^.ty[town];END;
  ctf:=town;
  IF active AND 2=2 THEN town:=trk.s;
  IF town>20 THEN BEGIN poi1.x:=mapx^.fx[town-20];poi1.y:=mapx^.fy[town-20];END
   ELSE BEGIN poi1.x:=mapx^.tx[town];poi1.y:=mapx^.ty[town];END;
  DEC(poi0.x,3);DEC(poi0.y,3);
  DEC(poi1.x,3);DEC(poi1.y,3);
  ctf2:=(poi0.x+poi1.x)DIV 2;
  ctf3:=(poi0.y+poi1.y)DIV 2;
  MapXY2ScrXY(poi0.x,poi0.y,poi0);
  MapXY2ScrXY(poi1.x,poi1.y,poi1);
  IF(poi0.x<20)OR(poi0.x>=GETMAXX-19)OR(poi0.y<20)OR(poi0.y>=GETMAXY-19)OR
   (poi1.x<20)OR(poi1.x>=GETMAXX-19)OR(poi1.y<20)OR(poi1.y>=GETMAXY-19)THEN BEGIN
    xp:=ctf2;yp:=ctf3;
    IF town>20 THEN BEGIN
      poi1.x:=mapx^.fx[town-20];
      poi1.y:=mapx^.fy[town-20];
    END ELSE BEGIN
      poi1.x:=mapx^.tx[town];
      poi1.y:=mapx^.ty[town];
    END;
    MapXY2ScrXY(poi1.x,poi1.y,poi0);
    WHILE(poi0.x<20)OR(poi0.x>=GETMAXX-19)OR(poi0.y<20)OR(poi0.y>=GETMAXY-19)DO BEGIN
      INC(zoom,zoom);
      MapXY2ScrXY(poi1.x,poi1.y,poi0);
    END;
    zoom:=zoom OR 128;
  END ELSE BEGIN
    GetCFOriginals(FALSE);
    IF zoom=16 THEN wo0:=33297 ELSE IF zoom=1 THEN wo0:=33313 ELSE wo0:=33329;
    IF active AND 2=2 THEN wo0:=wo0 AND NOT 512;
    ClickField(wo0);
  END;
  ms.b:=0;
  Mouse(1);
  IF soundbyte AND 8=8 THEN BEGIN
    StopSound(2);
    FreeSound(sounds[3]);
    soundbyte:=soundbyte AND NOT 8;
  END;
  StartSound(sounds[2],2,TRUE);
  drawedpos_enemy:=0;
  enemy.backgr_x:=65535;
  tip.time:=0;
  tip.xpos:=-1;
END;

{Funktion berechnet die Landschaft im gewÅnschten Bereich und legt die
 Bitmaps darauf}
PROCEDURE RenderMap(tof,tof2:BOOLEAN);

{Alpha-Texture, die Daten fÅr die Zuweisung des Typens in einem Dreieck
 enthÑlt.}
CONST type_texture_map:ARRAY[0..31,0..31]OF BYTE=(
  (1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,0,1,0,1,0,0,1,0,0,0,0,0),
  (2,1,1,1,1,1,1,1,1,1,0,0,1,1,0,1,1,1,1,1,1,1,0,1,1,0,0,1,0,0,0,0),
  (1,2,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,0,0,0,1,1,1,0,0,1,0,0,0,0,0),
  (1,1,1,0,1,0,1,1,1,1,1,1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,1,1,1,1,1,0,0,0,0,1,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,1,2,0,1,1,0,1,1,1,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,1,1,1,0,1,0,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (0,1,2,1,1,1,0,1,1,1,0,1,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,0,1,0,1,1,1,1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,2,1,1,0,1,1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,2,1,1,0,1,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,1,1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (0,1,0,0,2,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,0,2,2,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,1,0,1,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,1,1,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,1,2,1,2,2,2,1,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,1,2,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,2,0,0,1,0,0,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,2,2,2,2,0,0,2,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (0,1,2,2,2,2,0,2,2,0,0,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,1,2,2,0,2,2,2,0,2,0,2,0,2,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,2,2,2,2,2,2,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (1,2,0,2,2,2,2,2,2,0,0,2,0,0,2,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,2,1,2,2,2,2,0,2,2,2,0,2,0,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,2,2,2,2,2,0,2,2,2,2,0,2,2,0,2,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0),
  (2,2,2,2,2,2,2,0,2,0,2,0,0,0,2,0,2,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0),
  (2,2,2,0,2,2,2,2,0,0,2,2,2,0,2,2,2,0,0,0,0,2,2,0,0,2,0,2,0,0,0,0),
  (1,2,2,2,0,2,2,2,2,2,2,2,0,0,2,2,2,2,2,0,2,0,0,0,0,2,0,0,0,2,2,0),
  (2,2,2,2,2,2,2,2,2,2,2,0,2,2,0,0,2,2,2,2,0,2,2,2,0,0,0,0,0,0,0,0));

VAR random_map:ARRAY[0..4095]OF BYTE;  {Tabelle fÅr Zufallswerte}
    segm1,offs1,segm2,offs2:WORD;      {Zeiger auf Textur und Tabelle}

{Funktion zeichnet ein verlaufendes Viereck mittels zwei Dreieck}
PROCEDURE DrawQuadangle(x_origin,y_origin_u,y_origin_d,
                        y_origin_l,y_origin_r,x_difference:INTEGER;
                        color_u,color_d,color_l,color_r,
                        type_u,type_d,type_l,type_r:BYTE;
                        segment1,offset1,segment2,offset2:WORD);ASSEMBLER;

{Variable fÅr signifikante Werte}
VAR y_difference_u,y_difference_d,color_difference_u,color_difference_d:WORD;
    y_sign_u,y_sign_d,color_sign_u,color_sign_d,color_sign_y,y_difference:BYTE;
    actual_type:BYTE;
    x_dither_position:WORD;
ASM
  CMP x_difference,0
  JE @Ende_Schleife_3ecke               {Wenn kein Dreieck, dann Ende}
  MOV AX,y_origin_u
  CMP AX,y_origin_d
  JGE @Ende_Schleife_3ecke              {Wenn Oben>=Unten, dann Ende}
  MOV CX,2                              {Anzahl der Dreiecke in CX}
  @Schleife_3ecke:
    DEC CL                              {Seite dekrementieren}
    PUSH CX                             {Seite in Stack}

    {Werte-Zuweisung zu den Dreiecken:}
    JCXZ @Rechte_Seite1
      MOV AX,y_origin_l                 {y-Wert der linken Seite laden}
      JMP @Marke1
    @Rechte_Seite1:
      MOV AX,y_origin_r                 {y-Wert der rechten Seite laden}
    @Marke1:
    MOV BX,y_origin_u                   {oberen y-Wert laden}
    PUSH AX
    CMP AX,BX                           {y-Werte vergleichen}
    JL @Kleiner1                        {AX>=BX:}
      SUB AX,BX                         {Seite-Oben}
      MOV y_difference_u,AX             {speichern}
      MOV y_sign_u,1                    {1=positive Differenz}
      JMP @Marke2
    @Kleiner1:                          {AX<BX:}
      SUB BX,AX                         {Oben-Seite}
      MOV y_difference_u,BX             {speichern}
      MOV y_sign_u,0                    {0=negative Differenz}
    @Marke2:
    MOV BX,y_origin_d                   {unteren y-Wert laden}
    POP AX
    CMP AX,BX                           {y-Werte vergleichen}
    JG @Kleiner2                        {AX<=BX:}
      SUB BX,AX                         {Unten-Seite}
      MOV y_difference_d,BX             {speichern}
      MOV y_sign_d,1                    {1=positive Differenz}
      JMP @Marke3
    @Kleiner2:                          {AX>BX:}
      SUB AX,BX                         {Seite-Unten}
      MOV y_difference_d,AX             {speichern}
      MOV y_sign_d,0                    {0=negative Differenz}
    @Marke3:

    {Farb-Werte zu Ecken festlegen:}
    JCXZ @Rechte_Seite3
      MOV AH,type_l                     {linkes Dreieck}
      MOV AL,color_l
      JMP @Marke7
    @Rechte_Seite3:
      MOV AH,type_r                     {rechtes Dreieck}
      MOV AL,color_r
    @Marke7:
    MOV actual_type,AH                  {aktuellen Typ speicher}
    XOR AH,AH                           {AH lîschen}
    XOR BH,BH                           {BH lîschen}
    MOV BL,color_u                      {oberer Grauwert in BL}
    PUSH AX                             {Seitenwert in Stack}
    CMP AL,BL                           {Seitenwert und oberer Wert vergleichen}
    JB @Kleiner3
      SUB AL,BL
      MOV color_difference_u,AX         {Differenz}
      MOV color_sign_u,1                {Vorzeichen}
      JMP @Marke8
    @Kleiner3:
      SUB BL,AL
      MOV color_difference_u,BX         {Differenz}
      MOV color_sign_u,0                {Vorzeichen}
    @Marke8:
    XOR BH,BH
    MOV BL,color_d                      {unterer Grauwert in BL}
    POP AX                              {Seitenwert in AX}
    CMP AL,BL                           {Seitenwert und unterer Wert vergleichen}
    JA @Kleiner4
      SUB BL,AL
      MOV color_difference_d,BX         {Differenz}
      MOV color_sign_d,1                {Vorzeichen}
      JMP @Marke9
    @Kleiner4:
      SUB AL,BL
      MOV color_difference_d,AX         {Differenz}
      MOV color_sign_d,0                {Vorzeichen}
    @Marke9:

    {x-Schleife:}
    MOV CX,x_difference                 {CX=Schleifenregister fÅr x}
    INC CL
    @Schleife_x:
      DEC CL                            {x-Schleife dekrementieren}

      {Linien zeichnen:}
      MOV BX,CX                         {x-Position in BX kopieren}
      POP CX                            {Dreiecksseite in CX laden}
      PUSH CX                           {Dreiecksseite wieder in Stack}
      PUSH BX                           {x-Position in Stack}
      MOV AX,x_origin                   {x-Ursprung in AX kopieren}
      JCXZ @Rechte_Seite2               {Dreiecksseite links:}
        SUB AX,BX                       {Ursprung-Position}
        JMP @Marke4
      @Rechte_Seite2:                   {Dreiecksseite rechts:}
        ADD AX,BX                       {Position-Ursprung}
      @Marke4:
      {PUSH CX                           {Dreiecksseite in Stack}
      CMP AX,range.x_min
      JL @Ende_Schleife_y               {Linien au·erhalb des Fensters...}
      CMP AX,range.x_max                {...nicht zeichnen}
      JG @Ende_Schleife_y
      PUSH AX                           {x-Wert in Stack}
      {oberer Teil:}
      XOR DX,DX                         {DX lîschen}
      MOV AX,y_difference_u             {Hîhendifferenz Oben in AX kopieren}
      MUL BL                            {Hîhendifferenz*x-Position/x-Differenz}
      DIV x_difference                  {=y-Position}
      PUSH BX                           {x-Position in Stack}
      MOV BL,AL                         {y-Position in BL kopieren}
      MOV AX,y_origin_u                 {y-Ursprung Oben in AX kopieren}
      MOV CL,y_sign_u                   {Ausrichtung in CL kopieren}
      JCXZ @Subtraktion1
        ADD AX,BX                       {Ursprung+Position}
        JMP @Marke5
      @Subtraktion1:
        SUB AX,BX                       {Ursprung-Position}
      @Marke5:
      POP BX                            {x-Position laden}
      PUSH AX                           {y-Wert Oben in Stack}
      XOR DX,DX                         {DX lîschen}
      MOV AX,color_difference_u         {Farbdifferenz Oben in AX kopieren}
      MUL BL                            {Farbdifferenz*x-Position/x-Differenz}
      DIV x_difference                  {=Farbposition}
      PUSH BX                           {x-Position in Stack}
      MOV BL,AL                         {Farbposition in BL kopieren}
      MOV AL,color_u                    {Farbe Oben in AL kopieren}
      MOV CL,color_sign_u               {Vorzeichen in CL kopieren}
      JCXZ @Subtraktion2
        ADD AL,BL                       {Anfangsfarbe+Farbposition}
        JMP @Marke10
      @Subtraktion2:
        SUB AL,BL                       {Anfangsfarbe-Farbposition}
      @Marke10:
      POP BX                            {x-Position in BX laden}
      PUSH AX                           {Farbe 1 in Stack}
      {unterer Teil:}
      XOR DX,DX                         {DX lîschen}
      MOV AX,y_difference_d             {Hîhendifferenz Unten in AX kopieren}
      MUL BL                            {Hîhendifferenz*x-Position/x-Differenz}
      DIV x_difference                  {=y-Position}
      PUSH BX                           {x-Position in Stack}
      MOV BL,AL                         {y-Position in BL kopieren}
      MOV AX,y_origin_d                 {y-Ursprung Unten in AX kopieren}
      MOV CL,y_sign_d                   {Ausrichtung in CL kopieren}
      JCXZ @Addition1
        SUB AX,BX                       {Ursprung-Position}
        JMP @Marke6
      @Addition1:
        ADD AX,BX                       {Ursprung+Position}
      @Marke6:
      POP BX                            {x-Position laden}
      PUSH AX                           {y-Wert Unten in Stack}
      XOR DX,DX                         {DX lîschen}
      MOV AX,color_difference_d         {Farbdifferenz Unten in AX kopieren}
      MUL BL                            {Farbdifferenz*x-Position/x-Differenz}
      DIV x_difference                  {=Farbposition}
      MOV BL,AL                         {Farbposition in BL kopieren}
      MOV AL,color_d                    {Farbe Unten in AL kopieren}
      MOV CL,color_sign_d               {Vorzeichen in CL kopieren}
      JCXZ @Addition2
        SUB AL,BL                       {Anfangsfarbe-Farbposition}
        JMP @Marke11
      @Addition2:
        ADD AL,BL                       {Anfangsfarbe+Farbposition}
      @Marke11:
      MOV SI,AX                         {Farbe 2 in DI kopieren}
      {Linie zwischen Oben und Unten zeichnen:}
      POP AX                            {y-Wert Unten laden}
      POP DI                            {Farbe 1 laden}
      POP DX                            {y-Wert Oben laden}
      MOV CX,AX                         {y-Wert Unten in CX kopieren}
      SUB CX,DX                         {y-Wert Unten minus y-Wert Oben}
      INC CX
      MOV y_difference,CL               {y-Differenz fÅr aktuelle Linie speichern}
      POP AX                            {x-Wert laden}
      CMP CX,0
      JE @Ende_Schleife_y               {Wenn LinienlÑnge=0, dann nichts zeichnen}
      PUSH DI                           {Farbe 1 in Stack}
      CMP SI,DI                         {Farbe 1 und Farbe 2 vergleichen}
      JB @Kleiner5
        SUB SI,DI                       {Differenz}
        MOV color_sign_y,1              {Vorzeichen}
        JMP @Marke12
      @Kleiner5:
        SUB DI,SI                       {Differenz}
        MOV SI,DI
        MOV color_sign_y,0              {Vorzeichen}
      @Marke12:
      POP DI                            {Farbe 1 laden}
      POP BX                            {Position laden}
      PUSH BX                           {Position in Stack}
      PUSH AX                           {x-Wert in Stack}
      PUSH DX                           {y-Wert oben in Stack}
      XOR DX,DX
      MOV AL,31                         {Ditherposition berechnen}
      MUL BL
      DIV x_difference
      MOV x_dither_position,AX          {und speichern}
      POP DX                            {y-Wert oben laden}
      POP AX                            {x-Wert laden}
      @Schleife_y:
        DEC CL                          {y-Position dekrementieren}
        PUSH CX                         {y-Position in Stack}
        MOV BX,CX                       {y-Position fÅr Farbberechnung in BX kopieren}
        ADD CX,DX                       {y-Wert berechnen}

        CMP CX,range.y_min
        JL @KeinPixelZeichnen           {Pixel au·erhalb des Fensters...}
        CMP CX,range.y_max              {...nicht zeichnen}
        JG @KeinPixelZeichnen
        PUSH AX                         {wichtige Werte...}
        PUSH DX                         {...vor dem Aufruf von...}
        PUSH DI                         {,,,PutPixel im Stack ablegen}
        PUSH SI
        PUSH AX                         {x-Wert fÅr PutPixel}
        PUSH CX                         {y-Wert fÅr PutPixel}
        PUSH BX
        MOV AX,SI                       {Farbdifferenz in AX kopieren}
        MUL BL                          {Farbdifferenz*y-Position/y-Differenz}
        DIV y_difference                {=Farbposition}
        XOR AH,AH                       {AH lîschen}
        XOR CH,CH                       {CH lîschen}
        MOV CL,color_sign_y             {Vorzeichen prÅfen}
        JCXZ @Subtraktion3
          ADD DI,AX                     {Farbstart+Farbposition}
          JMP @Marke13
        @Subtraktion3:
          SUB DI,AX                     {Farbstart-Farbposition}
        @Marke13:
        XOR AX,AX                       {AX lîschen}
        MOV CX,dithering                {Dithering-Option prÅfen}
        JCXZ @Dithering_Ende
          POP BX
          POP AX                        {y-Wert in AX laden}
          POP CX                        {x-Wert in CX laden}
          PUSH CX                       {x-Wert wieder in Stack}
          PUSH AX                       {y-Wert wieder in Stack}
          PUSH BX
          XOR DX,DX                     {DX lîschen}
          MOV BX,2                      {BX:=2}
          DIV BX                        {y DIV 2}
          MOV AX,DX                     {y_Rest in AX}
          MUL BX                        {y_Rest*2}
          PUSH AX                       {Ergebnis in Stack}
          MOV AX,CX                     {x-Wert in AX kopieren}
          DIV BX                        {x DIV 2}
          POP AX                        {y_Rest*2 in AX laden}
          ADD DL,AL                     {y_Rest*2+x_Rest}
          MOV AL,4                      {AL:=4}
          SUB AL,DL                     {4-(y_Rest*2+x_Rest)}
          CMP AL,4                      {Wenn AL=4, dann AL:=0}
          JNE @Marke14
            XOR AL,AL                   {AL lîschen}
          @Marke14:
          MOV BL,2                      {BL:=2}
          MUL BL                        {AL*2}
        @Dithering_Ende:
        ADD AX,DI                       {Farb-Startwert zu AX addieren}
        MOV BL,8                        {BL:=8}
        DIV BL                          {Farbe DIV 8}
        POP BX
        PUSH AX
        MOV AL,31                       {Typ aus Texture laden}
        MUL BL
        DIV y_difference
        MOV BL,32
        MUL BL
        ADD AX,x_dither_position
        MOV ES,segment1
        MOV DI,offset1
        ADD DI,AX
        MOV CX,AX
        MOV BL,ES:[DI]
        POP AX
        CMP BL,2
        JE @Typ_Unten
        CMP BL,1
        JE @Typ_Oben
        ADD AL,actual_type
        JMP @Marke15
        @Typ_Unten:
        ADD AL,type_d
        JMP @Marke15
        @Typ_Oben:
        ADD AL,type_u
        @Marke15:
        MOV ES,segment2                 {Zufallswert aus Tabelle laden}
        MOV DI,offset2
        ADD DI,CX
        MOV BL,ES:[DI]
        ADD AL,BL
        PUSH AX                         {Farbe fÅr PutPixel}
        CALL PutPixel                   {Pixel zeichnen}
        POP SI
        POP DI
        POP DX                          {wichtige Werte zurÅckholen}
        POP AX
        @KeinPixelZeichnen:

        POP CX                          {y-Postion in CX laden}
        JCXZ @Ende_Schleife_y
        JMP @Schleife_y
      @Ende_Schleife_y:
      POP CX                            {x-Position in CX laden}

      JCXZ @Ende_Schleife_x
      JMP @Schleife_x
    @Ende_Schleife_x:

    POP CX                              {Dreiecksseite in CX laden}
    JCXZ @Ende_Schleife_3ecke
    JMP @Schleife_3ecke
  @Ende_Schleife_3ecke:
END;

{Funktion bestimmt nach Hîhe den Typ der Landschaft}
FUNCTION GetType(heigth:BYTE):BYTE;
BEGIN
  CASE heigth OF
    0..63:GetType:=0;
    64..65:GetType:=64;
    66..179:GetType:=32;
    180..209:GetType:=64;
    210..255:GetType:=96;
  END;
END;

{Funktion zeichnet die Stra·e auf die Landschaft}
PROCEDURE RoadLine(x0,y0,x1,y1:INTEGER;flag:BOOLEAN);
VAR cnt,xd,yd:INTEGER;value:SINGLE;value1,value2,value3,value4,color:BYTE;
BEGIN
  color:=36;
  xd:=x1-x0;
  yd:=y1-y0;
  IF(ABS(xd)>ABS(yd))OR(yd=0)THEN BEGIN
    IF(x0>x1)THEN BEGIN
      cnt:=x1;x1:=x0;x0:=cnt;
      cnt:=y1;y1:=y0;y0:=cnt;
      xd:=-xd;yd:=-yd;
    END;
    FOR cnt:=0 TO xd-1 DO IF(cnt+x0>=range.x_min)AND(cnt+x0<=range.x_max)THEN BEGIN
      x1:=cnt+x0;
      value:=cnt/xd*yd+y0;
      y1:=TRUNC(value);
      IF(y1<range.y_min)OR(y1>range.y_max)THEN CONTINUE;
      value:=FRAC(value);
      value3:=GetPixel(x1,y1);
      value4:=GetPixel(x1,y1+1);
      value1:=value3-TRUNC((1-value)*6);
      value2:=value4-TRUNC(value*6);
      IF((value1 MOD 32)<(value3 MOD 32))AND(value3<128)THEN PutPixel(x1,y1,value1);
      IF((value2 MOD 32)<(value4 MOD 32))AND(value4<128)THEN PutPixel(x1,y1+1,value2);
    END;
  END ELSE BEGIN
    IF(y0>y1)THEN BEGIN
      cnt:=x1;x1:=x0;x0:=cnt;
      cnt:=y1;y1:=y0;y0:=cnt;
      xd:=-xd;yd:=-yd;
    END;
    FOR cnt:=0 TO yd-1 DO IF(cnt+y0>=range.y_min)AND(cnt+y0<=range.y_max)THEN  BEGIN
      y1:=cnt+y0;
      value:=cnt/yd*xd+x0;
      x1:=TRUNC(value);
      IF(x1<range.x_min)OR(x1>range.x_max)THEN CONTINUE;
      value:=FRAC(value);
      value3:=GetPixel(x1,y1);
      value4:=GetPixel(x1+1,y1);
      value1:=value3-TRUNC((1-value)*6);
      value2:=value4-TRUNC(value*6);
      IF((value1 MOD 32)<(value3 MOD 32))AND(value3<128)THEN PutPixel(x1,y1,value1);
      IF((value2 MOD 32)<(value4 MOD 32))AND(value4<128)THEN PutPixel(x1+1,y1,value2);
    END;
  END;
END;
(*PROCEDURE RoadLine(x0,y0,x1,y1:INTEGER;VAR flag:BOOLEAN);
VAR xz,yz,xd,yd:INTEGER;color:BYTE;
BEGIN
  xd:=x1-x0;yd:=y1-y0;
  {y-Differenz grî·er als x-Differenz}
  IF ABS(xd)<ABS(yd) THEN BEGIN
    IF y0>y1 THEN BEGIN yz:=y0;y0:=y1;y1:=yz;xz:=x0;x0:=x1;x1:=xz;END;
    FOR yz:=y0 TO y1-1 DO BEGIN
      flag:=NOT flag;
    IF(flag)AND(yz>=range.y_min)AND(yz<=range.y_max)THEN BEGIN
      xz:=(yz-y1)*xd DIV yd+x1;
      {normal Linie mit schon vorhandenen Farbwert zeichnen}
      ASM
        PUSH xz
        PUSH yz
        CALL GetPixel
        MOV DX,xz
        CMP DX,range.x_min
        JL @KeinPixel
        CMP DX,range.x_max
        JG @KeinPixel
        CMP AL,128
        JAE @KeinPixel
          PUSH DX
          PUSH yz
          XOR AH,AH
          MOV BL,32
          DIV BL
          MOV AL,AH
          XOR AH,AH
          MOV BL,2
          MUL BL
          MOV BL,3
          DIV BL
          ADD AL,96
          XOR AH,AH
          PUSH AX
          CALL PutPixel
        @KeinPixel:
      END;
    END;
    END;
  END ELSE BEGIN
    IF xd=0 THEN xd:=1;
    IF x0>x1 THEN BEGIN yz:=y0;y0:=y1;y1:=yz;xz:=x0;x0:=x1;x1:=xz;END;
    FOR xz:=x0 TO x1-1 DO BEGIN
      flag:=NOT flag;
    IF(flag)AND(xz>=range.x_min)AND(xz<=range.x_max)THEN BEGIN
      yz:=(xz-x1)*yd DIV xd+y1;
      {normal Linie mit schon vorhandenen Farbwert zeichnen}
      ASM
        PUSH xz
        PUSH yz
        CALL GetPixel
        MOV DX,yz
        CMP DX,range.y_min
        JL @KeinPixel
        CMP DX,range.y_max
        JG @KeinPixel
        CMP AL,128
        JAE @KeinPixel
          PUSH xz
          PUSH DX
          XOR AH,AH
          MOV BL,32
          DIV BL
          MOV AL,AH
          XOR AH,AH
          MOV BL,2
          MUL BL
          MOV BL,3
          DIV BL
          ADD AL,96
          XOR AH,AH
          PUSH AX
          CALL PutPixel
        @KeinPixel:
      END;
    END;
    END;
  END;
END;*)
PROCEDURE PutPoint(xz,yz:INTEGER);ASSEMBLER;
ASM
  PUSH xz
  PUSH yz
  CALL GetPixel
  MOV DX,xz
  CMP DX,range.x_min
  JL @KeinPixel
  CMP DX,range.x_max
  JG @KeinPixel
  MOV DX,yz
  CMP DX,range.y_min
  JL @KeinPixel
  CMP DX,range.y_max
  JG @KeinPixel
  CMP AL,128
  JAE @KeinPixel
    PUSH xz
    PUSH DX
    XOR AH,AH
    MOV BL,32
    DIV BL
    MOV AL,AH
    XOR AH,AH
    MOV BL,2
    MUL BL
    MOV BL,3
    DIV BL
    ADD AL,96
    XOR AH,AH
    PUSH AX
    CALL PutPixel
  @KeinPixel:
END;


VAR xz,yz,typ:BYTE;x1,y1,xt,yt,x2,y2:INTEGER;p1,p2,p3,p4:point;w0,addx,addy:WORD;
    xnz,ynz,percent:SINGLE;
    timelength:LONGINT;olddithering,oldactive:BYTE;
    flag:BOOLEAN;

BEGIN
  {normale Zeichnung}
  IF tof2 THEN BEGIN
    Mouse(2);
    ClickField(0);
  END;

  oldactive:=active;
  {Pause setzen}
  active:=active OR 1;
  timelength:=GetClock;
  olddithering:=dithering;
  {unnîtiges Dithering entfernen}
  IF zoom>=8 THEN dithering:=0;

  {Zeit entfernen}
  IF tof AND tof2 THEN PUTIMAGE(269,463,tbkgr^,0);

  IF tof THEN BEGIN
    {Truck entfernen}
    IF active AND 2=2 THEN PutImage(trk.px-10,trk.py-10,trk.backgr,0);
    {Feind entfernen}
    WITH enemy DO IF backgr_x<>65535 THEN PutImage(backgr_x-10,backgr_y-10,backgr,0);
    {Seite kopieren}
    CopyPage(GetActivePage,1-GetActivePage);
  END;

  {falls nîtig Bildschirmgrenzen zuweisen}
  IF tof2 THEN BEGIN
    range.x_min:=0;
    range.y_min:=0;
    range.x_max:=GETMAXX;
    range.y_max:=GETMAXY;
  END;

  addx:=(GETMAXX+1) DIV 2*zoom;
  addy:=(GETMAXY+1) DIV 2*zoom;
  xt:=20 DIV zoom+2;

  {Hîhen laden}
  XMS2RAM(map[0],xms[1],62500,0);
  {Farbwerte laden}
  XMS2RAM(map[1],xms[1],62500,62500);
  NEW(map[2]);
  {Bitmaptypen laden}
  XMS2RAM(map[2],xms[1],62500,125000);
  {Bitmaps laden}
  XMS2RAM(page,xms[1],64000,187500);

  {Zufallswerte von neuem}
  RandSeed:=0;

  {Zeiger auf Texture setzen}
  segm1:=SEG(type_texture_map);
  offs1:=OFS(type_texture_map);

  {Zufallstabelle erstellen}
  FOR x1:=0 TO 4095 DO random_map[x1]:=RANDOM(2);

  {Zeichenseite wechseln}
  SetActivePage(1-GetActivePage);
  SetVisualPage(1-GetActivePage);

  {falls nîtig Bildschirm lîschen}
  IF NOT tof THEN BEGIN
    SETCOLOR(240);
    BAR(range.x_min,range.y_min,range.x_max,range.y_max);
  END;

  {Landschaft zeichnen}
  FOR yz:=1 TO maxfieldy-2 DO BEGIN
    FOR xz:=1 TO maxfieldx-2 DO BEGIN
      xt:=(INTEGER(xz-xp)-yz+yp)*20+addx;
      yt:=INTEGER(yz-yp+xz-xp)*10+addy;
      p1.y:=(yt-map[0]^[xz,yz])DIV zoom;
      p2.x:=(xt-20)DIV zoom;
      p4.y:=(yt+20-map[0]^[xz+1,yz+1])DIV zoom;

      {nicht-sichtbare Dreiecke nicht zeichnen}
      IF(p2.x>=range.x_min-20)AND(p2.x<=range.x_max+20)
       AND(p4.y>=range.y_min-20)AND(p1.y<=range.y_max+20)THEN BEGIN
        p2.y:=(yt+10-map[0]^[xz,yz+1])DIV zoom;
        p3.y:=(yt+10-map[0]^[xz+1,yz])DIV zoom;
        p1.x:=xt DIV zoom;
        p3.x:=(xt+20)DIV zoom;
        x1:=RANDOM(3072);
        segm2:=SEG(random_map[x1]);
        offs2:=OFS(random_map[x1]);

        {Viereck zeichnen}
        IF NOT tof THEN DrawQuadangle(p1.x,p1.y,p4.y,p2.y,p3.y,p1.x-p2.x,
         map[1]^[xz,yz]AND NOT 192*8,map[1]^[xz+1,yz+1]AND NOT 192*8,
         map[1]^[xz,yz+1]AND NOT 192*8,map[1]^[xz+1,yz]AND NOT 192*8,
         GetType(map[0]^[xz,yz]),GetType(map[0]^[xz+1,yz+1]),
         GetType(map[0]^[xz,yz+1]),GetType(map[0]^[xz+1,yz]),
         segm1,offs1,segm2,offs2);

        DEC(p1.y,20 DIV zoom);

        {Bitmap zeichnen}
        IF map[2]^[xz,yz]<>255 THEN FOR y1:=0 TO 39 DIV zoom DO BEGIN
          y2:=p1.y+y1;
          IF(y2>=range.y_min)AND(y2<=range.y_max)THEN BEGIN
            w0:=y1*40*zoom+WORD(map[2]^[xz,yz])*1600;
            FOR x1:=0 TO 39 DIV zoom DO BEGIN
              x2:=p2.x+x1;
              typ:=page^[w0+x1*zoom];
              IF(typ<>200)AND(x2>=range.x_min)AND(x2<=range.x_max)THEN PUTPIXEL(x2,y2,typ);
            END;
          END;
        END;

      END;
    END;
  END;

  DISPOSE(map[2]);map[2]:=NIL;
  dithering:=olddithering;

  {RÑnder der Karte zeichnen}
  IF NOT tof THEN BEGIN
    yz:=maxfieldy-1;
    FOR xz:=1 TO maxfieldx-2 DO BEGIN
      xt:=(INTEGER(xz-xp)-yz+yp)*20+addx;
      yt:=INTEGER(yz-yp+xz-xp)*10+addy;
      p1.x:=xt DIV zoom;
      p1.y:=(yt-map[0]^[xz,yz])DIV zoom;
      p2.x:=(xt+20) DIV zoom;
      p2.y:=(yt+10-map[0]^[xz+1,yz])DIV zoom;
      IF((p1.x>-40)AND(p1.x<GETMAXX+41)AND(p1.y>-40)AND(p1.y<GETMAXY+61))OR
       ((p2.x>-40)AND(p2.x<GETMAXX+41)AND(p2.y>-40)AND(p2.y<GETMAXY+61))THEN BEGIN
        p3.y:=yt DIV zoom;
        p4.y:=(yt+10)DIV zoom;
        x1:=p2.x-p1.x;
        xnz:=p2.y-p1.y;
        ynz:=p4.y-p3.y;
        FOR p3.x:=0 TO x1-1 DO BEGIN
          percent:=p3.x/x1;
          y1:=0;
          FOR x2:=ROUND(ynz*percent)+p3.y DOWNTO ROUND(xnz*percent)+p1.y DO BEGIN
            IF y1<180 THEN y2:=y1 DIV 20+3
             ELSE IF y1<210 THEN y2:=y1 DIV 20+63
             ELSE y2:=107;
            IF(p3.x+p1.x>=range.x_min)AND(p3.x+p1.x<=range.x_max)
             AND(x2>=range.y_min)AND(x2<=range.y_max)THEN
             PUTPIXEL(p3.x+p1.x,x2,y2+RANDOM(6));
            INC(y1,zoom);
          END;
        END;
      END;
    END;
    xz:=maxfieldx-1;
    FOR yz:=1 TO maxfieldy-2 DO BEGIN
      xt:=(INTEGER(xz-xp)-yz+yp)*20+addx;
      yt:=INTEGER(yz-yp+xz-xp)*10+addy;
      p1.x:=(xt-20) DIV zoom;
      p1.y:=(yt-map[0]^[xz,yz])DIV zoom;
      p2.x:=(xt) DIV zoom;
      p2.y:=(yt+10-map[0]^[xz,yz+1])DIV zoom;
      IF((p1.x>-40)AND(p1.x<GETMAXX+41)AND(p1.y>-40)AND(p1.y<GETMAXY+61))OR
       ((p2.x>-40)AND(p2.x<GETMAXX+41)AND(p2.y>-40)AND(p2.y<GETMAXY+61))THEN BEGIN
        p3.y:=yt DIV zoom;
        p4.y:=(yt+10)DIV zoom;
        x1:=p2.x-p1.x;
        xnz:=p1.y-p2.y;
        ynz:=p3.y-p4.y;
        FOR p3.x:=0 TO x1-1 DO BEGIN
          percent:=p3.x/x1;
          y1:=0;
          FOR x2:=ROUND(ynz*percent)+p4.y DOWNTO ROUND(xnz*percent)+p2.y DO BEGIN
            IF y1<180 THEN y2:=y1 DIV 20+7
             ELSE IF y1<210 THEN y2:=y1 DIV 20+67
             ELSE y2:=111;
            IF(p3.x+p1.x>=range.x_min)AND(p3.x+p1.x<=range.x_max)
             AND(x2>=range.y_min)AND(x2<=range.y_max)THEN
             PUTPIXEL(p3.x+p1.x,x2,y2+RANDOM(6));
            INC(y1,zoom);
          END;
        END;
      END;
    END;
  END;

  {Stra·e zeichnen}
  FOR typ:=1 TO road^.sc DO BEGIN
    xt:=road^.p1[typ];
    IF(xt=mapx^.it)AND(mapx^.itst=0)THEN CONTINUE;
    IF xt>20 THEN BEGIN x1:=mapx^.fx[xt-20];y1:=mapx^.fy[xt-20];END
     ELSE BEGIN x1:=mapx^.tx[xt];y1:=mapx^.ty[xt];END;
    yt:=road^.p2[typ];
    IF(yt=mapx^.it)AND(mapx^.itst=0)THEN CONTINUE;
    IF(tof)AND(mapx^.it<>xt)AND(mapx^.it<>yt)THEN CONTINUE;
    IF yt>20 THEN BEGIN x2:=mapx^.fx[yt-20];y2:=mapx^.fy[yt-20];END
     ELSE BEGIN x2:=mapx^.tx[yt];y2:=mapx^.ty[yt];END;
    xt:=Entfernung(x1,y1,x2,y2);
    flag:=FALSE;
    FOR yt:=0 TO xt DO BEGIN
      percent:=yt/xt;
      xnz:=INTEGER(x2-x1)*percent+x1;
      ynz:=INTEGER(y2-y1)*percent+y1;
      p1.x:=TRUNC((xnz-xp-ynz+yp)*20+(GETMAXX+1) DIV 2*zoom)DIV zoom;
      p1.y:=TRUNC((ynz-yp+xnz-xp)*10+(GETMAXY+1) DIV 2*zoom-map[0]^[ROUND(xnz),ROUND(ynz)])DIV zoom;
      IF(yt<>0)THEN RoadLine(p1.x,p1.y,p2.x,p2.y,flag);
      p2:=p1;
    END;
  END;

  {Namen an Orten ausgeben}
  IF zoom<16 THEN BEGIN
    FOR xz:=1 TO mapx^.tc DO IF(mapx^.it<>xz)OR(mapx^.itst>0)THEN BEGIN
      xt:=(INTEGER(mapx^.tx[xz]-xp)-mapx^.ty[xz]+yp)*20+(GETMAXX+1) DIV 2*zoom;
      yt:=INTEGER(mapx^.ty[xz]-yp+mapx^.tx[xz]-xp)*10+(GETMAXY+1) DIV 2*zoom;
      xt:=xt DIV zoom;yt:=(yt-map[0]^[mapx^.tx[xz],mapx^.ty[xz]])DIV zoom;
      IF zoom<4 THEN OutBTxt(xt-LENGTH(mapx^.tn[xz])*9 DIV 2,yt+12,mapx^.tn[xz],251)
       ELSE OutSTxt(xt-LENGTH(mapx^.tn[xz])*3,yt+5,mapx^.tn[xz],251)
    END;
    FOR xz:=1 TO mapx^.fc DO BEGIN
      xt:=((INTEGER(mapx^.fx[xz]-xp)-mapx^.fy[xz]+yp)*20+(GETMAXX+1) DIV 2*zoom)DIV zoom;
      yt:=((INTEGER(mapx^.fy[xz]-yp+mapx^.fx[xz]-xp)*10+(GETMAXY+1) DIV 2*zoom)-map[0]^[mapx^.fx[xz],mapx^.fy[xz]])DIV zoom;
      STR(xz,st);st:=st+': ';ID(st,xz);
      IF zoom<4 THEN OutBTxt(xt-LENGTH(st)*9 DIV 2,yt+12,st,251)
       ELSE OutSTxt(xt-LENGTH(st)*3,yt+5,st,251)
    END;
  END;

  {timelength:=GetClock-timelength;
  STR(timelength,st);
  OutBTxt(1,1,st,251);}

  IF savepic THEN SavePicture;

  {Werte zurÅcksetzen}
  trk.px:=65535;
  enemy.backgr_x:=65535;
  tip.time:=0;
  tip.xpos:=-1;
  active:=oldactive;
  GetCFOriginals(TRUE);
  IF zoom=16 THEN w0:=33297 ELSE IF zoom=1 THEN w0:=33313 ELSE w0:=33329;
  IF active AND 2=2 THEN w0:=w0 AND NOT 512;

  {Seite anzeigen}
  SetVisualPage(GetActivePage);

  IF tof2 THEN ClickField(w0);

  {Werte zurÅcksetzen}
  active:=active AND NOT 16;
  xap:=xp;
  yap:=yp;
  azoom:=zoom;
  drawedpos_enemy:=0;

  IF tof2 THEN Mouse(1);
END;
PROCEDURE Test4Scrolling;
PROCEDURE CopyMapPart(x0,y0,x1,y1,xn,yn:INTEGER);
VAR y_counter,x_difference:INTEGER;
    buffer:ARRAY[0..639]OF BYTE;
BEGIN
  x_difference:=x1-x0+1;
  FOR y_counter:=y0 TO y1 DO BEGIN
    MoveTo(x0,y_counter);
    GetXLine(buffer,x_difference);
    SetActivePage(1-GetActivePage);
    MoveTo(xn,y_counter-y0+yn);
    PutXLine(buffer,x_difference);
    SetActivePage(1-GetActivePage);
  END;
END;
VAR cfeld_alt:WORD;
BEGIN
  REPEAT
    IF(ms.b<>1)OR((ms.x>60)AND(ms.x<GETMAXX-60)AND(ms.y>20)AND(ms.y<GETMAXY-20))
     OR(ms.x<30)OR(ms.x>GETMAXX-30)THEN EXIT;
    cfeld_alt:=cfeld;
    Mouse(2);
    ClickField(0);
    IF trk.px<>65535 THEN PutImage(trk.px-10,trk.py-10,trk.backgr,0);
    WITH enemy DO IF backgr_x<>65535 THEN PutImage(backgr_x-10,backgr_y-10,backgr,0);
    Mouse(1);
    WHILE NOT((ms.b<>1)OR((ms.x>60)AND(ms.x<GETMAXX-60)AND(ms.y>20)AND(ms.y<GETMAXY-20))
     OR(ms.x<30)OR(ms.x>GETMAXX-30))DO BEGIN
      IF(ms.y<=20)AND(xp>10*zoom)AND(yp>10*zoom)THEN BEGIN
        DEC(xp,zoom*2);DEC(yp,zoom*2);
        range.x_min:=0;
        range.x_max:=GETMAXX;
        range.y_min:=0;
        range.y_max:=39;
        Mouse(2);
        PUTIMAGE(269,463,tbkgr^,0);
        CopyMapPart(0,0,GETMAXX,GETMAXY-40,0,40);
        RenderMap(FALSE,FALSE);
        Mouse(1);
      END ELSE IF(ms.y>=GETMAXY-20)AND(xp<maxfieldx-10*zoom)AND(yp<maxfieldy-10*zoom)THEN BEGIN
        INC(xp,zoom*2);INC(yp,zoom*2);
        range.x_min:=0;
        range.x_max:=GETMAXX;
        range.y_min:=GETMAXY-39;
        range.y_max:=GETMAXY;
        Mouse(2);
        PUTIMAGE(269,463,tbkgr^,0);
        CopyMapPart(0,40,GETMAXX,GETMAXY,0,0);
        RenderMap(FALSE,FALSE);
        Mouse(1);
      END;
      IF(ms.x<=60)AND(xp>5*zoom)AND(yp<maxfieldy-5*zoom)THEN BEGIN
        INC(yp,zoom);DEC(xp,zoom);
        range.x_min:=0;
        range.x_max:=39;
        range.y_min:=0;
        range.y_max:=GETMAXY;
        Mouse(2);
        PUTIMAGE(269,463,tbkgr^,0);
        CopyMapPart(0,0,GETMAXX-40,GETMAXY,40,0);
        RenderMap(FALSE,FALSE);
        Mouse(1);
      END ELSE IF(ms.x>=GETMAXX-60)AND(yp>5*zoom)AND(xp<maxfieldx-5*zoom)THEN BEGIN
        DEC(yp,zoom);INC(xp,zoom);
        range.x_min:=GETMAXX-39;
        range.x_max:=GETMAXX;
        range.y_min:=0;
        range.y_max:=GETMAXY;
        Mouse(2);
        PUTIMAGE(269,463,tbkgr^,0);
        CopyMapPart(40,0,GETMAXX,GETMAXY,0,0);
        RenderMap(FALSE,FALSE);
        Mouse(1);
      END;
      Mouse(3);
    END;
    Mouse(2);
    ClickField(cfeld_alt);
    Mouse(1);
  UNTIL 1=0;
  ms.f:=0;
END;
FUNCTION Scenes:BYTE;
VAR menutext:STRING[40];
BEGIN
  GETIMAGE(240,138,399,341,page^[0]);
  FOR b1:=0 TO 4 DO BEGIN
    CASE b1 OF 0:menutext:='EINLEITUNG';
      1:menutext:='ERMORDUNG';
      2:menutext:='VERHAFTUNG';
      3:menutext:='ENDSEQUENZ';
      4:menutext:='ZURöCK';
    END;
    GrBar(240,138+b1*41,399,177+b1*41,menutext);
  END;Mouse(1);
  REPEAT Keys;
    IF(key[2]=#72)OR(key[2]=#80)THEN BEGIN
      ms.x:=320;IF ms.y<120 THEN ms.y:=120;
      ms.y:=(ms.y-138)DIV 41*41+158;
      IF ms.y>284 THEN ms.y:=284;
      IF key[2]=#72 THEN DEC(ms.y,41) ELSE INC(ms.y,41);
      IF ms.y<158 THEN ms.y:=322 ELSE IF ms.y>322 THEN ms.y:=158;
    END ELSE key[2]:=#0;
    IF key[2]=#0 THEN Mouse(3) ELSE Mouse(7);
    b2:=255;FOR b1:=0 TO 4 DO IF Click(240,138+b1*41,399,177+b1*41,7)THEN b2:=b1;
    IF savepic THEN SavePicture;
  UNTIL b2<>255;
  Scenes:=b2;
  Mouse(2);
  PUTIMAGE(240,138,page^[0],0);
END;
PROCEDURE OutGameOver(textstring:STRING);
BEGIN
  GreenBar(200,220,439,259);
  GreenBar(204,224,435,255);
  OutText(320,230,textstring,240,6,1.5);
  ClearKeyboardBuffer;
  REPEAT Keys;
  UNTIL(key[1]<>#0)OR(key[2]<>#0);
END;
BEGIN
  NEW(news);NEW(tile);
  Intro(TRUE);
  REPEAT pb:=0;
    IF active AND 5=4THEN active:=active OR 16;
    ClickField(0);
    REPEAT
      CASE MainMenu OF
        0:IF CreateMap THEN BEGIN pb:=255;
            FOR zoom:=1 TO mapx^.tc DO IF mapx^.tt[zoom] AND 2=2 THEN BEGIN
              xp:=mapx^.tx[zoom]-3;yp:=mapx^.ty[zoom]-3;
            END;
            active:=active OR 1;active:=active AND NOT 2;
            zoom:=130;
            enemy.last_town:=0;
            REPEAT
              enemy.actual_town:=RANDOM(mapx^.tc)+1;
            UNTIL(enemy.actual_town<>mapx^.it)AND(enemy.actual_town<>trk.s);
            enemy.endtime:=100;
            enemy.staytime:=0;
            enemy.tx:=mapx^.tx[enemy.actual_town];
            enemy.ty:=mapx^.ty[enemy.actual_town];
            REPEAT
              b1:=RANDOM(mapx^.tc)+1;
            UNTIL b1<>enemy.actual_town;
            enemy.sx:=mapx^.tx[b1];
            enemy.sy:=mapx^.ty[b1];
            enemy.position:=1;
            enemy.distance:=1;
            enemy.backgr_x:=65535;
          END;
        1:IF DiskOp(1) THEN BEGIN
            pb:=255;
            active:=active OR 1;
            active:=active AND NOT 2;
            zoom:=130;
            IF ctf<21 THEN BEGIN
              xp:=mapx^.tx[ctf];
              yp:=mapx^.ty[ctf];
            END ELSE BEGIN
              xp:=mapx^.fx[ctf-20];
              yp:=mapx^.fy[ctf-20];
            END;
            DEC(xp,3);
            DEC(yp,3);
          END;
        2:IF active AND 5=0 THEN BEGIN
            Mouse(1);
            Einstellungen;
            Mouse(2);
          END ELSE IF DiskOp(2) THEN BEGIN
            pb:=255;
            active:=active OR 1;
            active:=active AND NOT 2;
            zoom:=130;
          END;
        3:BEGIN IF active AND 5>0 THEN pb:=255 ELSE
           IF mml_anim[3]<>'-' THEN Highscores(FALSE)
            ELSE IF cheats AND 1=0 THEN Intro(FALSE) ELSE
            CASE Scenes OF
            0:Intro(FALSE);
            1:GameOver(1);
            2:GameOver(2);
            3:Outro;
          END;
        END;
        4:HALT(0);
      END;
    UNTIL pb=255;
    active:=active OR 4;
    cdtimecounter:=32768;
    IF exist_SB THEN BEGIN
      IF LoadSound(sounds[2],'WIND')THEN soundbyte:=soundbyte OR 4;
    END;
    IF soundbyte AND 4=4 THEN StartSound(sounds[2],2,TRUE);
    IF zoom<128 THEN BEGIN
      IF zoom=16 THEN l1:=33297 ELSE IF zoom=1 THEN l1:=33313 ELSE l1:=33329;
      IF active AND 2=2 THEN l1:=l1 AND NOT 512;
      ClickField(l1);
      IF active AND 5=4THEN active:=active AND NOT 16;
    END;
    ctof.n:=0;
    Mouse(1);
    REPEAT
      IF zoom AND 128=128 THEN BEGIN DEC(zoom,128);RenderMap(FALSE,TRUE);END;
      REPEAT
        REPEAT
          ms.arrow:=TRUE;
          DrawSprites;
          Mouse(3);
          Test4Scrolling;
          IF ms.b=0 THEN cf:=ClickedField;
          IF savepic THEN SavePicture;
          IF ttime>49 THEN IF Timing THEN RenderMap(TRUE,TRUE);
          IF active AND 5=4 THEN BEGIN
            IF active AND 2=2 THEN BEGIN
              IF trk.pos>trk.dis THEN InTown(ctf);
            END;
          END;
          IF(cdtimecounter>13104)AND cdmusic AND(cd_rom<>'')THEN BEGIN
            CD_Stop;
            CD_Play(5);
            cdtimecounter:=0;
          END;
        UNTIL(ms.f<>0)OR(geld<min_geld)OR(geld>=max_geld)OR(death);
        IF ms.b=0 THEN cf:=ClickedField;
      UNTIL(ms.b<>0)OR(zoom AND 128=128)OR(geld<min_geld)OR(geld>=max_geld)OR(death);
      cf:=ClickedField;
      IF((ms.b=1)AND(cf=255))AND(zoom<>16)THEN BEGIN
        REPEAT Mouse(3);UNTIL ms.b AND 1=0;
        INC(xp,INTEGER(ms.y-GETMAXY DIV 2)*zoom DIV 20+INTEGER(ms.x-(GETMAXX+1) DIV 2)*zoom DIV 40);
        INC(yp,INTEGER(ms.y-GETMAXY DIV 2)*zoom DIV 20-INTEGER(ms.x-(GETMAXX+1) DIV 2)*zoom DIV 40);
        IF xp<zoom*6 THEN xp:=zoom*6 ELSE IF xp>maxfieldx-zoom*6 THEN xp:=maxfieldx-zoom*6;
        IF yp<zoom*10 THEN yp:=zoom*10 ELSE IF yp>maxfieldy-zoom*10 THEN yp:=maxfieldy-zoom*10;
        zoom:=zoom OR 128;
      END;
      IF((cf=20)OR(cf=36))AND(zoom<>1)THEN zoom:=zoom DIV 2+128;
      IF(cf=25)OR(cf=41)THEN InTown(ctf);
      IF cf=32 THEN Einstellungen;
      ms.arrow:=TRUE;
      IF((ms.b=2)AND(cf=255))AND(zoom<>16)THEN BEGIN
        IF cf=255 THEN REPEAT Mouse(3);UNTIL ms.b AND 2=0;
        xp:=maxfieldx DIV 2;yp:=maxfieldy DIV 2;
        zoom:=zoom OR 128;
      END;
      IF((cf=21)OR(cf=37))AND(zoom<>16)THEN BEGIN
        zoom:=zoom*2+128;IF zoom=144 THEN BEGIN xp:=125;yp:=125;END;
      END;
      IF(cf=31)OR(cf=47)THEN BEGIN
        MOUSE(2);
        active:=active OR 16;
        ClickField(cfeld AND NOT 32768);
        active:=active XOR 1;
        ClickField(cfeld OR 32768);
        MOUSE(1);
        active:=active AND NOT 16;
      END;
    UNTIL(cf=16)OR(geld<min_geld)OR(geld>=max_geld)OR(death);
    CD_Stop;
    IF soundbyte AND 4=4 THEN BEGIN
      StopSound(2);
      FreeSound(sounds[2]);
      soundbyte:=soundbyte AND NOT 4;
    END;
    Mouse(2);
    IF death THEN BEGIN
      IF COPY(mml_anim,1,3)=aus THEN OutGameOver('GAME OVER');
      OutPic(pal,1,0,255);
      GameOver(1);
      death:=FALSE;
      Highscores(FALSE);
    END ELSE BEGIN
      IF geld<min_geld THEN BEGIN
        IF COPY(mml_anim,1,3)=aus THEN OutGameOver('GAME OVER');
        OutPic(pal,1,0,255);
        GameOver(2);
        Highscores(FALSE);
      END;
      IF geld>=max_geld THEN BEGIN
        IF COPY(mml_anim,1,3)=aus THEN OutGameOver('SPIEL GEWONNEN');
        OutPic(pal,1,0,255);
        Outro;
        Highscores(TRUE);
      END;
    END;
  UNTIL pb=0;
  DISPOSE(tile);tile:=NIL;
  DISPOSE(news);news:=NIL;
END;

BEGIN END.