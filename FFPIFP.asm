************************************
* (C) COPYRIGHT 1980 MOTORLA INC.  *
************************************

***********************************************************
*               INTEGER TO FLOATING POINT                 *
*                                                         *
*      INPUT: D7 = FIXED POINT INTEGER (2'S COMPLEMENT)   *
*      OUTPUT: D7 = FAST FLOATING POINT EQUIVALENT        *
*                                                         *
*      CONDITION CODES:                                   *
*                N - SET IF RESULT IS NEGATIVE            *
*                Z - SET IF RESULT IS ZERO                *
*                V - CLEARED                              *
*                C - UNDEFINED                            *
*                X - UNDEFINED                            *
*                                                         *
*      D5 IS DESTROYED                                    *
*                                                         *
*      INTEGERS OF GREATER THAN 24 BITS WILL BE ROUNDED   *
*      AND IMPRECISE.                                     *
*                                                         *
*      CODE SIZE: 56 BYTES      STACK WORK AREA: 0 BYTES  *
*                                                         *
*      TIMINGS: (8MHZ NO WAIT STATES ASSUMED)             *
*         COMPOSITE AVERATE 31.75 MICROSECONDS            *
*            ARG = 0   4.25          MICROSECONDS         *
*            ARG > 0   13.75 - 47.50 MICROSECONDS         *
*            ARG < 0   15.50 - 50.25 MICROSECONDS         *
*                                                         *
***********************************************************
      XDEF    FFPIFP      EXTERNAL NAME


FFPIFP   MOVEQ   #64+31,D5  SETUP HIGH END EXPONENT
         TST.L   D7         ? INTEGER A ZERO
         BEQ.S   ITORTN     RETURN SAME RESULT IF SO
         BPL.S   ITOPLS     BRANCH IF POSITIVE INTEGER
         MOVEQ   #-32,D5    SETUP NEGATIVE HIGH EXPONENT -#80+64+32
         NEG.L   D7         FIND POSITIVE VALUE
         BVS.S   ITORTI     BRANCH MAXIMUM NEGATIVE NUMBER
         SUBQ.B  #1,D5      ADJUST FOR EXTRA ZERO BIT
ITOPLS   CMP.L   #$00007FFF,D7 ? POSSIBLE 17 BITS ZERO
         BHI.S   ITOLP      BRANCH IF NOT
         SWAP.W  D7         QUICK SHIFT BY SWAP
         SUB.B   #16,D5     DEDUCT 16 SHIFTS FROM EXPONENT
ITOLP    ADD.L   D7,D7      SHIFT MANTISSA UP
         DBMI    D5,ITOLP   LOOP UNTIL NORMALIZED
         TST.B   D7         ? TEST FOR ROUND UP
         BPL.S   ITORTI     BRANCH NO ROUNDING NEEDED
         ADD.L   #$100,D7   ROUND UP
         BCC.S   ITORTI     BRANCH NO OVERFLOW
         ROXR.L  #1,D7      ADJUST DOWN ONE BIT
         ADDQ.B  #1,D5      REFLECT RIGHT SHIFT IN EXPONENT BIAS
ITORTI   MOVE.B  D5,D7      INSERT SIGN/EXPONENT
ITORTN   RTS                RETURN TO CALLER