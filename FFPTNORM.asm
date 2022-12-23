         XDEF      FFPTNORM

***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

******************************
*        FFPTNORM            *
* NORMALIZE BIN(29,31) VALUE *
*   AND CONVERT TO FLOAT     *
*                            *
* INPUT: D6 - INTERNAL FIXED *
* OUTPUT: D6 - FFP FLOAT     *
*         CC - REFLECT VALUE *
* NOTES:                     *
*  1) D4 IS DESTROYED.       *
*                            *
* TIME: (8MHZ NO WAIT STATE) *
*       ZERO  4.0 MICROSEC.  *
*   AVG ELSE 17.0 MICROSEC.  *
*                            *
******************************


FFPTNORM MOVEQ     #$42,D4             SETUP INITIAL EXPONENT
         TST.L     D6                  TEST FOR NON-NEGATIVE
         BEQ.S     FSFRTN              RETURN IF ZERO
         BPL.S     FSFPLS              BRANCH IS >= 0
         NEG.L     D6                  ABSOLUTIZE INPUT
         MOVE.B    #$C2,D4             SETUP INITIAL NEGATIVE EXPONENT
FSFPLS   CMP.L     #$00007FFF,D6       TEST FOR A SMALL NUMBER
         BHI.S     FSFCONT             BRANCH IF NOT SMALL
         SWAP.W    D6                  SWAP HALVES
         SUB.B     #16,D4              OFFSET BY 16 SHIFTS
FSFCONT  ADD.L     D6,D6               SHIFT ANOTHER BIT
         DBMI      D4,FSFCONT          SHIFT LEFT UNTIL NORMALIZED
         TST.B     D6                  ? SHOULD WE ROUND UP
         BPL.S     FSFNRM              NO, BRANCH ROUNDED
         ADD.L     #$100,D6            ROUND UP
         BCC.S     FSFNRM              BRANCH NO OVERFLOW
         ROXR.L    #1,D6               ADJUST BACK FOR BIT IN 31
         ADDQ.B    #1,D4               MAKE UP FOR LAST SHIFT RIGHT
FSFNRM   MOVE.B    D4,D6               INSERT SIGN+EXPONENT
FSFRTN   RTS                           RETURN TO CALLER
