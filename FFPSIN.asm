***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*************************************************
*        FFPSIN FFPCOS FFPTAN FFPSINCS          *
*     FAST FLOATING POINT SINE/COSINE/TANGENT   *
*                                               *
*  INPUT:   D7 - INPUT ARGUMENT (RADIAN)        *
*                                               *
*  OUTPUT:  D7 - FUNCTION RESULT                *
*           (FFPSINCS ALSO RETURNS D6)          *
*                                               *
*     ALL OTHER REGISTERS TOTALLY TRANSPARENT   *
*                                               *
*  CODE SIZE: 334 BYTES   STACK WORK: 38 BYTES  *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF RESULT IN D7 IS ZERO        *
*        N - SET IF RESULT IN D7 IS NEGATIVE    *
*        C - UNDEFINED                          *
*        V - SET IF RESULT IS MEANINGLESS       *
*            (INPUT MAGNITUDE TOO LARGE)        *
*        X - UNDEFINED                          *
*                                               *
*  FUNCTIONS:                                   *
*             FFPSIN   -  SINE RESULT           *
*             FFPCOS   -  COSINE RESULT         *
*             FFPTAN   -  TANGENT RESULT        *
*             FFPSINCS -  BOTH SINE AND COSINE  *
*                         D6 - SIN, D7 - COSINE *
*                                               *
*  NOTES:                                       *
*    1) INPUT VALUES ARE IN RADIANS.            *
*    2) FUNCTION FFPSINCS RETURNS BOTH SINE     *
*       AND COSINE TWICE AS FAST AS CALCULATING *
*       THE TWO FUNCTIONS INDEPENDENTLY FOR     *
*       THE SAME VALUE.  THIS IS HANDY FOR      *
*       GRAPHICS PROCESSING.                    *
*    2) INPUT ARGUMENTS LARGER THAN TWO PI      *
*       SUFFER REDUCED PRECISION.  THE LARGER   *
*       THE ARGUMENT, THE SMALLER THE PRECISION.*
*       EXCESSIVELY LARGE ARGUMENTS WHICH HAVE  *
*       LESS THAN 5 BITS OF PRECISION ARE       *
*       RETURNED UNCHANGED WITH THE "V" BIT SET.*
*    3) FOR TANGENT ANGLES OF INFINITE VALUE    *
*       THE LARGEST POSSIBLE POSITIVE NUMBER    *
*       IS RETURNED ($FFFFFF7F). THIS STILL     *
*       GIVES RESULTS WELL WITHIN SINGLE        *
*       PRECISION CALCULATION.                  *
*    4) SPOT CHECKS SHOW ERRORS BOUNDED BY      *
*       4 X 10**-7 BUT FOR ARGUMENTS CLOSE TO   *
*       PI/2 INTERVALS WHERE 10**-5 IS SEEN.    *
*                                               *
*  TIME: (8MHZ NO WAIT STATES AND ARGUMENT      *
*         ASSUMED WITHIN +-PI)                  *
*                                               *
*           FFPSIN       413 MICROSECONDS       *
*           FFPCOS       409 MICROSECONDS       *
*           FFPTAN       501 MICROSECONDS       *
*           FFPSINCS     420 MICROSECONDS       *
*************************************************

         XDEF      FFPSIN,FFPCOS,FFPTAN,FFPSINCS ENTRY POINTS

         XREF      FFPTHETA                      INVERSE TANGENT TABLE

         XREF      FFPMUL2,FFPDIV,FFPSUB         MULTIPLY, DIVIDE AND SUBTRACT
         XREF      FFPTNORM                      TRANSCENDENTAL NORMALIZE ROUTINE

PI       EQU       $C90FDB42          FLOATING CONSTANT PI
FIXEDPI  EQU       $C90FDAA2          PI SKELETON TO 32 BITS PRECISION
INV2PI   EQU       $A2F9833E          INVERSE OF TWO-PI
KINV     EQU       $9B74EE40          FLOATING K INVERSE
NKFACT   EQU       $EC916240          NEGATIVE K INVERSE

