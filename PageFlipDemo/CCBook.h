//
//  CCBook.h
//  PageFlipDemo
//
//  Created by x on 8/29/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "CCLayer.h"

@protocol CCBookDelegate <NSObject>

-(NSInteger) numberOfPages;
-(CCNode *) contentsOfPage:(NSInteger) pageNumber;

@end

@class CCPage;

@interface CCBook : CCLayer {
    CCPage *_leftPage;
    CCPage *_rightPage;
    BOOL busy;
}

-(void) OnNext:(id) sender;
-(void) OnPrevious:(id) sender;

@property (nonatomic, unsafe_unretained) id<CCBookDelegate> delegate;

@end
