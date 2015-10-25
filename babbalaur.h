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
#else
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

struct Gamestate
{
    struct Mesh mesh;
    struct Shader shader;
    struct Camera camera;
};

bool32_t GameInit( struct Memory* memory );
bool32_t GameUpdate( struct Memory* memory, struct Input* newInput, struct Input* oldInput, real64_t dt );
void GameRender( struct Memory* memory );

#define BABBALAUR_H
#endif
