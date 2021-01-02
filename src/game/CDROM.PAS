UNIT CDROM;

INTERFACE

CONST
  SUCCESS  =  0;
  FAILURE  =  1;


 Function CD_Init : Integer;
 Function CD_Exit : Integer;
 Function CD_Play( Track: Byte ) : Integer;
 Function CD_Stop : Integer;
 Function CD_Resume : Integer;
 Function CD_Reset : Integer;
 Function CD_Status : Byte;
 Function CD_AudioStatus : Byte;
 Function CD_TrackInfo( var Min,Max: Byte ) : Integer;


IMPLEMENTATION

{$L CDROM.OBJ}

 Function CD_Init : Integer;                                   EXTERNAL;
 Function CD_Exit : Integer;                                   EXTERNAL;
 Function CD_Play( Track: Byte ) : Integer;                    EXTERNAL;
 Function CD_Stop : Integer;                                   EXTERNAL;
 Function CD_Resume : Integer;                                 EXTERNAL;
 Function CD_Reset : Integer;                                  EXTERNAL;
 Function CD_Status : Byte;                                    EXTERNAL;
 Function CD_AudioStatus : Byte;                               EXTERNAL;
 Function CD_TrackInfo( var Min,Max: Byte ) : Integer;         EXTERNAL;


END.