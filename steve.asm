;  ___           _        __ ___  __ ___
; / __|_ _  __ _| |_____ / /| __|/  \_  )
; \__ \ ' \/ _` | / / -_) _ \__ \ () / /
; |___/_||_\__,_|_\_\___\___/___/\__/___|

; Modifications to the snake6502 done by Willem van der Jagt:
; https://gist.github.com/wgt/9043907

; Can be played on Nick Morgan's 6502 emulator:
; http://skilldrick.github.io/easy6502/

; Change direction: W A S D

define appleL         $00 ; screen location of apple, low byte
define appleH         $01 ; screen location of apple, high byte
define snakeHeadL     $10 ; screen location of snake head, low byte
define snakeHeadH     $11 ; screen location of snake head, high byte
define snakeBodyStart $12 ; start of snake body byte pairs
define snakeDirection $02 ; direction (possible values are below)
define snakeLength    $03 ; snake length, in bytes
define startLength    $04 ; start lengh of the snake, in bytes
define snakeGrow      $05; how much the snake grows in this loop
define appleType      $06; what is the type of the current apple

; Apple types
define greenApple 1 ; add 1 to growth
define redApple   2 ; add 3 to growth
define goldApple  3 ; add 5 to growth

; Colors
define colorGreen 5
define colorWhite 1
define colorBlack 0
define colorRed   2
define colorGold  7

; Directions (each using a separate bit)
define movingUp      1
define movingRight   2
define movingDown    4
define movingLeft    8

; ASCII values of keys controlling the snake
define ASCII_w      $77
define ASCII_a      $61
define ASCII_s      $73
define ASCII_d      $64

; System variables
define sysRandom    $fe ; random byte address
define sysLastKey   $ff ; last key ASCII code address


  jsr init
  jsr loop

init:
  jsr initSnake
  jsr generateApple
  rts


initSnake:
  lda #$00 ; initialize the snake growth
  sta snakeGrow

  lda #movingRight ; set initial direction
  sta snakeDirection

  lda #startLength ; set initial length
  sta snakeLength

  lda #$01 ; update screen location of the head
  sta snakeHeadL

  lda #$0f
  sta $14 ; body segment 1

  lda #$02
  sta snakeHeadH
  sta $13 ; body segment 1
  sta $15 ; body segment 2
  rts

generateApple:
  jsr generateAppleType
  jsr generateApplePosition
  rts

generateAppleType:
  lda sysRandom
  tax
  and #$c0
  cmp #$c0
  beq generateRedApple
  txa
  and #$32
  cmp #$32
  beq generateGoldApple
generateGreenApple:
  lda #greenApple
  sta appleType
  rts
generateRedApple:
  lda #redApple
  sta appleType
  rts
generateGoldApple:
  lda #goldApple
  sta appleType
  rts

generateApplePosition:
  ;load a new random byte into $00
  lda sysRandom
  sta appleL

  ;load a new random number from 2 to 5 into $01
  lda sysRandom
  and #$03 ;mask out lowest 2 bits
  clc
  adc #2
  sta appleH

  rts


loop:
  jsr readKeys
  jsr checkCollision
  jsr updateSnake
  jsr drawApple
  jsr drawSnake
  jsr spinWheels
  jmp loop


readKeys:
  lda sysLastKey
  cmp #ASCII_w
  beq upKey
  cmp #ASCII_d
  beq rightKey
  cmp #ASCII_s
  beq downKey
  cmp #ASCII_a
  beq leftKey
  rts
upKey:
  lda #movingDown
  bit snakeDirection
  bne illegalMove

  lda #movingUp
  sta snakeDirection
  rts
rightKey:
  lda #movingLeft
  bit snakeDirection
  bne illegalMove

  lda #movingRight
  sta snakeDirection
  rts
downKey:
  lda #movingUp
  bit snakeDirection
  bne illegalMove

  lda #movingDown
  sta snakeDirection
  rts
leftKey:
  lda #movingRight
  bit snakeDirection
  bne illegalMove

  lda #movingLeft
  sta snakeDirection
  rts
illegalMove:
  rts


checkCollision:
  jsr checkAppleCollision
  jsr checkSnakeCollision
  rts


checkAppleCollision:
  lda appleL
  cmp snakeHeadL
  bne doneCheckingAppleCollision
  lda appleH
  cmp snakeHeadH
  bne doneCheckingAppleCollision
  jsr eatApple
doneCheckingAppleCollision:
  rts

eatApple:
  lda appleType
  cmp #redApple
  beq eatRedApple
  cmp #goldApple
  beq eatGoldApple
eatGreenApple:
  inc snakeGrow
  jsr generateApple
  rts
eatRedApple:
  inc snakeGrow
  inc snakeGrow
  inc snakeGrow
  jsr generateApple
  rts
eatGoldApple:
  inc snakeGrow
  inc snakeGrow
  inc snakeGrow
  inc snakeGrow
  inc snakeGrow
  jsr generateApple
  rts


checkSnakeCollision:
  ldx #2 ;start with second segment
snakeCollisionLoop:
  lda snakeHeadL,x
  cmp snakeHeadL
  bne continueCollisionLoop

maybeCollided:
  lda snakeHeadH,x
  cmp snakeHeadH
  beq didCollide

continueCollisionLoop:
  inx
  inx
  cpx snakeLength          ;got to last section with no collision
  beq didntCollide
  jmp snakeCollisionLoop

didCollide:
  jmp gameOver
didntCollide:
  rts


updateSnake:
  lda snakeGrow
  cmp #0
  beq startLoop
  inc snakeLength
  inc snakeLength
  dec snakeGrow

startLoop:
  ldx snakeLength
  dex
updateloop:
  lda snakeHeadL,x
  sta snakeBodyStart,x
  dex
  bpl updateloop

  lda snakeDirection
  lsr
  bcs up
  lsr
  bcs right
  lsr
  bcs down
  lsr
  bcs left
up: ; move the head up
  lda snakeHeadL
  sec
  sbc #$20
  sta snakeHeadL
  bcc upup
  rts
upup:
  dec snakeHeadH
  lda #$1 ; the minimum high byte is $02
  cmp snakeHeadH
  beq collision
  rts
right: ; move the head to the right
  inc snakeHeadL
  lda #$1f
  bit snakeHeadL
  beq collision
  rts
down: ; move the head down
  lda snakeHeadL
  clc
  adc #$20
  sta snakeHeadL
  bcs downdown
  rts
downdown:
  inc snakeHeadH
  lda #$6 ; the maximum high byte is $05
  cmp snakeHeadH
  beq collision
  rts
left: ; move the head to the left
  dec snakeHeadL
  lda snakeHeadL
  and #$1f
  cmp #$1f
  beq collision
  rts
collision:
  jmp gameOver


drawApple:
  ldy #0
  lda appleType
  cmp #redApple
  beq drawRedApple
  cmp #goldApple
  beq drawGoldApple
drawGreenApple:
  lda #colorGreen
  sta (appleL),y
  rts
drawRedApple:
  lda #colorRed
  sta (appleL),y
  rts
drawGoldApple:
  lda #colorGold
  sta (appleL),y
  rts


drawSnake:
  ldx snakeLength
  lda #colorBlack
  sta (snakeHeadL,x) ; erase end of tail (paint black)

  ldy #0
  lda #colorWhite
  sta (snakeHeadL),y ; paint head
  rts


spinWheels:
  ldx #99
spinloop:
  nop
  nop
  dex
  bne spinloop
  rts


gameOver:
