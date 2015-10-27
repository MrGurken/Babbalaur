/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include "babbalaur.h"

#ifdef _WIN32
bool32_t ReadFile( const char* file, const char* fileType, struct Memory* memory )
{
    bool32_t result = false;

    std::ifstream stream( file, std::ios::in | std::ios::binary );
    if( stream.is_open() )
    {
        stream.seekg( 0, std::ios::end );
        int len = stream.tellg();
        stream.seekg( 0, std::ios::beg );
        
        if( len < memory->size )
        {
            stream.read( (char*)memory->pointer, len );
            ((char*)memory->pointer)[len] = 0;
            result = true;
        }

        stream.close();
    }
    
    return result;
}
#else
bool32_t ReadFile( const char* file, const char* fileType, struct Memory* memory )
{
	bool32_t result = false;
	
	NSString* path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:[NSString stringWithUTF8String:fileType]];
	NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	if( content.length < memory->size )
	{
		memcpy( memory->pointer, [content UTF8String], content.length );
		((char*)memory->pointer)[content.length] = 0; // null terminate string
		result = true;
	}
	
	return result;
}
#endif

void MemTexture( struct Texture* texture, int width, int height, void* pixels, GLenum format )
{
    glGenTextures( 1, &texture->id );
    glBindTexture( GL_TEXTURE_2D, texture->id );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, format, GL_UNSIGNED_BYTE, pixels );

    texture->width = width;
    texture->height = height;
}

#ifdef _WIN32
bool32_t LoadTexture( struct Texture* texture, const char* file )
{
    bool32_t result = false;

    SDL_Surface* img = IMG_Load( file );
    if( img )
    {
        GLenum format = ( img->format->BytesPerPixel == 4 ? GL_RGBA : GL_RGB );
        MemTexture( texture, img->w, img->h, img->pixels, format );
        SDL_FreeSurface( img );
        result = true;
    }

    return result;
}
#else
bool32_t LoadTexture( struct Texture* texture, const char* file )
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

void UnloadTexture( struct Texture* texture )
{
	if( texture->id > 0 )
		glDeleteTextures( 1, &texture->id );
	
	texture->id = 0;
	texture->width = texture->height = 0;
}

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
	const char* fileType = ( type == GL_VERTEX_SHADER ? "vs" : "fs" );
    if( ReadFile( file, fileType, memory ) )
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

v2 GetTileOffset( uint8_t id )
{
    v2 result;
    
    int x = (id-1) % TILESHEET_WIDTH;
    int y = (id-1) / TILESHEET_WIDTH;

    result.x = x * TILE_UV_LENGTH;
    result.y = y * TILE_UV_LENGTH;

    return result;
}

/*#ifdef _WIN32
void RenderTile( struct Shader* shader, struct Mesh* mesh, uint8_t id, v2 position )
{
    if( id > 0 )
    {
        v2 tileOffset = GetTileOffset( id );

        v3 pos( position.x, position.y, 0.0f );
        v3 scale( TILE_SIZE, TILE_SIZE, 1.0f );
    
        m4 modelMatrix = glm::scale( glm::translate( m4(), pos ), scale );
        glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, value_ptr( modelMatrix ) );
        glUniform2f( shader->uniforms[UV_OFFSET], tileOffset.x, tileOffset.y );
        glUniform1f( shader->uniforms[UV_LENGTH], TILE_UV_LENGTH );

        RenderMesh( mesh );
    }
}
#else
void RenderTile( struct Shader* shader, struct Mesh* mesh, uint8_t id, GLKVector2 position )
{
	if( id > 0 )
	{
		v2 tileOffset = GetTileOffset( id );
		
		m4 modelMatrix = GLKMatrix4Multiply( GLKMatrix4MakeTranslation( position.x, position.y, 0.0f), GLKMatrix4MakeScale( TILE_SIZE, TILE_SIZE, 1.0f ) );
		glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, modelMatrix.m );
		glUniform2f( shader->uniforms[UV_OFFSET], tileOffset.x, tileOffset.y );
		glUniform1f( shader->uniforms[UV_LENGTH], TILE_UV_LENGTH );
		
		RenderMesh( mesh );
	}
}
#endif*/
void RenderTile( struct Shader* shader, struct Mesh* mesh, uint8_t id, v2 position )
{
	if( id > 0 )
	{
		v2 tileOffset = GetTileOffset( id );
		
		m4 modelMatrix = MATRIX_MULTIPLY( MATRIX_TRANSLATION( position.x, position.y, 0.0f ), MATRIX_SCALE( TILE_SIZE, TILE_SIZE, 1.0f ) );
		glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, MATRIX_VALUE(modelMatrix) );
		glUniform2f( shader->uniforms[UV_OFFSET], tileOffset.x, tileOffset.y );
		glUniform1f( shader->uniforms[UV_LENGTH], TILE_UV_LENGTH );
		
		RenderMesh( mesh );
	}
}

