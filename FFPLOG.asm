***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*************************************************
*                  FFPLOG                       *
*       FAST FLOATING POINT LOGORITHM           *
*                                               *
*  INPUT:   D7 - INPUT ARGUMENT                 *
*                                               *
*  OUTPUT:  D7 - LOGORITHMIC RESULT TO BASE E   *
*                                               *
*     ALL OTHER REGISTERS TOTALLY TRANSPARENT   *
*                                               *
*  CODE SIZE: 184 BYTES   STACK WORK: 38 BYTES  *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF THE RESULT IS ZERO          *
*        N - SET IF RESULT IN IS NEGATIVE       *
*        V - SET IF INVALID NEGATIVE ARGUMENT   *
*            OR ZERO ARGUMENT                   *
*        C - UNDEFINED                          *
*        X - UNDEFINED                          *
*                                               *
*                                               *
*  NOTES:                                       *
*    1) SPOT CHECKS SHOW ERRORS BOUNDED BY      *
*       5 X 10**-8.                             *
*    2) NEGATIVE ARGUMENTS ARE ILLEGAL AND CAUSE*
*       THE "V" BIT TO BE SET AND THE ABSOLUTE  *
*       VALUE USED INSTEAD.                     *
*    3) A ZERO ARGUMENT RETURNS THE LARGEST     *
*       NEGATIVE VALUE POSSIBLE WITH THE "V" BIT*
*       SET.                                    *
*                                               *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)          *
*                                               *
*        TIMES ARE VERY DATA SENSITIVE WITH     *
*        SAMPLES RANGING FROM 170 TO 556        *
*        MICROSECONDS                           *
*                                               *
*************************************************

         XDEF      FFPLOG                        ENTRY POINT

         XREF      FFPHTHET                      HYPERTANGENT TABLE
         XREF      FFPADD,FFPDIV,FFPSUB,FFPMUL2  ARITHMETIC PRIMITIVES
         XREF      FFPTNORM                      TRANSCENDENTAL NORMALIZE ROUTINE

FPONE    EQU       $80000041           FLOATING VALUE FOR ONE
LOG2     EQU       $B1721840           LOG(2) = .6931471805

**************
* LOG ENTRY  *
**************

* INSURE ARGUMENT POSITIVE
FFPLOG   TST.B     D7                  ? TEST SIGN
         BEQ.S     FPLZRO              BRANCH ARGUMENT ZERO
         BPL.S     FPLOK               BRANCH ALRIGHT

* ARGUMENT IS NEGATIVE - USE THE ABSOLUTE VALUE AND SET THE "V" BIT
         AND.B     #$7F,D7             TAKE ABSOLUTE VALUE
         BSR.S     FPLOK               FIND LOG(ABS(X))
FPSETV   OR.B      #$02,CCR            SET OVERFLOW BIT
         RTS                           RETURN TO CALLER

* ARGUMENT IS ZERO - RETURN LARGEST NEGATIVE NUMBER WITH "V" BIT
FPLZRO   MOVE.L    #-1,D7              RETURN LARGEST NEGATIVE
         BRA.S     FPSETV              RETURN WITH "V" BIT SET

* SAVE WORK REGISTERS AND STRIP EXPONENT OFF
FPLOK    MOVEM.L   D1-D6/A0,-(SP)      SAVE ALL WORK REGISTERS
         MOVE.B    D7,-(SP)            SAVE ORIGINAL EXPONENT
         MOVE.B    #64+1,D7            FORCE BETWEEN 1 AND 2
         MOVE.L    #FPONE,D6           LOAD UP A ONE
         MOVE.L    D7,D2               COPY ARGUMENT
         BSR       FFPADD              CREATE ARG+1
         EXG.L     D7,D2               SWAP RESULT WITH ARGUMENT
         BSR       FFPSUB              CREATE ARG-1
         MOVE.L    D2,D6               PREPARE FOR DIVIDE
         BSR       FFPDIV              RESULT IS (ARG-1)/(ARG+1)
         BEQ.S     FPLNOCR             ZERO SO CORDIC NOT NEEDED
