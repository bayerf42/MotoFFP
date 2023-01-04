# Port and cleanup of the Motorola 68343 floating point library for the Sirichote 68008 kit

## Origin
* Found at http://eab.abime.net/showthread.php?p=797994 
* Original file http://eab.abime.net/attachment.php?attachmentid=30480&d=1328104342
* unpacked `LZX` file with obscure online tool

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
* Allowed lower case `e` as exponent marker in`FFPAFP`

## Entry vectors

* Startup file `ffp_entry.asm` defines the branch entries into the library
* Include file `ffp_math.inc` defines official entrypoints for external library users
