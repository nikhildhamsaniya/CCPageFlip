//
//  MainLayer.h
//  PageFlipDemo
//
//  Created by x on 8/29/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import "CCNode.h"
#import "CCScene.h"
#import "CCBook.h"

@interface MainLayer: CCScene<CCBookDelegate>

@property (nonatomic, retain) CCBook* book;

@end
