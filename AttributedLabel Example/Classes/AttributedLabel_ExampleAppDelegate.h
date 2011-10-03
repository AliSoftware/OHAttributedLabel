//
//  AttributedLabel_ExampleAppDelegate.h
//  AttributedLabel Example
//
//  Created by Olivier on 18/02/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"

@interface AttributedLabel_ExampleAppDelegate : NSObject <UIApplicationDelegate, OHAttributedLabelDelegate> {
    UIWindow* window;
	IBOutlet OHAttributedLabel* label1;
	IBOutlet OHAttributedLabel* label2;
	IBOutlet OHAttributedLabel* label3;
	IBOutlet UISlider * sliderLineHeight;
	NSMutableSet* visitedLinks;
}
@property (nonatomic, retain) IBOutlet UIWindow* window;
-(IBAction)fillLabel1;
-(IBAction)toggleBold:(UISwitch*)aSwitch;
-(IBAction)fillLabel2;
-(IBAction)changeHAlignment;
-(IBAction)changeVAlignment;
-(IBAction)changeSize;
-(IBAction)fillLabel3;
-(IBAction)resetVisitedLinks;
-(IBAction)changeLineHeight:(id)sender;
@end

