# Port and cleanup of the Motorola 68343 floating point library for the [Sirichote 68008 kit](https://kswichit.net/68008/68008.htm)

## Purpose

This library contains 68k assembly subroutines to compute with floating point numbers.
It was originally written by Motorola about 40 years ago. It contains basic arithmetic,
parsing and printing decimal, and several transcendental functions.

It uses a special 32 bit format to represent real numbers, called *Fast Floating Point*,
which was apparently also used on Amiga computers in the 80s. The format is simpler
(and faster) than the modern IEEE-754 single precision format, but has a more limited
exponent range.

I use it to provide floating point numbers for [Lox68k](https://github.com/bayerf42/Lox68k)

## Building the library

* Build the Monitor ROM as [described here](https://github.com/bayerf42/Monitor)
* Load project `MotoFFP.prj` into *Ide68K* and build it.
* Execute
```sh
python makerom.py
```
to create `mon_ffp.bin` ROM image in the parallel `rom` directory.
* Burn this file into ROM or continue building the [Lox68k project](https://github.com/bayerf42/Lox68k).

If you don't want to build the ROM yourself, a pre-built image `mon_ffp.bin` is included in
the release, containing both the Monitor and the FFP library.

## Using the library

The main incentive for resurrection of the Motorola FFP library was to provide floating point
numbers for the Lox68k language, but of course you can utilize it for other projects
as well.

The file `test_ffp.asm` shows how to call some routines from the library. Compile it in *Ide68K*
(without a project file), load it to the Kit and run it. It prints the result of the computation
to the terminal.

## Entry vectors

* Startup file `ffp_entry.asm` defines the branch entries into the library
* Include file `ffp_math.inc` defines official entrypoints for external library users

## Origin
* Found at http://eab.abime.net/showthread.php?p=797994 
* Original file http://eab.abime.net/attachment.php?attachmentid=30480&d=1328104342
* unpacked obscure `LZX` archive with online tool

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
