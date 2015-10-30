//
//  mac_main.m
//  BabbaLaur01
//
//  Created by Niclas Olsson on 2015-10-24.
//  Copyright © 2015 SpaceCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#include "babbalaur.h"

@interface GameViewController : GLKViewController

@end

@interface GameViewController()
{
	Memory memory;
	Input newInput;
	Input oldInput;
	Input internalInput;
}
@property (strong, nonatomic) EAGLContext* context;

-(void)startGL;
-(void)stopGL;
-(void)update;
@end

@implementation GameViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	if( !self.context )
	{
		NSLog(@"Failed to create OpenGL context.");
	}
	
	GLKView* view = (GLKView*)self.view;
	view.context = self.context;
	view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	
	[self startGL];
	
	memory.size = GAME_MEMORY_POOL;
	memory.pointer = malloc( memory.size );
	
	GameInit( &memory );
}

-(void)dealloc
{
	free( memory.pointer );
	memory.size = 0;
	
	[self stopGL];
	
	if([EAGLContext currentContext] == self.context)
		[EAGLContext setCurrentContext:nil];
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	if ([self isViewLoaded] && ([[self view] window] == nil)) {
		self.view = nil;
		
		[self stopGL];
		
		if ([EAGLContext currentContext] == self.context) {
			[EAGLContext setCurrentContext:nil];
		}
		self.context = nil;
	}
}

-(BOOL)prefersStatusBarHidden
{
	return YES;
}

-(void)startGL
{
	[EAGLContext setCurrentContext:self.context];
}

-(void)stopGL
{
	[EAGLContext setCurrentContext:self.context];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [[touches anyObject] locationInView:self.view];
	
	internalInput.buttons[BUTTON_LEFT] = true;
	internalInput.mousePosition.x = point.x;
	internalInput.mousePosition.y = point.y;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [[touches anyObject] locationInView:self.view];
	
	internalInput.mousePosition.x = point.x;
	internalInput.mousePosition.y = point.y;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	internalInput.buttons[BUTTON_LEFT] = false;
}

-(void)update
{
	oldInput = newInput;
	
	for( int i=0; i<MAX_KEYS; i++ )
		newInput.keys[i] = internalInput.keys[i];
	for( int i=0; i<MAX_BUTTONS; i++ )
		newInput.buttons[i] = internalInput.buttons[i];
	
	newInput.mousePosition = internalInput.mousePosition;
	newInput.mouseDelta.x = newInput.mousePosition.x - oldInput.mousePosition.x;
	newInput.mouseDelta.y = newInput.mousePosition.y - oldInput.mousePosition.y;
	
	GameUpdate( &memory, &newInput, &oldInput, GAME_DT );
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	GameRender( &memory );
}

@end