# M6809-AeonOS9

Based around the work of NitrOS-9, a community-based distribution of the Microware OS-9 operating system for the 6809 that was introduced in the late 1970s and sold into the 1980s, its next evolution is into _novel metal_.

## Documentation

Please consult the [wiki](https://nitros9.sourceforge.io/wiki/index.php/Main_Page). Mind it is rather slow to load and could benefit being moved.

## Support and Ports

The Hitachi 6309, which contains additional registers and enhanced instructions, is also supported.

Here are the current ports available:

| Computer  | Port | Processor |
| ------------- | ------------- |  ------------- |
| TRS-80 Color Computer  | NitrOS-9 Level 1 | 6809 & 6309 |
| Radio Shack Color Computer 2 | NitrOS-9 Level 1 | 6809 & 6309 |
| Tandy Color Computer 3 | NitrOS-9 Level 2 | 6809 & 6309 |
| CoCo 3 FPGA | NitrOS-9 Level 2 | 6809 |
| Dragon 64 & Tano Dragon | NitrOS-9 Level 1 | 6809 |
| Dragon Alpha | NitrOS-9 Level 1 | 6809 |
| Atari w/ Liber809 | NitrOS-9 Level 1 | 6809 |
| Corsham 6809 SS-50 | NitrOS-9 Level 1 | 6809 |

## Downloading and Building

In order to build the OS, you need the following:

* [lwtools](http://lwtools.projects.l-w.ca). This package contains the required 6809 assembler and linker. To get directly to it, have a look [here](/tools/README.md)
* [ToolShed](https://github.com/cartheur/M6809-toolshed). Provides file system tools for creating disk images, copying files to and from those disk images, and more.

Once downloaded and installed, you can build the entire project:

```
export OS9DIR=$HOME/os9
make
```

The result is a number of disk images (ending in .dsk) that can be used on real floppy drives, emulators, and DriveWire.

### More information

* On the subject of retrocomputing, some good information can be found [here](https://www.roug.org/retrocomputing/os/os9).