//
//  MainLayer.m
//  PageFlipDemo
//
//  Created by x on 8/29/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "MainLayer.h"

#import "CCNode+CCBRelativePositioning.h"
#import "CCBReader.h"

@implementation MainLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainLayer *layer = [MainLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init]) ) {
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];

        self.book = (CCBook *)[CCBReader nodeGraphFromFile:@"book"];
        self.book.delegate = self;
        [self addChild:self.book];
	}
	return self;
}

-(void)cleanup
{
    [super cleanup];
    [self removeAllChildren];
    self.book = nil;
}

-(NSInteger)numberOfPages
{
    return 10;
}

-(CCNode *)contentsOfPage:(NSInteger)pageNumber
{
    CCNode *node = (pageNumber % 2) ? [CCBReader nodeGraphFromFile:@"page_a"] : [CCBReader nodeGraphFromFile:@"page_b"];

    CCNode *text = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", pageNumber]
                                      fontName:@"Helvetica"
                                      fontSize:50];
    [node addChild:text];
    [text setRelativePosition:ccp(50, 50) type:kCCBPositionTypePercent];

    return node;
}

@end
