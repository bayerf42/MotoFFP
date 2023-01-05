*-----------------------------------------------------------
* Title      : test_ffp.asm
* Written by : Fred Bayer
* Date       : 2023-01-05
* Description: Shows how to call the routines in Motorola FFP
*              library. Divides two numbers given in decimal
*              and prints result to terminal.
*              See the library comments for register conventions etc.
*-----------------------------------------------------------

    include ../monitor/include/monitor4x.inc
    include ffp_math.inc

    ORG $400

start:
    lea     (num1,PC),A0
    jsr     ffp_asc_to_flp     ; Convert 1st number from ASCII to FFP, result in D7
    move.l  D7,-(SP)           ; store for later

    lea     (num2,PC),A0
    jsr     ffp_asc_to_flp     ; Convert 2nd number from ASCII to FFP, result in D7

    move.l  (SP)+,D6           ; recall first number

    jsr     ffp_div            ; divide D7 by D6, result in D7

    move.w  #0,-(SP)           ; Push string terminator NUL onto stack
    jsr     ffp_flp_to_asc     ; Convert D7 back to ASCII, result string will be on stack

    move.l  SP,-(SP)           ; looks strange, but is right: string's start addr is the SP
                               ; push it onto stack where pstring expects its parameter
    jsr     pstring            ; and print it to Terminal
    lea     (4+14+2,SP),SP     ; clean-up stack: 4 bytes string pointer,
                               ; 14 bytes result string, 2 bytes NUL terminator (to keep SP even)

    trap    #0                 ; Back to Monitor
    bra.s   start


num1:
    dc.b    "3.141592656e+11",0

num2:
    dc.b    "-47.345E-8",0
