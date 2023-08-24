# The Tris

The Tris is a clone of a rather well known game of Russian origin, written in 100 % 80386 assembly, for the IBM PC clone architecture.

I wrote this in 1994-1995 as an exercise to learn the x86 assembly language. If my memory serves me correctly, I got a ton of hints and tips from Teemu Valtonen (aka. Saracen/EMF back in the demo scene days).

The code isn't of particularly high quality. E.g., everything is in one large file, and some of the labels and comments are in Finnish, etc. I might clean it up at some point, but I'm publishing it as is for now.

## How to Compile

You will need MS-DOS in one form or another, and Borland Turbo Assembler.

DOSBox (https://www.dosbox.com) is an easy alternative.

I found old copies of TASM 4.0 installation disks, and they worked fine. The software appears to be available for download from so-called abandonware sites, but I am unsure about their legality, so I am not linking to them here.

Place all the files into a folder, make sure TASM and TLINK are in the path, and run MAKE.BAT.

```MS-DOS
C:\THETRIS>make
```

## Usage

```MS-DOS
C:\THETRIS>thetris
```

## Files

| **Filename** | **What it is**                                                                  |
|--------------|---------------------------------------------------------------------------------|
| THETRIS.ASM  | This is the source code for the whole game, pretty much.                        |
| DEFHIGH.ASM  | Default high score table                                                        |
| KIRJAPU.ASM  | Contains offsets into the graphic file that has all the characters and numbers. |
| THETRIS.PAL  | A generated palette file                                                        |
| *.OBJ        | These are the graphics as linkable OBJ files.                                   |
| *.LBM        | The graphics in Deluxe Paint format (320 px x 200 px, 256 colors)               |

## Screenshots

![Welcome Screen](./screenshots/thetris_000.png?raw=true)
![Gameplay](./screenshots/thetris_001.png?raw=true)
![Game Over](./screenshots/thetris_002.png?raw=true)
![Setup Screen](./screenshots/thetris_003.png?raw=true)

## Contributors

All graphics were done by [Tero Saarni](https://github.com/tsaarni) back in the day.

## License

[MIT](https://choosealicense.com/licenses/mit/)
