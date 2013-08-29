//
//  HelloWorldLayer.h
//  PageFlipDemo
//
//  Created by x on 8/9/13.
//  Copyright x 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCPage.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer 

@property (nonatomic, strong) CCActionInterval *pageFlip;
@property (nonatomic, strong) CCPage *page;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
