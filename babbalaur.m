/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include "babbalaur.h"

bool32_t ButtonDown( Input* input, int index )
{
    return input->buttons[index];
}

bool32_t ButtonUp( Input* input, int index )
{
    return !input->buttons[index];
}

bool32_t ButtonPressed( Input* newInput, Input* oldInput, int index )
{
    if( ButtonUp( newInput, index ) )
        return false;
    return ButtonUp( oldInput, index );
}

bool32_t ButtonReleased( Input* newInput, Input* oldInput, int index )
{
    if( ButtonDown( newInput, index ) )
        return false;
    return ButtonDown( oldInput, index );
}

bool32_t KeyDown( Input* input, int index )
{
    return input->keys[index];
}

bool32_t KeyUp( Input* input, int index )
{
    return !input->keys[index];
}

bool32_t KeyPressed( Input* newInput, Input* oldInput, int index )
{
    if( KeyUp( newInput, index ) )
        return false;
    return KeyUp( oldInput, index );
}

bool32_t KeyReleased( Input* newInput, Input* oldInput, int index )
{
    if( KeyDown( newInput, index ) )
        return false;
    return KeyDown( oldInput, index );
}

#ifdef _WIN32
bool32_t ReadFile( const char* file, const char* fileType, Memory* memory )
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
bool32_t ReadFile( const char* file, const char* fileType, Memory* memory )
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

void MemTexture( Texture* texture, int w, int h, void* pixels, GLenum format )
{    
    glGenTextures( 1, &texture->id );
    glBindTexture( GL_TEXTURE_2D, texture->id );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, format, GL_UNSIGNED_BYTE, pixels );

    texture->width = w;
    texture->height = h;
}

#ifdef _WIN32
bool32_t LoadTexture( Texture* texture, const char* file )
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

#ifdef _WIN32
bool32_t LoadFont( Font* font, const char* file, int size )
{
    bool32_t result = false;

    TTF_Font* sdlFont = TTF_OpenFont( file, size );
    if( sdlFont )
    {
        int glyphsGenerated = 0;
        SDL_Color white = { 255, 255, 255 };
        
        for( int i=0; i<FONT_MAX_GLYPHS; i++ )
        {
            char buf[2] = { (char)i, 0 }; // have to be null terminated
            SDL_Surface* pre = TTF_RenderText_Solid( sdlFont, buf, white );

            if( pre )
            {
                SDL_Surface* post = SDL_CreateRGBSurface( 0, pre->w, pre->h, 32, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000 );
                SDL_BlitSurface( pre, 0, post, 0 );

                if( post )
                {
                    MemTexture( &font->glyphs[i], post->w, post->h, post->pixels, GL_RGBA );

                    // TODO: Retrieve kerning from OS
                
                    glyphsGenerated++;
                    SDL_FreeSurface( post );
                }
                
                SDL_FreeSurface( pre );
                pre = 0;
            }
        }
        
        TTF_CloseFont( sdlFont );

        if( glyphsGenerated > 32 )
        {
            result = true;
            font->size = size;

            // TODO: Remove this once we have working kerning
            for( int i=0; i<FONT_MAX_GLYPHS*FONT_MAX_GLYPHS; i++ )
                font->kerning[i] = 0;
        }
    }
    
    return result;
}
#else
bool32_t LoadFont( Font* font, const char* file, int size )
{
	// NOTE: The filetype is assumed to be .ttf (TrueType Font)
	
	bool32_t result = false;
	
	NSString* texturePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:@"ttf"];
	NSError* theError;
	
	return result;
}
#endif

void UnloadFont( Font* font )
{
	for( int i=0; i<FONT_MAX_GLYPHS; i++ )
		UnloadTexture( &font->glyphs[i] );
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

    BIND_VERTEX_ARRAY( 0 );
    
    mesh->size = 0;
    return true;
}

bool32_t BufferMesh( Mesh* mesh, Vertex* v, int nv, GLuint* i, int ni )
{
    BIND_VERTEX_ARRAY( mesh->vao );
    
    glBindBuffer( GL_ARRAY_BUFFER, mesh->vbo );
    glBufferData( GL_ARRAY_BUFFER, sizeof(Vertex)*nv, v, GL_STATIC_DRAW );

    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, mesh->ibo );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(GLuint)*ni, i, GL_STATIC_DRAW );

    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );

    BIND_VERTEX_ARRAY( 0 );
    
    mesh->size = ni;

    return true;
}

void RenderMesh( Mesh* mesh )
{
    BIND_VERTEX_ARRAY( mesh->vao );
    
    glBindBuffer( GL_ARRAY_BUFFER, mesh->vbo );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, mesh->ibo );
    glDrawElements( GL_TRIANGLES, mesh->size, GL_UNSIGNED_INT, 0 );
}

