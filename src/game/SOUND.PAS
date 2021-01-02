{$F+,G+,I-}
UNIT Sound_SB;

INTERFACE

USES crtn,dos,sb_vars,memory,vars;

PROCEDURE SoundPause;
PROCEDURE SoundContinue;
FUNCTION InitSB:BOOLEAN;
PROCEDURE DSP_Block(gr,dgr:WORD;bk:POINTER);
PROCEDURE SetBalance(wert:BYTE);{Wert=0..24}
PROCEDURE SetVolume(wert:BYTE);{Wert=0..31}
PROCEDURE WriteDSP(v:BYTE);
FUNCTION ResetSB:BOOLEAN;
PROCEDURE SetTimeconst(tc:BYTE);
PROCEDURE Spiele_SB(Segm,Offs,dgr,dsize:WORD);
PROCEDURE Spiele_SBPro(Segm,Offs,dgr,dsize:WORD);
PROCEDURE Spiele_SB16(Segm,Offs,dgr,dsize:WORD);
FUNCTION InitSoundFile(filename:STRING):BOOLEAN;
PROCEDURE PlaySound;
PROCEDURE SoundDone;
FUNCTION WriteDSP_IRQ:STRING;
FUNCTION WriteDSP_Adr:STRING;
PROCEDURE ExitSB;
PROCEDURE SetTreble(tl,tr:BYTE);
PROCEDURE SetBass(bl,br:BYTE);
PROCEDURE BassFilter;
PROCEDURE NoFilter;
PROCEDURE TrebleFilter;

IMPLEMENTATION

VAR xmsbuf:BYTE;
    buflength:WORD;
    bufpos:LONGINT;
    vocb1,vocb2:POINTER;
    pause_voc:BOOLEAN;

PROCEDURE WriteDSP(v:BYTE);
BEGIN
  REPEAT UNTIL PORT[dsp_adr+$c]<128;
  PORT[dsp_adr+$C]:=v;
END;
FUNCTION SbReadBYTE:BYTE;
BEGIN
  REPEAT UNTIL PORT[dsp_adr+$A]<>$AA;
  SbReadBYTE:=PORT[dsp_adr+$A];
END;
PROCEDURE SBreset;
VAR bt,ct,stat:BYTE;
BEGIN
  PORT[dsp_adr+$6]:=1;
  FOR ct:=1 TO 100 DO;
  PORT[dsp_adr+$6]:=0;
  bt:=0;
  repeat
    ct:=0;
    repeat
      stat:=PORT[dsp_adr+$E];
    until(ct>8000)OR(stat>=128);
    INC(bt);
  until(bt>100)OR(PORT[dsp_adr+$A]=$AA);
END;
FUNCTION ResetSB:BOOLEAN;
VAR ct,stat:BYTE;
BEGIN
  PORT[dsp_adr+$6]:=1;
  FOR ct:=1TO 100DO;
  PORT[dsp_adr+$6]:=0;
  stat:=0;
  ct:=0;
  WHILE(stat<>$AA)AND(ct<100)DO BEGIN
    stat:=PORT[dsp_adr+$E];
    stat:=PORT[dsp_adr+$A];
    INC(ct);
  END;
  ResetSB:=(stat=$AA);
END;
FUNCTION Detect_Reg_SB16:BOOLEAN;
VAR port,lst:WORD;
BEGIN
 Detect_Reg_sb16:=SbRegDetected;
 IF SbRegDetected THEN EXIT;
 port:=startport;
 lst:=endport;
 WHILE(NOT SbRegDetected)AND(port<=lst)DO BEGIN
   dsp_adr:=port;
   SbRegDetected:=ResetSB;
   IF NOT SbRegDetected THEN INC(port,$10);
 END;
 Detect_Reg_sb16:=SbRegDetected;
END;
PROCEDURE Write_Mixer(Reg,Val:BYTE);
BEGIN
 PORT[dsp_adr+$4]:=Reg;
 PORT[dsp_adr+$5]:=Val;
