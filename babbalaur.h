#if !defined(BABBALAUR_H)
/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include <stdio.h>
#include <stdint.h>

#if _WIN32

#define DIFFUSE_VS_PATH "./shaders/diffuse.vs"
#define DIFFUSE_FS_PATH "./shaders/diffuse.fs"
#define TILESHEET_PATH "./textures/tilesheet.png"

#else

#define DIFFUSE_VS_PATH "diffuse"
#define DIFFUSE_FS_PATH "diffuse"
#define TILESHEET_PATH "tilesheet"

#endif

#ifdef _WIN32

#define WINDOW_X SDL_WINDOWPOS_UNDEFINED
#define WINDOW_Y SDL_WINDOWPOS_UNDEFINED
#define WINDOW_W 640
#define WINDOW_H 480

#else

#define WINDOW_X 32
#define WINDOW_Y 32
#define WINDOW_W 320
#define WINDOW_H 480

#endif

#define WINDOW_TITLE "Babba Laur"

#define GAME_DT 0.015
#define GAME_MAP_WIDTH 10
#define GAME_MAP_HEIGHT 10
#define GAME_MEMORY_POOL KILOBYTES(64)

#define TILESHEET_WIDTH 10
#define TILE_UV_LENGTH ( 1.0f / TILESHEET_WIDTH )
#define TILE_SIZE 32.0f
#define TILE_INDEX(x,y) (y*GAME_MAP_WIDTH+x)

#define KILOBYTES(n) (1024*n)
#define MEGABYTES(n) (1024*KILOBYTES(n))
#define GIGABYTES(n) (1024*MEGABYTES(n))

#ifndef MIN
#define MIN(a,b) (a<b?a:b)
#define MAX(a,b) (a>b?a:b)
#endif

typedef int32_t bool32_t;
typedef float real32_t;
typedef double real64_t;

typedef struct MemoryTag
{
    void* pointer;
    uint32_t size;
} Memory;

#include "maths.h"
#include "graphics.h"
//#include "io.h"

enum
{
    BUTTON_LEFT=0,
    BUTTON_RIGHT,
    BUTTON_MIDDLE,
    MAX_BUTTONS
};

enum
{
    KEY_SPACE=0,
    KEY_ENTER,
    MAX_KEYS
};

typedef struct InputTag
{
    v2 mousePosition;
    v2 mouseDelta;
    bool32_t buttons[MAX_BUTTONS];
    bool32_t keys[MAX_KEYS];
} Input;

typedef struct CameraTag
{
    v3 position;
    m4 projection;
    m4 view;
} Camera;

enum
{
    ORIENTATION_LEFT = 0,
    ORIENTATION_RIGHT,
    ORIENTATION_TOP,
    ORIENTATION_BOTTOM
};

enum
{
    MACHINE_ADJ_TOP_LEFT = 0,
    MACHINE_ADJ_TOP,
    MACHINE_ADJ_TOP_RIGHT,
    MACHINE_ADJ_LEFT,
    MACHINE_ADJ_RIGHT,
    MACHINE_ADJ_BOTTOM_LEFT,
    MACHINE_ADJ_BOTTOM,
    MACHINE_ADJ_BOTTOM_RIGHT,
    MACHINE_MAX_ADJ
};
#define MACHINE_ADJ_LENGTH 3

typedef struct MachineTag
{
    int orientation;
    p2 gridPoint;
    bool32_t alive;
    int type;
} Machine;

typedef struct GamestateTag
{
    Mesh quadMesh;
    Shader shader;
    Camera camera;
    Texture texture;
    uint8_t map[GAME_MAP_HEIGHT*GAME_MAP_WIDTH];
    Machine machines[GAME_MAP_HEIGHT*GAME_MAP_WIDTH];
    Memory memory;
} Gamestate;

bool32_t GameInit( Memory* memory );
bool32_t GameUpdate( Memory* memory, Input* newInput, Input* oldInput, real64_t dt );
void GameRender( Memory* memory );

#define BABBALAUR_H
#endif
