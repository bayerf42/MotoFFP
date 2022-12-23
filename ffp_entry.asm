    INCLUDE ffp_math.inc


****************************************************************************************************
* Math FFP entrypoints, keep in sync with ffp_math.inc 
****************************************************************************************************

    ORG    ffp_base

    bra.w  FFPABS
    bra.w  FFPADD
    bra.w  FFPARND
    bra.w  FFPAFP
    bra.w  FFPATAN
    bra.w  FFPCMP
    bra.w  FFPCOS
    bra.w  FFPCOSH
    bra.w  FFPDIV
    bra.w  FFPEXP
    bra.w  FFPFPA
    bra.w  FFPFPI
    bra.w  FFPIFP
    bra.w  FFPLOG
    bra.w  FFPMUL2
    bra.w  FFPNEG
    bra.w  FFPPWR
    bra.w  FFPSIN
    bra.w  FFPSINCS
    bra.w  FFPSINH
    bra.w  FFPSQRT
    bra.w  FFPSUB
    bra.w  FFPTAN
    bra.w  FFPTANH
    bra.w  FFPTST