END;
FUNCTION Read_Mixer(Reg:BYTE):BYTE;
BEGIN
  PORT[dsp_adr+$4]:=Reg;
  Read_Mixer:=PORT[dsp_adr+$5];
END;
PROCEDURE SetTreble(tl,tr:BYTE);
BEGIN
  IF sb16detected THEN BEGIN
    Write_Mixer(68,tl);
    Write_Mixer(69,tr);
  END;
END;
PROCEDURE SetBass(bl,br:BYTE);
BEGIN
  IF sb16detected THEN BEGIN
    Write_Mixer(70,bl);
    Write_Mixer(71,br);
  END;
END;
PROCEDURE BassFilter;
VAR hilfe:BYTE;
BEGIN
 IF sb16detected THEN BEGIN
   write_Mixer(68,63);                  { Treble runter              }
   write_Mixer(69,63);
   write_Mixer(70,255);                 { Bass voll Power !          }
   write_Mixer(71,255);                 { Bass voll Power !          }
 END ELSE BEGIN
   hilfe:=read_Mixer($0c);            { Tiefer Filter              }
   hilfe:=hilfe OR 8;
   Write_Mixer($0c,hilfe);
   hilfe:=read_Mixer($0e);            { Filter einschalten         }
   hilfe:=hilfe AND 2;
   write_Mixer($0e,hilfe);
 END;
END;
PROCEDURE NoFilter;
VAR hilfe:BYTE;
BEGIN
 IF sb16detected THEN BEGIN
   write_Mixer(68,192);                  { Treble runter              }
   write_Mixer(69,192);
   write_Mixer(70,192);                 { Bass voll Power !          }
   write_Mixer(71,192);                 { Bass voll Power !          }
 END ELSE BEGIN
   hilfe:=read_Mixer($0e);            { Filter ausschalten         }
   hilfe:=hilfe OR 32;
   write_Mixer($0e,hilfe);
 END;
END;
PROCEDURE TrebleFilter;
VAR hilfe:BYTE;
BEGIN
 IF sb16detected THEN BEGIN
   write_Mixer(68,255);                 { zurÅck auf default         }
   write_Mixer(69,255);
   write_Mixer(70,127);
   write_Mixer(71,127);
 END ELSE BEGIN
   hilfe:=read_Mixer($0c);            { Hîhen-Filter               }
   hilfe:=hilfe OR 247;
   Write_Mixer($0c,hilfe);
   hilfe:=read_Mixer($0e);            { Filter einschalten         }
   hilfe:=hilfe AND 2;
   write_Mixer($0e,hilfe);
 END;
END;
PROCEDURE SetBalance(wert:BYTE);
VAR left,right:BYTE;
BEGIN
  IF Sb16Detected THEN BEGIN
    left :=12;
    right:=12;
    IF Wert < 12 THEN right:=wert;
    IF Wert > 12 THEN left :=24-Wert;
    write_Mixer(50,(left  SHL 4));
    write_Mixer(51,(right SHL 4));
  END ELSE BEGIN
    wert:=wert SHR 1;
    CASE Wert OF 0..6:Write_Mixer(02,(7 SHL 5)+(Wert SHL 1));
      7:Write_Mixer(02,(7 SHL 5)+(7 SHL 1));
      8..13:Write_Mixer(02,((13-Wert) SHL 5)+(7 SHL 1));
    END;
  END;
END;
PROCEDURE SetVolume(wert:BYTE);
BEGIN
  IF sb16detected THEN BEGIN
    write_Mixer(48,wert{ SHL 3});
    write_Mixer(49,wert{ SHL 3});
  END ELSE BEGIN
    IF MixerDetected THEN BEGIN
      {wert:=wert SHR 2;}
      write_Mixer($22,{(wert SHL 5)+(wert SHL 1)}wert);
    END ELSE BEGIN
      outvolume:=Wert SHL 1;
    END;
  END;
