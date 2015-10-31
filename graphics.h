#if !defined(GRAPHICS_H)
/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

// INCLUSION
#ifdef _WIN32
#include "GL\glew.h"
#include "windows.h"
#include "SDL_image.h"

#define GEN_VERTEX_ARRAYS( n, ptr ) glGenVertexArrays( n, ptr )
#define BIND_VERTEX_ARRAY( vao ) glBindVertexArray( vao )

#else

#define GEN_VERTEX_ARRAYS( n, ptr ) glGenVertexArraysOES( n, ptr )
#define BIND_VERTEX_ARRAY( vao ) glBindVertexArrayOES( vao )

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#endif

#include "io.h"

// STRUCTS
#define SHADER_MAX_UNIFORMS 14
enum
{
    PROJECTION_MATRIX=0,
    VIEW_MATRIX,
    MODEL_MATRIX,
    UV_OFFSET,
    UV_LENGTH
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

typedef struct MeshTag
{
    GLuint vao;
    GLuint vbo;
    GLuint ibo;
    int size;
} Mesh;

// MACROS AND FUNCTIONS

void MemTexture( Texture* texture, int width, int height, void* pixels, GLenum format )
{
    
}

#ifdef _WIN32
bool32_t LoadTexture( Texture* texture, const char* file )
{
    bool32_t result = false;

    SDL_Surface* img = IMG_Load( file );
    if( img )
    {
        GLenum format = ( img->format->BytesPerPixel == 4 ? GL_RGBA : GL_RGB );
        
        glGenTextures( 1, &texture->id );
        glBindTexture( GL_TEXTURE_2D, texture->id );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, img->w, img->h, 0, format, GL_UNSIGNED_BYTE, img->pixels );

        texture->width = img->w;
        texture->height = img->h;
    
        SDL_FreeSurface( img );
        result = true;
    }

    return result;
}

#else

bool32_t LoadTexture( Texture* texture, const char* file )
{
    bool32_t result = false;
    
    NSString* texturePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:@"png"];
    NSError* theError;
    GLKTextureInfo* info = [GLKTextureLoader textureWithContentsOfFile:texturePath options:nil error:&theError];
    
    texture->id = info.name;
    texture->width = info.width;
    texture->height = info.height;
    
    return result;
}
#endif

void UnloadTexture( Texture* texture )
{
    if( texture->id > 0 )
        glDeleteTextures( 1, &texture->id );
    
    texture->id = 0;
    texture->width = texture->height = 0;
}

bool32_t CreateShader( Shader* shader )
{
    shader->program = glCreateProgram();
    shader->nuniforms = 0;

    return true;
}

bool32_t MemShader( Shader* shader, const char* source, GLenum type )
{
    bool32_t result = true;
    
    GLuint s = glCreateShader( type );
    glShaderSource( s, 1, &source, 0 );
    glCompileShader( s );

#ifdef DEBUG
    GLint success;
    glGetShaderiv( s, GL_COMPILE_STATUS, &success );
    if( success == GL_FALSE )
    {
        char buf[1024] = {};
        int len = 1024;
        glGetShaderInfoLog( s, 1024, &len, buf );
        printf( "Shader compilation failed:\n%s\n", buf );
        result = false;
    }
    else
#endif
    {
        glAttachShader( shader->program, s );
        glDeleteShader( s );
    }

    return result;
}

bool32_t LoadShader( Shader* shader, Memory* memory, const char* file, GLenum type )
{
    const char* fileType = ( type == GL_VERTEX_SHADER ? "vs" : "fs" );
    if( ReadFile( file, fileType, memory ) )
        return MemShader( shader, (const char*)memory->pointer, type );
    return false;
}

bool32_t LinkShader( Shader* shader )
{
    bool32_t result = true;
    glLinkProgram( shader->program );

#ifdef DEBUG
    GLint success;
    glGetProgramiv( shader->program, GL_LINK_STATUS, &success );
    if( success == GL_FALSE )
    {
        char buf[1024] = {};
        int len = 1024;
        glGetProgramInfoLog( shader->program, 1024, &len, buf );
        printf( "Shader linking failed:\n%s\n", buf );
        result = false;
    }
#endif

    return result;
}

bool32_t AddUniform( Shader* shader, const char* uniform )
{
    bool32_t result = false;
    
    GLint location = glGetUniformLocation( shader->program, uniform );
    shader->uniforms[shader->nuniforms++] = location;
    result = ( location >= 0 );

    return result;
}

bool32_t CreateMesh( Mesh* mesh )
{
    /*
#ifdef _WIN32
    glGenVertexArrays( 1, &mesh->vao );
    glBindVertexArray( mesh->vao );
#else
    glGenVertexArraysOES( 1, &mesh->vao );
    glBindVertexArrayOES( mesh->vao );
    #endif*/

    GEN_VERTEX_ARRAYS( 1, &mesh->vao );
    BIND_VERTEX_ARRAY( mesh->vao );

    glGenBuffers( 1, &mesh->vbo );
    glBindBuffer( GL_ARRAY_BUFFER, mesh->vbo );
    
    glGenBuffers( 1, &mesh->ibo );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, mesh->ibo );

    glEnableVertexAttribArray( 0 );
    glEnableVertexAttribArray( 1 );

    glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0 );
    glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)(sizeof(GLfloat)*3) );

    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
    
/*#ifdef _WIN32
    glBindVertexArray( 0 );
#else
    glBindVertexArrayOES( 0 );
    #endif*/

    BIND_VERTEX_ARRAY( 0 );
    
    mesh->size = 0;
    return true;
}

bool32_t BufferMesh( Mesh* mesh, Vertex* v, int nv, GLuint* i, int ni )
{
/*#ifdef _WIN32
    glBindVertexArray( mesh->vao );
#else
    glBindVertexArrayOES( mesh->vao );
#endif*/

    BIND_VERTEX_ARRAY( mesh->vao );
    
    glBindBuffer( GL_ARRAY_BUFFER, mesh->vbo );
    glBufferData( GL_ARRAY_BUFFER, sizeof(Vertex)*nv, v, GL_STATIC_DRAW );

    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, mesh->ibo );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*ni, i, GL_STATIC_DRAW );

    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
    
/*#ifdef _WIN32
    glBindVertexArray( 0 );
#else
    glBindVertexArrayOES( 0 );
    #endif*/

    BIND_VERTEX_ARRAY( 0 );

    mesh->size = ni;

    return true;
}

void RenderMesh( Mesh* mesh )
{
/*#ifdef _WIN32
    glBindVertexArray( mesh->vao );
#else
    glBindVertexArrayOES( mesh->vao );
    #endif*/

    BIND_VERTEX_ARRAY( mesh->vao );
    glBindBuffer( GL_ARRAY_BUFFER, mesh->vbo );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, mesh->ibo );
    glDrawElements( GL_TRIANGLES, mesh->size, GL_UNSIGNED_INT, 0 );
}

#define GRAPHICS_H
#endif
