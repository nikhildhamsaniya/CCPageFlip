//
//  CCPageFlipControl.h
//  PageFlipDemo
//
//  Created by x on 8/21/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "CCLayer.h"

@class CCPage;

@interface CCPageFlipControl : CCLayer {
    NSDate *_touchStart;
    CCPage *_page;
    BOOL isLeft;
}

@property (nonatomic) float swipeDelay;

@end