END;
PROCEDURE Reset_Mixer;ASSEMBLER;
ASM
  mov dx,dsp_adr+$4
  mov al,0
  out dx,al
  mov cx,50
@loop:
  loop @loop
  INC dx
  out dx,al
END;
FUNCTION Detect_Mixer_SB16:BOOLEAN;
VAR SaveReg:WORD;
    NewReg :WORD;
BEGIN
  Detect_Mixer_SB16:=MixerDetected;
  IF NOT SbRegDetected                { Abbruch,wenn keine Sound- }
  OR MixerDetected THEN EXIT;           { blaster-Karte vorhANDen    }
                                        { oder Mixer-Chip schon      }
                                        { initalisiert               }
  Reset_Mixer;
  SaveReg:=Read_Mixer($22);           { Register sichern           }
  Write_Mixer($22,243);                { Wenn der geschribene wert  }
  NewReg :=Read_Mixer($22);           { mit dem zurÅckgelesenen    }
                                        { Åbereinstimmt,so ist ein  }
                                        { Zugriff mîglich und somit  }
                                        { ein Mixer vorhANDen        }
  IF NewReg=243 THEN BEGIN
    MixerDetected:=TRUE;
    STEREO:=True;
  END;
  Write_Mixer($22,SaveReg);            { Altes Register zurÅck      }
  Detect_Mixer_SB16:=MixerDetected;
END;
PROCEDURE SBGetDSPVersion;
VAR i:WORD;
    t:WORD;
    s:STRING[2];
BEGIN
  WriteDSP($E1);                     { $E1=Versionsabfrage      }
  SBVersMaj:=SBReadBYTE;
  SBVersMin:=SBReadBYTE;
  STR(SBVersMaj,SBVersStr);
  SBVersStr:=SBVersStr+'.';
  STR(SBVersMin,s);
  IF SBVersMin>9 THEN SBVersStr:=SBVersStr+s
   ELSE SBVersStr:=SBVersStr+'0'+s;
END;
FUNCTION WriteDSP_Adr:STRING;
BEGIN
  CASE dsp_adr OF
    $210:WriteDSP_Adr:='210';
    $220:WriteDSP_Adr:='220';
    $230:WriteDSP_Adr:='230';
    $240:WriteDSP_Adr:='240';
    $250:WriteDSP_Adr:='250';
    $260:WriteDSP_Adr:='260';
    $270:WriteDSP_Adr:='270';
    $270:WriteDSP_Adr:='280';
   END;
END;
FUNCTION WriteDSP_IRQ:string;
BEGIN
  CASE dsp_irq OF
     $2:WriteDSP_IRQ:='2';
     $3:WriteDSP_IRQ:='3';
     $5:WriteDSP_IRQ:='5';
     $7:WriteDSP_IRQ:='7';
    $10:WriteDSP_IRQ:='10';
   END;
END;
PROCEDURE SetTimeconst(tc:BYTE);
BEGIN
  WriteDSP($40);                     { $40=Setze Sample Rate    }
  WriteDSP(tc);
END;
PROCEDURE TestUebertragung;
BEGIN
  FILLCHAR(vocb1^,2000,127);
  lastone:=TRUE;
  DSP_Block(2000,2000,vocb1);
  DELAY(100);
END;
PROCEDURE ExitSB;
BEGIN
  SETINTVEC($8+dsp_irq,oldint);         { Alten Interrupt wieder her-}
  PORT[$21]:=PORT[$21] OR irqmsk;     { stellen und Maskierung auf }
  PORT[dsp_adr+$C]:=$d3;              { alten Wert zurÅck          }
  PORT[$20]:=$20;
  WriteDSP($D0);
