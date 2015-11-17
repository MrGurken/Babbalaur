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

// Phase 1
TEST( Tile, TileIDParsing )
{
    v2 offset = GetTileOffset( 1 );
    EXPECT_FLOAT_EQ( 0.0f, offset.x );
    EXPECT_FLOAT_EQ( 0.0f, offset.y );

    offset = GetTileOffset( 10 );
    EXPECT_FLOAT_EQ( 9.0f/TILESHEET_WIDTH, offset.x );
    EXPECT_FLOAT_EQ( 0.0f, offset.y );

    offset = GetTileOffset( 11 );
    EXPECT_FLOAT_EQ( 0.0f, offset.x );
    EXPECT_FLOAT_EQ( 1.0f/TILESHEET_WIDTH, offset.y );

    offset = GetTileOffset( 25 );
    EXPECT_FLOAT_EQ( 4.0f/TILESHEET_WIDTH, offset.x );
    EXPECT_FLOAT_EQ( 2.0f/TILESHEET_WIDTH, offset.y );
}

TEST( Tile, GetTileID )
{
    uint8_t map[GAME_MAP_HEIGHT*GAME_MAP_WIDTH];
    for( int i=0; i<GAME_MAP_HEIGHT*GAME_MAP_WIDTH; i++ )
        map[i] = i;

    uint8_t id = GetTileID( map, 0, 0 );
    EXPECT_EQ( 0, id );

    id = GetTileID( map, 5, 0 );
    EXPECT_EQ( 5, id );

    id = GetTileID( map, 5, 1 );
    EXPECT_EQ( 15, id );

    id = GetTileID( map, 5, 5 );
    EXPECT_EQ( 55, id );
}

// Phase 2
TEST( Space, ScreenToWorldSpace )
{
    v3 pos = MAKE_v3( 0.0f, 0.0f, 0.0f );
    v2 mpos = MAKE_v2( 10.0f, 10.0f );

    v2 worldPos = ScreenToWorld( pos, mpos );
    EXPECT_FLOAT_EQ( 10.0f, worldPos.x );
    EXPECT_FLOAT_EQ( 10.0f, worldPos.y );

    mpos.x = mpos.y = 320.0f;

    worldPos = ScreenToWorld( pos, mpos );
    EXPECT_FLOAT_EQ( 320.0f, worldPos.x );
    EXPECT_FLOAT_EQ( 320.0f, worldPos.y );

    mpos.x = mpos.y = 0.0f;
    pos.x = 32.0f;

    worldPos = ScreenToWorld( pos, mpos );
    EXPECT_FLOAT_EQ( 32.0f, worldPos.x );
    EXPECT_FLOAT_EQ( 0.0f, worldPos.y );

    pos.y = 32.0f;

    worldPos = ScreenToWorld( pos, mpos );
    EXPECT_FLOAT_EQ( 32.0f, worldPos.x );
    EXPECT_FLOAT_EQ( 32.0f, worldPos.y );

    pos.x = pos.y = -32.0f;

    worldPos = ScreenToWorld( pos, mpos );
    EXPECT_FLOAT_EQ( -32.0f, worldPos.x );
    EXPECT_FLOAT_EQ( -32.0f, worldPos.y );
}

TEST( Space, WorldToScreenSpace )
{
    v3 pos = MAKE_v3( 0.0f, 0.0f, 0.0f );
    v2 mpos = MAKE_v2( 10.0f, 10.0f );

    v2 screenPos = WorldToScreen( pos, mpos );
    EXPECT_FLOAT_EQ( 10.0f, screenPos.x );
    EXPECT_FLOAT_EQ( 10.0f, screenPos.y );

    mpos.x = mpos.y = 320.0f;

    screenPos = WorldToScreen( pos, mpos );
    EXPECT_FLOAT_EQ( 320.0f, screenPos.x );
    EXPECT_FLOAT_EQ( 320.0f, screenPos.y );

    mpos.x = mpos.y = 0.0f;
    pos.x = 32.0f;

    screenPos = WorldToScreen( pos, mpos );
    EXPECT_FLOAT_EQ( 32.0f, screenPos.x );
    EXPECT_FLOAT_EQ( 0.0f, screenPos.y );

    pos.y = 32.0f;

    screenPos = WorldToScreen( pos, mpos );
    EXPECT_FLOAT_EQ( 32.0f, screenPos.x );
    EXPECT_FLOAT_EQ( 32.0f, screenPos.y );

    pos.x = pos.y = -32.0f;

    screenPos = WorldToScreen( pos, mpos );
    EXPECT_FLOAT_EQ( -32.0f, screenPos.x );
    EXPECT_FLOAT_EQ( -32.0f, screenPos.y );
}

