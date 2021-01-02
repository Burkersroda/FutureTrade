UNIT SB_VARS;

INTERFACE

TYPE pt=RECORD ofs,sgm:WORD;END;
     voiceblock=RECORD
                  kennung:BYTE;
                  laeng_lo:WORD;
                  laeng_hi:BYTE;
                  sr:BYTE;
                  pack:BYTE;
                END;

CONST block_activ:BYTE=1;
      outvolume:BYTE=63;
      startport:WORD=$200;
      endport:WORD=$280;
      force_mono:BOOLEAN=false;
      force_sb:BOOLEAN=false;
      force_irq:BOOLEAN=false;
      force_dma:BOOLEAN=false;
      force_base:BOOLEAN=false;
      dsp_irq:BYTE=5;
      dma_ch:BYTE=1;
      dsp_adr:WORD=$220;
      SbVersMin:BYTE=0;
      SbVersMaj:BYTE=0;
      stereo:BOOLEAN=false;
      SbRegDetected:BOOLEAN=FALSE;
      IRQDetected:BOOLEAN=FALSE;
      SbRegInited:BOOLEAN=FALSE;
      SbProDetected:BOOLEAN=FALSE;
      SbProInited:BOOLEAN=FALSE;
      Sb16Detected:BOOLEAN=FALSE;
      Sb16Inited:BOOLEAN=FALSE;
      MixerDetected:BOOLEAN=FALSE;
      dma_page:ARRAY[0..3] OF BYTE=($87,$83,$81,$81);
      dma_adr:ARRAY[0..3] OF BYTE=(0,2,4,6);
      dma_wc:ARRAY[0..3]OF BYTE=(1,3,5,7);
      sb16_outputlaenge:WORD=0;

VAR sound_over:BOOLEAN;
    SbVersStr:STRING[5];
    oldInt:POINTER;
    irqmsk:BYTE;
    intback:POINTER;
    port21:BYTE;
    vocf:FILE;
    ofgr,fgr:LONGINT;
    blk1,blk2:POINTER;
    {vblock:voiceblock;}
    samplingrate:BYTE;
    dsp_rdy_voc:BOOLEAN;
    blockgr:WORD;
    playing_voc:BOOLEAN;
    lastone:BOOLEAN;
    sound_ready:BOOLEAN;
    vocsstereo:BOOLEAN;

IMPLEMENTATION

END.