format ELF64

section '.text' executable
public _start
extrn printf
extrn _exit
extrn InitWindow
extrn WindowShouldClose
extrn CloseWindow
extrn BeginDrawing
extrn EndDrawing
extrn ClearBackground
extrn DrawRectangle
extrn DrawRectangleV
extrn GetFrameTime
extrn GetScreenWidth
extrn GetScreenHeight

_start:
  mov rdi, 800
  mov rsi, 600
  mov rdx, title
  call InitWindow

.again:
  call WindowShouldClose
  test rax, rax
  jnz .over
  call BeginDrawing

  mov rdi, 0xFF181818
  call ClearBackground

  ;; getting the border
  call GetScreenWidth
  mov [border], eax
  mov [border+8], eax
  call GetScreenHeight
  mov [border+4], eax
  mov [border+12], eax
  movaps xmm0, [border]
  cvtdq2ps xmm0, xmm0
  movaps [border], xmm0

  ;; next position
  call GetFrameTime
  shufps xmm0, xmm0, 0
  mulps xmm0, [velocity]
  addps xmm0, [position]

  ;; check collisions
  movaps xmm1, xmm0
  cmpltps xmm1, [zero]
  movaps xmm2, xmm0
  addps xmm2, [size]
  cmpnltps xmm2, [border]
  orps xmm1, xmm2
  cvtdq2ps xmm1, xmm1
  mulps xmm1, [minus_one]
  movaps xmm2, [one]
  subps xmm2, xmm1

  ;; update position
  movaps xmm3, [position]
  mulps  xmm3, xmm1
  movaps xmm4, xmm0
  mulps  xmm4, xmm2
  addps  xmm3, xmm4
  movaps [position], xmm3

  ;; update velocity
  subps xmm2, xmm1
  movaps xmm3, [velocity]
  mulps xmm2, xmm3
  movaps [velocity], xmm2

  ;; rendering rect 1
  movq xmm0, [position]
  movq xmm1, [size]
  mov rdi, 0xFF0000FF
  call DrawRectangleV

  ;; rendering rect 2
  movq xmm0, [position + 8]
  movq xmm1, [size + 8]
  mov rdi, 0xFF00FF00
  call DrawRectangleV

  call EndDrawing
  jmp .again

.over:
  call CloseWindow
  mov rdi, 0
  call _exit

section '.data' writeable
position:
  dd 200.0
  dd 200.0
  dd 400.0
  dd 400.0
velocity:
  dd -200.0
  dd -300.0
  dd 300.0
  dd 400.0
size:
  dd 200.0
  dd 200.0
  dd 100.0
  dd 100.0
border:
  dd 0.0
  dd 0.0
  dd 0.0
  dd 0.0
zero:
  dd 0.0
  dd 0.0
  dd 0.0
  dd 0.0
minus_one:
  dd -1.0
  dd -1.0
  dd -1.0
  dd -1.0
one:
  dd 1.0
  dd 1.0
  dd 1.0
  dd 1.0
title: db "Hello Raylib from Fasm", 0
section '.note.GNU-stack'