bool32_t CreateCamera( struct Camera* camera )
{
    camera->position.x = camera->position.y = camera->position.z = 0.0f;

/*#ifdef _WIN32
    camera->projection = glm::ortho( 0.0f, (real32_t)WINDOW_W, (real32_t)WINDOW_H, 0.0f, -1.0f, 1.0f );
    camera->view = m4();
#else
    //camera->projection = GLKMatrix4MakeOrtho( 0.0f, (real32_t)WINDOW_W, (real32_t)WINDOW_H, 0.0f, -1.0f, 1.0f );
    CGRect bounds = [[UIScreen mainScreen] bounds];
    camera->projection = GLKMatrix4MakeOrtho( 0.0f, bounds.size.width, bounds.size.height, 0.0f, -1.0f, 1.0f );
    camera->view = GLKMatrix4Identity;
#endif*/
	
	v2 bounds;
#ifdef _WIN32
	bounds.x = WINDOW_WIDTH;
	bounds.y = WINDOW_HEIGHT;
#else
	CGRect br = [[UIScreen mainScreen] bounds];
	bounds.x = br.size.width;
	bounds.y = br.size.height;
#endif
	
	camera->projection = MATRIX_ORTHO( bounds.x, bounds.y );
	camera->view = MATRIX_IDENTITY;

    return true;
}

bool32_t GameInit( struct Memory* memory )
{
    bool32_t result = true;
    
    struct Gamestate* g = (struct Gamestate*)memory->pointer;
    g->memory.size = memory->size - sizeof(struct Gamestate);
    g->memory.pointer = (uint8_t*)memory->pointer + sizeof(struct Gamestate);

    struct Vertex quadVertices[] =
        {
            { 0, 0, 0, 0, 0 },
            { 0, 1, 0, 0, 1 },
            { 1, 0, 0, 1, 0 },
            { 1, 1, 0, 1, 1 }
        };

    GLuint quadIndices[] =
        {
            0, 1, 2,
            1, 3, 2
        };
    
    if( !CreateMesh( &g->quadMesh ) )
        result = false;
    if( !BufferMesh( &g->quadMesh, quadVertices, 4, quadIndices, 6 ) )
        result = false;

	if( !CreateShader( &g->shader ) )
		result = false;
	if( !LoadShader( &g->shader, &g->memory, "diffuse", GL_VERTEX_SHADER ) )
		result = false;
	if( !LoadShader( &g->shader, &g->memory, "diffuse", GL_FRAGMENT_SHADER ) )
		result = false;
    if( !LinkShader( &g->shader ) )
        result = false;
    AddUniform( &g->shader, "ProjectionMatrix" );
    AddUniform( &g->shader, "ViewMatrix" );
    AddUniform( &g->shader, "ModelMatrix" );
    AddUniform( &g->shader, "UVOffset" );
    AddUniform( &g->shader, "UVLength" );

    if( !CreateCamera( &g->camera ) )
        result = false;

	if( !LoadTexture( &g->texture, "tilesheet" ) )
		result = false;

    for( int y=0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x=0; x<GAME_MAP_WIDTH; x++ )
        {
            g->map[y][x] = y*TILESHEET_WIDTH+x+1;
        }
    }
    
    return result;
}

bool32_t GameUpdate( struct Memory* memory, struct Input* newInput, struct Input* oldInput, real64_t dt )
{
    return true;
}

void GameRender( struct Memory* memory )
{
    struct Gamestate* g = (struct Gamestate*)memory->pointer;
    
    glClearColor( 1.0f, 0.0f, 0.0f, 0.0f );
    glClear( GL_COLOR_BUFFER_BIT );

    glUseProgram( g->shader.program );
    glBindTexture( GL_TEXTURE_2D, g->texture.id );
	
/*#ifdef _WIN32
    glUniformMatrix4fv( g->shader.uniforms[PROJECTION_MATRIX], 1, GL_FALSE, value_ptr( g->camera.projection ) );
    glUniformMatrix4fv( g->shader.uniforms[VIEW_MATRIX], 1, GL_FALSE, value_ptr( g->camera.view ) );
#else
    glUniformMatrix4fv( g->shader.uniforms[PROJECTION_MATRIX], 1, GL_FALSE, g->camera.projection.m );
    glUniformMatrix4fv( g->shader.uniforms[VIEW_MATRIX], 1, GL_FALSE, g->camera.view.m );
#endif

    for( int y=0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x=0; x<GAME_MAP_WIDTH; x++ )
        {
#ifdef _WIN32
            RenderTile( &g->shader, &g->quadMesh, g->map[y][x], v2( x*TILE_SIZE, y*TILE_SIZE ) );
#else
			RenderTile( &g->shader, &g->quadMesh, g->map[y][x], GLKVector2Make( x*TILE_SIZE, y*TILE_SIZE ) );
#endif
        }
    }*/
	
	glUniformMatrix4fv( g->shader.uniforms[PROJECTION_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.projection ) );
	glUniformMatrix4fv( g->shader.uniforms[VIEW_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.view ) );
	
	for( int y=0; y<GAME_MAP_HEIGHT; y++ )
	{
		for( int x=0; x<GAME_MAP_WIDTH; x++ )
		{
			RenderTile( &g->shader, &g->quadMesh, g->map[y][x], MAKE_V2( x*TILE_SIZE, y*TILE_SIZE ) );
		}
	}
}
