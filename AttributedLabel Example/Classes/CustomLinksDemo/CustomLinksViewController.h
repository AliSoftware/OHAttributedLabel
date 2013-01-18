//
//  CustomLinksViewController.h
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 31/08/12.
//
//

#import <UIKit/UIKit.h>
#import <OHAttributedLabel/OHAttributedLabel.h>

@interface CustomLinksViewController : UIViewController <OHAttributedLabelDelegate>

@property(nonatomic, retain) IBOutlet OHAttributedLabel* customLinkDemoLabel;
@property(nonatomic, retain) IBOutlet OHAttributedLabel* mentionDemoLabel;

-(IBAction)toggleBold:(UISwitch*)boldSwitch;
-(IBAction)toggleIndentation:(UISwitch*)indentationSwitch;
@end
