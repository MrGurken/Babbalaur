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

#define MAKE_v2( x, y ) v2( x, y )
#define MAKE_v3( x, y, z ) v3( x, y, z )
#define MAKE_v4( x, y, z, w ) v4( x, y, z, w )
#define MATRIX_VALUE( matrix ) value_ptr( matrix )
#define MATRIX_IDENTITY m4()
#define MATRIX_ORTHO( x, y ) glm::ortho( 0.0f, x, y, 0.0f, -1.0f, 1.0f )
#define MATRIX_MULTIPLY( a, b ) a * b
#define MATRIX_TRANSLATION( x, y, z ) glm::translate( m4(), v3( x, y, z ) )
#define MATRIX_SCALE( x, y, z ) glm::scale( m4(), v3( x, y, z ) )

#else

#import <GLKit/GLKit.h>

typedef GLKVector2 v2;
typedef GLKVector3 v3;
typedef GLKVector4 v4;
typedef GLKMatrix4 m4;

#define MAKE_v2( x, y ) GLKVector2Make( x, y )
#define MAKE_v3( x, y, z ) GLKVector3Make( x, y ,z )
#define MAKE_v4( x, y, z, w ) GLKVector4Make( x, y, z, w )
#define MATRIX_VALUE( matrix ) matrix.m
#define MATRIX_IDENTITY GLKMatrix4Identity
#define MATRIX_ORTHO( x, y ) GLKMatrix4MakeOrtho( 0.0f, x, y, 0.0f, -1.0f, 1.0f )
#define MATRIX_MULTIPLY( a, b ) GLKMatrix4Multiply( a, b )
#define MATRIX_TRANSLATION( x, y, z ) GLKMatrix4MakeTranslation( x, y, z )
#define MATRIX_SCALE( x, y, z ) GLKMatrix4MakeScale( x, y, z )

#endif

#define MATHS_H
#endif

typedef struct point2
{
    int32_t x, y;
} p2;
