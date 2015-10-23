#if !defined(BABBALAUR_H)
/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include <stdint.h>
#include "maths.h"
#include "graphics.h"

#define WINDOW_X SDL_WINDOWPOS_UNDEFINED
#define WINDOW_Y SDL_WINDOWPOS_UNDEFINED
#define WINDOW_W 640
#define WINDOW_H 480
#define WINDOW_TITLE "Babba Laur"

#define GAME_DT 0.015

#define KILOBYTES(n) (1024*n)
#define MEGABYTES(n) (1024*KILOBYTES(n))
#define GIGABYTES(n) (1024*MEGABYTES(n))

typedef int32_t bool32_t;
typedef float real32_t;
typedef double real64_t;

struct Memory
{
    void* pointer;
    uint32_t size;
};

struct Input
{
    v2 mousePosition;
    v2 mouseDelta;
    bool32_t lmbDown;
    bool32_t rmbDown;
    bool32_t spaceDown;
};

bool32_t GameInit( Memory* memory );
bool32_t GameUpdate( Memory* memory, Input* newInput, Input* oldInput, real64_t dt );
void GameRender( Memory* memory );

#define BABBALAUR_H
#endif
