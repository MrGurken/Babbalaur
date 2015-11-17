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
#include "SDL_ttf.h"

#define DIFFUSE_VS_PATH "./shaders/diffuse.vs"
#define DIFFUSE_FS_PATH "./shaders/diffuse.fs"
#define TILESHEET_PATH "./textures/tilesheet.png"
#define TILESHEET_NAME "Tilesheet"
#define ARROWS_PATH "./textures/arrows.png"
#define ARROWS_NAME "Arrows"
#define FONT_PATH "./fonts/verdana24.txt"
#define FONT_NAME "Verdana24"
#define CONVEYER_PATH "./textures/conveyer.png"
#define CONVEYER_NAME "Conveyer"
#define CONVEYER_DOWN_ANIMATION_PATH "./animations/conveyer_down.txt"
#define CONVEYER_UP_ANIMATION_PATH "./animations/conveyer_up.txt"
#define CONVEYER_LEFT_ANIMATION_PATH "./animations/conveyer_left.txt"
#define CONVEYER_RIGHT_ANIMATION_PATH "./animations/conveyer_right.txt"

#define WINDOW_X SDL_WINDOWPOS_UNDEFINED
#define WINDOW_Y SDL_WINDOWPOS_UNDEFINED
#define WINDOW_W 640
#define WINDOW_H 480

#else

#define DIFFUSE_VS_PATH "diffuse"
#define DIFFUSE_FS_PATH "diffuse"
#define TILESHEET_PATH "tilesheet"
#define TILESHEET_NAME "Tilesheet"
#define FONT_PATH "verdana24"
#define FONT_NAME "Verdana24"

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

#define SHADER_MAX_UNIFORMS 14
enum
{
    PROJECTION_MATRIX=0,
    VIEW_MATRIX,
    MODEL_MATRIX,
    UV_OFFSET,
    UV_LENGTH,
    COLOR
};

typedef struct ShaderTag
{
    GLuint program;
    GLuint uniforms[SHADER_MAX_UNIFORMS];
    int nuniforms;
} Shader;

typedef struct VertexTag
{
    real32_t x, y, z;
    real32_t u, v;
} Vertex;

typedef struct TextureTag
{
    GLuint id;
    int width;
    int height;
} Texture;

#define FONT_ASCII_MIN 33 // 32 = SPACE
#define FONT_ASCII_MAX 127 // 127 = DEL
#define FONT_ASCII_RANGE (FONT_ASCII_MAX-FONT_ASCII_MIN) // 96
#define FONT_GLYPHS_PER_ROW 10
#define FONT_MAX_PATH 128
typedef struct FontTag
{
    Texture* texture;
    uint8_t size;
    uint8_t ascent;
    uint8_t descent;
    uint8_t lineskip;
    uint8_t linespace;
    uint8_t advance[FONT_ASCII_RANGE];
} Font;

#define ASSETS_MAX_TEXTURES 16
#define ASSETS_MAX_FONTS 4
#define ASSETS_MAX_NAME 32
typedef struct AssetsTag
{
    Texture textures[ASSETS_MAX_TEXTURES];
    char textureNames[ASSETS_MAX_TEXTURES][ASSETS_MAX_NAME];
    int ntextures;
    Font fonts[ASSETS_MAX_FONTS];
    char fontNames[ASSETS_MAX_FONTS][ASSETS_MAX_NAME];
    int nfonts;
} Assets;

typedef struct MeshTag
{
    GLuint vao;
    GLuint vbo;
    GLuint ibo;
    int size;
} Mesh;

typedef struct CameraTag
{
    v3 position;
    m4 projection;
    m4 view;
} Camera;

typedef struct FrameTag
{
    v2 offset;
    real32_t length;
    real32_t delay;
} Frame;

#define ANIMATION_MAX_FRAMES 4
typedef struct AnimationTag
{
    Frame frames[ANIMATION_MAX_FRAMES];
    int nframes;
    int current;
    real32_t elapsed;
} Animation;

#define ANIMATOR_MAX_ANIMATIONS 4
typedef struct AnimatorTag
{
    Animation animations[ANIMATOR_MAX_ANIMATIONS];
    int nanimations;
    int current;
} Animator;

enum
{
    ORIENTATION_LEFT = 0,
    ORIENTATION_RIGHT,
    ORIENTATION_UP,
    ORIENTATION_DOWN
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

enum
{
    MACHINE_PROVIDER=2,
    MACHINE_COLLECTOR,
    MACHINE_CONVEYER_BELT,
    MACHINE_ASSEMBLER,
};

#define PART_ARBITRARY 2
typedef int Part;

#define MACHINE_DELAY 30
#define MACHINE_MAX (GAME_MAP_HEIGHT*GAME_MAP_WIDTH)
#define MACHINE_MAX_PARTS 5
typedef struct MachineTag
{
    int orientation;
    p2 gridPoint;
    bool32_t alive;
    int type;
    int delay;
    //Part parts[MACHINE_MAX_PARTS];
    //int nparts;
    Part inBuffer[MACHINE_MAX_PARTS];
    int ninParts;
    Part outBuffer[MACHINE_MAX_PARTS];
    int noutParts;
    Animator animator;
} Machine;

#define LEVEL_DELAY 150
typedef struct LevelTag
{
    bool32_t running;
    int incoming;
    int outgoing;
    int delay;
    int curOrientation;
} Level;

#define REGION_MAX_CHILDREN 8
typedef struct GUIRegionTag
{
    v2 position;
    v2 bounds;
    bool32_t isDown;
    bool32_t wasDown;
    Texture* background;

    struct GUIRegionTag* parent;
    struct GUIRegionTag* children[REGION_MAX_CHILDREN];
    int nchildren;
} GUIRegion;

#define SCREEN_MAX_TITLE 32
typedef void (ScreenUpdateFunction)( Memory* memory, Input* newInput, Input* oldInput, real32_t dt );
typedef void (ScreenRenderFunction)( Memory* memory );
typedef struct ScreenTag
{
    char title[SCREEN_MAX_TITLE];
    ScreenUpdateFunction* update;
    ScreenRenderFunction* render;
} Screen;

#define SCREEN_BUFFER_MAX 8
typedef struct ScreenBufferTag
{
    Screen* screens[SCREEN_BUFFER_MAX];
    int nscreens;
    int current;
    Screen* curScreen;
} ScreenBuffer;

typedef struct GamestateTag
{
    Mesh quadMesh;
    Shader shader;
    Camera camera;
    Assets assets;
    Texture* texture;
    Texture* arrowsTexture;
    Texture* conveyerTexture;
    Font* font;
    uint8_t map[GAME_MAP_HEIGHT*GAME_MAP_WIDTH];
    Machine machines[MACHINE_MAX];
    Level level;
    GUIRegion region;
    GUIRegion childRegion;
    Screen mainScreen;
    Screen optionsScreen;
    ScreenBuffer screenBuffer;
    Memory memory;
} Gamestate;

bool32_t GameInit( Memory* memory );
bool32_t GameUpdate( Memory* memory, Input* newInput, Input* oldInput, real64_t dt );
void GameRender( Memory* memory );

#define BABBALAUR_H
#endif
