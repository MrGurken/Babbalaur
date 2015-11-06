/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */
#include "GL\glew.h"
#include "GL\wglew.h"
#include "SDL.h"
#include "SDL_ttf.h."
#include "SDL_image.h"
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <string>
using namespace std;

#define ASCII_SPACE 32
#define ASCII_DEL 127
#define ASCII_RANGE (ASCII_DEL-ASCII_SPACE-1) // 95

#define CHARS_PER_ROW 10 // 10*10 = 100, we need 96

typedef struct GlyphTag
{
    SDL_Surface* surface;
    uint8_t advance;
} Glyph;

int main( int argc, char* argv[] )
{
    if( argc < 4 )
    {
        printf( "Usage: font_maker.exe [fontname] [fontsize] [filename]\n" );
        printf( "[fontname] is the location of the font you wish to load.\n" );
        printf( "[fontsize] is roughly the vertical size of the font in pixels.\n" );
        printf( "[filename] is the name of the file you wish to save as.\n" );
        return 0;
    }
    else
    {
        if( SDL_Init( SDL_INIT_EVERYTHING ) < 0 ||
            TTF_Init() < 0 )
        {
            printf( "Failed to initialize SDL.\n" );
            return -1;
        }

        int generatedGlyphs = 0;
        
        const char* fontname = argv[1];
        int fontsize = atoi( argv[2] );
        const char* filename = argv[3];
        
        if( fontsize > 0 )
        {
            TTF_Font* font = TTF_OpenFont( fontname, fontsize );
            if( font )
            {
                SDL_Color white = { 255, 255, 255 };
                SDL_Color red = { 255, 0, 0 };
                Glyph glyphs[ASCII_RANGE] = {};

                for( int i=0; i<ASCII_RANGE; i++ )
                {
                    char glyphCharacter = (char)(i+ASCII_SPACE+1);
#if 1
                    SDL_Surface* pre = TTF_RenderGlyph_Solid( font, glyphCharacter, white );
#else
                    SDL_Surface* pre = TTF_RenderGlyph_Solid( font, glyphCharacter, red );
#endif

                    if( pre )
                    {
                        SDL_Surface* post = SDL_CreateRGBSurface( 0, pre->w, pre->h, 32, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000 );
                        SDL_BlitSurface( pre, 0, post, 0 );

                        if( post )
                        {
                            int32_t advance;
                            if( TTF_GlyphMetrics( font, glyphCharacter, 0, 0, 0, 0, &advance ) >= 0 )
                                glyphs[i].advance = (uint8_t)advance;
                            glyphs[i].surface = post;
                            
                            generatedGlyphs++;
                        }

                        SDL_FreeSurface( pre );
                    }
                }

                int ascent = TTF_FontAscent( font );
                int descent = TTF_FontDescent( font );
                int lineskip = TTF_FontLineSkip( font );

                int linespace;
                TTF_GlyphMetrics( font, ' ', 0, 0, 0, 0, &linespace );
            
                TTF_CloseFont( font );

                if( generatedGlyphs > 0 )
                {
                    int maxWidth = 0, maxHeight = 0;

                    // get max width and height
                    for( int i=0; i<ASCII_RANGE; i++ )
                    {
                        if( glyphs[i].surface->w > maxWidth )
                            maxWidth = glyphs[i].surface->w;
                        if( glyphs[i].surface->h > maxHeight )
                            maxHeight = glyphs[i].surface->h;
                    }

                    uint32_t maxVal = ( maxWidth > maxHeight ? maxWidth : maxHeight );
                    int minSize = maxVal * CHARS_PER_ROW;

                    int imageSize = 128;
                    while( imageSize < minSize )
                        imageSize *= 2; // maintain power of 2

                    SDL_Surface* img = SDL_CreateRGBSurface( 0, imageSize, imageSize, 32, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000 );
                    if( img )
                    {
                        string name = filename + string(".txt");
                        
                        ofstream stream( name, ios::out | ios::binary );
                        if( stream.is_open() )
                        {
                            char buf[ASCII_RANGE] = { maxVal, ascent, descent, lineskip, linespace };
                            stream.write( buf, 5 );
                            
                            int i=0;
                            for( int y=0; y<CHARS_PER_ROW && i<ASCII_RANGE; y++ )
                            {
                                for( int x=0; x<CHARS_PER_ROW && i<ASCII_RANGE; x++, i++ )
                                {
                                    SDL_Rect dst = { x*maxVal, y*maxVal, 0, 0 };
                                    SDL_BlitSurface( glyphs[i].surface, 0, img, &dst );
                                    
                                    // NOTE: Don't do this. Don't write 1 byte at a time
                                    //stream.write( glyphs[i].advance, 1 );

                                    buf[i] = glyphs[i].advance;
                                }
                            }

                            // NOTE: This is much better, write all the bytes at the same time
                            stream.write( buf, ASCII_RANGE );

                            stream.close();

                            string pngname = filename + string(".png");
                            IMG_SavePNG( img, pngname.c_str() );

                            printf( "Font generation completed. %d glyphs generated.\n", generatedGlyphs );
                        }
                        else
                            printf( "Failed to create file \"%s\".\n", name.c_str() );
                    }
                    
                    // free surfaces
                    for( int i=0; i<ASCII_RANGE; i++ )
                        SDL_FreeSurface( glyphs[i].surface );
                }
                else
                    printf( "Font generation failed. No glyphs generated.\n" );
            }
            else
                printf( "Failed to open font \"%s\".\n", fontname );
        }
        else
            printf( "Fontsize can't be less than 0.\n" );

        TTF_Quit();
        SDL_Quit();
    }
    
    return 0;
}