********************************************
* ENTRY FOR RETURNING BOTH SINE AND COSINE *
********************************************
FFPSINCS MOVE.W    #-2,-(SP)           FLAG BOTH SINE AND COSINE WANTED
         BRA.S     FPSCOM              ENTER COMMON CODE

**********************
* TANGENT ENTRY POINT*
**********************
FFPTAN   MOVE.W    #-1,-(SP)           FLAG TANGENT WITH MINUS VALUE
         BRA.S     FPSCHL              CHECK VERY SMALL VALUES

**************************
* COSINE ONLY ENTRY POINT*
**************************
FFPCOS   MOVE.W    #1,-(SP)            FLAG COSINE WITH POSITIVE VALUE
         BRA.S     FPSCOM              ENTER COMMON CODE

* NEGATIVE SINE/TANGENT SMALL VALUE CHECK
FPSCHM   CMP.B     #$80+$40-8,D7       ? LESS OR SAME AS -2**-9
         BHI.S     FPSCOM              CONTINUE IF NOT TOO SMALL
* RETURN ARGUMENT
FPSRTI   ADDQ.L    #2,SP               RID INTERNAL PARAMETER
         TST.B     D7                  SET CONDITION CODES
         RTS                           RETURN TO CALLER

************************
* SINE ONLY ENTRY POINT*
************************
FFPSIN   CLR.W     -(SP)               FLAG SINE WITH ZERO
* SINE AND TANGENT VALUES < 2**-9 RETURN IDENTITIES
FPSCHL   TST.B     D7                  TEST SIGN
         BMI.S     FPSCHM              BRANCH MINUS
         CMP.B     #$40-8,D7           ? LESS OR SAME THAN 2**-9
         BLS.S     FPSRTI              RETURN IDENTITY

* SAVE REGISTERS AND INSURE INPUT WITHIN + OR - PI RANGE
FPSCOM   MOVEM.L   D1-D6/A0,-(SP)      SAVE ALL WORK REGISTERS
         MOVE.L    D7,D2               COPY INPUT OVER
         ADD.B     D7,D7               RID SIGN BIT
         CMP.B     #(64+5)<<1,D7       ? ABS(ARG) < 2**6 (32)
         BLS.S     FPSNLR              BRANCH YES, NOT TOO LARGE
* ARGUMENT IS TOO LARGE TO SUBTRACT TO WITHIN RANGE
         CMP.B     #(64+20)<<1,D7      ? TEST EXCESSIVE SIZE (>2**20)
         BLS.S     FPSGPR              NO, GO AHEAD AND USE
* ERROR - ARGUMENT SO LARGE RESULT HAS NO PRECISION
         OR.B      #$02,CCR            FORCE V BIT ON
         MOVEM.L   (SP)+,D1-D6/A0      RESTORE REGISTERS
         ADDQ.L    #2,SP               CLEAN INTERNAL ARGUMENT OFF STACK
         RTS                           RETURN TO CALLER

* WE MUST FIND MOD(ARG,TWOPI) SINCE ARGUMENT IS TOO LARGE FOR
SUBTRACTIONS
FPSGPR   MOVE.L    #INV2PI,D6          LOAD UP 2*PI INVERSE CONSTANT
         MOVE.L    D2,D7               COPY OVER INPUT ARGUMENT
         BSR       FFPMUL2             DIVIDE BY TWOPI (VIA MULTIPLY INVERSE)
* CONVERT QUOTIENT TO FLOAT INTEGER
         MOVE.B    D7,D5               COPY EXPONENT OVER
         AND.B     #$7F,D5             RID SIGN FROM EXPONENT
         SUB.B     #64+24,D5           FIND FRACTIONAL PRECISION
         NEG.B     D5                  MAKE POSITIVE
         MOVEQ     #-1,D4              SETUP MASK OF ALL ONES
         CLR.B     D4                  START ZEROES AT LOW BYTE
         LSL.L     D5,D4               SHIFT ZEROES INTO FRACTIONAL PART
         OR.B      #$FF,D4             DO NOT REMOVE SIGN AND EXPONENT
         AND.L     D4,D7               STRIP FRACTIONAL BITS ENTIRELY
         MOVE.L    #PI+1,D6            LOAD UP 2*PI CONSTANT
         BSR       FFPMUL2             MULTIPLY BACK OUT
         MOVE.L    D7,D6               SETUP TO SUBTRACT MULTIPLE OF TWOPI
         MOVE.L    D2,D7               MOVE ARGUMENT IN
         BSR       FFPSUB              FIND REMAINDER OF TWOPI DIVIDE
         MOVE.L    D7,D2               USE IT AS NEW INPUT ARGUMENT

