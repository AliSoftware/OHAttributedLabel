//
//  UIAppearanceDemoViewController.h
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 08/09/12.
//
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"

@interface UIAppearanceDemoViewController : UIViewController
@property (retain, nonatomic) IBOutlet UISegmentedControl *defaultLinkColorSegment;
@property (retain, nonatomic) IBOutlet UISegmentedControl *defaultHighlightedLinkColorSegment;
@property (retain, nonatomic) IBOutlet OHAttributedLabel *sampleLabel;

- (IBAction)changeDefaultLinkColor:(UISegmentedControl *)sender;
- (IBAction)changeDefaultHighlightedLinkColor:(UISegmentedControl *)sender;
@end
