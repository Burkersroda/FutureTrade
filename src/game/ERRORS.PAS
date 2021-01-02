{$F+,I-,S-}
UNIT Errors;
INTERFACE
FUNCTION GetError(nr:BYTE):STRING;
IMPLEMENTATION
CONST err:ARRAY[1..46]OF STRING[33]=
            ((#1'Invalid function number'),
             (#2'File not found'),
             (#3'Path not found'),
             (#4'Too many open files'),
             (#5'File access denied'),
             (#6'Invalid file handle'),
             (#12'Invalid file access code'),
             (#15'Invalid drive number'),
             (#16'Cannot remove current directory'),
             (#17'Cannot rename across drives'),
             (#18'No more files'),
             (#100'Disk read error'),
             (#101'Disk write error'),
             (#102'File not assigned'),
             (#103'File not open'),
             (#104'File not open for input'),
             (#105'File not open for output'),
             (#106'Invalid numeric format'),
             (#150'Disk is write-protected'),
             (#151'Bad drive request struct length'),
             (#152'Drive not ready'),
             (#154'CRC error in data'),
             (#156'Disk seek error'),
             (#157'Unknown media type'),
             (#158'Sector not found'),
             (#159'Printer out of paper'),
             (#160'Device write fault'),
             (#161'Device read fault'),
             (#162'Hardware failure'),
             (#200'Division by zero'),
             (#201'Range check error'),
             (#202'Stack overflow error'),
             (#203'Heap overflow error'),
             (#204'Invalid pointer operation'),
             (#205'Floating point overflow'),
             (#206'Floating point underflow'),
             (#207'Invalid floating point operation'),
             (#208'Overlay manager not installed'),
             (#209'Overlay file read error'),
             (#210'Object not initialized'),
             (#211'Call to abstract method'),
             (#212'Stream registration error'),
             (#213'Collection index out of range'),
             (#214'Collection overflow error'),
             (#215'Arithmetic overflow error'),
             (#216'General Protection fault'));

FUNCTION GetError(nr:BYTE):STRING;
VAR by:BYTE;
BEGIN
  GetError:='';
  FOR by:=1 TO 46 DO IF nr=ORD(err[by,1]) THEN
   GetError:=Copy(err[by],2,LENGTH(err[by])-1);
END;
END.
