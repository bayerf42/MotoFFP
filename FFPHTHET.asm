***************************************
* (C) COPYRIGHT 1981 BY MOTOROLA INC. *
***************************************

         XDEF      FFPHTHET     EXTERNAL DEFINITION

*********************************************************
*     INVERSE HYPERBOLIC TANGENT TABLE FOR CORDIC       *
*                                                       *
* THE FOLLOWING TABLE IS USED DURING CORDIC             *
* TRANSCENDENTAL EVALUATIONS FOR LOG AND EXP. IT HAS    *
* INVERSE HYPERBOLIC TANGENT FOR 2**-N WHERE N RANGES   *
* FROM 1 TO 24.  THE FORMAT IS BINARY(31,29)            *
* PRECISION (I.E. THE BINARY POINT IS ASSUMED BETWEEN   *
* BITS 27 AND 28 WITH THREE LEADING NON-FRACTION BITS.) *
*********************************************************

FFPHTHET DC.L      $8C9F53D0>>3 HARCTAN(2**-1)   .549306144
         DC.L      $4162BBE8>>3 HARCTAN(2**-2)   .255412812
         DC.L      $202B1238>>3 HARCTAN(2**-3)
         DC.L      $10055888>>3 HARCTAN(2**-4)
         DC.L      $0800AAC0>>3 HARCTAN(2**-5)
         DC.L      $04001550>>3 HARCTAN(2**-6)
         DC.L      $020002A8>>3 HARCTAN(2**-7)
         DC.L      $01000050>>3 HARCTAN(2**-8)
         DC.L      $00800008>>3 HARCTAN(2**-9)
         DC.L      $00400000>>3 HARCTAN(2**-10)
         DC.L      $00200000>>3 HARCTAN(2**-11)
         DC.L      $00100000>>3 HARCTAN(2**-12)
         DC.L      $00080000>>3 HARCTAN(2**-13)
         DC.L      $00040000>>3 HARCTAN(2**-14)
         DC.L      $00020000>>3 HARCTAN(2**-15)
         DC.L      $00010000>>3 HARCTAN(2**-16)
         DC.L      $00008000>>3 HARCTAN(2**-17)
         DC.L      $00004000>>3 HARCTAN(2**-18)
         DC.L      $00002000>>3 HARCTAN(2**-19)
         DC.L      $00001000>>3 HARCTAN(2**-20)
         DC.L      $00000800>>3 HARCTAN(2**-21)
         DC.L      $00000400>>3 HARCTAN(2**-22)
         DC.L      $00000200>>3 HARCTAN(2**-23)
         DC.L      $00000100>>3 HARCTAN(2**-24)

