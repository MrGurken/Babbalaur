#if !defined(IO_H)
/* ========================================================================
   $File: $
   $Date: $
   $Revision: $
   $Creator: Tunder $
   $Notice: (C) Copyright 2014 by SpaceCat, Inc. All Rights Reserved. $
   ======================================================================== */

#ifdef _WIN32

#include "SDL.h"
#include <windows.h>
#include <fstream>

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

#define IO_H
#endif