* CONVERT ARGUMENT TO BINARY(31,26) PRECISION FOR REDUCTION WITHIN +-PI
FPSNLR   MOVE.L    #FIXEDPI>>4,D4      LOAD PI
         MOVE.L    D2,D7               COPY FLOAT ARGUMENT
         CLR.B     D7                  CLEAR SIGN AND EXPONENT
         TST.B     D2                  TEST SIGN
         BMI.S     FPSNMI              BRANCH NEGATIVE
         SUB.B     #64+6,D2            OBTAIN SHIFT VALUE
         NEG.B     D2                  FOR 5 BIT NON-FRACTION BITS
         CMP.B     #31,D2              ? VERY SMALL NUMBER
         BLS.S     FPSSH1              NO, GO AHEAD AND SHIFT
         MOVEQ     #0,D7               FORCE TO ZERO
FPSSH1   LSR.L     D2,D7               CONVERT TO FIXED POINT
* FORCE TO +PI OR BELOW
FPSPCK   CMP.L     D4,D7               ? GREATER THAN PI
         BLE.S     FPSCKM              BRANCH NOT
         SUB.L     D4,D7               SUBTRACT
         SUB.L     D4,D7               .  TWOPI
         BRA.S     FPSPCK              AND CHECK AGAIN

FPSNMI   SUB.B     #$80+64+6,D2        RID SIGN AND GET SHIFT VALUE
         NEG.B     D2                  FOR 5 NON-FRACTIONAL BITS
         CMP.B     #31,D2              ? VERY SMALL NUMBER
         BLS.S     FPSSH2              NO, GO AHEAD AND SHIFT
         MOVEQ     #0,D7               FORCE TO ZERO
FPSSH2   LSR.L     D2,D7               CONVERT TO FIXED POINT
         NEG.L     D7                  MAKE NEGATIVE
         NEG.L     D4                  MAKE -PI
* FORCE TO -PI OR ABOVE
FPSNCK   CMP.L     D4,D7               ? LESS THAN -PI
         BGE.S     FPSCKM              BRANCH NOT
         SUB.L     D4,D7               ADD
         SUB.L     D4,D7               .  TWOPI
         BRA.S     FPSNCK              AND CHECK AGAIN

*****************************************
* CORDIC CALCULATION REGISTERS:         *
* D1 - LOOP COUNT   A0 - TABLE POINTER  *
* D2 - SHIFT COUNT                      *
* D3 - X'   D5 - X                      *
* D4 - Y'   D6 - Y                      *
* D7 - TEST ARGUMENT                    *
*****************************************

* INPUT WITHIN RANGE, NOW START CORDIC SETUP
FPSCKM   MOVE.L    #0,D5               X=0
         MOVE.L    #NKFACT,D6          Y=NEGATIVE INVERSE K FACTOR SEED
         MOVE.L    #FIXEDPI>>2,D4      SETUP FIXED PI/2 CONSTANT
         ASL.L     #3,D7               NOW TO BINARY(31,29) PRECISION
         BMI.S     FPSAP2              BRANCH IF MINUS TO ADD PI/2
         NEG.L     D6                  Y=POSITIVE INVERSE K FACTOR SEED
         NEG.L     D4                  SUBTRACT PI/2 FOR POSITIVE ARGUMENT
FPSAP2   ADD.L     D4,D7               ADD CONSTANT
         LEA       (FFPTHETA,PC),A0    LOAD ARCTANGENT TABLE
         MOVEQ     #23,D1              LOOP 24 TIMES
         MOVEQ     #-1,D2              PRIME SHIFT COUNTER
