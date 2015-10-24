//
//  mac_main.m
//  BabbaLaur01
//
//  Created by Niclas Olsson on 2015-10-24.
//  Copyright © 2015 SpaceCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface GameViewController : GLKViewController

@end

@interface GameViewController()
{
	
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
}

-(void)dealloc
{
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

-(void)update
{
	
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
	glClearColor( 1.0f, 0.0f, 0.0f, 1.0f );
	glClear( GL_COLOR_BUFFER_BIT );
}

@end