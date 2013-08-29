//
//  MainViewController.m
//  PageFlipDemo
//
//  Created by x on 8/29/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/CADisplayLink.h>
#import "CCDirector.h"
#import "MainLayer.h"

@interface MainViewController ()

@end

@implementation MainViewController

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.view addSubview:nil];

    CCDirector *director = [CCDirector sharedDirector];
	CCGLView *glView = [CCGLView viewWithFrame:self.view.bounds
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH24_STENCIL8
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
	[director setView:glView];

    [self.view addSubview:director.view];
    MainLayer *layer = [MainLayer node];
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// add layer as a child to scene
	[scene addChild: layer];
    [director runWithScene: scene];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [displayLink invalidate];
    [displayLink release];
    [super viewWillDisappear:animated];
}

@end
