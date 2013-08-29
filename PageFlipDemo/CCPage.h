//
//  CCPage.h
//  PageFlipDemo
//
//  Created by x on 8/9/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "CCLayer.h"
#import "CCRenderTexture.h"
#import "CCPageGrid.h"

@class CCPageSide;

@interface CCPage : CCNode {
    CGSize _gridVertices;
    CCPageGrid *_pageGrid;
    CGPoint _cornerCoordinates;
}

+(id) page;
+(id) pageWithSize:(CGSize) size;
+(id) pageWithNode1:(CCNode *)node1
              node2:(CCNode *)node2;

-(id) init;
-(id) initWithSize:(CGSize) size;
-(id) initWithNode1:(CCNode *)node1
              node2:(CCNode *)node2;

// Setting the time (in [0:1]) will set the page's animation accordingly,
// 0 - the page is not flipped, it's shown on the right-hand side.
// 1 - the page is fully flipped, it's shown on the left-hand side.
@property (nonatomic) ccTime time;

@property (nonatomic) NSInteger number;

// Adding children to these nodes will show them on the pages.
@property (nonatomic, retain, readonly) CCPageSide *pageSide1;
@property (nonatomic, retain, readonly) CCPageSide *pageSide2;

@property (nonatomic) float rho;
@property (nonatomic) float apex;
@property (nonatomic) float theta;

@property (nonatomic) float flipDuration;
@property (nonatomic) float flipSplit;

-(void) configureTurn;
-(void) curl;
-(void) curlTo:(CGPoint) pos;

-(void) flipLeft;
-(void) flipRight;
-(void) flipClose;
-(void) flipFar;

@end
