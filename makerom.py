### Python script to build a ROM image including Monitor and FFP lib

import bincopy

rom_path = "../roms/"
rom_base = 0x40000

rom = bincopy.BinFile()
rom.add_binary_file(rom_path + "monitor.bin", rom_base)
rom.add_file("motoffp.hex")
rom.fill()
rom.exclude(0, rom_base)

with open(rom_path + "mon_ffp.bin","wb") as dest:
  dest.write(rom.as_binary())

