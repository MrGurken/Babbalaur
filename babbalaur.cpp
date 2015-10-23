/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include "babbalaur.h"

bool32_t GameInit( Memory* memory )
{
    return true;
}

bool32_t GameUpdate( Memory* memory, Input* newInput, Input* oldInput, real64_t dt )
{
    return true;
}

void GameRender( Memory* memory )
{
    glClearColor( 1.0f, 0.0f, 0.0f, 1.0f );
    glClear( GL_COLOR_BUFFER_BIT );
}
