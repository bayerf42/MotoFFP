***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*************************************************
*                  FFPEXP                       *
*       FAST FLOATING POINT EXPONENT            *
*                                               *
*  INPUT:   D7 - INPUT ARGUMENT                 *
*                                               *
*  OUTPUT:  D7 - EXPONENTIAL RESULT             *
*                                               *
*     ALL OTHER REGISTERS ARE TRANSPARENT       *
*                                               *
*  CODE SIZE: 256 BYTES   STACK WORK: 34 BYTES  *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF RESULT IN D7 IS ZERO        *
*        N - CLEARED                            *
*        V - SET IF OVERLOW OCCURRED            *
*        C - UNDEFINED                          *
*        X - UNDEFINED                          *
*                                               *
*                                               *
*  NOTES:                                       *
*    1) AN OVERFLOW RETURNS THE LARGEST         *
*       MAGNITUDE NUMBER.                       *
*    2) SPOT CHECKS SHOW AT LEAST 6.8 DIGIT     *
*       ACCURACY FOR ALL ABS(ARG) < 30.         *
*                                               *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)          *
*                                               *
*              488 MICROSECONDS                 *
*                                               *
*  LOGIC:   1) FIND N = INT(ARG/LN 2).  THIS IS *
*              ADDED TO THE MANTISSA AT THE END.*
*           3) REDUCE ARGUMENT TO RANGE BY      *
*              FINDING ARG = MOD(ARG, LN 2).    *
*           4) DERIVE EXP(ARG) WITH CORDIC LOOP.*
*           5) ADD N TO EXPONENT GIVING RESULT. *
*                                               *
*************************************************

         XDEF      FFPEXP              ENTRY POINT

         XREF      FFPHTHET            HYPERTANGENT TABLE

         XREF      FFPMUL2,FFPSUB      ARITHMETIC PRIMITIVES
         XREF      FFPTNORM            TRANSCENDENTAL NORMALIZE ROUTINE

LN2      EQU       $B1721840           LN 2 (BASE E)             .693147180
LN2INV   EQU       $B8AA3B41           INVERSE OF LN 2 (BASE E) 1.44269504
CNJKHINV EQU       $9A8F4441           FLOATING CONJUGATE OF K INVERSE
*                                      CORRECTED FOR THE EXTRA CONVERGENCE
*                                      DURING SHIFTS FOR 4 AND 13
KFCTSEED EQU       $26A3D100           K CORDIC SEED


* OVERFLOW - RETURN ZERO OR HIGHEST VALUE AND "V" BIT
FPEOVFLW MOVE.W    (SP)+,D6            LOAD SIGN WORD AND WORK OFF STACK
         TST.B     D6                  ? WAS ARGUMENT NEGATIVE
         BPL.S     FPOVNZRO            NO, CONTINUE
         MOVEQ     #0,D7               RETURN A ZERO
         BRA.S     FPOVRTN             AS RESULT IS TOO SMALL
FPOVNZRO MOVEQ     #-1,D7              SET ALL ZEROES
         LSR.B     #1,D7               ZERO SIGN BIT
         OR.B      #$02,CCR            SET OVERFLOW BIT
FPOVRTN  MOVEM.L   (SP)+,D1-D6/A0      RESTORE REGISTERS
         RTS                           RETURN TO CALLER

* RETURN ONE FOR ZERO ARGUMENT
FFPE1    MOVE.L    #$80000041,D7       RETURN A TRUE ONE
         LEA       7*4+2(SP),SP        IGNORE STACK SAVES
         TST.B     D7                  SET CONDITION CODE PROPERLY
         RTS                           RETURN TO CALLER

**************
* EXP ENTRY  *
**************

* SAVE WORK REGISTERS AND INSURE POSITIVE ARGUMENT
FFPEXP   MOVEM.L   D1-D6/A0,-(SP)      SAVE ALL WORK REGISTERS
         MOVE.W    D7,-(SP)            SAVE SIGN IN LOW ORDER BYTE FOR LATER
         BEQ.S     FFPE1               RETURN A TRUE ONE FOR ZERO EXPONENT
         AND.B     #$7F,D7             TAKE ABSOLUTE VALUE

* DIVIDE BY LOG 2 BASE E FOR PARTIAL RESULT
FPEPOS   MOVE.L    D7,D2               SAVE ORIGINAL ARGUMENT
         MOVE.L    #LN2INV,D6          LOAD INVERSE TO MULTIPLY (FASTER)
         BSR       FFPMUL2             OBTAIN DIVISION THRU MULTIPLY
         BVS       FPEOVFLW            BRANCH IF TOO LARGE
* CONVERT QUOTIENT TO BOTH FIXED AND FLOAT INTEGER
         MOVE.B    D7,D5               COPY EXPONENT OVER
         MOVE.B    D7,D6               COPY EXPONENT OVER
         SUB.B     #64+32,D5           FIND NON-FRACTIONAL PRECISION
         NEG.B     D5                  MAKE POSITIVE
         CMP.B     #24,D5              ? INSURE NOT TOO LARGE
         BLE.S     FPEOVFLW            BRANCH TOO LARGE
         CMP.B     #32,D5              ? TEST UPPER RANGE
         BGE.S     FPESML              BRANCH LESS THAN ONE
         LSR.L     D5,D7               SHIFT TO INTEGER
         MOVE.B    D7,(SP)             PLACE ADJUSTED EXPONENT WITH SIGN BYTE
         LSL.L     D5,D7               BACK TO NORMAL WITHOUT FRACTION
         MOVE.B    D6,D7               RE-INSERT SIGN+EXPONENT
         MOVE.L    #LN2,D6             MULTIPLY BY LN2 TO FIND RESIDUE
         BSR       FFPMUL2             MULTIPLY BACK OUT
         MOVE.L    D7,D6               SETUP TO SUBTRACT MULTIPLE OF LN 2
         MOVE.L    D2,D7               MOVE ARGUMENT IN
         BSR       FFPSUB              FIND REMAINDER OF LN 2 DIVIDE
         MOVE.L    D7,D2               COPY FLOAT ARGUMENT
         BRA.S     FPEADJ              ADJUST TO FIXED

