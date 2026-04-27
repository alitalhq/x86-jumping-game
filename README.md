# DOS Jumping Game

A simple 40x25 text mode Assembly x86 jumping game.

## How to Play

- **Space**: Jump
- **Goal**: Avoid obstacles and earn points
- **Game Over**: Press any key to restart

## Obstacles

Three different obstacle types:
- 1x1 (single block)
- 1x2 (vertical, 2 blocks high)
- 2x1 (horizontal, 2 blocks wide)

## Player Animation

- **A** - Standing on ground
- **^** - Jumping up
- **V** - Falling down

## Compile & Run

Requirements: DOS/DOSBox environment

Compile with NASM:
```bash
nasm -f bin main.asm -o jumping.com
```

Run:
```bash
jumping.com
```

## Adjust Game Speed

Change `oyun_hizi` value in main.asm:
```assembly
oyun_hizi dw 4000h
```
- Larger value = slower
- Smaller value = faster

## Requirements

- x86 Architecture (16-bit real mode)
- DOS or DOSBox
- Assembler (NASM, MASM, or TASM)

