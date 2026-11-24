# The Tris

The Tris is a clone of a rather well known game of Russian origin, written in 100 % 80386
assembly, for the IBM PC clone architecture.

I wrote this in 1994-1995 as an exercise to learn the x86 assembly language. If my memory serves
me correctly, I got a ton of hints and tips from Teemu Valtonen (aka. Saracen/EMF back in the
demo scene days).

The code isn't of particularly high quality. E.g., some of the labels and comments are in
Finnish, etc. It used to be one large file, which has since been split into modules without
touching the code itself, so it still builds into the same program as before.

## How to Compile

You will need MS-DOS in one form or another, and Borland Turbo Assembler.

DOSBox (<https://www.dosbox.com>) is an easy alternative.

I found old copies of TASM 4.0 installation disks, and they worked fine. The software appears to
be available for download from so-called abandonware sites, but I am unsure about their legality,
so I am not linking to them here.

Place all the files into a folder, keeping the subfolders, make sure TASM and TLINK are in the
path, and run MAKE.BAT. It assembles the modules into an OBJ folder and links THETRIS.EXE.

```MS-DOS
C:\THETRIS>make
```

On macOS, `tools/build.sh` runs the same MAKE.BAT in a headless
[DOSBox-X](https://dosbox-x.com) and prints the SHA-256 of the resulting THETRIS.EXE. Point the
`TASM_DIR` environment variable at the folder that holds TASM.EXE and TLINK.EXE first.

```sh
TASM_DIR=~/dos/tasm tools/build.sh
```

## Usage

```MS-DOS
C:\THETRIS>thetris
```

## Files

| **Filename**     | **What it is**                                                                                           |
|------------------|----------------------------------------------------------------------------------------------------------|
| MAKE.BAT         | Assembles the modules and links the game.                                                                |
| THETRIS.LNK      | Linker response file. It lists the modules in the order their code had in the original single file.      |
| src/MAIN.ASM     | Program entry point: initialisation, clean-up and exit to DOS.                                           |
| src/PALETTE.ASM  | Palette fades and waiting for the vertical retrace.                                                      |
| src/MENU.ASM     | Game menu, information screen, setup, key redefinition, high score screen and the starting level prompt. |
| src/SCREEN.ASM   | Text output and clearing the screen.                                                                     |
| src/GAME.ASM     | The game itself: main loop, key handling, game over and typing a name into the high score table.         |
| src/MOVE.ASM     | Dropping, moving and rotating the current piece.                                                         |
| src/SCORE.ASM    | Removing full lines, scoring, level changes, sound effects and the score panel.                          |
| src/NEXT.ASM     | Random numbers, picking the next piece and the next piece preview.                                       |
| src/FILES.ASM    | Reading and writing the high score and setup files.                                                      |
| src/PIECE.ASM    | Drawing, erasing and collision testing of blocks and pieces.                                             |
| src/KEYBOARD.ASM | Keyboard interrupt handler.                                                                              |
| src/DATA.ASM     | The data segment: texts, tables and variables.                                                           |
| inc/COMMON.INC   | Constants, segments and the symbols the modules use from each other.                                     |
| inc/DEFHIGH.ASM  | Default high score table                                                                                 |
| inc/FONT.ASM     | Contains offsets into the graphic file that has all the characters and numbers.                          |
| inc/THETRIS.PAL  | A generated palette file                                                                                 |
| gfx/*.OBJ        | These are the graphics as linkable OBJ files.                                                            |
| gfx/*.LBM        | The graphics in Deluxe Paint format (320 px x 200 px, 256 colors)                                        |
| tools/build.sh   | Builds the game in a headless DOSBox-X and prints the SHA-256 of THETRIS.EXE.                            |
| tools/lint.sh    | Checks the source format: line endings, encoding, column layout and module registration.                 |

## Screenshots

![Welcome Screen](./screenshots/thetris_000.png?raw=true)
![Gameplay](./screenshots/thetris_001.png?raw=true)
![Game Over](./screenshots/thetris_002.png?raw=true)
![Setup Screen](./screenshots/thetris_003.png?raw=true)

## Contributors

All graphics were done by [Tero Saarni](https://github.com/tsaarni) back in the day.

## License

[MIT](https://choosealicense.com/licenses/mit/)
