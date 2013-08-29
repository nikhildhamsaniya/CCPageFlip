//
//  CCPageFlipControl.m
//  PageFlipDemo
//
//  Created by x on 8/21/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "CCPageFlipControl.h"
#import "CCPage.h"
#import "CGPointExtension.h"

@implementation CCPageFlipControl

- (id)init
{
    self = [super init];
    if (self) {
        _swipeDelay = 0.5;
    }
    return self;
}

-(void)onEnter
{
    [super onEnter];

    CCNode *page = self.parent;
    while (page != nil && ![page isKindOfClass:[CCPage class]]) {
        page = page.parent;
    }

    NSAssert(page != nil, @"Unable to find page for the CCPageFlipControl to flip.");
    _page = (CCPage *)page;
    [_page retain];

    self.touchMode = kCCTouchesOneByOne;
    self.touchEnabled = YES;
}

-(void)onExitTransitionDidStart
{
    [_page release];
    [super onExitTransitionDidStart];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    _touchStart = [[NSDate date] retain];
    if (![self touchIsInside:touch]) {
        return NO;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:(isLeft ? @"pageFlipLeftStarted" : @"pageFlipRightStarted")
                                                        object:nil
                                                      userInfo:@{ @"page": _page }];
    return YES;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint location = [_page convertTouchToNodeSpaceAR:touch];
    CGSize size = _page.contentSize;
    CGPoint anchor = _page.anchorPoint;
    size = CGSizeMake(size.width * _page.scaleX, size.height * _page.scaleY);

    CGRect bbox = CGRectMake(-size.width * anchor.x, -size.height * anchor.y,
                             size.width * 2, size.height);
    float t = (location.x - bbox.origin.x + size.width) / bbox.size.width;
    // NSLog(@"%f %f %f", location.x, bbox.origin.x, t);
    [_page curlTo:ccp(t, 0)];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    NSLog(@"Touch Ended");
    float touchTime = [_touchStart timeIntervalSinceNow] * -1;
    [_touchStart release];
    BOOL isSwipe = touchTime < self.swipeDelay;
    BOOL isTap = [self touchIsInside:touch];
    ((isSwipe || isTap) ? [_page flipFar] : [_page flipClose]);
}

-(BOOL) touchIsInside:(UITouch *)touch
{
    CGPoint location = [self convertTouchToNodeSpaceAR:touch];
    CGSize size = self.contentSize;
    CGPoint anchor = self.anchorPoint;
    size = CGSizeMake(size.width * self.scaleX, size.height * self.scaleY);

    CGRect bbox = CGRectMake(-size.width * anchor.x, -size.height * anchor.y,
                             size.width, size.height);
    return CGRectContainsPoint(bbox, location);
}


@end