int GetKerning( Font* font, char a, char b )
{
    return ( font->kerning[a*FONT_MAX_GLYPHS+b] );
}

void RenderText( Shader* shader, Mesh* quadMesh, Font* font, const char* text, v2 position )
{
	char minChar = (char)FONT_ASCII_MIN;
	char maxChar = (char)FONT_ASCII_MAX;
	
    v2 offset = MAKE_v2( 0, 0 );
    int len = strlen( text );
    for( int i=0; i<len; i++ )
    {
        Texture* glyph = &font->glyphs[text[i]];
		
        if( text[i] > minChar && text[i] < maxChar )
        {
            m4 modelMatrix = MATRIX_MULTIPLY( MATRIX_TRANSLATION( position.x+offset.x, position.y+offset.y, 0 ), MATRIX_SCALE( glyph->width, glyph->height, 1.0f ) );
            glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, MATRIX_VALUE(modelMatrix) );
            glUniform2f( shader->uniforms[UV_OFFSET], 0.0f, 0.0f );
            glUniform1f( shader->uniforms[UV_LENGTH], 1.0f );

            glBindTexture( GL_TEXTURE_2D, glyph->id );

            RenderMesh( quadMesh );
        }

        if( text[i] == '\n' )
        {
            offset.x = 0;
            offset.y += font->size;
        }
        else
        {
            offset.x += glyph->width;
            if( i < len-1 )
            {
                offset.x += GetKerning( font, text[i], text[i+1] );
            }
        }
    }
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

void RenderTile( Shader* shader, Mesh* mesh, uint8_t id, v2 position )
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

bool32_t CreateCamera( Camera* camera )
{
    camera->position.x = camera->position.y = camera->position.z = 0.0f;

    camera->projection = MATRIX_ORTHO( (real32_t)WINDOW_W, (real32_t)WINDOW_H );
    camera->view = MATRIX_IDENTITY;

    return true;
}

uint8_t GetTileID( uint8_t* map, int x, int y )
{
    return map[y*GAME_MAP_WIDTH+x];
}

v2 ScreenToWorld( v3 world, v2 screen )
{
    return MAKE_v2( screen.x+world.x, screen.y+world.y );
}

v2 WorldToScreen( v3 world, v2 screen )
{
    return MAKE_v2( screen.x+world.x, screen.y+world.y );
}

p2 WorldToGrid( v2 world )
{
    p2 gridPoint;
    gridPoint.x = (int)( world.x / TILE_SIZE );
    gridPoint.y = (int)( world.y / TILE_SIZE );
    return gridPoint;
}

Machine* GetMachine( Machine* machines, int x, int y )
{
    return &machines[y*GAME_MAP_WIDTH+x];
}

Machine* GridToMachine( Machine* machines, p2 gridPoint )
{
    Machine* result = 0;

    if( gridPoint.x >= 0 && gridPoint.x < GAME_MAP_WIDTH &&
        gridPoint.y >= 0 && gridPoint.y < GAME_MAP_HEIGHT )
    {
        result = GetMachine( machines, gridPoint.x, gridPoint.y );
    }
    
    return result;
}

bool32_t GetAdjacentMachines( Machine* machines,
                              p2 gridPoint,
                              Machine** buffer )
{
    bool32_t result = false;

    int i=0;
    for( int y=gridPoint.y-1; y<MACHINE_ADJ_LENGTH; y++ )
    {
        for( int x=gridPoint.x-1; x<MACHINE_ADJ_LENGTH; x++, i++ )
        {
            if( x == 1 && y == 1 )
                continue;
            
            p2 index = { x, y };
            Machine* ptr = GridToMachine( machines, index );

            if( ptr && ptr->alive )
            {
                result = true;
                buffer[i] = ptr;
            }
            else
                buffer[i] = 0;
        }
    }
    
    return result;
}

bool32_t GetAdjacentMachine( Machine* machines,
                             p2 gridPoint,
                             Machine** buffer,
                             int direction )
{
    bool32_t result = false;
    
    p2 offset = {};
    switch( direction )
    {
        case MACHINE_ADJ_TOP_LEFT: offset.x = -1; offset.y = -1; break;
        case MACHINE_ADJ_TOP: offset.y = -1; break;
        case MACHINE_ADJ_TOP_RIGHT: offset.x = 1; offset.y = -1; break;
        case MACHINE_ADJ_LEFT: offset.x = -1; break;
        case MACHINE_ADJ_RIGHT: offset.x = 1; break;
        case MACHINE_ADJ_BOTTOM_LEFT: offset.x = -1; offset.y = 1; break;
        case MACHINE_ADJ_BOTTOM: offset.y = 1; break;
        case MACHINE_ADJ_BOTTOM_RIGHT: offset.x = 1; offset.y = 1; break;
    }

    p2 index = { gridPoint.x + offset.x, gridPoint.y + offset.y };
    Machine* ptr = GridToMachine( machines, index );

    if( ptr && ptr->alive )
    {
        *buffer = ptr;
        result = true;
    }
    else
        *buffer = 0;

    return result;
}

