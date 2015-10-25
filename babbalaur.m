/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include "babbalaur.h"

#ifdef _WIN32
bool32_t ReadFile( const char* file, Memory* memory )
{
    bool32_t result = false;
    
    std::ifstream stream( file );
    if( stream.is_open() )
    {
        stream.seekg( 0, std::ios::end );
        int len = stream.tellg();
        stream.seekg( 0, std::ios::beg );

        if( len < memory->size )
        {
            stream.read( (char*)memory->pointer, len );
            ((char*)memory->pointer)[memory->size-1] = 0;
            result = true;
        }
        
        stream.close();
    }

    return result;
}
#else
bool32_t ReadFile( const char* file, struct Memory* memory )
{
	bool32_t result = false;
	
	NSString* str = [NSString stringWithContentsOfFile:[NSString stringWithUTF8String:file] encoding:NSUTF8StringEncoding error:nil];
	if( str.length < memory->size )
	{
		memcpy( memory->pointer, [str UTF8String], str.length );
		result = true;
	}
	
	return result;
}
#endif

bool32_t CreateShader( struct Shader* shader )
{
    shader->program = glCreateProgram();
    shader->nuniforms = 0;

    return true;
}

bool32_t MemShader( struct Shader* shader, const char* source, GLenum type )
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

bool32_t LoadShader( struct Shader* shader, struct Memory* memory, const char* file, GLenum type )
{
    if( ReadFile( file, memory ) )
        return MemShader( shader, (const char*)memory->pointer, type );
    return false;
}

bool32_t LinkShader( struct Shader* shader )
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

bool32_t AddUniform( struct Shader* shader, const char* uniform )
{
    bool32_t result = false;
    
    GLint location = glGetUniformLocation( shader->program, uniform );
    shader->uniforms[shader->nuniforms++] = location;
    result = ( location >= 0 );

    return result;
}

bool32_t CreateMesh( struct Mesh* mesh )
{
#ifdef _WIN32
    glGenVertexArrays( 1, &mesh->vao );
    glBindVertexArray( mesh->vao );
#else
	glGenVertexArraysOES( 1, &mesh->vao );
	glBindVertexArrayOES( mesh->vao );
#endif

    glGenBuffers( 1, &mesh->vbo );
    glBindBuffer( GL_ARRAY_BUFFER, mesh->vbo );
    
    glGenBuffers( 1, &mesh->ibo );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, mesh->ibo );

    glEnableVertexAttribArray( 0 );
    glEnableVertexAttribArray( 1 );

    glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, sizeof(struct Vertex), 0 );
    glVertexAttribPointer( 1, 2, GL_FLOAT, GL_FALSE, sizeof(struct Vertex), (void*)(sizeof(GLfloat)*3) );

    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
#ifdef _WIN32
    glBindVertexArray( 0 );
#else
	glBindVertexArrayOES( 0 );
#endif
	
    mesh->size = 0;
    return true;
}

bool32_t BufferMesh( struct Mesh* mesh, struct Vertex* v, int nv, GLuint* i, int ni )
{
#ifdef _WIN32
	glBindVertexArray( mesh->vao );
#else
	glBindVertexArrayOES( mesh->vao );
#endif
	
    glBindBuffer( GL_ARRAY_BUFFER, mesh->vbo );
    glBufferData( GL_ARRAY_BUFFER, sizeof(struct Vertex)*nv, v, GL_STATIC_DRAW );

    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, mesh->ibo );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*ni, i, GL_STATIC_DRAW );

    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
	
#ifdef _WIN32
	glBindVertexArray( 0 );
#else
    glBindVertexArrayOES( 0 );
#endif

    mesh->size = ni;

    return true;
}

void RenderMesh( struct Mesh* mesh )
{
#ifdef _WIN32
	glBindVertexArray( mesh->vao );
#else
	glBindVertexArrayOES( mesh->vao );
#endif
    glBindBuffer( GL_ARRAY_BUFFER, mesh->vbo );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, mesh->ibo );
    glDrawElements( GL_TRIANGLES, mesh->size, GL_UNSIGNED_INT, 0 );
}