END;
PROCEDURE Spiele_SB16(Segm,Offs,dgr,dsize:WORD);
VAR li:WORD;
BEGIN
  PORT[$0A]:=dma_ch+4;                { DMA-Kanal sperren          }
  PORT[$0c]:=0;                       { Adresse des Puffers   }
  PORT[$0B]:=$48+dma_ch;                     { fÅr Soundausgabe           }
  PORT[dma_adr[dma_ch]]:=Lo(offs);    { an DMA-Controller          }
  PORT[dma_adr[dma_ch]]:=Hi(offs);
  PORT[dma_wc[dma_ch]]:=Lo(dgr-1);  { Grî·e des Blockes (block-  }
  PORT[dma_wc[dma_ch]]:=Hi(dgr-1);  { groesse) an DMA-Controller }
  PORT[dma_page[dma_ch]]:=Segm;
  IF sb16_outputlaenge<>dsize THEN BEGIN
    WriteDSP($C6);                   { DSP-Befehl 8-Bit Åber DMA  }
    IF stereo THEN BEGIN               { fÅr SB16 Nur zum Starten ! }
      WriteDSP($20);
    END ELSE
      WriteDSP($00);
    WriteDSP(Lo(dsize-1));           { Grî·e des Blockes an       }
    WriteDSP(Hi(dsize-1));           { den DSP                    }
    sb16_outputlaenge:=dsize;
  END ELSE BEGIN
    WriteDSP($45);                   { DMA Continue SB16 8-Bit    }
  END;
  PORT[$0A]:=dma_ch;                  { DMA-Kanal freigeben        }
END;
PROCEDURE Spiele_SB(Segm,Offs,dgr,dsize:WORD);
VAR li:WORD;
BEGIN
  PORT[$0A]:=dma_ch+4;                { DMA-Kanal sperren          }
  PORT[$0c]:=0;                       { Adresse des Puffers   }
  PORT[$0B]:=$48+dma_ch;                     { fÅr Soundausgabe           }
  PORT[dma_adr[dma_ch]]:=Lo(offs);    { an DMA-Controller          }
  PORT[dma_adr[dma_ch]]:=Hi(offs);
  PORT[dma_wc[dma_ch]]:=Lo(dgr-1);  { Grî·e des Blockes (block-  }
  PORT[dma_wc[dma_ch]]:=Hi(dgr-1);  { groesse) an DMA-Controller }
  PORT[dma_page[dma_ch]]:=Segm;
  WriteDSP($14);
  WriteDSP(Lo(dsize-1));             { Grî·e des Blockes an       }
  WriteDSP(Hi(dsize-1));             { den DSP                    }
  PORT[$0A]:=dma_ch;                  { DMA-Kanal freigeben        }
END;
PROCEDURE Spiele_SBPro(Segm,Offs,dgr,dsize:WORD);
VAR li:WORD;
BEGIN
  PORT[$0A]:=dma_ch+4;                { DMA-Kanal sperren          }
  PORT[$0c]:=0;                       { Adresse des Puffers  }
  PORT[$0B]:=$48+dma_ch;                     { fÅr Soundausgabe           }
  PORT[dma_adr[dma_ch]]:=Lo(offs);    { an DMA-Controller          }
  PORT[dma_adr[dma_ch]]:=Hi(offs);
  PORT[dma_wc[dma_ch]]:=Lo(dgr-1);  { Grî·e des Blockes (block-  }
  PORT[dma_wc[dma_ch]]:=Hi(dgr-1);  { groesse) an DMA-Controller }
  PORT[dma_page[dma_ch]]:=Segm;

  WriteDSP($48);
  WriteDSP(Lo(dsize-1));             { Grî·e des Blockes an       }
  WriteDSP(Hi(dsize-1));             { den DSP                    }
  WriteDSP($91);
  PORT[$0A]:=dma_ch;                  { DMA-Kanal freigeben        }
END;
PROCEDURE Dsp_Block(gr,dgr:WORD;bk:pointer);
VAR l:longint;
    pn,offs:WORD;
    hBYTE:BYTE;
    a:WORD;
    OldV,NewV,Hilfe:BYTE;
    stereoreg:BYTE;
    sr:WORD;
    samps:BYTE;
