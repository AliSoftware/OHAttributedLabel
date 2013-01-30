//
//  CustomLinksViewController.m
//  AttributedLabel Example
//
//  Created by Olivier Halligon on 31/08/12.
//
//

#import "CustomLinksViewController.h"
#import <OHAttributedLabel/NSAttributedString+Attributes.h>
#import <OHAttributedLabel/OHASBasicMarkupParser.h>
#import "UIAlertView+Commodity.h"

@interface CustomLinksViewController ()
-(void)fillDemoLabel;
-(void)configureMentionLabel;
@end



@implementation CustomLinksViewController
@synthesize customLinkDemoLabel = _customLinkDemoLabel;
@synthesize mentionDemoLabel = _mentionDemoLabel;

-(void)viewDidLoad
{
    [self fillDemoLabel];
	[self configureMentionLabel];
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    self.customLinkDemoLabel = nil;
    self.mentionDemoLabel = nil;
}

#if ! __has_feature(objc_arc)
-(void)dealloc
{
    [_customLinkDemoLabel release];
    [_mentionDemoLabel release];
    [super dealloc];
}
#endif

/////////////////////////////////////////////////////////////////////////////
#pragma mark - Top Label : Simple text with bold and custom link.
/////////////////////////////////////////////////////////////////////////////



#define TXT_BEGIN "Discover "
#define TXT_BOLD "FoodReporter"
#define TXT_MIDDLE " to "
#define TXT_LINK "share your food"
#define TXT_END " with your friends!"

-(void)fillDemoLabel
{
	NSString* txt = @ TXT_BEGIN TXT_BOLD TXT_MIDDLE TXT_LINK TXT_END; // concat the 5 (#define) constant parts in a single NSString
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:txt];
	// for those calls we don't specify a range so it affects the whole string
	[attrStr setFont:[UIFont systemFontOfSize:18]];
	[attrStr setTextColor:[UIColor grayColor]];
    
    // Set Paragraph Style: alignment, linebreak, indentation
    OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
    paragraphStyle.textAlignment = kCTJustifiedTextAlignment;
    paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
    paragraphStyle.firstLineHeadIndent = 30.f; // indentation for first line
    paragraphStyle.headIndent =  10.f; // indentation for lines other than the first (= left margin)
    paragraphStyle.tailIndent = -10.f; // right margin (negative values to count from the right edge instead of left edge)
    [attrStr setParagraphStyle:paragraphStyle];
    
	// now we only change the color of "FoodReporter"
	[attrStr setTextColor:[UIColor colorWithRed:0.f green:0.5f blue:0.0 alpha:1.f] range:[txt rangeOfString:@TXT_BOLD]];
	[attrStr setTextBold:YES range:[txt rangeOfString:@TXT_BOLD]];

	// and add a link to the "share your food!" text
    [attrStr setLink:[NSURL URLWithString:@"http://www.foodreporter.net"] range:[txt rangeOfString:@TXT_LINK]];
    
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	self.customLinkDemoLabel.attributedText = attrStr;
    self.customLinkDemoLabel.centerVertically = YES;
}

-(IBAction)toggleIndentation:(UISwitch*)indentationSwitch
{
 	/**(3)** (... later ...) Modify again the existing string *******/
	
	// Get the current attributedString and make it a mutable copy so we can modify it
	NSMutableAttributedString* mas = [self.customLinkDemoLabel.attributedText mutableCopy];
	// Modify the indent of the whole paragraph
	[mas modifyParagraphStylesWithBlock:^(OHParagraphStyle *paragraphStyle) {
        paragraphStyle.firstLineHeadIndent = indentationSwitch.on ? 30.f : 0.f;
        paragraphStyle.headIndent = indentationSwitch.on ?  10.f : 0.f;
        paragraphStyle.tailIndent = indentationSwitch.on ? -10.f : 0.f;
    }];
	// Affect back the attributed string to the label
	self.customLinkDemoLabel.attributedText = mas;
    
#if ! __has_feature(objc_arc)
	// Cleaning: balance the "mutableCopy" call with a "release"
	[mas release];
#endif
   
}

