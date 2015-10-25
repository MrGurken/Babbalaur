/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include "babbalaur.m"
#include "SDL.h"

int main( int argc, char* argv[] )
{
    if( SDL_Init( SDL_INIT_EVERYTHING ) < 0 )
        return -1;
    
    SDL_Window* window = SDL_CreateWindow( WINDOW_TITLE,
                                           WINDOW_X, WINDOW_Y,
                                           WINDOW_W, WINDOW_H,
                                           SDL_WINDOW_OPENGL );

    if( window )
    {
        SDL_GLContext context = SDL_GL_CreateContext( window );
        if( context )
        {
            glewExperimental = GL_TRUE;
            if( glewInit() != GLEW_OK )
                return -1;
            
            Memory memory;
            memory.size = KILOBYTES(2);
            memory.pointer = malloc( memory.size );

            Input newInput = {}, oldInput = {};

            const real64_t dt = GAME_DT;
            real64_t accumulator = 0.0;
            uint32_t ticks = SDL_GetTicks();
            
            bool32_t running = GameInit( &memory );
            while( running )
            {
                uint32_t curTicks = SDL_GetTicks();
                uint32_t frametime = curTicks - ticks;
                ticks = curTicks;

                accumulator += (real64_t)frametime / 1000.0;

                while( accumulator > dt )
                {
                    oldInput = newInput;
                    
                    SDL_Event e;
                    while( SDL_PollEvent( &e ) )
                    {
                        if( e.type == SDL_QUIT )
                            running = false;
                        else if( e.type == SDL_KEYDOWN )
                        {
                            if( e.type == SDLK_ESCAPE )
                                running = false;
                            else if( e.type == SDLK_SPACE )
                                newInput.spaceDown = true;
                        }
                        else if( e.type == SDL_KEYUP )
                        {
                            if( e.type == SDLK_SPACE )
                                newInput.spaceDown = false;
                        }
                        else if( e.type == SDL_MOUSEBUTTONDOWN )
                        {
                            if( e.button.button == SDL_BUTTON_LEFT )
                                newInput.lmbDown = true;
                            else if( e.button.button == SDL_BUTTON_RIGHT )
                                newInput.rmbDown = true;
                        }
                        else if( e.type == SDL_MOUSEBUTTONUP )
                        {
                            if( e.button.button == SDL_BUTTON_LEFT )
                                newInput.lmbDown = false;
                            else if( e.button.button == SDL_BUTTON_RIGHT )
                                newInput.rmbDown = false;
                        }
                        else if( e.type == SDL_MOUSEMOTION )
                        {
                            newInput.mousePosition.x = e.motion.x;
                            newInput.mousePosition.y = e.motion.y;
                            newInput.mouseDelta.x = e.motion.xrel;
                            newInput.mouseDelta.y = e.motion.yrel;
                        }
                    }

                    if( !GameUpdate( &memory, &newInput, &oldInput, dt ) )
                        running = false;

                    accumulator -= dt;
                }

                GameRender( &memory );
                SDL_GL_SwapWindow( window );
            }
        }

        SDL_GL_DeleteContext( context );
    }

    SDL_DestroyWindow( window );
    SDL_Quit();

    return 0;
}
