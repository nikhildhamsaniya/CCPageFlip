//
//  CCPage.m
//  PageFlipDemo
//
//  Created by x on 8/9/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "CCPage.h"
#import "kazmath/GL/matrix.h"
#import "CGPointExtension.h"
#import "CCDirectorIOS.h"
#import "CCTouchDispatcher.h"
#import "CCActionTween.h"
#import "CCActionInstant.h"
#import "CCPageFlipControl.h"

@interface CCPageSide : CCNode

+(id) pageSide;
+(id) pageSideWithSize:(CGSize)size;
-(id) init;
-(id) initWithSize:(CGSize)size;

@property (nonatomic, retain, readonly) CCRenderTexture *renderTexture;

@end

static inline CGFloat lerp(CGFloat ft, CGFloat f0, CGFloat f1)
{
    // Linear interpolation between f0 and f1
	return f0 + (f1 - f0) * ft;
}

@implementation CCPageSide

+(id) pageSide {
    return [[[self class] alloc] init];
}

+(id) pageSideWithSize:(CGSize)size
{
    return [[[self class] alloc] initWithSize:size];
}

-(id) init
{
    self = [self initWithSize:CGSizeMake(200, 200)];
    return self;
}

-(id) initWithSize:(CGSize)size
{
    self = [super init];

    if (self) {
        self.contentSize = size;
    }

    return self;
}

-(CGSize)contentSize
{
    return [super contentSize];
}

-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    if (_renderTexture) {
        [_renderTexture release];
    }

    _renderTexture = [[CCRenderTexture renderTextureWithWidth:_contentSize.width
                                                       height:_contentSize.height] retain];
}

-(void)visit
{
    [_renderTexture beginWithClear:1.0 g:1.0 b:1.0 a:1.0];
    [super visit];
    [_renderTexture end];
}

-(void) cleanup
{
    if (_renderTexture) {
        [_renderTexture release];
        _renderTexture = nil;
    }

    [self removeAllChildrenWithCleanup:YES];

    [super cleanup];
}

-(void) dealloc
{
    if (_renderTexture) {
        [_renderTexture release];
        _renderTexture = nil;
    }

    [super dealloc];
}

@end


@implementation CCPage

@synthesize time = _time;

#pragma mark - Static constructors

+(id) page
{
    return [[[self class] alloc] init];
}

+(id) pageWithSize:(CGSize) size
{
    return [[[self class] alloc] initWithSize:size];
}

+(id) pageWithNode1:(CCNode *)node1
              node2:(CCNode *)node2
{
    return [[[self class] alloc] initWithNode1:node1 node2:node2];
}

#pragma mark - Constructors

-(id)init
{
    self = [self initWithSize:CGSizeMake(200, 200)];
    return self;
}

-(id) initWithSize:(CGSize) size
{
    CCPageSide *pageSide1 = [CCPageSide pageSideWithSize:size];
    CCPageSide *pageSide2 = [CCPageSide pageSideWithSize:size];
    self = [self initWithPageSide1:pageSide1 pageSide2:pageSide2];
    return self;
}

-(id) initWithPageSide1:(CCPageSide *)pageSide1
              pageSide2:(CCPageSide *)pageSide2
{
    NSAssert(CGSizeEqualToSize(pageSide1.contentSize, pageSide2.contentSize),
             @"The two sides of a page must have the same size.");
    self = [super init];
    if (self) {
        _pageSide1 = [pageSide1 retain];
        _pageSide2 = [pageSide2 retain];
        _gridVertices = CGSizeMake(60, 60);
        _contentSize = pageSide1.contentSize;
        _pageGrid = [[CCPageGrid gridWithSize:_contentSize verticeCount:_gridVertices] retain];

        _flipDuration = 0.6;
        _flipSplit = 0.15;

        // Right page
        _pageSide1.anchorPoint = CGPointMake(0, 0);

        // Left page
        _pageSide2.anchorPoint = CGPointMake(1, 0);

        [self addChild:_pageSide1];
        [self addChild:_pageSide2];

        [self setTime:0];
    }
    return self;
}

