# Headeronly

## Description:
A perl script to combine a `.c` and a `.h` into a single `.h`
that can be included as a stand alone header.
The header output is named `headeronly-FILE.h` by default to 
avoid name conflicts with your module files. This can be renamed
at your discretion. The script will also strip any main function it encounters.

*NOTE:* The header must be wrapped in a `#ifndef`.
```c
#ifndef _FILE_H_
#define _FILE_H_
/* code */
#endif
```

## Usage:
```
headeronly.pl [file.c] [file.h]
```
