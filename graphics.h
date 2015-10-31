#if !defined(GRAPHICS_H)
/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#ifdef _WIN32

#include "GL\glew.h"
#include "windows.h"

#define GEN_VERTEX_ARRAYS( n, ptr ) glGenVertexArrays( n, ptr )
#define BIND_VERTEX_ARRAY( vao ) glBindVertexArray( vao )

#else

#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

#define GEN_VERTEX_ARRAYS( n, ptr ) glGenVertexArraysOES( n, ptr )
#define BIND_VERTEX_ARRAY( vao ) glBindVertexArrayOES( vao )

#endif

#define GRAPHICS_H
#endif