BEGIN
  playing_voc:=TRUE;
  sound_over:=FALSE;
  l:=16*longint(pt(bk).sgm)+pt(bk).ofs;
  pn:=pt(l).sgm;
  offs:=pt(l).ofs;
  sb16_outputlaenge:=0;
  IF samplingrate<>0 THEN SetTimeconst(samplingrate);
  IF SB16Detected THEN BEGIN
    IF stereo THEN BEGIN
      Spiele_SB16(pn,offs,dgr,gr);
    END ELSE BEGIN
      Spiele_SB16(pn,offs,dgr,gr);
    END;
  END ELSE BEGIN
    IF stereo THEN BEGIN
      Spiele_SBPro(pn,offs,dgr,gr);
    END ELSE BEGIN
      Spiele_SB(pn,offs,dgr,gr);
    END;
  END;
END;
FUNCTION InitSoundFile(filename:STRING):BOOLEAN;
CONST vockenn:ARRAY[0..5]OF CHAR='SOUND'+#$1A;
VAR kennstr:ARRAY[0..5]OF CHAR;
    sr,rb:WORD;samplingr:LONGINT;
    counter,sampldiv:BYTE;
    buf,buf2:^ScrArray;
BEGIN
  InitSoundFile:=FALSE;
  IF(MEMAVAIL<128008)OR(hixms<21)OR NOT exist_SB THEN EXIT;
  ASSIGN(vocf,filename+'.SND');
  RESET(vocf,1);
  IF IORESULT<>0 THEN EXIT;
  BLOCKREAD(vocf,kennstr,6);
  IF kennstr<>vockenn THEN BEGIN
    CLOSE(vocf);
    EXIT;
  END;
  NEW(buf);
  SoundDone;
  vocsstereo:=stereo;
  stereo:=false;
  ofgr:=FILESIZE(vocf)-23;
  IF ofgr>16000 THEN blockgr:=16000 ELSE blockgr:=ofgr;
  blockgr:=blockgr DIV 2;
  buflength:=0;
  counter:=20;
  sampldiv:=1;
  WHILE LONGINT(buflength)+LONGINT(blockgr)<64005 DO INC(buflength,blockgr);
  WHILE((ofgr DIV sampldiv)DIV buflength+1>hixms-20)AND(sampldiv<16)DO sampldiv:=sampldiv*2;
  IF sampldiv=16 THEN BEGIN CLOSE(vocf);EXIT;END;
  fgr:=fgr DIV sampldiv;
  BLOCKREAD(vocf,buf^[1],3);
  samplingr:=(LONGINT(buf^[1])+LONGINT(buf^[2])*256)DIV sampldiv;
  IF buf^[3]=2 THEN BEGIN
    stereo:=TRUE;
    IF sbprodetected THEN samplingr:=samplingr*2;
    samplingrate:=256-LONGINT(1000000DIV samplingr);
  END ELSE BEGIN
    samplingrate:=256-LONGINT(1000000DIV samplingr);
  END;
  IF sampldiv<>1 THEN NEW(buf2);
  REPEAT INC(counter);
    IF sampldiv=1 THEN BEGIN
      BLOCKREAD(vocf,buf^,buflength,rb);
      FILLCHAR(buf^[rb],buflength-rb,128);
      RAM_2_XMS(buf,xms[counter],64004)
    END ELSE BEGIN
      FOR sr:=0 TO sampldiv-1 DO BEGIN
        samplingr:=sr*(buflength DIV sampldiv);
        BLOCKREAD(vocf,buf^,buflength,rb);
        FILLCHAR(buf^[rb],buflength-rb,128);
        rb:=0;
        REPEAT buf2^[samplingr+rb DIV sampldiv]:=buf^[rb];
          INC(rb,sampldiv);
        UNTIL rb>=buflength-sampldiv;
      END;
      RAM_2_XMS(buf2,xms[counter],64004)
    END;
  UNTIL(rb=0)OR(counter=hixms);
  IF sampldiv<>1 THEN BEGIN DISPOSE(buf2);buf2:=NIL;END;
  DISPOSE(buf);buf:=NIL;
  CLOSE(vocf);
  InitSoundFile:=TRUE;
