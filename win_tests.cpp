/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#include "babbalaur.m"
#include "SDL.h"
#include "gtest\gtest.h"

TEST( Tilemap, TileIDParsing )
{
    v2 offset = GetTileOffset( 1 );
    EXPECT_FLOAT_EQ( 0.0f, offset.x );
    EXPECT_FLOAT_EQ( 0.0f, offset.y );

    offset = GetTileOffset( 10 );
    EXPECT_FLOAT_EQ( 9.0f, offset.x );
    EXPECT_FLOAT_EQ( 0.0f, offset.y );

    offset = GetTileOffset( 11 );
    EXPECT_FLOAT_EQ( 0.0f, offset.x );
    EXPECT_FLOAT_EQ( 1.0f, offset.y );

    offset = GetTileOffset( 25 );
    EXPECT_FLOAT_EQ( 4.0f, offset.x );
    EXPECT_FLOAT_EQ( 2.0f, offset.y );
}

int main( int argc, char* argv[] )
{
    ::testing::InitGoogleTest( &argc, argv );
    return RUN_ALL_TESTS();
}
