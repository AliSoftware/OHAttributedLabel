//
//  BasicDemoViewController.H
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 31/08/12.
//
//

#import <UIKit/UIKit.h>
#import <OHAttributedLabel/OHAttributedLabel.h>

@interface BasicDemoViewController : UIViewController <OHAttributedLabelDelegate>

@property(nonatomic, retain) IBOutlet OHAttributedLabel* demoLabel;
@property(retain, nonatomic) IBOutlet OHAttributedLabel* htmlLabel;
@property(retain, nonatomic) IBOutlet OHAttributedLabel* basicMarkupLabel;

-(IBAction)fillDemoLabel;
-(IBAction)changeHAlignment;
-(IBAction)changeVAlignment;
-(IBAction)changeSize;
-(IBAction)resetVisitedLinks;
@end
