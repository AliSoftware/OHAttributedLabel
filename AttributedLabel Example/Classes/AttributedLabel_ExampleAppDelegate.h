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
	
	NSMutableSet* visitedLinks;
}
@property (nonatomic, retain) IBOutlet UIWindow* window;
-(IBAction)fillLabel1;
-(IBAction)makeWorldBold;
-(IBAction)fillLabel2;
-(IBAction)changeHAlignment;
-(IBAction)changeVAlignment;
-(IBAction)changeSize;
-(IBAction)resetVisitedLinks;
@end