bool32_t CreateCamera( struct Camera* camera )
{
    camera->position.x = camera->position.y = camera->position.z = 0.0f;

#ifdef _WIN32
    camera->projection = glm::ortho( 0.0f, (real32_t)WINDOW_W, (real32_t)WINDOW_H, 0.0f, -1.0f, 1.0f );
    camera->view = m4();
#else
	//camera->projection = GLKMatrix4MakeOrtho( 0.0f, (real32_t)WINDOW_W, (real32_t)WINDOW_H, 0.0f, -1.0f, 1.0f );
	CGRect bounds = [[UIScreen mainScreen] bounds];
	camera->projection = GLKMatrix4MakeOrtho( 0.0f, bounds.size.width, bounds.size.height, 0.0f, -1.0f, 1.0f );
	camera->view = GLKMatrix4Identity;
#endif

    return true;
}

bool32_t GameInit( struct Memory* memory )
{
    bool32_t result = true;
    
    struct Gamestate* g = (struct Gamestate*)memory->pointer;

    struct Vertex vdata[] =
    {
        /*{ 0, 0, 0, 0.5f, 0.5f },
        { 1, -1, 0, 1.0f, 1.0f },
        { -1, -1, 0, 0.0f, 1.0f }*/
        { 0, 0, 0, 0, 0 },
        { 128, 128, 0, 1, 1 },
        { 0, 128, 0, 0, 1 }
    };

    GLuint idata[] =
    {
        0, 1, 2
    };
    
    if( !CreateMesh( &g->mesh ) )
        result = false;
    if( !BufferMesh( &g->mesh, vdata, 9, idata, 3 ) )
        result = false;
	
	const char* vsource = "attribute vec3 PositionIn;"
	"uniform mat4 ProjectionMatrix;"
	"uniform mat4 ViewMatrix;"
	"uniform mat4 ModelMatrix;"
	"void main() { gl_Position = ProjectionMatrix * ViewMatrix * ModelMatrix * vec4( PositionIn, 1.0 ); }";
	const char* fsource = "void main() { gl_FragColor = vec4( 0.0, 0.0, 1.0, 1.0 ); }";

    if( !CreateShader( &g->shader ) )
        result = false;
    if( !MemShader( &g->shader, vsource, GL_VERTEX_SHADER ) )
        result = false;
    if( !MemShader( &g->shader, fsource, GL_FRAGMENT_SHADER ) )
        result = false;
    if( !LinkShader( &g->shader ) )
        result = false;
    if( !AddUniform( &g->shader, "ProjectionMatrix" ) )
        result = false;
    if( !AddUniform( &g->shader, "ViewMatrix" ) )
        result = false;
    if( !AddUniform( &g->shader, "ModelMatrix" ) )
        result = false;

    if( !CreateCamera( &g->camera ) )
        result = false;
    
    return result;
}

bool32_t GameUpdate( struct Memory* memory, struct Input* newInput, struct Input* oldInput, real64_t dt )
{
    return true;
}

void GameRender( struct Memory* memory )
{
    struct Gamestate* g = (struct Gamestate*)memory->pointer;
    
    glClearColor( 1.0f, 0.0f, 0.0f, 1.0f );
    glClear( GL_COLOR_BUFFER_BIT );

    glUseProgram( g->shader.program );
#ifdef _WIN32
    glUniformMatrix4fv( g->shader.uniforms[0], 1, GL_FALSE, value_ptr( g->camera.projection ) );
    glUniformMatrix4fv( g->shader.uniforms[1], 1, GL_FALSE, value_ptr( g->camera.view ) );
    glUniformMatrix4fv( g->shader.uniforms[2], 1, GL_FALSE, value_ptr( m4() ) );
#else
	glUniformMatrix4fv( g->shader.uniforms[0], 1, GL_FALSE, g->camera.projection.m );
	glUniformMatrix4fv( g->shader.uniforms[1], 1, GL_FALSE, g->camera.view.m );
	glUniformMatrix4fv( g->shader.uniforms[2], 1, GL_FALSE, GLKMatrix4Identity.m );
#endif
    RenderMesh( &g->mesh );
}