END;
PROCEDURE PlaySound;
VAR stereoreg:BYTE;
    buf:^ScrArray;
BEGIN
  IF MAXAVAIL<64004 THEN BEGIN CLOSE(vocf);EXIT;END;
  playing_voc:=TRUE;
  sound_ready:=FALSE;
  NEW(buf);
  fgr:=ofgr;
  bufpos:=0;
  xmsbuf:=0;
  XMS_2_RAM(buf,xms[xmsbuf+21],64004);
  MOVE(buf^,vocb1^,blockgr);
  DEC(fgr,blockgr);
  INC(bufpos,blockgr);
  block_activ:=1;
  IF fgr>1 THEN BEGIN
    MOVE(buf^[blockgr],vocb2^,blockgr);
    DEC(fgr,blockgr);
    INC(bufpos,blockgr);
  END;
  DISPOSE(buf);
  WriteDSP($D1);
  lastone:=FALSE;
  IF NOT sb16Detected THEN BEGIN
    IF Stereo THEN BEGIN
      stereoreg:=Read_Mixer($0E);
      stereoreg:=stereoreg OR 2;
      Write_Mixer($0E,stereoreg);
    END ELSE BEGIN
      stereoreg:=Read_Mixer($0E);
      stereoreg:=stereoreg AND NOT 2;
      Write_Mixer($0E,stereoreg);
    END;
  END;
  pause_voc:=FALSE;
  DSP_Block(blockgr,blockgr,vocb1);
END;
PROCEDURE SoundDone;
BEGIN
  lastone:=TRUE;
  stereo:=vocsstereo;
END;
PROCEDURE SoundPause;
BEGIN
  pause_voc:=TRUE;
END;
PROCEDURE SoundContinue;
BEGIN
  pause_voc:=FALSE;
  {IF block_activ=1 THEN BEGIN
    dsp_block_sb16(blockgr,blockgr,vocb2,false,true);
    block_activ:=2;
  END ELSE BEGIN
    dsp_block_sb16(blockgr,blockgr,vocb1,false,true);
    block_activ:=1;
  END;}
END;
PROCEDURE Interrupt_Check;INTERRUPT;
BEGIN
  IRQDetected:=TRUE;
  PORT[$20]:=$20;
END;
PROCEDURE DSP_Int_SB16;INTERRUPT;
VAR h:BYTE;
    buf:^ScrArray;
BEGIN
  IF playing_voc THEN BEGIN
    NEW(buf);
    h:=PORT[dsp_adr+$E];
    IF(fgr>blockgr DIV 2)AND NOT lastone THEN BEGIN
      lastone:=FALSE;
      IF block_activ=1 THEN BEGIN
        IF NOT pause_voc THEN DSP_Block(blockgr,blockgr,vocb2);
        IF bufpos DIV buflength<>xmsbuf THEN BEGIN
          xmsbuf:=bufpos DIV buflength;
          XMS_2_RAM(buf,xms[xmsbuf+21],64004);
        END;
        MOVE(buf^[bufpos-bufpos DIV buflength*buflength],vocb1^,blockgr);
        DEC(fgr,blockgr);
        INC(bufpos,blockgr);
        block_activ:=2;
      END ELSE BEGIN
        IF NOT pause_voc THEN DSP_Block(blockgr,blockgr,vocb1);
        IF bufpos DIV buflength<>xmsbuf THEN BEGIN
          xmsbuf:=bufpos DIV buflength;
          XMS_2_RAM(buf,xms[xmsbuf+21],64004);
        END;
        MOVE(buf^[bufpos-bufpos DIV buflength*buflength],vocb2^,blockgr);
        DEC(fgr,blockgr);
        INC(bufpos,blockgr);
        block_activ:=1;
      END;
    END ELSE BEGIN
      IF NOT lastone THEN BEGIN
        IF block_activ=1 THEN BEGIN
          IF NOT pause_voc THEN DSP_Block(blockgr,blockgr,vocb2);
          lastone:=TRUE;
        END ELSE BEGIN
          IF NOT pause_voc THEN DSP_Block(blockgr,blockgr,vocb1);
          lastone:=TRUE;
        END;
      END ELSE BEGIN
        sound_ready:=TRUE;
        sound_over:=TRUE;
        WriteDSP($D0);
      END;
    END;
    DISPOSE(buf);buf:=NIL;
  END;
  PORT[$20]:=$20;
