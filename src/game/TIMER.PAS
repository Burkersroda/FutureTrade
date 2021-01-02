{...}
VAR ecpnt:POINTER;
{...}
{$F+}
PROCEDURE Timer;INTERRUPT;
BEGIN
  INLINE($9C);INLINE($FF/$1E/ecpnt);
  {...}
END;
{$F-}
{...}
BEGIN
  GETINTVEC($1C,ecpnt);
  SETINTVEC($1C,@Timer);
  {...}
  SETINTVEC($1C,ecpnt);
END.