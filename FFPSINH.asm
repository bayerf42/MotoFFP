***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*************************************************
*            FFPSINH/FFPCOSH/FFPTANH            *
*       FAST FLOATING POINT HYPERBOLICS         *
*                                               *
*  INPUT:   D7 - FLOATING POINT ARGUMENT        *
*                                               *
*  OUTPUT:  D7 - HYPERBOLIC RESULT              *
*                                               *
*  !!!WRONG !!!!!!!!!!!!!!!!!!!!!!!!!!!         *
*  -->ALL OTHER REGISTERS ARE TRANSPARENT       *
*  REGISTER D3-D5 will be destroyed !!!!        *
*  HAVE TO SAVE D3-D5 AROUND CALLS              *
*                                               *
*  CODE SIZE:  36 BYTES   STACK WORK: 50 BYTES  *
*                                               *
*  CALLS: FFPEXP, FFPDIV, FFPADD AND FFPSUB     *
*                                               *
*  CONDITION CODES:                             *
*        Z - SET IF THE RESULT IS ZERO          *
*        N - SET IF THE RESULT IS NEGATIVE      *
*        V - SET IF OVERFLOW OCCURRED           *
*        C - UNDEFINED                          *
*        X - UNDEFINED                          *
*                                               *
*  NOTES:                                       *
*    1) AN OVERFLOW WILL PRODUCE THE MAXIMUM    *
*       SIGNED VALUE WITH THE "V" BIT SET.      *
*    2) SPOT CHECKS SHOW AT LEAST SEVEN DIGIT   *
*       PRECISION.                              *
*                                               *
*  TIME: (8MHZ NO WAIT STATES ASSUMED)          *
*                                               *
*        SINH  623 MICROSECONDS                 *
*        COSH  601 MICROSECONDS                 *
*        TANH  623 MICROSECONDS                 *
*                                               *
*************************************************

         XDEF      FFPSINH,FFPCOSH,FFPTANH       ENTRY POINTS

         XREF      FFPEXP,FFPDIV,FFPADD,FFPSUB   FUNCTIONS CALLED

FPONE    EQU       $80000041           FLOATING ONE

**********************************
*            FFPCOSH             *
*  THIS FUNCTION IS DEFINED AS   *
*            X    -X             *
*           E  + E               *
*           --------             *
*              2                 *
* WE EVALUATE EXACTLY AS DEFINED *
**********************************

FFPCOSH  MOVE.L    D6,-(SP)  SAVE OUR ONE WORK REGISTER
         AND.B     #$7F,D7   FORCE POSITIVE (RESULTS SAME BUT EXP FASTER)
         BSR       FFPEXP    EVALUATE E TO THE X
         BVS.S     FHCRTN    RETURN IF OVERFLOW (RESULT IS HIGHEST NUMBER)
         MOVE.L    D7,-(SP)  SAVE RESULT
         MOVE.L    D7,D6     SETUP FOR DIVIDE INTO ONE
         MOVE.L    #FPONE,D7 LOAD FLOATING POINT ONE
         BSR       FFPDIV    COMPUTE E TO -X AS THE INVERSE
         MOVE.L    (SP)+,D6  PREPARE TO ADD TOGETHER
         BSR       FFPADD    CREATE THE NUMERATOR
         SUBQ.B    #1,D7     DIVIDE BY TWO