Machine* PlaceMachine( Machine* machines, p2 gridPoint, int type )
{
    Machine* machine = GridToMachine( machines, gridPoint );
    if( machine && !machine->alive )
    {
        machine->alive = true;
        machine->type = type;
    }
    else
        machine = 0;
    return machine;
}

bool32_t CreateMachine( Machine* machine, p2 gridPoint )
{
    machine->orientation = ORIENTATION_LEFT;
    machine->gridPoint = gridPoint;
    machine->alive = false;
    machine->type = 1;

    return true;
}

void RenderMachine( Shader* shader, Mesh* mesh, Machine* machine, v2 position )
{
    if( machine->alive )
    {
        m4 modelMatrix = MATRIX_MULTIPLY( MATRIX_TRANSLATION( position.x, position.y, 0.0f ), MATRIX_SCALE( TILE_SIZE, TILE_SIZE, 1.0f ) );
        glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, MATRIX_VALUE(modelMatrix) );
        glUniform2f( shader->uniforms[UV_OFFSET], 0.0f, 0.0f );
        glUniform1f( shader->uniforms[UV_LENGTH], 1.0f );

        RenderMesh( mesh );
    }
}

bool32_t GameInit( Memory* memory )
{
    bool32_t result = true;
    
    Gamestate* g = (Gamestate*)memory->pointer;
    int stateSize = sizeof(Gamestate);
    g->memory.size = memory->size - stateSize;
    g->memory.pointer = (uint8_t*)memory->pointer + stateSize;
    
    printf( "Allocated memory %d, used %d, temp %d.\n", memory->size, stateSize, g->memory.size );

    Vertex quadVertices[] =
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
    if( !LoadShader( &g->shader, &g->memory, DIFFUSE_VS_PATH, GL_VERTEX_SHADER ) )
        result = false;
    if( !LoadShader( &g->shader, &g->memory, DIFFUSE_FS_PATH, GL_FRAGMENT_SHADER ) )
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

    if( !LoadTexture( &g->texture, TILESHEET_PATH ) )
        result = false;
    if( !LoadFont( &g->font, FONT_PATH, 24 ) )
        result = false;

    for( int y=0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x=0; x<GAME_MAP_WIDTH; x++ )
        {
            g->map[TILE_INDEX(x,y)] = TILE_INDEX(x,y)+1;

            p2 gridPoint = { x, y };
            if( !CreateMachine( &g->machines[TILE_INDEX(x,y)], gridPoint ) )
            {
                result = false;
            }
        }
    }

    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glEnable( GL_BLEND );
    
    return result;
}

bool32_t GameUpdate( Memory* memory, Input* newInput, Input* oldInput, real64_t dt )
{
    Gamestate* g = (Gamestate*)memory->pointer;
    
    if( ButtonReleased( newInput, oldInput, BUTTON_LEFT ) )
    {
        v2 mpos = newInput->mousePosition;
        v2 worldPos = ScreenToWorld( g->camera.position, mpos );
        p2 gridPoint = WorldToGrid( worldPos );

        Machine* machine = PlaceMachine( g->machines, gridPoint, 2 );
        if( machine )
            printf( "Placed machine at %d:%d\n", gridPoint.x, gridPoint.y );
        else
            printf( "Failed to place machine.\n" );
    }
    return true;
}

void GameRender( Memory* memory )
{
    Gamestate* g = (Gamestate*)memory->pointer;
    
    glClearColor( 1.0f, 0.0f, 0.0f, 0.0f );
    glClear( GL_COLOR_BUFFER_BIT );

    glUseProgram( g->shader.program );
    glBindTexture( GL_TEXTURE_2D, g->texture.id );
    
    glUniformMatrix4fv( g->shader.uniforms[PROJECTION_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.projection ) );
    glUniformMatrix4fv( g->shader.uniforms[VIEW_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.view ) );
    
    for( int y=0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x=0; x<GAME_MAP_WIDTH; x++ )
        {
            RenderTile( &g->shader, &g->quadMesh, g->map[TILE_INDEX(x,y)], MAKE_v2( x*TILE_SIZE, y*TILE_SIZE ) );
            RenderMachine( &g->shader, &g->quadMesh, &g->machines[TILE_INDEX(x,y)], MAKE_v2( x*TILE_SIZE, y*TILE_SIZE ) );
        }
    }

    RenderText( &g->shader, &g->quadMesh, &g->font, "Testing...", MAKE_v2( 32, 32 ) );
}
