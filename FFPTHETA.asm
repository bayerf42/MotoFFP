***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

         XDEF      FFPTHETA            EXTERNAL DEFINITION

*********************************************************
*             ARCTANGENT TABLE FOR CORDIC               *
*                                                       *
* THE FOLLOWING TABLE IS USED DURING CORDIC             *
* TRANSCENDENTAL EVALUATIONS FOR SINE, COSINE, AND      *
* TANGENT AND REPRESENTS ARCTANGENT VALUES 2**-N WHERE  *
* N RANGES FROM 0 TO 24.  THE FORMAT IS BINARY(31,29)   *
* PRECISION (I.E. THE BINARY POINT IS BETWEEN BITS      *
* 28 AND 27 GIVING TWO LEADING NON-FRACTION BITS.)      *
*********************************************************

FFPTHETA DC.L      $C90FDAA2>>3  ARCTAN(2**0)
         DC.L      $76B19C15>>3  ARCTAN(2**-1)
         DC.L      $3EB6EBF2>>3  ARCTAN(2**-2)
         DC.L      $1FD5BA9A>>3  ARCTAN(2**-3)
         DC.L      $0FFAADDB>>3  ARCTAN(2**-4)
         DC.L      $07FF556E>>3  ARCTAN(2**-5)
         DC.L      $03FFEAAB>>3  ARCTAN(2**-6)
         DC.L      $01FFFD55>>3  ARCTAN(2**-7)
         DC.L      $00FFFFAA>>3  ARCTAN(2**-8)
         DC.L      $007FFFF5>>3  ARCTAN(2**-9)
         DC.L      $003FFFFE>>3  ARCTAN(2**-10)
         DC.L      $001FFFFF>>3  ARCTAN(2**-11)
         DC.L      $000FFFFF>>3  ARCTAN(2**-12)
         DC.L      $0007FFFF>>3  ARCTAN(2**-13)
         DC.L      $0003FFFF>>3  ARCTAN(2**-14)
         DC.L      $0001FFFF>>3  ARCTAN(2**-15)
         DC.L      $0000FFFF>>3  ARCTAN(2**-16)
         DC.L      $00007FFF>>3  ARCTAN(2**-17)
         DC.L      $00003FFF>>3  ARCTAN(2**-18)
         DC.L      $00001FFF>>3  ARCTAN(2**-19)
         DC.L      $00000FFF>>3  ARCTAN(2**-20)
         DC.L      $000007FF>>3  ARCTAN(2**-21)
         DC.L      $000003FF>>3  ARCTAN(2**-22)
         DC.L      $000001FF>>3  ARCTAN(2**-23)
         DC.L      $000000FF>>3  ARCTAN(2**-24)
         DC.L      $0000007F>>3  ARCTAN(2**-25)
         DC.L      $0000003F>>3  ARCTAN(2**-26)
