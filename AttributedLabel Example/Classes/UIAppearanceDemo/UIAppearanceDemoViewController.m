//
//  UIAppearanceDemoViewController.m
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 08/09/12.
//
//

#import "UIAppearanceDemoViewController.h"
#import "OHAttributedLabel.h"

@interface UIAppearanceDemoViewController ()

@end

@implementation UIAppearanceDemoViewController
@synthesize defaultLinkColorSegment = _defaultLinkColorSegment;
@synthesize defaultHighlightedLinkColorSegment = _defaultHighlightedLinkColorSegment;
@synthesize sampleLabel = _sampleLabel;

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Init/Dealloc
/////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.sampleLabel addCustomLink:nil inRange:NSMakeRange(8,11)];
}

- (void)viewDidUnload
{
    [self setSampleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setDefaultLinkColorSegment:nil];
    [self setDefaultHighlightedLinkColorSegment:nil];
}

- (void)dealloc
{
    [_defaultLinkColorSegment release];
    [_defaultHighlightedLinkColorSegment release];
    [_sampleLabel release];
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - IBActions
/////////////////////////////////////////////////////////////////////////////

- (void)forceSampleLabelNewAppearance
{
    // UIAppearance is usually meant to be called on the beginning of the application.
    // But here we want to force it to be taken into account for the sample label already displayed
    // The easiest hack to do this is to make the sample label disappear from the screen and reappear again.
    
    // Of course this is not normally needed as  you usually customize your UIAppearance values in
    // application:didFinishLaunchingWithOptions: or anywhere before any OHAttributedLabel has been displayed yet.
    [self.sampleLabel removeFromSuperview];
    [self.view addSubview:self.sampleLabel];
}

- (IBAction)changeDefaultLinkColor:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex >= 0)
    {
        UIColor* colors[] = { [UIColor blueColor], [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0], nil };
        UIColor* color = colors[sender.selectedSegmentIndex];
        [[OHAttributedLabel appearance] setLinkColor:color];
        [self forceSampleLabelNewAppearance];
    }
}

- (IBAction)changeDefaultHighlightedLinkColor:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex >= 0)
    {
        UIColor* colors[] = { [UIColor colorWithWhite:0.4 alpha:0.3], [UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.3], [UIColor colorWithRed:0.3 green:0.7 blue:0.3 alpha:0.3], nil };
        UIColor* color = colors[sender.selectedSegmentIndex];
        [[OHAttributedLabel appearance] setHighlightedLinkColor:color];
        [self forceSampleLabelNewAppearance];
    }
}

@end


