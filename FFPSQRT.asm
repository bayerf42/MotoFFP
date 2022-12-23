*******************************************
* (C)  COPYRIGHT 1981 BY MOTOROLA INC.    *
*******************************************

********************************************
*           FFPSQRT SUBROUTINE             *
*                                          *
* INPUT:                                   *
*          D7 - FLOATING POINT ARGUMENT    *
*                                          *
* OUTPUT:                                  *
*          D7 - FLOATING POINT SQUARE ROOT *
*                                          *
* CONDITION CODES:                         *
*                                          *
*          N - CLEARED                     *
*          Z - SET IF RESULT IS ZERO       *
*          V - SET IF ARGUMENT WAS NEGATIVE*
*          C - CLEARED                     *
*          X - UNDEFINED                   *
*                                          *
*    REGISTERS D3 THRU D6 ARE VOLATILE     *
*                                          *
* CODE: 194 BYTES    STACK WORK: 4 BYTES   *
*                                          *
* NOTES:                                   *
*   1) NO OVERFLOWS OR UNDERFLOWS CAN      *
*      OCCUR.                              *
*   2) A NEGATIVE ARGUMENT CAUSES THE      *
*      ABSOLUTE VALUE TO BE USED AND THE   *
*      "V" BIT SET TO INDICATE THAT A      *
*      NEGATIVE SQUARE ROOT WAS ATTEMPTED. *
*                                          *
* TIMES:                                   *
* ARGUMENT ZERO         3.50 MICROSECONDS  *
* MINIMUM TIME > 0    187.50 MICROSECONDS  *
* AVERAGE TIME > 0    193.75 MICROSECONDS  *
* MAXIMUM TIME > 0    200.00 MICROSECONDS  *
********************************************

      XDEF   FFPSQRT   ENTRY POINT

* NEGATIVE ARGUMENT HANDLER
FPSINV   AND.B     #$7F,D7   TAKE ABSOLUTE VALUE
         BSR.S     FFPSQRT   FIND SQRT(ABS(X))
         OR.B      #$02,CCR  SET "V" BIT
         RTS                 RETURN TO CALLER

*********************
* SQUARE ROOT ENTRY *
*********************
FFPSQRT  MOVE.B    D7,D3     COPY S+EXPONENT OVER
         BEQ.S     FPSRTN    RETURN ZERO IF ZERO ARGUMENT
         BMI.S     FPSINV    NEGATIVE, REJECT WITH SPECIAL CONDITION CODES
         LSR.B     #1,D3     DIVIDE EXPONENT BY TWO
         BCC.S     FPSEVEN   BRANCH EXPONENT WAS EVEN
         ADDQ.B    #1,D3     ADJUST ODD VALUES UP BY ONE
         LSR.L     #1,D7     OFFSET ODD EXPONENT'S MANTISSA ONE BIT
FPSEVEN  ADD.B     #$20,D3   RENORMALIZE EXPONENT
         SWAP.W    D3        SAVE RESULT S+EXP FOR FINAL MOVE
         MOVE.W    #23,D3    SETUP LOOP FOR 24 BIT GENERATION
         LSR.L     #7,D7     PREPARE FIRST TEST VALUE
         MOVE.L    D7,D4     D4 - PREVIOUS VALUE DURING LOOP
         MOVE.L    D7,D5     D5 - NEW TEST VALUE DURING LOOP
         MOVE.L    A0,D6     SAVE ADDRESS REGISTER
         LEA       (FPSTBL,PC),A0 LOAD TABLE ADDRESS
         MOVE.L    #$00800000,D7 D7 - INITIAL RESULT (MUST BE A ONE)
         SUB.L     D7,D4     PRESET OLD VALUE IN CASE ZERO BIT NEXT
         SUB.L     #$01200000,D5 COMBINE FIRST LOOP CALCULATIONS
         BRA.S     FPSENT    GO ENTER LOOP CALCULATIONS

*                   SQUARE ROOT CALCULATION
* THIS IS AN OPTIMIZED SCHEME FOR THE RECURSIVE SQUARE ROOT ALGORITHM:
*
*  STEP N+1:
*     TEST VALUE <= .0  0  0  R  R  R  0 1  THEN GENERATE A ONE IN RESULT R
*                     N  2  1  N  2  1        ELSE A ZERO IN RESULT R      N+1
*                                                                    N+1
* PRECALCULATIONS ARE DONE SUCH THAT THE ENTRY IS MIDWAY INTO STEP 2

FPSONE   BSET      D3,D7     INSERT A ONE INTO THIS POSITION
         MOVE.L    D5,D4     UPDATE NEW TEST VALUE
FPSZERO  ADD.L     D4,D4     MULTIPLY TEST RESULT BY TWO
         MOVE.L    D4,D5     COPY IN CASE NEXT BIT ZERO
         SUB.L     (A0)+,D5  SUBTRACT THE '01' ENDING PATTERN
         SUB.L     D7,D5     SUBTRACT RESULT BITS COLLECTED SO FAR
FPSENT   DBMI      D3,FPSONE BRANCH IF A ONE GENERATED IN THE RESULT
         DBPL      D3,FPSZERO BRANCH IF A ZERO GENERATED

* ALL 24 BITS CALCULATED. NOW TEST RESULT OF 25TH BIT
         BLS.S     FPSFIN    BRANCH NEXT BIT ZERO, NO ROUNDING
         CMP.L     #$00FFFFFF,D7   INSURE NO OVERFLOW
         BEQ.S     FPSFIN    BRANCH MANTISSA ALL 1'S
         ADDQ.L    #1,D7     ROUND UP (CANNOT OVERFLOW)
FPSFIN   LSL.L     #8,D7     NORMALIZE RESULT
         MOVE.L    D6,A0     RESTORE ADDRESS REGISTER
         SWAP.W    D3        RESTORE S+EXP SAVE
         MOVE.B    D3,D7     MOVE IN FINAL SIGN+EXPONENT
FPSRTN   RTS                 RETURN TO CALLER

* TABLE TO FURNISH '01' SHIFTS DURING THE ALGORITHM LOOP
FPSTBL   DC.L      1<<20,1<<19,1<<18,1<<17,1<<16,1<<15
         DC.L      1<<14,1<<13,1<<12,1<<11,1<<10,1<<9,1<<8
         DC.L      1<<7,1<<6,1<<5,1<<4,1<<3,1<<2,1<<1,1<<0
         DC.L      0,0

