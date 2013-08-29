//
//  CCBook.m
//  PageFlipDemo
//
//  Created by x on 8/29/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "CCBook.h"
#import "CCPage.h"
#import "CCActionInstant.h"
#import "CCActionInterval.h"
#import "CCActionTween.h"
#import "CCNode+CCBRelativePositioning.h"

#define Z_ORDER_ACTIVE_PAGE 10
#define Z_ORDER_INACTIVE_PAGE 8

@implementation CCBook

-(void)onEnter
{
    [super onEnter];

    _rightPage = [self createPage:0];
}

-(CCPage *) createPage:(NSInteger)pageNumber {
    CCNode *page0 = [self.delegate contentsOfPage:pageNumber];
    CCNode *page1 = [self.delegate contentsOfPage:pageNumber + 1];
    if (page0 == nil || page1 == nil) {
        return nil;
    }

    CCPage *page = [CCPage pageWithNode1:page0 node2:page1];
    page.number = pageNumber;
    page.zOrder = Z_ORDER_INACTIVE_PAGE;
    [self addChild:page];
    [page setRelativePosition:ccp(50, 0) type:kCCBPositionTypePercent];
    return page;
}

-(void) OnNext:(id) sender {
    if (busy) {
        return;
    }

    CCPage *page = _rightPage;
    busy = YES;
    _rightPage = [self createPage:page.number + 2];
    page.zOrder = Z_ORDER_ACTIVE_PAGE;
    [page runAction:[CCSequence actionOne:[CCActionTween actionWithDuration:page.flipDuration key:@"time" from:page.time to:1]
                                      two:[CCCallBlock actionWithBlock:^{
        [_leftPage removeFromParentAndCleanup:YES];
        _leftPage = page;
        page.zOrder = Z_ORDER_INACTIVE_PAGE;
        busy = NO;
    }]]];
}

-(void) OnPrevious:(id) sender {
    if (busy) {
        return;
    }

    busy = YES;
    CCPage *page = _leftPage;
    _leftPage = [self createPage:page.number - 2];
    _leftPage.time = 1.0;
    page.zOrder = Z_ORDER_ACTIVE_PAGE;
    [page runAction:[CCSequence actionOne:[CCActionTween actionWithDuration:page.flipDuration key:@"time" from:page.time to:0]
                                      two:[CCCallBlock actionWithBlock:^{
        [_rightPage removeFromParentAndCleanup:YES];
        _rightPage = page;
        page.zOrder = Z_ORDER_INACTIVE_PAGE;
        busy = NO;
    }]]];
}

@end