* CONVERT TO BIN(31,29) PRECISION
         SUB.B     #64+3,D7            ADJUST EXPONENT
         NEG.B     D7                  FOR SHIFT NECESSARY
         CMP.B     #31,D7              ? INSURE NOT TOO SMALL
         BLS.S     FPLSHF              NO, GO SHIFT
         MOVEQ     #0,D7               FORCE TO ZERO
FPLSHF   LSR.L     D7,D7               SHIFT TO BIN(31,29) PRECISION *** FBI: is this correct?

*****************************************
* CORDIC CALCULATION REGISTERS:         *
* D1 - LOOP COUNT   A0 - TABLE POINTER  *
* D2 - SHIFT COUNT                      *
* D3 - Y'   D5 - Y                      *
* D4 - X'   D6 - Z                      *
* D7 - X                                *
*****************************************

         MOVEQ     #0,D6               Z=0
         MOVE.L    #1<<29,D5           Y=1
         LEA       (FFPHTHET,PC),A0    TO INVERSE HYPERBOLIC TANGENT TABLE
         MOVEQ     #22,D1              LOOP 23 TIMES
         MOVEQ     #1,D2               PRIME SHIFT COUNTER
         BRA.S     CORDICg             ENTER CORDIC LOOP

* CORDIC LOOP
FPLPLSg  ASR.L     D2,D4               SHIFT(X')
         SUB.L     D4,D5               Y = Y - X'
         ADD.L     (A0),D6             Z = Z + HYPERTAN(I)
CORDICg  MOVE.L    D7,D4               X' = X
         MOVE.L    D5,D3               Y' = Y
         ASR.L     D2,D3               SHIFT(Y')
FPLNLPg  SUB.L     D3,D7               X = X - Y'
         BPL.S     FPLPLSg             BRANCH NEGATIVE
         MOVE.L    D4,D7               RESTORE X
         ADDQ.L    #4,A0               TO NEXT TABLE ENTRY
         ADDQ.B    #1,D2               INCREMENT SHIFT COUNT
         LSR.L     #1,D3               SHIFT(Y')
         DBRA      D1,FPLNLPg          AND LOOP UNTIL DONE

* NOW CONVERT TO FLOAT AND ADD EXPONENT*LOG(2) FOR FINAL RESULT
         MOVEQ     #0,D7               DEFAULT ZERO IF TOO SMALL
         BSR       FFPTNORM            FLOAT Z
         BEQ.S     FPLNOCR             BRANCH IF TOO SMALL
         ADDQ.B    #1,D6               TIMES TWO
         MOVE.L    D6,D7               SETUP IN D7 IN CASE EXP=0
FPLNOCR  MOVE.L    D7,D2               SAVE RESULT
         MOVEQ     #0,D6               PREPARE ORIGINAL EXPONENT LOAD
         MOVE.B    (SP)+,D6            LOAD IT BACK
         SUB.B     #64+1,D6            CONVERT EXPONENT TO BINARY
         BEQ.S     FPLZPR              BRANCH ZERO PARTIAL HERE
         MOVE.B    D6,D1               SAVE SIGN BYTE
         BPL.S     FPLPOS              BRANCH POSITIVE VALUE
         NEG.B     D6                  FORCE POSITIVE
FPLPOS   ROR.L     #8,D6               PREPARE TO CONVERT TO INTEGER
         MOVEQ     #$47,D5             SETUP EXPONENT MASK
FPLNORM  ADD.L     D6,D6               SHIFT TO LEFT
         DBMI      D5,FPLNORM          EXP-1 AND BRANCH IF NOT NORMALIZED
         MOVE.B    D5,D6               FIX IN EXPONENT
         AND.B     #$80,D1             EXTRACT SIGN
         OR.B      D1,D6               INSERT SIGN IN
         MOVE.L    #LOG2,D7            MULTIPLY EXPONENT BY LOG(2)
         BSR       FFPMUL2             MULTIPLY D6 AND D7
         MOVE.L    D2,D6               NOW ADD CORDIC RESULT
         BSR       FFPADD              FOR FINAL ANSWER

FPLZPR   MOVEM.L   (SP)+,D1-D6/A0      RESTORE REGISTERS
         RTS                           RETURN TO CALLER