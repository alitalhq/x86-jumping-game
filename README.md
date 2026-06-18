# x86 DOS Jumping Game

A side-scrolling obstacle-avoidance game written in x86 16-bit Assembly for DOS, running in 40×25 text mode.

## Gameplay

The player character moves at a fixed X position while obstacles scroll from right to left. Press **Space** to jump over them.

| Key | Action |
|-----|--------|
| `Space` | Jump (only from ground) |
| Any key | Restart after Game Over |

**Scoring:** +1 point each time an obstacle passes the player (3 obstacles = up to +3 per cycle).

## Player States

| Character | State |
|-----------|-------|
| `A` | Standing on ground |
| `^` | Jumping up |
| `V` | Falling down |

## Obstacle Types

All obstacles are drawn with `#` characters:

| Type | Shape | Description |
|------|-------|-------------|
| 1 | `#` | 1×1 single block |
| 2 | `#` over `#` | 1×2 vertical (2 blocks tall) |
| 3 | `##` | 2×1 horizontal (2 blocks wide) |

## Compile & Run

> **Note:** This project uses **MASM/TASM syntax** (`.data`, `.code`, `proc/endp` directives). Use TASM or MASM inside DOSBox — NASM is **not** compatible with this syntax.

### With TASM (recommended)

```
tasm main.asm
tlink /t main.obj
main.com
```

### With MASM

```
masm main.asm;
link main.obj;
main.exe
```

### DOSBox setup

Mount your project directory and assemble inside DOSBox:

```
mount c C:\path\to\project
c:
tasm main.asm
tlink /t main.obj
main.com
```

## Adjust Game Speed

Change `oyun_hizi` in `main.asm` (microsecond delay per frame via `INT 15h AH=86h`):

```asm
oyun_hizi dw 4000h   ; 16384 µs per frame (default)
```

- Larger value → slower game
- Smaller value → faster game

## Technical Details

### Environment

- **Architecture:** x86 16-bit real mode
- **File format:** DOS COM (`.org 100h`)
- **Video mode:** 40×25 text mode (INT 10h mode `01h`)
- **Cursor:** Hidden via `INT 10h AH=01h`, `CX=2607h`

### Game Loop Structure

Each frame executes these steps in order:

1. **Score display** — render score string at position (0, 0)
2. **Erase** — clear player and all obstacle characters from previous positions
3. **Input** — poll keyboard with `INT 16h AH=01h`; Space triggers jump if on ground
4. **Move obstacles** — decrement each obstacle's X; wrap to 62 when underflow (byte wraps to 255)
5. **Jump / gravity** — if `ziplaniyor > 0`, move player up 1 row and decrement counter; else apply gravity (move down until Y=12)
6. **Collision** — check if player X equals any obstacle X, then compare Y
7. **Draw** — render all obstacles and player character
8. **Delay** — `INT 15h AH=86h` busy-wait for `oyun_hizi` microseconds

### BIOS / DOS Interrupt Usage

| Interrupt | AH | Purpose |
|-----------|----|---------|
| `INT 10h` | `00h` | Set video mode (40×25 text) |
| `INT 10h` | `01h` | Configure cursor shape (hide) |
| `INT 10h` | `02h` | Set cursor position |
| `INT 10h` | `0Eh` | Write character (TTY mode) |
| `INT 15h` | `86h` | Microsecond delay |
| `INT 16h` | `00h` | Read keystroke |
| `INT 16h` | `01h` | Check keystroke available |
| `INT 21h` | `09h` | Print `$`-terminated string |

### Jump Mechanics

- Jump is triggered only when `oyuncu_y == 12` (ground level)
- `ziplaniyor` is set to `6` — player moves up 1 row per frame for 6 frames
- After the counter reaches 0, gravity increments Y each frame until `Y == 12`
- Maximum jump height: 6 rows above ground

### Memory Layout (`.data` segment)

| Variable | Type | Description |
|----------|------|-------------|
| `oyuncu_x / oyuncu_y` | `db` | Player position (fixed X=5) |
| `engel_y` | `db` | Shared Y for all obstacles (=12) |
| `engel1/2/3_x` | `db` | X positions of three obstacles |
| `engel1/2/3_tipi` | `db` | Obstacle type (1, 2, or 3) |
| `skor` | `dw` | Score counter |
| `ziplaniyor` | `db` | Jump countdown (0 = grounded) |
| `ziplama_yonu` | `db` | Direction: 0=ground, 1=up, 2=down |
| `oyun_hizi` | `dw` | Frame delay in µs (`4000h` = 16384) |

### Helper Procedures

| Procedure | Description |
|-----------|-------------|
| `imlec_hareket` | Sets cursor to (`DL`, `DH`) via `INT 10h AH=02h` |
| `karakter_yaz` | Writes character in `AL` via `INT 10h AH=0Eh` |
| `skor_guncelle` | Converts `skor` (word) to 3-digit ASCII in `skor_str` |

## Requirements

- x86 16-bit real mode environment (DOSBox or real DOS)
- TASM or MASM assembler