TEST( Space, WorldToGridSpace )
{
    v2 worldPos = MAKE_v2( 16.0f, 16.0f );

    p2 gridPoint = WorldToGrid( worldPos );
    EXPECT_EQ( 0, gridPoint.x );
    EXPECT_EQ( 0, gridPoint.y );

    worldPos.x = 48.0f;
    
    gridPoint = WorldToGrid( worldPos );
    EXPECT_EQ( 1, gridPoint.x );
    EXPECT_EQ( 0, gridPoint.y );

    worldPos.y = 72.0f;

    gridPoint = WorldToGrid( worldPos );
    EXPECT_EQ( 1, gridPoint.x );
    EXPECT_EQ( 2, gridPoint.y );
}

TEST( Input, MouseInput )
{
    Input newInput = {};
    Input oldInput = {};

    newInput.buttons[BUTTON_LEFT] = true;

    EXPECT_TRUE( ButtonDown( &newInput, BUTTON_LEFT ) );
    EXPECT_FALSE( ButtonDown( &oldInput, BUTTON_RIGHT ) );
    EXPECT_TRUE( ButtonPressed( &newInput, &oldInput, BUTTON_LEFT ) );
    EXPECT_FALSE( ButtonReleased( &newInput, &oldInput, BUTTON_LEFT ) );

    oldInput.buttons[BUTTON_LEFT] = true;

    EXPECT_TRUE( ButtonDown( &newInput, BUTTON_LEFT ) );
    EXPECT_TRUE( ButtonDown( &oldInput, BUTTON_LEFT ) );
    EXPECT_FALSE( ButtonPressed( &newInput, &oldInput, BUTTON_LEFT ) );
    EXPECT_FALSE( ButtonReleased( &newInput, &oldInput, BUTTON_LEFT ) );

    newInput.buttons[BUTTON_LEFT] = false;

    EXPECT_FALSE( ButtonDown( &newInput, BUTTON_LEFT ) );
    EXPECT_TRUE( ButtonDown( &oldInput, BUTTON_LEFT ) );
    EXPECT_FALSE( ButtonPressed( &newInput, &oldInput, BUTTON_LEFT ) );
    EXPECT_TRUE( ButtonReleased( &newInput, &oldInput, BUTTON_LEFT ) );

    newInput.buttons[BUTTON_RIGHT] = true;
    
    EXPECT_TRUE( ButtonDown( &newInput, BUTTON_RIGHT ) );
    EXPECT_FALSE( ButtonDown( &oldInput, BUTTON_RIGHT ) );
    EXPECT_TRUE( ButtonPressed( &newInput, &oldInput, BUTTON_RIGHT ) );
    EXPECT_FALSE( ButtonReleased( &newInput, &oldInput, BUTTON_RIGHT ) );
}

TEST( Input, KeyInput )
{
    Input newInput = {};
    Input oldInput = {};

    newInput.keys[KEY_SPACE] = true;

    EXPECT_TRUE( KeyDown( &newInput, KEY_SPACE ) );
    EXPECT_FALSE( KeyDown( &oldInput, KEY_SPACE ) );
    EXPECT_TRUE( KeyPressed( &newInput, &oldInput, KEY_SPACE ) );
    EXPECT_FALSE( KeyReleased( &newInput, &oldInput, KEY_SPACE ) );

    oldInput.keys[KEY_SPACE] = true;

    EXPECT_TRUE( KeyDown( &newInput, KEY_SPACE ) );
    EXPECT_TRUE( KeyDown( &oldInput, KEY_SPACE ) );
    EXPECT_FALSE( KeyPressed( &newInput, &oldInput, KEY_SPACE ) );
    EXPECT_FALSE( KeyReleased( &newInput, &oldInput, KEY_SPACE ) );

    newInput.keys[KEY_SPACE] = false;

    EXPECT_FALSE( KeyDown( &newInput, KEY_SPACE ) );
    EXPECT_TRUE( KeyDown( &oldInput, KEY_SPACE ) );
    EXPECT_FALSE( KeyPressed( &newInput, &oldInput, KEY_SPACE ) );
    EXPECT_TRUE( KeyReleased( &newInput, &oldInput, KEY_SPACE ) );

    newInput.keys[KEY_ENTER] = true;

    EXPECT_TRUE( KeyDown( &newInput, KEY_ENTER ) );
    EXPECT_FALSE( KeyDown( &oldInput, KEY_ENTER ) );
    EXPECT_TRUE( KeyPressed( &newInput, &oldInput, KEY_ENTER ) );
    EXPECT_FALSE( KeyReleased( &newInput, &oldInput, KEY_ENTER ) );
}

TEST( Machine, GridToMachinePointer )
{
    Machine machines[GAME_MAP_WIDTH*GAME_MAP_HEIGHT];

    // Test minimum value
    p2 gridPoint = { 0, 0 };
    Machine* machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( &machines[0], machine );

    // Test within range
    gridPoint.x = gridPoint.y = 1;
    machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( &machines[11], machine );

    gridPoint.x = gridPoint.y = 5;
    machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( &machines[55], machine );

    // Test out of bounds, underflow
    gridPoint.x = gridPoint.y = -1;
    machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( 0, machine );

    // Test out of bounds, overflow
    gridPoint.x = gridPoint.y = 10;
    machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( 0, machine );

    // Test out of bounds, overflow, x only
    gridPoint.y = 5;
    machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( 0, machine );

    // Test out of bounds, overflow, y only
    gridPoint.x = 5;
    gridPoint.y = 10;
    machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( 0, machine );

    // Test out of bounds, underflow, y only
    gridPoint.y = -1;
    machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( 0, machine );

    // Test out of bounds, underflow, x only
    gridPoint.x = -1;
    gridPoint.y = 5;
    machine = GridToMachine( machines, gridPoint );
    EXPECT_EQ( 0, machine );
}

