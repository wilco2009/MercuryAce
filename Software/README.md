This folder contains the assembly code for FORTH words that add high resolution capabilities to the Jupiter Ace, when using the hi-res add-on board.

To build the tapes, you need a compatible assembler (pasmo is used by default) and a Python interpreter. Pre-built tapes are provided, since the binaries are small. Note that the assembler code must be relocatable; see chapter 25 of the manual. GNU *make* is also necessary.

At the signal level, the Jupiter Ace tape format is mostly compatible with the Spectrum's. However, Jupiter Ace emulators have traditionally used their own file format for storing tapes, and confusingly, their extension is .tap, just as the Spectrum tapes. To help reduce this confusion, in this repository, a tape in Jupiter Ace format will have the extension .j.tap, while a tape in Spectrum format will have the extension .s.tap. They differ just in a very small detail, but enough to make them incompatible.

Note that a file in Spectrum format can't be directly loaded and used in a Spectrum; however, it can be used with tools designed for a Spectrum, such as a TZXduino or fuse's `tapeconv`, to produce audio that can be used directly on a real Jupiter Ace. The MAME tool `castool` can handle both Jupiter and Spectrum .tap formats.
