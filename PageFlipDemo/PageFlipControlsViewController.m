//
//  PageFlipControlsViewController.m
//  PageFlipDemo
//
//  Created by x on 8/21/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "PageFlipControlsViewController.h"
#import <QuartzCore/CADisplayLink.h>
#import "CCDirector.h"
#import "HelloWorldLayer.h"
#import "CCPage.h"

@implementation PageFlipControlsViewController

-(void) update {
    self.apex.value = page.apex;
    self.rho.value = page.rho;
    self.theta.value = page.theta;
    self.animationPhase.value = page.time;
    self.apexLabel.text = [NSString stringWithFormat:@"%f", self.apex.value ];
    self.rhoLabel.text = [NSString stringWithFormat:@"%f", self.rho.value ];
    self.thetaLabel.text = [NSString stringWithFormat:@"%f", self.theta.value ];
    self.phaseLabel.text = [NSString stringWithFormat:@"%f", self.animationPhase.value ];

    // NSLog(@"%f %f %f %f", self.apex.value, self.rho.value, self.theta.value, self.animationPhase.value);
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.view addSubview:nil];
    displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(update)] retain];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

	// for rotation and other messages
    CCDirector *director = [CCDirector sharedDirector];

	CCGLView *glView = [CCGLView viewWithFrame:self.cocos2dView.bounds
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:GL_DEPTH24_STENCIL8_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
	[director setView:glView];

    [self.cocos2dView addSubview:director.view];
    HelloWorldLayer *layer = [HelloWorldLayer node];
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	// add layer as a child to scene
	[scene addChild: layer];
    [director runWithScene: scene];
    page = layer.page;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [displayLink invalidate];
    [displayLink release];
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [_animationPhase release];
    [_theta release];
    [_rho release];
    [_apex release];
    [_cocos2dView release];
    [_phaseLabel release];
    [_rhoLabel release];
    [_thetaLabel release];
    [_apexLabel release];
    [super dealloc];
}

- (IBAction)timeChanged:(id)sender {
    page.time = ((UISlider *)sender).value;
}

- (IBAction)rhoChanged:(id)sender {
    page.rho = ((UISlider *)sender).value;
    [page curl];
}

- (IBAction)thetaChanged:(id)sender {
    page.theta = ((UISlider *)sender).value;
    [page curl];
}

- (IBAction)apexChanged:(id)sender {
    page.apex = ((UISlider *)sender).value;
    [page curl];
}

@end
