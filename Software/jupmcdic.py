#!/usr/bin/env python3

# (C) Copyright 2024 Pedro Gimeno Fortea

# Build a tape with the given machine code snippets as words

# Usage: python jupmcdic.py <name> <word1>.bin <word2>.bin ...
#
# That will generate <name>.j.tap, a tape with <name> in the header,
# containing a FORTH dictionary with the words MCODE, <WORD1>, <WORD2>, ...
# where the definition of <WORD1> is the machine code contained in <word1>.bin
# and so on. Note that the extension may be something other than .bin, but it
# will be stripped.

# For the meaning of MCODE, see chapter 25 of the Jupiter Ace manual (where it
# is called just CODE).

# Note that the word MCODE can be EDITed, but the others can't (ERROR 14).

import sys, struct, os

def short2bytes(i):
  return bytearray((i & 255, (i >> 8) & 255))

def main(tapename, blobnames):
  blobs = []
  words = []

  for blobname in blobnames:
    f = open(blobname, 'rb')
    blobs.append(f.read())
    f.close()
    words.append(os.path.splitext(os.path.basename(blobname))[0].upper()
      .encode('latin1')[:31]
      .replace(b'\xA3', b'\x60')    # pound sign
      .replace(b'\xA9', b'\x7F'))   # copyright sign

  # Build a word defined as follows:
  #   DEFINER MCODE DOES> CALL ;
  data = bytearray(b'MCODE')
  data[-1] |= 0x80   # bit 7 set for terminator
  mcodelen = len(data)
  calladdr = 0x3C5E + mcodelen
  data.extend(
    b'\x14\x00'      # length
    b'\x49\x3C'      # Pointer to the previous word, 'FORTH'
  )
  ptrLast = 0x3C51 + len(data)
  data.extend(bytearray((mcodelen,)))  # Length of "MCODE"
  data.extend(b'\x85\x10')             # 'Create and enclose' (DEFINER)
  data.extend(short2bytes(calladdr))   # address of CALL below
  data.extend(b'\xE8\x10')      # 10E8h contains a pointer to the EXIT routine
  data.extend(short2bytes(-12 - mcodelen))   # ?? negative offset?
  data.extend(
    b'\xCD\xF0\x0F'  # CALL 0FF0h (start interpreting?)
    b'\xA7\x10'      # 10A7h contains a pointer to the CALL word routine
    b'\xB6\x04'      # 04B6h contains a pointer to the EXIT routine
  )

  # Build the words as if they were defined using:
  # MCODE <word> <byte> C, <byte> C, <byte> C, ...
  for i in range(len(blobnames)):
    data.extend(words[i])
    data[-1] |= 0x80
    data.extend(short2bytes(len(blobs[i]) + 7))
    data.extend(short2bytes(ptrLast))
    ptrLast = 0x3C51 + len(data)
    data.extend((len(words[i]),))
    data.extend(short2bytes(calladdr))
    data.extend(blobs[i])

  header = bytearray(struct.pack('<HB10s7HB',
    0x1A,   # length of header
    0,      # indicator "this is a dictionary"
    (tapename.encode('latin1') + b'          ')[:10],   # file name
    len(data),
    0x3C51,
    ptrLast,
    0x3C4C, 0x3C4C, 0x3C4F,
    0x3C51 + len(data),
    0
  ))

  xorsum = 0
  for i in header[2:]:
    xorsum ^= i
  header[-1] = xorsum

  xorsum = 0
  for i in data:
    xorsum ^= i
  data.extend((xorsum,))

  header.extend(short2bytes(len(data)))

  f = open(tapename + '.j.tap', 'wb')
  f.write(header)
  f.write(data)
  f.close()

if __name__ == '__main__':
  main(sys.argv[1], sys.argv[2:])
