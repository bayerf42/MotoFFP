# Port and cleanup of the Motorola 68343 floating point library for the Sirichote 68008 kit

## Changes

* Removed unneeded IEEE files `IEFABS.SA`, `IEFADD.SA`, `IEFAFP.SA`
  There were no other IEEE files in the archive, probably got lost somewhere... 
* Removed unneeded program `FFPFPBCD.SA`
* Removed unneeded demo programs `FFPDEMO.SA` and `FFPCALC.SA`
* Removed `*.HT` files
* Renamed source files `*.SA` to `*.asm`
* Use `FFPMUL2` instead of `FFPMUL` because of higher precision
* Removed unsupported `TTL`, `PAGE`, `IDNT`, `OPT PCS`, `SECTION 9` directives
* Removed `END` directives to combine all sources
* Changed `MOVE.L #nn,Dm` to `MOVEQ #nn,Dm` if value in range
* Changed `ADD.s #n` to `ADDQ.s #n` if value in range
* Changed `SUB.s #n` to `SUBQ.s #n` if value in range
* Use PC-relative addressing for constant tables
* Reactivated the CCR manipulation instructions, which weren't supported by ancient assembler
* Renamed some duplicated labels
* Removed 68010 compatibility code to save `SR` on the stack 
* Created project file for defined order
* Allowed lower case `e` as exponent marker


## To check:
*  `LSR.L D7,D7` in log and atan code is very suspect, would always put 0 into D7


## Entry vectors

* Startup file `ffp_entry.asm` defines the branch entries into the library
* Include file `ffp_math.inc` defines official entrypoints for external library users
