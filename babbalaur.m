/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include "babbalaur.h"

bool32_t Contains( v2 position, v2 bounds, v2 point )
{
    return ( point.x >= position.x && point.y >= position.y &&
             point.x <= (position.x+bounds.x) && point.y <= (position.y+bounds.y) );
}

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

bool32_t CreateAssets( Assets* assets )
{
    assets->ntextures = 0;
    assets->nfonts = 0;

    return true;
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
	if( path )
	{
		NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
		if( content && content.length < memory->size )
		{
			memcpy( memory->pointer, [content UTF8String], content.length );
			((char*)memory->pointer)[content.length] = 0; // null terminate string
			result = true;
		}
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
Texture* LoadTexture( Assets* assets, const char* file, const char* name )
{
    Texture* result = 0;

    for( int i=0; i<assets->ntextures && result == 0; i++ )
        if( strncmp( assets->textureNames[i], name, ASSETS_MAX_NAME ) == 0 )
            result = &assets->textures[i];

    if( result == 0 && assets->ntextures < ASSETS_MAX_TEXTURES )
    {
        SDL_Surface* img = IMG_Load( file );
        if( img )
        {
            result = &assets->textures[assets->ntextures];
            strncpy( assets->textureNames[assets->ntextures], name, ASSETS_MAX_NAME );            
            assets->ntextures++;

            GLenum format = ( img->format->BytesPerPixel == 4 ? GL_RGBA : GL_RGB );
            MemTexture( result, img->w, img->h, img->pixels, format );
            SDL_FreeSurface( img );
        }
    }
    
    return result;
}
#else
Texture* LoadTexture( Assets* assets, const char* file, const char* name )
{
    Texture* result = 0;

    for( int i=0; i<assets->ntextures && result == 0; i++ )
        if( strncmp( assets->textureNames[i], name, ASSETS_MAX_NAME ) == 0 )
            result = &assets->textures[i];

    if( result == 0 && assets->ntextures < ASSETS_MAX_TEXTURES )
    {
        result = &assets->textures[assets->ntextures];
        strncpy( assets->textureNames[assets->ntextures], name, ASSETS_MAX_NAME );
        assets->ntextures++;
        
        NSString* texturePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:@"png"];
        NSError* theError;
        GLKTextureInfo* info = [GLKTextureLoader textureWithContentsOfFile:texturePath options:nil error:&theError];

        result->id = info.name;
        result->width = info.width;
        result->height = info.height;
    }

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
/*Font* LoadFont( Assets* assets, const char* texture, const char* info, const char* name )
{
    Font* result = 0;

    for( int i=0; i<assets->nfonts && result == 0; i++ )
        if( strncmp( assets->fontNames[i], name, ASSETS_MAX_NAME ) == 0 )
            result = &assets->fonts[i];

    if( result == 0 && assets->nfonts < ASSETS_MAX_FONTS )
    {
        result = &assets->fonts[assets->nfonts];
        strncpy( assets->fontNames[assets->nfonts], name, ASSETS_MAX_NAME );
        assets->nfonts++;

        result->texture = LoadTexture( assets, texture, name );

        if( result->texture )
        {
            std::ifstream stream( info, std::ios::in | std::ios::binary );
            if( stream.is_open() )
            {
                char buf[5] = {};
                stream.read( buf, 5 );

                result->size = buf[0];
                result->ascent = buf[1];
                result->descent = buf[2];
                result->lineskip = buf[3];
                result->linespace = buf[4];

                stream.read( (char*)(&result->advance), FONT_ASCII_RANGE );
                stream.close();
            }
        }
        else
        {
            assets->nfonts--;
            result = 0;
        }
    }

    return result;
    }*/

Font* LoadFont( Assets* assets, const char* font, const char* name )
{
    Font* result = 0;

    for( int i=0; i<assets->nfonts && result == 0; i++ )
        if( strncmp( assets->fontNames[i], name, ASSETS_MAX_NAME ) == 0 )
            result = &assets->fonts[i];

    if( result == 0 && assets->nfonts < ASSETS_MAX_FONTS )
    {
        result = &assets->fonts[assets->nfonts];
        strncpy( assets->fontNames[assets->nfonts], name, ASSETS_MAX_NAME );
        assets->nfonts++;
        
        std::ifstream stream( font, std::ios::in | std::ios::binary );
        if( stream.is_open() )
        {
            // read the path to the font texture
            char buf[FONT_MAX_PATH] = {};
            stream.read( buf, FONT_MAX_PATH );

            result->texture = LoadTexture( assets, buf, name );

            if( result->texture )
            {
                // read the font specific attributes
                stream.read( buf, 3 );
            
                result->size = buf[0];
                result->lineskip = buf[1];
                result->linespace = buf[2];

                // read the glyph specific attributes
                stream.read( (char*)(&result->advance), FONT_ASCII_RANGE );
            }
            else
            {
                assets->nfonts--;
                result = 0;
            }
            
            stream.close();
        }
    }

    return result;
}
#else
Font* LoadFont( Assets* assets, const char* file, const char* name )
{
    Font* result = 0;
    
    for( int i=0; i<assets->nfonts; i++ )
        if( strncmp( assets->fontNames[i], name, ASSETS_MAX_NAME ) == 0 )
            result = &assets->fonts[i];
    
    if( result == 0 && assets->nfonts < ASSETS_MAX_TEXTURES )
    {
        NSString* infoPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file] ofType:@".txt"];
        NSString* content = [NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
        
        if( content.length > 0 )
        {
            result = &assets->fonts[assets->nfonts];
            strncpy( assets->fontNames[assets->nfonts], name, ASSETS_MAX_NAME );
            assets->nfonts++;
            
            const char* data = [content UTF8String];
        
            // read the path to the font texture
            char buf[FONT_MAX_PATH] = {};
            strncpy( buf, data, FONT_MAX_PATH );
        
            result->texture = LoadTexture( assets, buf, name );
        
            if( result )
            {
                // read font attributes
                data += FONT_MAX_PATH;
            
                result->size = *data++;
                result->lineskip = *data++;
                result->linespace = *data++;
            
                // read glyph attributes
                for( int i=0; i<FONT_ASCII_RANGE; i++ )
                    result->advance[i] = *data++;
            }
            else
            {
                assets->nfonts--;
                result = 0;
            }
        }
    }
    
    return result;
}
#endif

v2 TextSize( Font* font, const char* text )
{
    v2 result = MAKE_v2( 0, 0 );
    real32_t width = 0.0f;

    const char* c = text;
    while( c != 0 )
    {
        if( *c == '\n' )
        {
            if( width > result.x )
                result.x = width;
            width = 0.0f;
            result.y += font->lineskip;
            c++;
        }
        else
            result.x += font->advance[*c++];
    }

    return result;
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

void RenderText( Shader* shader, Mesh* quadMesh, Font* font, const char* text, v2 position, v4 color )
{
    v2 offset = MAKE_v2( 0, 0 );
    int len = strlen( text );
    for( int i=0; i<len; i++ )
    {
        int index = text[i] - FONT_ASCII_MIN;
        if( index >= 0 && index < FONT_ASCII_RANGE )
        {
            real32_t glyphSize = (real32_t)font->size / (real32_t)font->texture->width;
        
            v2 glyphOffset = MAKE_v2( ( index % FONT_GLYPHS_PER_ROW ) * glyphSize,
                                      ( index / FONT_GLYPHS_PER_ROW ) * glyphSize );

            v2 pos = MAKE_v2( position.x+offset.x, position.y+offset.y );
    
            m4 modelMatrix = MATRIX_MULTIPLY( MATRIX_TRANSLATION( pos.x, pos.y, 0.0f ),
                                              MATRIX_SCALE( font->size, font->size, 1.0f ) );
            glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, MATRIX_VALUE(modelMatrix) );
            glUniform2f( shader->uniforms[UV_OFFSET], glyphOffset.x, glyphOffset.y );
            glUniform1f( shader->uniforms[UV_LENGTH], glyphSize );
            glUniform4f( shader->uniforms[COLOR], color.r, color.g, color.b, color.a );

            glBindTexture( GL_TEXTURE_2D, font->texture->id );

            RenderMesh( quadMesh );

            offset.x += font->advance[index];
        }
        else
        {
            if( text[i] == '\n' )
            {
                offset.x = 0.0f;
                offset.y += font->lineskip;
            }
            else if( text[i] == ' ' )
            {
                offset.x += font->linespace;
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

void RenderTile( Shader* shader, Mesh* mesh, Texture* tilesheet, uint8_t id, v2 position )
{
    if( id > 0 )
    {
        v2 tileOffset = GetTileOffset( id );
        
        m4 modelMatrix = MATRIX_MULTIPLY( MATRIX_TRANSLATION( position.x, position.y, 0.0f ),
                                          MATRIX_SCALE( TILE_SIZE, TILE_SIZE, 1.0f ) );
        glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, MATRIX_VALUE(modelMatrix) );
        glUniform2f( shader->uniforms[UV_OFFSET], tileOffset.x, tileOffset.y );
        glUniform1f( shader->uniforms[UV_LENGTH], TILE_UV_LENGTH );
        glUniform4f( shader->uniforms[COLOR], 1.0f, 1.0f, 1.0f, 1.0f );

        glBindTexture( GL_TEXTURE_2D, tilesheet->id );
        
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

bool32_t CreateFrame( Frame* frame )
{
    frame->offset.x = frame->offset.y = 0.0f;
    frame->length = frame->delay = 0.0f;

    return true;
}

bool32_t CreateAnimation( Animation* animation )
{
    for( int i=0; i<ANIMATION_MAX_FRAMES; i++ )
        if( !CreateFrame( &animation->frames[i] ) )
            return false;

    animation->nframes = 0;
    animation->current = 0;
    animation->elapsed = 0.0f;

    return true;
}

#ifdef WIN32
bool32_t LoadAnimation( Animation* animation, const char* file )
{
    bool32_t result = false;
    
    std::ifstream stream( file );
    if( stream.is_open() )
    {
        stream >> animation->nframes;
        for( int i=0; i<animation->nframes; i++ )
        {
            stream >> animation->frames[i].offset.x;
            stream >> animation->frames[i].offset.y;
            stream >> animation->frames[i].length;
            stream >> animation->frames[i].delay;
        }
        
        stream.close();
        result = true;
    }

    return result;
}
#else
bool32_t IsDigit( char c )
{
	return ( c >= '0' && c <= '9' );
}

bool32_t IsWhitespace( char c )
{
	return ( c == ' ' || c == '\t' ||
			c == '\r' || c == '\n' );
}

bool32_t IsDelimiter( char c )
{
	return ( c == ',' || c == '.' );
}

int32_t ReadInt32( char** str )
{
	int32_t result = 0;
	bool negative = false;
	
	while( IsWhitespace( **str ) || IsDelimiter( **str ) )
		(*str)++;
	
	if( *str[0] == '-' )
	{
		negative = true;
		(*str)++;
	}
	
	while( IsDigit( **str ) )
	{
		result *= 10;
		result += **str - '0';
		(*str)++;
	}
	
	return ( negative ? -result : result );
}

real32_t ReadReal32( char** str )
{
	real32_t result = 0.0f;
	bool negative = false;
	
	while( IsWhitespace( **str ) || IsDelimiter( **str ) )
		(*str)++;
	
	if( *str[0] == '-' )
	{
		negative = true;
		(*str)++;
	}
	
	// read whole part
	while( IsDigit( **str ) )
	{
		result *= 10;
		result += **str - '0';
		(*str)++;
	}
	
	if( IsDelimiter( **str ) )
	{
		(*str)++;
		
		// read fraction part
		real32_t pos = 0.1f;
		while( IsDigit( **str ) )
		{
			result += (real32_t)(**str - '0') * pos;
			pos *= 0.1f;
			(*str)++;
		}
	}
	
	return ( negative ? -result : result );
}

bool32_t LoadAnimation( Animation* animation, const char* file, Memory* memory )
{
	bool32_t result = false;
	
	if( ReadFile( file, "txt", memory ) )
	{
		char* ptr = (char*)memory->pointer;
		
		int nframes = ReadInt32( &ptr );
		animation->nframes = nframes;
		for( int i=0; i<nframes; i++ )
		{
			real32_t xoffset = ReadReal32( &ptr );
			real32_t yoffset = ReadReal32( &ptr );
			real32_t length = ReadReal32( &ptr );
			real32_t delay = ReadReal32( &ptr );
			
			animation->frames[i].offset.x = xoffset;
			animation->frames[i].offset.y = yoffset;
			animation->frames[i].length = length;
			animation->frames[i].delay = delay;
		}
		
		result = true;
	}
	
	return result;
}
#endif

void UpdateAnimation( Animation* animation, real32_t dt )
{
    if( animation->nframes > 0 )
    {
        animation->elapsed += dt;

        if( animation->elapsed > animation->frames[animation->current].delay )
        {
            animation->elapsed -= animation->frames[animation->current].delay;
            
            animation->current++;
            if( animation->current >= animation->nframes )
                animation->current = 0;
        }
    }
}

bool32_t CreateAnimator( Animator* animator )
{
    for( int i=0; i<ANIMATOR_MAX_ANIMATIONS; i++ )
        if( !CreateAnimation( &animator->animations[i] ) )
            return false;

    animator->nanimations = 0;

    return true;
}

void UpdateAnimator( Animator* animator, real32_t dt )
{
    for( int i=0; i<animator->nanimations; i++ )
        UpdateAnimation( &animator->animations[i], dt );
}

bool32_t GetCurrentFrame( Animator* animator, Frame* frame, int index )
{
    bool32_t result = false;

    if( animator->nanimations > 0 )
    {
        if( animator->animations[index].nframes > 0 )
        {
            *frame = animator->animations[index].frames[animator->animations[index].current];
            result = true;
        }
    }
    
    return result;
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

p2 NextGridPoint( int orientation )
{
    p2 result = { 0, 0 };
    
    switch( orientation )
    {
        case ORIENTATION_LEFT: result.x--; break;
        case ORIENTATION_RIGHT: result.x++; break;
        case ORIENTATION_UP: result.y--; break;
        case ORIENTATION_DOWN: result.y++; break;
    }

    return result;
}

Machine* NextMachine( Machine* machines, p2 gridPoint )
{
    Machine* current = GridToMachine( machines, gridPoint );
    p2 nextPoint = NextGridPoint( current->orientation );

    gridPoint.x += nextPoint.x;
    gridPoint.y += nextPoint.y;

    return GridToMachine( machines, gridPoint );
}

Machine* PlaceMachine( Machine* machines, p2 gridPoint, int type, int orientation )
{
    Machine* machine = GridToMachine( machines, gridPoint );
    if( machine && !machine->alive )
    {
        machine->alive = true;
        machine->type = type;
        machine->orientation = orientation;
        //machine->animator.current = orientation;
    }
    else
        machine = 0;
    return machine;
}

bool32_t PushPart( Machine* machine, Part part )
{
    bool32_t result = false;

    if( machine->ninParts < MACHINE_MAX_PARTS )
    {
        machine->inBuffer[machine->ninParts++] = part;
        result = true;
    }

    return result;
}

bool32_t PopPart( Machine* machine )
{
    bool32_t result = false;

    if( machine->ninParts > 0 )
    {
        for( int i=0; i<machine->ninParts-1; i++ )
            machine->inBuffer[i] = machine->inBuffer[i+1];
        machine->ninParts--;
        
        result = true;
    }

    return result;
}

bool32_t CreateMachine( Machine* machine, p2 gridPoint )
{
    machine->orientation = ORIENTATION_LEFT;
    machine->gridPoint = gridPoint;
    machine->alive = false;
    machine->type = 1;
    machine->delay = MACHINE_DELAY;
    machine->ninParts = 0;
    machine->noutParts = 0;

    return true; //CreateAnimator( &machine->animator );
}

void RenderMachine( Shader* shader, Mesh* mesh,
                    Texture* conveyerTexture, Texture* arrows,
                    Animator* animator,
                    Machine* machine, v2 position )
{
    if( machine->alive )
    {
        // render machine
        m4 modelMatrix = MATRIX_MULTIPLY( MATRIX_TRANSLATION( position.x, position.y, 0.0f ), MATRIX_SCALE( TILE_SIZE, TILE_SIZE, 1.0f ) );
        glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, MATRIX_VALUE(modelMatrix) );

        /*v2 offset = GetTileOffset( machine->type );
        glUniform2f( shader->uniforms[UV_OFFSET], offset.x, offset.y );
        glUniform1f( shader->uniforms[UV_LENGTH], TILE_UV_LENGTH );*/

        Frame frame;
        GetCurrentFrame( animator, &frame, machine->orientation );

        frame.offset.x /= (real32_t)conveyerTexture->width;
        frame.offset.y /= (real32_t)conveyerTexture->height;
        frame.length /= (real32_t)conveyerTexture->width;
        
        glUniform2f( shader->uniforms[UV_OFFSET], frame.offset.x, frame.offset.y );
        glUniform1f( shader->uniforms[UV_LENGTH], frame.length );

        if( machine->ninParts > 0 )
            glUniform4f( shader->uniforms[COLOR], 1.0f, 0.0f, 0.0f, 1.0f );
        else
            glUniform4f( shader->uniforms[COLOR], 1.0f, 1.0f, 1.0f, 1.0f );

        glBindTexture( GL_TEXTURE_2D, conveyerTexture->id );

        RenderMesh( mesh );

        // render arrow
        v2 offset;
        offset.x = (real32_t)( machine->orientation % 2 );
        offset.y = (real32_t)( machine->orientation / 2 );
        glUniform2f( shader->uniforms[UV_OFFSET], offset.x*0.5f, offset.y*0.5f );
        glUniform1f( shader->uniforms[UV_LENGTH], 0.5f );

        glBindTexture( GL_TEXTURE_2D, arrows->id );

        RenderMesh( mesh );
    }
}

bool32_t CreateLevel( Level* level )
{
    level->running = false;
    level->incoming = 3;
    level->outgoing = 0;
    level->delay = LEVEL_DELAY;
    level->curOrientation = ORIENTATION_DOWN;

    return true;
}

void UpdateLevel( Level* level, Machine* machines )
{
    p2 gridPoint = { 3, 0 };
    Machine* provider = GridToMachine( machines, gridPoint );

    gridPoint.y = 9;
    Machine* collector = GridToMachine( machines, gridPoint );

    if( provider )
    {
        if( level->incoming > 0 )
        {
            if( level->delay <= 0 )
            {
                PushPart( provider, PART_ARBITRARY );
                
                level->delay = LEVEL_DELAY;
                level->incoming--;
                printf( "Giving part to provider.\n" );
            }
            else
                level->delay--;
        }
    }

    int i=0;
    for( int y=0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x=0; x<GAME_MAP_WIDTH; x++, i++ )
        {
            if( machines[i].alive )
            {
                int minRequired = ( machines[i].type == MACHINE_ASSEMBLER ? 1 : 0 );
                if( machines[i].ninParts > minRequired )
                {
                    if( machines[i].delay <= 0 )
                    {
                        p2 gridPoint = { x, y };
                        Machine* next = NextMachine( machines, gridPoint );

                        if( next == collector )
                        {
                            level->outgoing++;
                            PopPart( machines+i );
                            machines[i].delay = MACHINE_DELAY;
                        }
                        else if( next && next->alive )
                        {
                            if( PushPart( next, PART_ARBITRARY ) )
                            {
                                PopPart( machines+i );
                                if( minRequired > 0 )
                                    PopPart( machines+i );
                                machines[i].delay = MACHINE_DELAY;
                            }
                        }
                    }
                    else
                        machines[i].delay--;
                }
            }
        }
    }
}

bool32_t CreateGUIRegion( GUIRegion* region, real32_t x, real32_t y, real32_t w, real32_t h )
{
    region->position.x = x;
    region->position.y = y;
    region->bounds.x = w;
    region->bounds.y = h;
    region->isDown = false;
    region->wasDown = false;
    region->background = 0;
    region->nchildren = 0;
    region->background = 0;

    return true;
}

bool32_t AddChild( GUIRegion* parent, GUIRegion* child )
{
    bool32_t result = false;
    
    if( parent->nchildren < REGION_MAX_CHILDREN )
    {
        parent->children[parent->nchildren++] = child;
        child->parent = parent;
        result = true;
    }

    return result;
}

void RemoveChildByIndex( GUIRegion* parent, int index )
{
    // NOTE: Swap the last item with the index. Then decrease the number of children
    if( index >= 0 && index < parent->nchildren )
    {
        parent->children[index]->parent = 0;
        parent->children[index] = parent->children[--parent->nchildren];
    }
}

bool32_t RemoveChild( GUIRegion* parent, GUIRegion* child )
{
    bool32_t result = false;

    for( int i=0; i<parent->nchildren && !result; i++ )
    {
        if( parent->children[i] == child )
        {
            RemoveChildByIndex( parent, i );
            result = true;
        }
    }

    return result;
}

bool32_t GUIRegionPressed( GUIRegion* region )
{
    if( region->wasDown )
        return false;
    return region->isDown;
}

bool32_t GUIRegionReleased( GUIRegion* region )
{
    if( region->isDown )
        return false;
    return region->wasDown;
}

void UpdateGUIRegion( GUIRegion* region, Input* newInput, Input* oldInput, v2 offset )
{
    region->wasDown = region->isDown;
    
    v2 position = MAKE_v2( region->position.x+offset.x, region->position.y+offset.y );
    region->isDown = ( ButtonDown( newInput, BUTTON_LEFT ) &&
                       Contains( position, region->bounds, newInput->mousePosition ) );;

    for( int i=0; i<region->nchildren; i++ )
        UpdateGUIRegion( region->children[i], newInput, oldInput, position );
}

void RenderGUIRegion( Shader* shader, Mesh* mesh, GUIRegion* region, v2 offset )
{
    m4 viewMatrix = MATRIX_IDENTITY;
    glUniformMatrix4fv( shader->uniforms[VIEW_MATRIX], 1, GL_FALSE, MATRIX_VALUE( viewMatrix ) );

    v2 position = region->position;
    position.x += offset.x;
    position.y += offset.y;
    
    m4 modelMatrix = MATRIX_MULTIPLY( MATRIX_TRANSLATION( position.x, position.y, 0.0f ),
                                      MATRIX_SCALE( region->bounds.x, region->bounds.y, 1.0f ) );
    glUniformMatrix4fv( shader->uniforms[MODEL_MATRIX], 1, GL_FALSE, MATRIX_VALUE(modelMatrix) );

    glUniform2f( shader->uniforms[UV_OFFSET], 0.0f, 0.0f );
    glUniform1f( shader->uniforms[UV_LENGTH], 1.0f );

    //glBindTexture( GL_TEXTURE_2D, region->background->id );

    RenderMesh( mesh );

    for( int i=0; i<region->nchildren; i++ )
        RenderGUIRegion( shader, mesh, region->children[i], position );
}

bool32_t CreateScreen( Screen* screen, const char* title, ScreenUpdateFunction* update, ScreenRenderFunction* render )
{
    strncpy( screen->title, title, SCREEN_MAX_TITLE );
    screen->update = update;
    screen->render = render;
    
    return true;
}

bool32_t CreateScreenBuffer( ScreenBuffer* buffer )
{
    buffer->current = 0;
    buffer->nscreens = 0;
    
    return true;
}

void PushScreen( ScreenBuffer* buffer, Screen* screen )
{
    buffer->current++;
    if( buffer->current >= SCREEN_BUFFER_MAX )
        buffer->current = 0;
    
    buffer->screens[buffer->current] = screen;
    buffer->curScreen = screen;
    
    if( buffer->nscreens < SCREEN_BUFFER_MAX )
        buffer->nscreens++;
}

void PopScreen( ScreenBuffer* buffer )
{
    if( buffer->nscreens > 0 )
    {
        buffer->current--;
        if( buffer->current < 0 )
            buffer->current = SCREEN_BUFFER_MAX-1;
    
        buffer->curScreen = buffer->screens[buffer->current];
        buffer->nscreens--;
    }
}

void MainScreen_Update( Memory* memory, Input* newInput, Input* oldInput, real32_t dt )
{
    Gamestate* g = (Gamestate*)memory->pointer;
    
    if( ButtonPressed( newInput, oldInput, BUTTON_LEFT) )
        PopScreen( &g->screenBuffer );
        //PushScreen( &g->screenBuffer, &g->optionsScreen );
}

void MainScreen_Render( Memory* memory )
{
    Gamestate* g = (Gamestate*)memory->pointer;
    
    glClearColor( 1.0f, 0.0f, 0.0f, 0.0f );
    glClear( GL_COLOR_BUFFER_BIT );
    
    glUseProgram( g->shader.program );
    glBindTexture( GL_TEXTURE_2D, g->texture->id );
    
    glUniformMatrix4fv( g->shader.uniforms[PROJECTION_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.projection ) );
    glUniformMatrix4fv( g->shader.uniforms[VIEW_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.view ) );
    glUniform4f( g->shader.uniforms[COLOR], 1.0f, 1.0f, 1.0f, 1.0f );
    
    RenderText( &g->shader, &g->quadMesh, g->font, g->mainScreen.title, MAKE_v2( 32, 32 ), MAKE_v4( 1.0f, 0.0f, 1.0f, 1.0f ) );
}

void OptionsScreen_Update( Memory* memory, Input* newInput, Input* oldInput, real32_t dt )
{
    Gamestate* g = (Gamestate*)memory->pointer;
    
    if( ButtonPressed( newInput, oldInput, BUTTON_LEFT ) )
        PopScreen( &g->screenBuffer );
}

void OptionsScreen_Render( Memory* memory )
{
    Gamestate* g = (Gamestate*)memory->pointer;
    
    glClearColor( 0.0f, 1.0f, 0.0f, 1.0f );
    glClear( GL_COLOR_BUFFER_BIT );
    
    glUseProgram( g->shader.program );
    glBindTexture( GL_TEXTURE_2D, g->texture->id );
    
    glUniformMatrix4fv( g->shader.uniforms[PROJECTION_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.projection ) );
    glUniformMatrix4fv( g->shader.uniforms[VIEW_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.view ) );
    glUniform4f( g->shader.uniforms[COLOR], 1.0f, 1.0f, 1.0f, 1.0f );
    
    RenderText( &g->shader, &g->quadMesh, g->font, g->optionsScreen.title, MAKE_v2( 32, 32 ), MAKE_v4( 0.0f, 1.0f, 1.0f, 1.0f ) );
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
    AddUniform( &g->shader, "Color" );

    if( !CreateCamera( &g->camera ) )
        result = false;

    if( !CreateAssets( &g->assets ) )
        result = false;
    else
    {
        g->texture = LoadTexture( &g->assets, TILESHEET_PATH, TILESHEET_NAME );
        g->arrowsTexture = LoadTexture( &g->assets, ARROWS_PATH, ARROWS_NAME );
        g->conveyerTexture = LoadTexture( &g->assets, CONVEYER_PATH, CONVEYER_NAME );
        g->font = LoadFont( &g->assets, FONT_PATH, FONT_NAME );

        if( !g->texture || !g->arrowsTexture || !g->font )
            result = false;
    }

    /*Animator animator;
    if( !CreateAnimator( &animator ) )
        result = false;
    if( !LoadAnimation( &animator.animations[ORIENTATION_LEFT], CONVEYER_LEFT_ANIMATION_PATH ) )
        result = false;
    if( !LoadAnimation( &animator.animations[ORIENTATION_RIGHT], CONVEYER_RIGHT_ANIMATION_PATH ) )
        result = false;
    if( !LoadAnimation( &animator.animations[ORIENTATION_UP], CONVEYER_UP_ANIMATION_PATH ) )
        result = false;
    if( !LoadAnimation( &animator.animations[ORIENTATION_DOWN], CONVEYER_DOWN_ANIMATION_PATH ) )
        result = false;
        animator.nanimations = 4;*/

    if( !CreateAnimator( &g->machineAnimator ) )
        result = false;
    if( !LoadAnimation( &g->machineAnimator.animations[ORIENTATION_LEFT], CONVEYER_LEFT_ANIMATION_PATH, &g->memory ) )
        result = false;
    if( !LoadAnimation( &g->machineAnimator.animations[ORIENTATION_RIGHT], CONVEYER_RIGHT_ANIMATION_PATH, &g->memory ) )
        result = false;
    if( !LoadAnimation( &g->machineAnimator.animations[ORIENTATION_UP], CONVEYER_UP_ANIMATION_PATH, &g->memory ) )
        result = false;
    if( !LoadAnimation( &g->machineAnimator.animations[ORIENTATION_DOWN], CONVEYER_DOWN_ANIMATION_PATH, &g->memory ) )
        result = false;
    g->machineAnimator.nanimations = 4;

    for( int y=0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x=0; x<GAME_MAP_WIDTH; x++ )
        {
            g->map[TILE_INDEX(x,y)] = 1;

            p2 gridPoint = { x, y };
            int index = TILE_INDEX(x,y);
            if( !CreateMachine( &g->machines[index], gridPoint ) )
                result = false;
        }
    }    

    p2 gridPoint = { 3, 0 };
    PlaceMachine( g->machines, gridPoint, MACHINE_PROVIDER, ORIENTATION_DOWN );
    gridPoint.y = 9;
    PlaceMachine( g->machines, gridPoint, MACHINE_COLLECTOR, ORIENTATION_DOWN );

    if( !CreateLevel( &g->level ) )
        result = false;

    if( !CreateGUIRegion( &g->region, 32, 256, 256, 128 ) )
        result = false;
    if( !CreateGUIRegion( &g->childRegion, 0, 0, 256, 12 ) )
        result = false;
    AddChild( &g->region, &g->childRegion );
    
    // make screens
    if( !CreateScreen( &g->mainScreen, "Main Menu", MainScreen_Update, MainScreen_Render ) )
        result = false;
    if( !CreateScreen( &g->optionsScreen, "Options", OptionsScreen_Update, OptionsScreen_Render ) )
        result = false;
    if( !CreateScreenBuffer( &g->screenBuffer ) )
        result = false;
    
    PushScreen( &g->screenBuffer, &g->mainScreen );
    PushScreen( &g->screenBuffer, &g->optionsScreen );

    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    glEnable( GL_BLEND );
    
    return result;
}

bool32_t GameUpdate( Memory* memory, Input* newInput, Input* oldInput, real64_t dt )
{
    bool32_t result = false;
    
    Gamestate* g = (Gamestate*)memory->pointer;

#if 0
    if( g->screenBuffer.nscreens >  0 )
    {
        g->screenBuffer.curScreen->update( memory, newInput, oldInput, dt );
        result = true;
    }
#else
    if( ButtonReleased( newInput, oldInput, BUTTON_LEFT ) )
    {
        v2 mpos = newInput->mousePosition;
        v2 worldPos = ScreenToWorld( g->camera.position, mpos );
        p2 gridPoint = WorldToGrid( worldPos );

        Machine* machine = PlaceMachine( g->machines, gridPoint, MACHINE_CONVEYER_BELT, g->level.curOrientation );
        if( machine )
        {
            printf( "Placed %d at %d:%d\n", machine, gridPoint.x, gridPoint.y );
        }
        else
            printf( "Failed to place machine.\n" );
    }

    if( ButtonReleased( newInput, oldInput, BUTTON_RIGHT ) )
    {
        v2 mpos = newInput->mousePosition;
        v2 worldPos = ScreenToWorld( g->camera.position, mpos );
        p2 gridPoint = WorldToGrid( worldPos );

        Machine* machine = PlaceMachine( g->machines, gridPoint, MACHINE_ASSEMBLER, g->level.curOrientation );
        if( machine )
        {
            printf( "Placed %d at %d:%d\n", machine, gridPoint.x, gridPoint.y );
        }
        else
            printf( "Failed to place assembler.\n" );
    }

    if( KeyReleased( newInput, oldInput, KEY_SPACE ) )
    {
        g->level.running = !g->level.running;
    }

    if( KeyReleased( newInput, oldInput, KEY_ENTER ) )
    {
        g->level.curOrientation++;
        if( g->level.curOrientation > ORIENTATION_DOWN )
            g->level.curOrientation = ORIENTATION_LEFT;

        printf( "Orientation: %d\n", g->level.curOrientation );
    }

    /*for( int i=0; i<MACHINE_MAX; i++ )
    {
        //if( g->machines[i].alive )
        {
            UpdateAnimator( &g->machines[i].animator, dt );
        }
        }*/

    UpdateAnimator( &g->machineAnimator, dt );

    if( g->level.running )
    {
        UpdateLevel( &g->level, g->machines );
    }
    
    result = true;
#endif
    
    return result;
}

void GameRender( Memory* memory )
{
    Gamestate* g = (Gamestate*)memory->pointer;

#if 0
    if( g->screenBuffer.nscreens > 0 )
        g->screenBuffer.curScreen->render( memory );
#else
    glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
    glClear( GL_COLOR_BUFFER_BIT );

    glUseProgram( g->shader.program );
    glBindTexture( GL_TEXTURE_2D, g->texture->id );
    
    glUniformMatrix4fv( g->shader.uniforms[PROJECTION_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.projection ) );
    glUniformMatrix4fv( g->shader.uniforms[VIEW_MATRIX], 1, GL_FALSE, MATRIX_VALUE( g->camera.view ) );
    glUniform4f( g->shader.uniforms[COLOR], 1.0f, 1.0f, 1.0f, 1.0f );
    
    for( int y=0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x=0; x<GAME_MAP_WIDTH; x++ )
        {
            RenderTile( &g->shader, &g->quadMesh, g->texture,
                        g->map[TILE_INDEX(x,y)], MAKE_v2( x*TILE_SIZE, y*TILE_SIZE ) );
            RenderMachine( &g->shader, &g->quadMesh,
                           g->conveyerTexture, g->arrowsTexture,
                           &g->machineAnimator,
                           &g->machines[TILE_INDEX(x,y)],
                           MAKE_v2( x*TILE_SIZE, y*TILE_SIZE ) );
        }
    }
#endif
}
