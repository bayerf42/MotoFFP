***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

*************************************************************
*                      FFPCMP                               *
*              FAST FLOATING POINT COMPARE                  *
*                                                           *
*  INPUT:  D6 - FAST FLOATING POINT ARGUMENT (SOURCE)       *
*          D7 - FAST FLOATING POINT ARGUMENT (DESTINATION)  *
*                                                           *
*  OUTPUT: CONDITION CODE REFLECTING THE FOLLOWING BRANCHES *
*          FOR THE RESULT OF COMPARING THE DESTINATION      *
*          MINUS THE SOURCE:                                *
*                                                           *
*                  GT - DESTINATION GREATER                 *
*                  GE - DESTINATION GREATER OR EQUAL TO     *
*                  EQ - DESTINATION EQUAL                   *
*                  NE - DESTINATION NOT EQUAL               *
*                  LT - DESTINATION LESS THAN               *
*                  LE - DESTINATION LESS THAN OR EQUAL TO   *
*                                                           *
*      CONDITION CODES:                                     *
*              N - CLEARED                                  *
*              Z - SET IF RESULT IS ZERO                    *
*              V - CLEARED                                  *
*              C - UNDEFINED                                *
*              X - UNDEFINED                                *
*                                                           *
*               ALL REGISTERS TRANSPARENT                   *
*                                                           *
*************************************************************

         XDEF      FFPCMP    FAST FLOATING POINT COMPARE

***********************
* COMPARE ENTRY POINT *
***********************
FFPCMP   TST.B     D6        ? FIRST NEGATIVE
         BPL.S     FFPCP     NO FIRST IS POSITIVE
         TST.B     D7        ? SECOND NEGATIVE
         BPL.S     FFPCP     NO, ONE IS POSITIVE
* IF BOTH NEGATIVE THEN COMPARE MUST BE DONE BACKWARDS
         CMP.B     D7,D6     COMPARE SIGN AND EXPONENT ONLY FIRST
         BNE.S     FFPCRTN   RETURN IF THAT IS SUFFICIENT
         CMP.L     D7,D6     COMPARE REVERSE ORDER IF BOTH NEGATIVE
         RTS                 RETURN TO CALLER
FFPCP    CMP.B     D6,D7     COMPARE SIGN AND EXPONENT ONLY FIRST
         BNE.S     FFPCRTN   RETURN IF THAT IS SUFFICIENT
         CMP.L     D6,D7     NO, COMPARE FULL LONGWORDS THEN
FFPCRTN  RTS                 AND RETURN TO THE CALLER

*************************************************************
*                     FFPTST                                *
*           FAST FLOATING POINT TEST                        *
*                                                           *
*  INPUT:  D7 - FAST FLOATING POINT ARGUMENT                *
*                                                           *
*  OUTPUT: CONDITION CODES SET FOR THE FOLLOWING BRANCHES:  *
*                                                           *
*                  EQ - ARGUMENT EQUALS ZERO                *
*                  NE - ARGUMENT NOT EQUAL ZERO             *
*                  PL - ARGUMENT IS POSITIVE (INCLUDES ZERO)*
*                  MI - ARGUMENT IS NEGATIVE                *
*                                                           *
*      CONDITION CODES:                                     *
*              N - SET IF RESULT IS NEGATIVE                *
*              Z - SET IF RESULT IS ZERO                    *
*              V - CLEARED                                  *
*              C - UNDEFINED                                *
*              X - UNDEFINED                                *
*                                                           *
*               ALL REGISTERS TRANSPARENT                   *
*                                                           *
*************************************************************
         XDEF      FFPTST    FAST FLOATING POINT TEST

********************
* TEST ENTRY POINT *
********************
FFPTST   TST.B     D7        RETURN TESTED CONDITION CODE
         RTS                 TO CALLER