-(id) initWithNode1:(CCNode *)node1
              node2:(CCNode *)node2
{
    CGSize s1 = node1.contentSize;
    CGSize s2 = node2.contentSize;
    CGSize size = CGSizeMake(max(s1.width, s2.width),
                             max(s1.height, s2.height));
    self = [self initWithSize:size];
    if (self) {
        node1.anchorPoint = CGPointMake(0.5, 0.5);
        node1.position = CGPointMake(s1.width / 2, s1.height / 2);
        [_pageSide1 addChild:node1];
        node2.anchorPoint = CGPointMake(0.5, 0.5);
        node2.position = CGPointMake(s2.width / 2, s2.height / 2);
        [_pageSide2 addChild:node2];
    }
    return self;
}

-(void)cleanup
{
    [self removeAllChildrenWithCleanup:YES];

    [_pageGrid release];
    _pageGrid = nil;

    [_pageSide1 release];
    _pageSide1 = nil;
    [_pageSide2 release];
    _pageSide2 = nil;

    [super cleanup];
}

#pragma mark - Public API

-(void)setTime:(ccTime)time
{
    _time = max(0, min(time, 1.0));

    if ((fabs(_time) <= 1e-3)) {
        time = 0.0;
    }

    if (fabs(_time - 1.0) <= 1e-2) {
        time = 1.0;
    }

    _time = time;
    [self configureTurn];
    [self curl];
}

-(ccTime)time
{
    return _time;
}

#pragma mark - Internals

-(void)visit
{
	// quick return if not visible. children won't be drawn.
	if (!_visible)
		return;

    _pageSide1.anchorPoint = CGPointMake(0, 0);
    _pageSide2.anchorPoint = CGPointMake(0, 0);

	kmGLPushMatrix();
	[self transform];

	if(_children) {
		ccArray *arrayData = _children->data;
		for(NSUInteger i = 0 ; i < arrayData->num; i++ ) {
			CCNode *child = arrayData->arr[i];
            [child visit];
		}

        // [_pageSide1 visit];
        // [_pageSide2 visit];
    }

    [self draw];

    _pageSide1.anchorPoint = CGPointMake(0, 0);
    _pageSide2.anchorPoint = CGPointMake(1, 0);

	// reset for next frame
	_orderOfArrival = 0;

	kmGLPopMatrix();
}

-(void)draw
{
    ccGLBindTexture2DN( 0, _pageSide1.renderTexture.sprite.texture.name );
    ccGLBindTexture2DN( 1, _pageSide2.renderTexture.sprite.texture.name );

	[_pageGrid blit];
}

-(void)dealloc
{
    [_pageGrid release];
    [super dealloc];
}

-(void)curl
{
    float theta = _theta;
    float ay = -_apex * _contentSize.height;
    float rho = _rho;

	float sinTheta = sinf(theta);
	float cosTheta = cosf(theta);

	float sinRho = sinf(rho);
	float cosRho = cosf(rho);

	for( int i = 0; i <=_gridVertices.width; i++ )
	{
		for( int j = 0; j <= _gridVertices.height; j++ )
		{
			// Get original vertex
			ccVertex3F	p = [_pageGrid originalVertex:ccp(i,j)];

            {
                // curl the page
                float R = sqrtf(p.x*p.x + (p.y - ay) * (p.y - ay));
                float r = R * sinTheta;
                float alpha = asinf( p.x / R );
                float beta = alpha / sinTheta;
                float cosBeta = cosf( beta );

                // If beta > PI then we've wrapped around the cone
                // Reduce the radius to stop these points interfering with others
                p.x = ( r * sinf(beta));
                p.y = ( R + ay - ( r*(1 - cosBeta)*sinTheta));
                p.z = r * ( 1 - cosBeta ) * cosTheta; // "100" didn't work for
            }

            {
                // Rotate
                float x = p.x;
                float z = p.z;
                p.x = (x * cosRho - z * sinRho);
                p.y = p.y;
                p.z = (x * sinRho + z * cosRho);
            }

            // Set new coords
			[_pageGrid setVertex:ccp(i,j) vertex:p];
		}
	}

    CGPoint vertex = ccp(_gridVertices.width -1, 0);
    ccVertex3F p = [_pageGrid vertex:vertex];
    _cornerCoordinates = ccp(p.x, p.y);
}

