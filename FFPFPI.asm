**************************************
* (C) COPYRIGHT 1980 BY MOTORLA INC. *
**************************************

***********************************************************
*            FAST FLOATING POINT TO INTEGER               *
*                                                         *
*      INPUT:  D7 = FAST FLOATING POINT NUMBER            *
*      OUTPUT: D7 = FIXED POINT INTEGER (2'S COMPLEMENT)  *
*                                                         *
*  CONDITION CODES:                                       *
*             N - SET IF RESULT IS NEGATIVE               *
*             Z - SET IF RESULT IS ZERO                   *
*             V - SET IF OVERFLOW OCCURRED                *
*             C - UNDEFINED                               *
*             X - UNDEFINED                               *
*                                                         *
*  REGISTER D5 IS DESTROYED                               *
*                                                         *
*  INTEGERS OF OVER 24 BIT PRECISION WILL BE IMPRECISE    *
*                                                         *
*  NOTE: MAXIMUM SIZE INTEGER RETURNED IF OVERFLOW        *
*                                                         *
*   CODE SIZE: 78 BYTES        STACK WORK AREA: 0 BYTES   *
*                                                         *
*      TIMINGS:  (8 MHZ NO WAIT STATES ASSUMED)           *
*           COMPOSITE AVERAGE 15.00 MICROSECONDS          *
*            ARG = 0   4.75 MICROSECONDS                  *
*            ARG # 0   10.50 - 18.25 MICROSECONDS         *
*                                                         *
***********************************************************

        XDEF      FFPFPI     ENTRY POINT


FFPFPI  MOVE.B    D7,D5          SAVE SIGN/EXPONENT                4
        BMI.S     FPIMI          BRANCH IF MINUS VALUE             8/10
        BEQ.S     FPIRTN         RETURN IF ZERO                    8/10
        CLR.B     D7             CLEAR FOR SHIFT                   4
        SUB.B     #65,D5         EXPONENT-1 TO BINARY              8
        BMI.S     FPIRT0         RETURN ZERO FOR FRACTION          8/10
        SUB.B     #31,D5         ? OVERFLOW                        8
        BPL.S     FPIOVP         BRANCH IF TOO LARGE               8/10
        NEG.B     D5             ADJUST FOR SHIFT                  4
        LSR.L     D5,D7          FINALIZE INTEGER                  8-70
FPIRTN  RTS                      RETURN TO CALLER                  16

* POSITIVE OVERFLOW
FPIOVP  MOVEQ     #-1,D7         LOAD ALL ONES
        LSR.L     #1,D7          PUT ZERO IN AS SIGN
        OR.B      #$02,CCR       SET OVERFLOW BIT ON
        RTS                      RETURN TO CALLER

* FRACTION ONLY RETURNS ZERO
FPIRT0  MOVEQ     #0,D7          RETURN ZERO
        RTS                      BACK TO CALLER

* INPUT IS A MINUS INTEGER
FPIMI   CLR.B     D7             CLEAR FOR CLEAN SHIFT                 4
        SUB.B     #$80+65,D5     EXPONENT-1 TO BINARY AND STRIP SIGN   8
        BMI.S     FPIRT0         RETURN ZERO FOR FRACTION              8/10
        SUB.B     #31,D5         ? OVERFLOW                            8
        BPL.S     FPICHM         BRANCH POSSIBLE MINUS OVERFLOW        8/10
        NEG.B     D5             ADJUST FOR SHIFT COUNT                4
        LSR.L     D5,D7          SHIFT TO PROPER MAGNITUDE             8-70
        NEG.L     D7             TO MINUS NOW                          6
        RTS                      RETURN TO CALLER                      16

* CHECK FOR MAXIMUM MINUS NUMBER OR MINUS OVERFLOW
FPICHM  BNE.S     FPIOVM         BRANCH MINUS OVERFLOW
        NEG.L     D7             ATTEMPT CONVERT TO NEGATIVE
        TST.L     D7             CLEAR OVERFLOW BIT
        BMI.S     FPIRTN         RETURN IF MAXIMUM NEGATIVE INTEGER
FPIOVM  MOVEQ     #0,D7          CLEAR D7
        BSET.L    #31,D7         SET HIGH BIT ON FOR MAXIMUM NEGATIVE
        OR.B      #$02,CCR       SET OVERFLOW BIT ON
        RTS                      AND RETURN TO CALLER