-(IBAction)toggleBold:(UISwitch*)boldSwitch
{
	/**(3)** (... later ...) Modify again the existing string *******/
	
	// Get the current attributedString and make it a mutable copy so we can modify it
	NSMutableAttributedString* mas = [self.customLinkDemoLabel.attributedText mutableCopy];
	NSString* plainText = [mas string];
	// Modify the font of "FoodReporter" to bold variant
	[mas setTextBold:boldSwitch.on range:[plainText rangeOfString:@TXT_BOLD]];
	// Affect back the attributed string to the label
	self.customLinkDemoLabel.attributedText = mas;
    
#if ! __has_feature(objc_arc)
	// Cleaning: balance the "mutableCopy" call with a "release"
	[mas release];
#endif
}





/////////////////////////////////////////////////////////////////////////////
#pragma mark - Bottom Label : Using Links for navigation in your app, in this example we are detecting "@mention" strings
/////////////////////////////////////////////////////////////////////////////


-(void)configureMentionLabel
{
    // Detect all "@xxx" mention-like strings using the "@\w+" regular expression
    NSRegularExpression* userRegex = [NSRegularExpression regularExpressionWithPattern:@"\\B@\\w+" options:0 error:nil];
    NSMutableAttributedString* mas = [self.mentionDemoLabel.attributedText mutableCopy];
    [userRegex enumerateMatchesInString:self.mentionDemoLabel.text options:0 range:NSMakeRange(0,self.mentionDemoLabel.text.length)
                             usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
    {
        // For each "@xxx" user mention found, add a custom link:
        NSString* user = [[self.mentionDemoLabel.text substringWithRange:match.range] substringFromIndex:1]; // get the matched user name, removing the "@"
        NSString* linkURLString = [NSString stringWithFormat:@"user:%@", user]; // build the "user:" link
        [mas setLink:[NSURL URLWithString:linkURLString] range:match.range]; // add it
    }];
    
    OHParagraphStyle* para = [OHParagraphStyle defaultParagraphStyle];
    para.firstLineHeadIndent = 30;
    para.headIndent = 5;
    para.tailIndent = -5;
    para.textAlignment = kCTTextAlignmentJustified;
    [mas setParagraphStyle:para];
    [OHASBasicMarkupParser processMarkupInAttributedString:mas];
    
    self.mentionDemoLabel.attributedText = mas;
    self.mentionDemoLabel.centerVertically = YES;
}

-(IBAction)changeLineSpacing:(UISlider*)slider
{
    NSMutableAttributedString* mas = [self.mentionDemoLabel.attributedText mutableCopy];
    [mas modifyParagraphStylesWithBlock:^(OHParagraphStyle *paragraphStyle) {
        paragraphStyle.lineSpacing = slider.value;
    }];
    self.mentionDemoLabel.attributedText = mas;
#if ! __has_feature(objc_arc)
	// Cleaning: balance the "mutableCopy" call with a "release"
	[mas release];
#endif
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - OHAttributedString Delegate Method
/////////////////////////////////////////////////////////////////////////////


-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
	if ([[linkInfo.URL scheme] isEqualToString:@"user"])
    {
		// We use this arbitrary URL scheme to handle custom actions
		// So URLs like "user:xxx" will be handled here instead of opening in Safari.
		// Note: in the above example, "xxx" is the 'resourceSpecifier' part of the URL
		NSString* user = [linkInfo.URL resourceSpecifier];

        // Display some message according to the user name clicked
        NSString* title = [NSString stringWithFormat:@"Tap on user %@", user];
        NSString* message = [NSString stringWithFormat:@"Here you may display the profile of user %@ on a new screen for example.", user];
        [UIAlertView showWithTitle:title message:message];
		
		// Prevent the URL from opening in Safari, as we handled it here manually instead
		return NO;
	}
    else
    {
        if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
        {
            // Execute the default behavior, which is opening the URL in Safari for URLs, starting a call for phone numbers, ...
            return YES;
        }
        else
        {
            [UIAlertView showWithTitle:@"Tap on link" message:[NSString stringWithFormat:@"Should open link %@", linkInfo.extendedURL]];
            return NO;
        }
	}
}

@end