-(void) curlTo:(CGPoint) pos
{
    float t = 0.0;
    float delta = 1.0;
    float width = self.contentSize.width * 2; // multiply by 2 because there are two pages.
    float expectedPos = -width / 2 + width * pos.x;

    while (delta >= 1e-4) {
        self.time = t + delta;
        // TODO: only recalculate the position of a single point in the grid,
        // instead of the entire grid
        CGPoint vertex = ccp(_gridVertices.width -1, 0);
        ccVertex3F p = [_pageGrid vertex:vertex];
        if (p.x >= expectedPos) {
            t += delta;
        }

        delta /= 2;
    }
}

#pragma mark - Configuration - you can tweak this
- (void)configureTurn
{
    float RAD = (180.0f / M_PI);
    // This method computes rho, theta, and A for time parameter t using pre-defined functions to simulate a natural page turn
    // without finger tracking, i.e., for a quick swipe of the finger to turn to the next page.
    // These functions were constructed empirically by breaking down a page turn into phases and experimenting with trial and error
    // until we got acceptable results. This basic example consists of three distinct phases, but a more elegant solution yielding
    // smoother transitions can be obtained by curve fitting functions to our key data points once satisfied with the behavior.
    CGFloat angle1 =  90.0f / RAD;  //  }
    CGFloat angle2 =   8.0f / RAD;  //  }
    CGFloat angle3 =   6.0f / RAD;  //  }
    CGFloat     A1 =   4;        //  }
    CGFloat     A2 =   1.5;        //  }--- Experiment with these parameters to adjust the page turn behavior to your liking.
    CGFloat     A3 =   3;        //  }
    CGFloat theta1 =   0.25f;       //  }
    CGFloat theta2 =   0.5f;        //  }
    CGFloat theta3 =  10.0f;        //  }
    CGFloat theta4 =   2.0f;        //  }

    CGFloat f1, f2, dt;
    float rho, theta, A;
    float t = _time;

    // Here rho, the angle of the page rotation around the spine, is a linear function of time t. This is the simplest case and looks
    // Good Enough. A side effect is that due to the curling effect, the page appears to accelerate quickly at the beginning
    // of the turn, then slow down toward the end as the page uncurls and returns to its natural form, just like in real life.
    // A non-linear function may be slightly more realistic but is beyond the scope of this example.
    rho = t * M_PI;
    float t1 = 0.45f;
    float t2 = 0.65f;

    if (t <= t1) {
        // Start off with a flat page with no deformation at the beginning of a page turn, then begin to curl the page gradually
        // as the hand lifts it off the surface of the book.
        dt = t / t1;
        f1 = sin(M_PI * pow(dt, theta1) / 2.0);
        f2 = sin(M_PI * pow(dt, theta2) / 2.0);
        theta = lerp(f1, angle1, angle2);
        A = lerp(f2, A1, A2);
    } else if (t <= t2) {
        // Produce the most pronounced curling near the middle of the turn. Here small values of theta and A
        // result in a short, fat cone that distinctly show the curl effect.
        dt = (t - t1) / (t2 - t1);
        theta = lerp(dt, angle2, angle3);
        A = lerp(dt, A2, A3);
    } else {
        // Near the middle of the turn, the hand has released the page so it can return to its normal form.
        // Ease out the curl until it returns to a flat page at the completion of the turn. More advanced simulations
        // could apply a slight wobble to the page as it falls down like in real life.
        dt = (t - 0.4) / 0.6;
        f1 = sin(M_PI * pow(dt, theta3) / 2.0);
        f2 = sin(M_PI * pow(dt, theta4) / 2.0);
        theta = lerp(f1, angle3, angle1);
        A = lerp(f2, A3, A1);
    }

    _apex = A;
    _rho = rho;
    _theta = theta;
}

-(void)flipLeft
{
    float duration = _flipDuration * (1.0 - _time);
    [self runAction:[CCActionTween actionWithDuration:duration key:@"time" from:_time to:1]];
}

-(void)flipRight
{
    float duration = _flipDuration * _time;
    [self runAction:[CCActionTween actionWithDuration:duration key:@"time" from:_time to:0]];
}

-(void) flipClose
{
    ((_cornerCoordinates.x >=0) ? [self flipRight] : [self flipLeft]);
}

-(void) flipFar
{
    ((_cornerCoordinates.x < 0) ? [self flipRight] : [self flipLeft]);
}

@end
