//
//  BasicDemoViewController.H
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 31/08/12.
//
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"

@interface BasicDemoViewController : UIViewController <OHAttributedLabelDelegate>

@property(nonatomic, retain) IBOutlet OHAttributedLabel* demoLabel;

-(IBAction)fillDemoLabel;
-(IBAction)changeHAlignment;
-(IBAction)changeVAlignment;
-(IBAction)changeSize;
-(IBAction)resetVisitedLinks;
@end