TEST( Machine, MachineOmniDiscovery )
{
    Machine machines[GAME_MAP_WIDTH*GAME_MAP_HEIGHT];
    int i=0;
    for( int y =0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x = 0; x<GAME_MAP_WIDTH; x++, i++ )
        {
            p2 gridPoint = { x,y };
            CreateMachine( &machines[i], gridPoint );
        }
    }
    machines[0].alive = true;

    // test with gridpoint
    p2 gridPoint = { 1, 0 };
    Machine* adj[MACHINE_MAX_ADJ] = {};
    ASSERT_TRUE( GetAdjacentMachines( machines, gridPoint, adj ) );

    EXPECT_NE( nullptr, adj[MACHINE_ADJ_LEFT] );
    EXPECT_EQ( 0, adj[MACHINE_ADJ_RIGHT] );

    // test null case
    gridPoint.x = 5;
    Machine* adj3[MACHINE_MAX_ADJ] = {};
    ASSERT_FALSE( GetAdjacentMachines( machines, gridPoint, adj ) );

    EXPECT_EQ( 0, adj3[MACHINE_ADJ_LEFT] );
    EXPECT_EQ( 0, adj3[MACHINE_ADJ_RIGHT] );
}

TEST( Machine, MachineDirectionalDiscovery )
{
    Machine machines[GAME_MAP_WIDTH*GAME_MAP_HEIGHT];
    int i=0;
    for( int y =0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x = 0; x<GAME_MAP_WIDTH; x++, i++ )
        {
            p2 gridPoint = { x,y };
            CreateMachine( &machines[i], gridPoint );
        }
    }
    machines[0].alive = true;
    
    // test with gridpoint
    p2 gridPoint = { 1, 0 };
    int direction = MACHINE_ADJ_LEFT;
    Machine* adj = 0;
    
    ASSERT_TRUE( GetAdjacentMachine( machines, gridPoint, &adj, direction ) );
    EXPECT_NE( nullptr, adj );

    direction = MACHINE_ADJ_RIGHT;
    ASSERT_FALSE( GetAdjacentMachine( machines, gridPoint, &adj, direction ) );
    EXPECT_EQ( nullptr, adj ); // should clear the pointer

    direction = MACHINE_ADJ_TOP;
    ASSERT_FALSE( GetAdjacentMachine( machines, gridPoint, &adj, direction ) );
    EXPECT_EQ( nullptr, adj );

    direction = MACHINE_ADJ_BOTTOM;
    ASSERT_FALSE( GetAdjacentMachine( machines, gridPoint, &adj, direction ) );
}

TEST( Machine, PlaceMachine )
{
    Machine machines[GAME_MAP_WIDTH*GAME_MAP_HEIGHT];
    int i=0;
    for( int y =0; y<GAME_MAP_HEIGHT; y++ )
    {
        for( int x = 0; x<GAME_MAP_WIDTH; x++, i++ )
        {
            p2 gridPoint = { x,y };
            CreateMachine( &machines[i], gridPoint );
        }
    }
    machines[0].alive = true;

    // test valid placement
    p2 gridPoint = { 1, 0 };
    ASSERT_NE( nullptr, PlaceMachine( machines, gridPoint, 2 , 0 ) );
    EXPECT_EQ( 2, machines[1].type );

    // test out of bounds, underflow, y only
    gridPoint.y = -1;
    ASSERT_EQ( nullptr, PlaceMachine( machines, gridPoint, 2, 0 ) );

    // test out of bounds, underflow, x only
    gridPoint.y = 0;
    gridPoint.x = -1;
    ASSERT_EQ( nullptr, PlaceMachine( machines, gridPoint, 2, 0 ) );

    // test out of bounds, overflow, x only
    gridPoint.x = GAME_MAP_WIDTH+1;
    ASSERT_EQ( nullptr, PlaceMachine( machines, gridPoint, 2, 0 ) );

    // test out of bounds, overflow, y only
    gridPoint.x = 0;
    gridPoint.y = GAME_MAP_HEIGHT+1;
    ASSERT_EQ( nullptr, PlaceMachine( machines, gridPoint, 2, 0 ) );

    // test placement on occupied tile
    gridPoint.y = 0;
    ASSERT_EQ( nullptr, PlaceMachine( machines, gridPoint, 2, 0 ) );
    EXPECT_EQ( 1, machines[0].type );
}

int main( int argc, char* argv[] )
{
    ::testing::InitGoogleTest( &argc, argv );
    return RUN_ALL_TESTS();
}
