#!/usr/bin/env python3

# (C) Copyright 2024 Pedro Gimeno Fortea

# Convert a tap from Jupiter format to Spectrum format

import sys, struct

def main():
  if len(sys.argv) != 3:
    sys.stdout.write("Usage: python jtap2sptap.py infile.tap outfile.tap\n")
    return 0

  hdrblock = True
  f = open(sys.argv[1], 'rb')
  try:
    f2 = open(sys.argv[2], 'wb')
    try:
      while True:
        blocklen = f.read(2)
        if blocklen == b'':
          break
        blocklen = struct.unpack('<H', blocklen)[0]
        data = bytearray(f.read(blocklen))
        if blocklen == 0 or len(data) != blocklen:
          sys.stderr.write('Bad block - not a TAP file?')
          return 1
        if hdrblock and blocklen != 0x1A:
          sys.stderr.write('Bad header block - not a Jupiter Ace TAP file?')
          return 1
        blocklen += 1
        f2.write(struct.pack('<HB', blocklen, 0 if hdrblock else 255))
        f2.write(data)
        hdrblock = not hdrblock

    finally:
      f2.close()
  finally:
    f.close()


sys.exit(main() or 0)
