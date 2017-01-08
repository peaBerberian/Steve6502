# Steve the snake

## Overview

This is an implementation of the [snake video game](https://en.wikipedia.org/wiki/Snake_(video_game)), written in [6502](https://en.wikipedia.org/wiki/MOS_Technology_6502) assembly.

This implementation is based on [Nick Morgan](https://twitter.com/skilldrick)'s implementation from [easy 6502](http://skilldrick.github.io/easy6502/), itself based on [Willem van der Jagt](https://twitter.com/wgt) [implementation](https://gist.github.com/wkjagt/9043907).

I did this project as a first step with 6502 assembly (don't mind it, this is just a tiny personal project, I just like writing nice README.md files).

## Building the game

The game can be played on [skilldrick's 6502js](https://github.com/skilldrick/6502js) 6502 assembler and simulator.  A web version of this tool can be found directly on his [easy6502 website](http://skilldrick.github.io/easy6502).

All the code is available in the [steve.asm](https://raw.githubusercontent.com/peaBerberian/Steve6502/master/steve.asm) file.

## How to play

If you played snake, you know how to play:
  - You control a snake wanting to eat as much apples as it can.
  - When your "head" collides with an apple, you grow and a new apple is generated somewhere else.

You lose if either:
  - You go out of the screen boundaries.
  - You eat yourself (your head collides with your body).

### Controls

There are 4 controls to move steve arround:

| Key | Direction  |
|-----|------------|
|  w  | Move up    |
|  a  | Move left  |
|  s  | Move down  |
|  d  | Move right |

Steve cannot:
  - move up if he already moves down
  - move left if he already moves right
  - ...

Once steve's head collides with an apple, he eats it!

### Apple types

There are 3 kind of apples, based on their colors. Rarer is the apple, more steve will grow after eating it:

| Apple color | probability | Steve growth, in pixel |
|:-----------:|:-----------:|:----------------------:|
|    Green    |     5/8     |            1           |
|     Red     |     1/4     |            3           |
|     Gold    |     1/8     |            5           |

### Notes

I did not add a winning mechanism yet, and after eating too much apples you might encounter a buffer overflow, leading to unwanted behaviors. Let's just say that after eating to much apples, steve becomes sick or that the game goes into hard mode, as you wish.

## Possible improvements

- add a winning mechanism
- set a maximum duration for the gold apple
- add obstacles
- add bonus/malus
