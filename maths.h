#if !defined(MATHS_H)
/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#ifdef _WIN32

#include "glm.hpp"
#include "matrix_transform.hpp"
#include "type_ptr.hpp"

typedef glm::vec2 v2;
typedef glm::vec3 v3;
typedef glm::vec4 v4;
typedef glm::mat4 m4;

#define maths glm

#else

#import <GLKit/GLKit.h>

typedef GLKVector2 v2;
typedef GLKVector3 v3;
typedef GLKVector4 v4;
typedef GLKMatrix4 m4;

#endif

#define MATHS_H
#endif