* MULTIPLE LESS THAN ONE
FPESML   CLR.B     (SP)                DEFAULT INITIAL MULTIPLY TO ZERO
         MOVE.L    D2,D7               BACK TO ORIGINAL ARGUMENT

* CONVERT ARGUMENT TO BINARY(31,29) PRECISION
FPEADJ   CLR.B     D7                  CLEAR SIGN AND EXPONENT
         SUB.B     #64+3,D2            OBTAIN SHIFT VALUE
         NEG.B     D2                  FOR 2 NON-FRACTION BITS
         CMP.B     #31,D2              INSURE NOT TOO SMALL
         BLS.S     FPESHF              BRANCH TO SHIFT IF OK
         MOVEQ     #0,D7               FORCE TO ZERO
FPESHF   LSR.L     D2,D7               CONVERT TO FIXED POINT

*****************************************
* CORDIC CALCULATION REGISTERS:         *
* D1 - LOOP COUNT   A0 - TABLE POINTER  *
* D2 - SHIFT COUNT                      *
* D3 - Y'   D5 - Y                      *
* D4 - X'   D6 - X                      *
* D7 - TEST ARGUMENT                    *
*****************************************

* INPUT WITHIN RANGE, NOW START CORDIC SETUP
FPECOM   MOVEQ     #0,D5               Y=0
         MOVE.L    #KFCTSEED,D6        X=1 WITH JKHINVERSE FACTORED OUT
         LEA       (FFPHTHET,PC),A0    POINT TO HPERBOLIC TANGENT TABLE
         MOVEQ     #0,D2               PRIME SHIFT COUNTER

* PERFORM CORDIC LOOP REPEATING SHIFTS 4 AND 13 TO GUARANTEE CONVERGENCE
* (REF. "A UNIFIED ALGORITHM FOR ELEMENTARY FUNCTIONS" J.S.WALTHER
*        PG. 380 SPRING JOINT COMPUTER CONFERENCE 1971)
         MOVEQ     #3,D1               DO SHIFTS 1 THRU 4
         BSR.S     CORDICx             FIRST CORDIC LOOPS
         SUBQ.L    #4,A0               REDO TABLE ENTRY
         SUBQ.W    #1,D2               REDO SHIFT COUNT
         MOVEQ     #9,D1               DO FOUR THROUGH 13
         BSR.S     CORDICx             SECOND CORDIC LOOPS
         SUBQ.L    #4,A0               BACK TO ENTRY 13
         SUBQ.W    #1,D2               REDO SHIFT FOR 13
         MOVEQ     #10,D1              NOW 13 THROUGH 23
         BSR.S     CORDICx             AND FINISH UP

* NOW FINALIZE THE RESULT
         TST.B     1(SP)               TEST ORIGINAL SIGN
         BPL.S     FSEPOS              BRANCH POSITIVE ARGUMENT
         NEG.L     D5                  CHANGE Y FOR SUBTRACTION
         NEG.B     (SP)                NEGATE ADJUSTED EXPONENT TO SUBTRACT
FSEPOS   ADD.L     D5,D6               ADD OR SUBTRACT Y TO/FROM X
         BSR       FFPTNORM            FLOAT X
         MOVE.L    D6,D7               SETUP RESULT
* ADD LN2 FACTOR INTEGER TO THE EXPONENT
         ADD.B     (SP),D7             ADD TO EXPONENT
         BMI       FPEOVFLW            BRANCH IF TOO LARGE
         BEQ       FPEOVFLW            BRANCH IF TOO SMALL
         ADDQ.L    #2,SP               RID WORK DATA OFF STACK
         MOVEM.L   (SP)+,D1-D6/A0      RESTORE REGISTERS
         RTS                           RETURN TO CALLER

*************************
* CORDIC LOOP SUBROUTINE*
*************************
CORDICx  ADDQ.W    #1,D2               INCREMENT SHIFT COUNT
         MOVE.L    D5,D3               COPY Y
         MOVE.L    D6,D4               COPY X
         ASR.L     D2,D3               SHIFT FOR Y'
         ASR.L     D2,D4               SHIFT FOR X'
         TST.L     D7                  TEST ARG VALUE
         BMI.S     FEBMI               BRANCH MINUS TEST
         ADD.L     D4,D5               Y=Y+X'
         ADD.L     D3,D6               X=X+Y'
         SUB.L     (A0)+,D7            ARG=ARG-TABLE(N)
         DBRA      D1,CORDICx          LOOP UNTIL DONE
         RTS                           RETURN

FEBMI    SUB.L     D4,D5               Y=Y-X'
         SUB.L     D3,D6               X=X-Y'
         ADD.L     (A0)+,D7            ARG=ARG+TABLE(N)
         DBRA      D1,CORDICx          LOOP UNTIL DONE
         RTS                           RETURN