FHCRTN   MOVEM.L   (SP)+,D6  RESTORE OUR WORK REGISTER (don't clear V flag)
         RTS                 RETURN TO CALLER WITH ANSWER

**********************************
*            FFPSINH             *
*  THIS FUNCTION IS DEFINED AS   *
*            X    -X             *
*           E  - E               *
*           --------             *
*              2                 *
* HOWEVER, WE EVALUATE IT VIA    *
* THE COSH FORMULA SINCE ITS     *
* ADDITION IN THE NUMERATOR      *
* IS SAFER THAN OUR SUBTRACTION  *
*                                *
* THUS THE FUNCTION BECOMES:     *
*            X                   *
*    SINH = E  - COSH            *
*                                *
**********************************

FFPSINH  MOVE.L    D6,-(SP)  SAVE OUR ONE WORK REGISTER
         BSR       FFPEXP    EVALUATE E TO THE X
         BNE.S     FHSCHOV   it's save to invert
         OR.B      #$02,CCR  signal overflow on large negative args
FHSCHOV  BVS.S     FHSRTN    RETURN IF OVERLOW FOR MAXIMUM VALUE
         MOVE.L    D7,-(SP)  SAVE RESULT
         MOVE.L    D7,D6     SETUP FOR DIVIDE INTO ONE
         MOVE.L    #FPONE,D7 LOAD FLOATING POINT ONE
         BSR       FFPDIV    COMPUTE E TO -X AS THE INVERSE
         MOVE.L    (SP),D6   PREPARE TO ADD TOGETHER
         BSR       FFPADD    CREATE THE NUMERATOR
         BEQ.S     FHSZRO    BRANCH IF ZERO RESULT
         SUBQ.B    #1,D7     DIVIDE BY TWO
         BVC.S     FHSZRO    BRANCH IF NO UNDERFLOW
         MOVEQ     #0,D7     ZERO IF UNDERFLOW
FHSZRO   MOVE.L    D7,D6     MOVE FOR FINAL SUBTRACT
         MOVE.L    (SP)+,D7  RELOAD E TO X AGAIN AND FREE
         BSR       FFPSUB    RESULT IS E TO X MINUS COSH
FHSRTN   MOVEM.L   (SP)+,D6  RESTORE OUR WORK REGISTER (don't clear V flag)
         RTS                 RETURN TO CALLER WITH ANSWER

**********************************
*            FFPTANH             *
*  THIS FUNCTION IS DEFINED AS   *
*  SINH/COSH WHICH REDUCES TO:   *
*            2X                  *
*           E  - 1               *
*           ------               *
*            2X                  *
*           E  + 1               *
*                                *
* WHICH WE EVALUATE.             *
**********************************

FFPTANH  MOVE.L    D6,-(SP)  SAVE OUR ONE WORK REGISTER
         TST.B     D7        ? ZERO
         BEQ.S     FFPTRTN   RETURN TRUE ZERO IF SO
         ADDQ.B    #1,D7     X TIMES TWO
         BVS.S     FFPTOVF   BRANCH IF OVERFLOW/UNDERFLOW
         BSR       FFPEXP    EVALUATE E TO THE 2X
         BVS.S     FFPTOVF2  BRANCH IF TOO LARGE
         MOVE.L    D7,-(SP)  SAVE RESULT
         MOVE.L    #FPONE,D6 LOAD FLOATING POINT ONE
         BSR       FFPADD    ADD 1 TO E**2X
         MOVE.L    D7,-(SP)  SAVE DENOMINATOR
         MOVE.L    4(SP),D7  NOW PREPARE TO SUBTRACT
         BSR       FFPSUB    CREATE NUMERATOR
         MOVE.L    (SP)+,D6  RESTORE DENOMINATOR
         BSR       FFPDIV    CREATE RESULT
         ADDQ.L    #4,SP     FREE E**2X OFF OF STACK
FFPTRTN  MOVE.L    (SP)+,D6  RESTORE OUR WORK REGISTER
         RTS                 RETURN TO CALLER WITH ANSWER

FFPTOVF  MOVE.L    #$80000082,D7 FLOAT ONE WITH EXPONENT OVER TO LEFT
         ROXR.B    #1,D7     SHIFT IN CORRECT SIGN
         BRA.S     FFPTRTN   AND RETURN

FFPTOVF2 MOVE.L    #FPONE,D7 RETURN +1 AS RESULT
         BRA.S     FFPTRTN