* CORDIC LOOP
FSINLP   ADDQ.W    #1,D2               INCREMENT SHIFT COUNT
         MOVE.L    D5,D3               COPY X
         MOVE.L    D6,D4               COPY Y
         ASR.L     D2,D3               SHIFT FOR X'
         ASR.L     D2,D4               SHIFT FOR Y'
         TST.L     D7                  TEST ARG VALUE
         BMI.S     FSBMI               BRANCH MINUS TEST
         SUB.L     D4,D5               X=X-Y'
         ADD.L     D3,D6               Y=Y+X'
         SUB.L     (A0)+,D7            ARG=ARG-TABLE(N)
         DBRA      D1,FSINLP           LOOP UNTIL DONE
         BRA.S     FSCOM               ENTER COMMON CODE
FSBMI    ADD.L     D4,D5               X=X+Y'
         SUB.L     D3,D6               Y=Y-X'
         ADD.L     (A0)+,D7            ARG=ARG+TABLE(N)
         DBRA      D1,FSINLP           LOOP UNTIL DONE

* NOW SPLIT UP TANGENT AND FFPSINCS FROM SINE AND COSINE
FSCOM    MOVE.W    7*4(SP),D1          RELOAD INTERNAL PARAMETER
         BPL.S     FSSINCOS            BRANCH FOR SINE OR COSINE

         ADDQ.B    #1,D1               SEE IF WAS -1 FOR TANGENT
         BNE.S     FSDUAL              NO, MUST BE BOTH SIN AND COSINE
* TANGENT FINISH
         BSR.S     FSFLOAT             FLOAT Y (SIN)
         MOVE.L    D6,D7               SETUP FOR DIVIDE INTO
         MOVE.L    D5,D6               PREPARE X
         BSR.S     FSFLOAT             FLOAT X (COS)
         BEQ.S     FSTINF              BRANCH INFINITE RESULT
         BSR       FFPDIV              TANGENT = SIN/COS
FSINFRT  MOVEM.L   (SP)+,D1-D6/A0      RESTORE REGISTERS
         ADDQ.L    #2,SP               DELETE INTERNAL PARAMETER
         RTS                           RETURN TO CALLER
* TANGENT IS INFINITE. RETURN MAXIMUM POSITIVE NUMBER.
FSTINF   MOVE.L    #$FFFFFF7F,D7       LARGEST FFP NUMBER
         BRA.S     FSINFRT             AND CLEAN UP

* SINE AND COSINE
FSSINCOS BEQ.S     FSSINE              BRANCH IF SINE
         MOVE.L    D5,D6               USE X FOR COSINE
FSSINE   BSR.S     FSFLOAT             CONVERT TO FLOAT
         MOVE.L    D6,D7               RETURN RESULT
         TST.B     D7                  AND CONDITION CODE TEST
         MOVEM.L   (SP)+,D1-D6/A0      RESTORE REGISTERS
         ADDQ.L    #2,SP               DELETE INTERNAL PARAMETER
         RTS                           RETURN TO CALLER

* BOTH SINE AND COSINE
FSDUAL   MOVE.L    D5,-(SP)            SAVE COSINE DERIVITIVE
         BSR.S     FSFLOAT             CONVERT SINE DERIVITIVE TO FLOAT
         MOVE.L    D6,6*4(SP)          PLACE SINE INTO SAVED D6
         MOVE.L    (SP)+,D6            RESTORE COSINE DERIVITIVE
         BRA.S     FSSINE              AND CONTINUE RESTORING SINE ON THE SLY

* FSFLOAT - FLOAT INTERNAL PRECISION BUT TRUNCATE TO ZERO IF < 2**-21
FSFLOAT  MOVE.L    D6,D4               COPY INTERNAL PRECISION VALUE
         BMI.S     FSFNEG              BRANCH NEGATIVE
         CMP.L     #$000000FF,D6       ? TEST MAGNITUDE
         BHI       FFPTNORM            NORMALIZE IF NOT TOO SMALL
FSFZRO   MOVEQ     #0,D6               RETURN A ZERO
         RTS                           RETURN TO CALLER
FSFNEG   ASR.L     #8,D4               SEE IF ALL ONES BITS 8-31
         ADDQ.L    #1,D4               ? GOES TO ZERO
         BNE       FFPTNORM            NORMALIZE IF NOT TOO SMALL
         BRA.S     FSFZRO              RETURN ZERO
