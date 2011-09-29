//
//  AttributedLabel_ExampleAppDelegate.m
//  AttributedLabel Example
//
//  Created by Olivier on 18/02/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import "AttributedLabel_ExampleAppDelegate.h"
#import "NSAttributedString+Attributes.h"

@implementation AttributedLabel_ExampleAppDelegate

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [self.window makeKeyAndVisible];

	visitedLinks = [[NSMutableSet alloc] init];
	
	/* Don't forget to add the CoreText framework in your project ! */
	[self fillLabel1];
	[self fillLabel2];
	[self fillLabel3];
	
    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)application {
	[visitedLinks release];
}




/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Label 1 : Simple text with bold and custom link.
/////////////////////////////////////////////////////////////////////////////



#define TXT_BEGIN "Discover "
#define TXT_BOLD "FoodReporter"
#define TXT_MIDDLE " to "
#define TXT_LINK "share your food"
#define TXT_END " with your friends!"

-(IBAction)fillLabel1 {
	NSString* txt = @ TXT_BEGIN TXT_BOLD TXT_MIDDLE TXT_LINK TXT_END; // concat the 3 (#define) constant parts in a single NSString
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:txt];
	// for those calls we don't specify a range so it affects the whole string
	[attrStr setFont:[UIFont systemFontOfSize:18]];
	[attrStr setTextColor:[UIColor grayColor]];

	// now we only change the color of "Hello"
	[attrStr setTextColor:[UIColor colorWithRed:0.f green:0.f blue:0.5 alpha:1.f] range:[txt rangeOfString:@TXT_BOLD]];
	[attrStr setTextBold:YES range:[txt rangeOfString:@TXT_BOLD]];
	
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	label1.attributedText = attrStr;
	// and add a link to the "share your food!" text
	[label1 addCustomLink:[NSURL URLWithString:@"http://www.foodreporter.net"] inRange:[txt rangeOfString:@TXT_LINK]];
	 
	// Use the "Justified" alignment
	label1.textAlignment = UITextAlignmentJustify;
	// "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.	
}

-(IBAction)toggleBold:(UISwitch*)aSwitch
{
	/**(3)** (... later ...) Modify again the existing string *******/
	// Get the current attributedString and make it a mutable copy so we can modify it
	NSMutableAttributedString* mas = [label1.attributedText mutableCopy];
	// Modify the the font of "FoodReporter" to bold
	[mas setTextBold:aSwitch.on range:[[label1.attributedText string] rangeOfString:@TXT_BOLD]];
	// Affect back the attributed string to the label
	label1.attributedText = mas;
	// Cleaning: balance the "mutableCopy" call with a "release"
	[mas release];
}






/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Label 2 : Alignment, Size, etc
/////////////////////////////////////////////////////////////////////////////

-(IBAction)changeLineHeight:(id)sender{
    NSMutableAttributedString* attrStr = [label2.attributedText mutableCopy];
    [attrStr setTextAlignment:label2.textAlignment lineBreakMode:label2.lineBreakMode lineHeight:sliderLineHeight.value];
    label2.attributedText = attrStr;
    [label2 setNeedsDisplay];
}


-(IBAction)fillLabel2 {
	// Suppose you already have set the following properties of the myAttributedLabel object in InterfaceBuilder:
	// - 'text' set to "Hello World!"
	// - fontSize set to 12, text color set to gray
	
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = [label2.attributedText mutableCopy];
	// and only change the color of "Hello"
	[attrStr setTextColor:[UIColor redColor] range:NSMakeRange(0,5)];
	
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	label2.attributedText = attrStr;
	// Use the "Justified" alignment
	label2.textAlignment = UITextAlignmentCenter;
	// "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.
	label2.automaticallyAddLinksForType = NSTextCheckingTypeDate|NSTextCheckingTypeAddress|NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber;

	[attrStr release];
}


-(IBAction)changeHAlignment {
	label2.textAlignment = (label2.textAlignment+1) % 4;
}

-(IBAction)changeVAlignment {
	label2.centerVertically = !label2.centerVertically;
}

-(IBAction)changeSize {
	CGRect r = label2.frame;
	r.size.width = 500 - r.size.width; // switch between 200 and 300px
	label2.frame = r;
}




/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Label 3 : Using Links for navigation in your app
/////////////////////////////////////////////////////////////////////////////


-(IBAction)fillLabel3 {
	NSRange linkRange = [label3.text rangeOfString:@"internal navigation"];
	[label3 addCustomLink:[NSURL URLWithString:@"user://tom1362"] inRange:linkRange];
	label3.centerVertically = YES;
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Visited Links
/////////////////////////////////////////////////////////////////////////////

id objectForLinkInfo(NSTextCheckingResult* linkInfo) {
	return (id)linkInfo.URL ?: (id)linkInfo.phoneNumber ?: (id)linkInfo.addressComponents ?: (id)linkInfo.date ?: (id)[linkInfo description];
}

-(UIColor*)colorForLink:(NSTextCheckingResult*)link underlineStyle:(int32_t*)pUnderline {
	if ([visitedLinks containsObject:objectForLinkInfo(link)]) {
		// Visited link
		*pUnderline = kCTUnderlineStyleSingle|kCTUnderlinePatternDot;
		return [UIColor purpleColor];
	} else {
		*pUnderline = kCTUnderlineStyleSingle|kCTUnderlinePatternSolid;
		return [UIColor blueColor];
	}
}

void DisplayAlert(NSString* title, NSString* message) {
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];					
}

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo {
	[visitedLinks addObject:objectForLinkInfo(linkInfo)];
	[attributedLabel setNeedsDisplay];
	
	if ([[linkInfo.URL scheme] isEqualToString:@"user"]) {
		// We use this arbitrary URL scheme to handle custom actions
		// So URLs like "user://xxx" will be handled here instead of opening in Safari.
		// Note: in the above example, "xxx" is the 'host' of the URL
		NSString* user = [linkInfo.URL host];
		DisplayAlert(@"User Profile",[NSString stringWithFormat:@"Here you should display the profile of user %@ on a new screen.",user]);
		
		// Prevent the URL from opening as we handled here manually instead
		return NO;
	} else {
		switch (linkInfo.resultType) {
			case NSTextCheckingTypeLink:
				break;
			case NSTextCheckingTypeAddress:
				DisplayAlert(@"Address",[linkInfo.addressComponents description]);
				break;
			case NSTextCheckingTypeDate:
				DisplayAlert(@"Date",[linkInfo.date description]);
				break;
			case NSTextCheckingTypePhoneNumber:
				DisplayAlert(@"Phone Number",linkInfo.phoneNumber);
				break;
			default:
				DisplayAlert(@"Unknown link type",[NSString stringWithFormat:@"You typed on an unknown link type (NSTextCheckingType %d)",linkInfo.resultType]);
				break;
		}
		// Execute the default behavior, which is opening the URL in Safari.
		return YES;
	}
}

-(IBAction)resetVisitedLinks {
	[visitedLinks removeAllObjects];
	[label1 setNeedsDisplay];
	[label2 setNeedsDisplay];
	[label3 setNeedsDisplay];
}

/////////////////////////////////////////////////////////////////////////////


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
