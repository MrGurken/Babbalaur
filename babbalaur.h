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
#include "maths.h"
#include "graphics.h"

#if _WIN32
#include <fstream>
#include "SDL.h"
#include "SDL_image.h"

#define DIFFUSE_VS_PATH "./shaders/diffuse.vs"
#define DIFFUSE_FS_PATH "./shaders/diffuse.fs"
#define TILESHEET_PATH "./textures/tilesheet.png"

#else

#define DIFFUSE_VS_PATH "diffuse"
#define DIFFUSE_FS_PATH "diffuse"
#define TILESHEET_PATH "tilesheet"

#endif

#define WINDOW_X SDL_WINDOWPOS_UNDEFINED
#define WINDOW_Y SDL_WINDOWPOS_UNDEFINED
#define WINDOW_W 640
#define WINDOW_H 480
#define WINDOW_TITLE "Babba Laur"

#define GAME_DT 0.015

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

#define SHADER_MAX_UNIFORMS 14
enum
{
    PROJECTION_MATRIX=0,
    VIEW_MATRIX,
    MODEL_MATRIX,
    UV_OFFSET,
    UV_LENGTH
};

struct Shader
{
    GLuint program;
    GLuint uniforms[SHADER_MAX_UNIFORMS];
    int nuniforms;
};

struct Vertex
{
    real32_t x, y, z;
    real32_t u, v;
};

struct Texture
{
    GLuint id;
    int width;
    int height;
};

struct Mesh
{
    GLuint vao;
    GLuint vbo;
    GLuint ibo;
    int size;
};

struct Camera
{
    v3 position;
    m4 projection;
    m4 view;
};

#define TILESHEET_WIDTH 10
#define TILE_UV_LENGTH ( 1.0f / TILESHEET_WIDTH )
#define TILE_SIZE 32.0f

#define GAME_MAP_WIDTH 10
#define GAME_MAP_HEIGHT 10
struct Gamestate
{
    struct Mesh quadMesh;
    struct Shader shader;
    struct Camera camera;
    struct Texture texture;
    uint8_t map[GAME_MAP_HEIGHT][GAME_MAP_WIDTH];
    struct Memory memory;
};

bool32_t GameInit( struct Memory* memory );
bool32_t GameUpdate( struct Memory* memory, struct Input* newInput, struct Input* oldInput, real64_t dt );
void GameRender( struct Memory* memory );

#define BABBALAUR_H
#endif