END;
PROCEDURE Detect_sbIRQ;
CONST moegliche_irqs:ARRAY[1..5] OF BYTE=($2,$3,$5,$7,$10);
VAR i:integer;
    h:BYTE;
BEGIN
  getintvec($8+dsp_irq,intback);         { Werte sichern !            }
  port21:=PORT[$21];
  fillchar(vocb1^,1200,128);
  SetTimeconst(211);
  samplingrate:=0;
  WriteDSP($D3);                      { Lautsprecher aus           }
  i:=1;
  WHILE(i<=5)AND(NOT IRQDetected)DO BEGIN
    dsp_irq:=moegliche_irqs[i];      { zu TestENDer IRQ           }
    getintvec($8+dsp_irq,oldint);      { Interrupt Verbiegen        }
    setintvec($8+dsp_irq,@Interrupt_Check);
    irqmsk:=1 SHL dsp_irq;
    PORT[$21]:=PORT[$21] AND NOT irqmsk;
    DSP_Block(1200,1200,vocb1);
    delay(150);
    setintvec($8+dsp_irq,oldint);      { Interrupt wieder zurÅck    }
    PORT[$21]:=PORT[$21] OR irqmsk;
    h:=PORT[dsp_adr+$E];
    PORT[$20]:=$20;
    INC(i);
  END;
  WriteDSP($D1);                      { Lautsprecher wieder ein    }
  setintvec($8+dsp_irq,intback);         { Alte Werte zurÅck !!!      }
  PORT[$21]:=PORT21;
  sound_over:=true;
  IF IRQDetected=FALSE THEN
  dsp_irq:=0;
END;
FUNCTION InitSB:BOOLEAN;
BEGIN
  IF NOT detect_Reg_sb16 THEN BEGIN
    InitSb:=FALSE;
    EXIT;
  END;
{ Soundblaster gefunden      }
  IF NOT force_irq THEN detect_sbIRQ;    { IRQ auto-detection         }
  TestUebertragung;
  IF NOT force_irq THEN BEGIN detect_sbIRQ;    { 2. Test fÅr SB nîtig !     }
    IF IRQDetected=FALSE THEN BEGIN
      InitSb:=FALSE;
      EXIT;
    END;
  END;
  IF Detect_Mixer_sb16 THEN SbProDetected:=TRUE;               { SB Pro gefunden            }
  SbGetDspVersion;
  IF SbVersMaj>=4 THEN BEGIN                { SB 16 ASP gefunden         }
    Sb16Detected:=true;
    SBProDetected:=false;
  END;
  WriteDSP($D1);                      { Lautsprecher ein           }
  getintvec($8+dsp_irq,oldint);          { Alten Interrupt sichern,  }
  setintvec($8+dsp_irq,@DSP_Int_SB16);   { auf eigene Routine setzen  }
  irqmsk:=1 SHL dsp_irq;               { Interrupt einmaskieren     }
  PORT[$21]:=PORT[$21] AND NOT irqmsk;
END;

BEGIN
 sound_over:=TRUE;
 GETMEM(vocb1,8000);
 GETMEM(vocb2,8000);
END.

