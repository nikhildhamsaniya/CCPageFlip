//
//  PageFlipControlsViewController.h
//  PageFlipDemo
//
//  Created by x on 8/21/13.
//  Copyright (c) 2013 x. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCPage;

@protocol PageFlipControlsDelegate <NSObject>

@end

@interface PageFlipControlsViewController : UIViewController {
    CADisplayLink *displayLink;
    CCPage *page;
}

@property (retain, nonatomic) IBOutlet UISlider *animationPhase;
@property (retain, nonatomic) IBOutlet UISlider *apex;
@property (retain, nonatomic) IBOutlet UISlider *rho;
@property (retain, nonatomic) IBOutlet UISlider *theta;
@property (retain, nonatomic) IBOutlet UIView *cocos2dView;
- (IBAction)timeChanged:(id)sender;
- (IBAction)rhoChanged:(id)sender;
- (IBAction)thetaChanged:(id)sender;
- (IBAction)apexChanged:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *phaseLabel;
@property (retain, nonatomic) IBOutlet UILabel *rhoLabel;
@property (retain, nonatomic) IBOutlet UILabel *thetaLabel;
@property (retain, nonatomic) IBOutlet UILabel *apexLabel;

@end
