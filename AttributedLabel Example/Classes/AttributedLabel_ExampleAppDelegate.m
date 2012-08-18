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
- (void)applicationWillTerminate:(UIApplication *)application
{
#if ! __has_feature(objc_arc)
	[visitedLinks release];
#endif
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

-(IBAction)fillLabel1
{
	NSString* txt = @ TXT_BEGIN TXT_BOLD TXT_MIDDLE TXT_LINK TXT_END; // concat the 5 (#define) constant parts in a single NSString
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:txt];
	// for those calls we don't specify a range so it affects the whole string
	[attrStr setFont:[UIFont fontWithName:@"Helvetica" size:18]];
	[attrStr setTextColor:[UIColor grayColor]];
    [attrStr setTextAlignment:kCTJustifiedTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];

	// now we only change the color of "FoodReporter"
	[attrStr setTextColor:[UIColor colorWithRed:0.f green:0.f blue:0.5 alpha:1.f] range:[txt rangeOfString:@TXT_BOLD]];
	[attrStr setTextBold:YES range:[txt rangeOfString:@TXT_BOLD]];
	
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	label1.attributedText = attrStr;
	// and add a link to the "share your food!" text
	[label1 addCustomLink:[NSURL URLWithString:@"http://www.foodreporter.net"] inRange:[txt rangeOfString:@TXT_LINK]];
	 
	// "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.
}

-(IBAction)toggleBold:(UISwitch*)aSwitch
{
	/**(3)** (... later ...) Modify again the existing string *******/
	
	// Get the current attributedString and make it a mutable copy so we can modify it
	NSMutableAttributedString* mas = [label1.attributedText mutableCopy];
	NSString* plainText = [mas string];
	// Modify the the font of "FoodReporter" to bold
	[mas setTextBold:aSwitch.on range:[plainText rangeOfString:@TXT_BOLD]];
	// Affect back the attributed string to the label
	label1.attributedText = mas;
	
	// Restore the link (as each time we change the attributedText we remove custom links to avoid inconsistencies
	[label1 addCustomLink:[NSURL URLWithString:@"http://www.foodreporter.net"] inRange:[plainText rangeOfString:@TXT_LINK]];

#if ! __has_feature(objc_arc)
	// Cleaning: balance the "mutableCopy" call with a "release"
	[mas release];
#endif
}






/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Label 2 : Alignment, Size, etc
/////////////////////////////////////////////////////////////////////////////




-(IBAction)fillLabel2
{
	// Suppose you already have set the following properties of the myAttributedLabel object in InterfaceBuilder:
	// - 'text' set to "Hello World!"
	// - fontSize set to 12, text color set to gray
	
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = [label2.attributedText mutableCopy];
    [attrStr setTextAlignment:kCTCenterTextAlignment lineBreakMode:kCTLineBreakByWordWrapping];
	// and only change the color of "Hello"
	[attrStr setTextColor:[UIColor redColor] range:NSMakeRange(26,5)];
	
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	label2.attributedText = attrStr;
	// "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.
	label2.automaticallyAddLinksForType = NSTextCheckingTypeDate|NSTextCheckingTypeAddress|NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber;
    label2.centerVertically = NO;

#if ! __has_feature(objc_arc)
	[attrStr release];
#endif
}


-(IBAction)changeHAlignment
{
    // NOTE: You could use label2.textAlignment but this does not support the "Justified" text alignement
    // label2.textAlignment = ( (int)label2.textAlignment + 1 ) % 3;
    // So we prefer to set the CTTextAlignment on the whole NSAttributedString instead
    
    
    NSMutableAttributedString* attrStr = [label2.attributedText mutableCopy];
    
    CTTextAlignment textAlign = [attrStr textAlignmentAtIndex:0 effectiveRange:NULL];
    textAlign = (CTTextAlignment)  ( ((int)textAlign + 1) % 4 ); // loop thru enum values 0 to 3 (left, center, right, justified)
    [attrStr setTextAlignment:textAlign lineBreakMode:kCTLineBreakByWordWrapping];
    
    label2.attributedText = attrStr;
#if ! __has_feature(objc_arc)
	[attrStr release];
#endif
}

-(IBAction)changeVAlignment
{
	label2.centerVertically = !label2.centerVertically;
}

-(IBAction)changeSize
{
	CGRect r = label2.frame;
	r.size.width = 500 - r.size.width; // switch between 200 and 300px
	label2.frame = r;
}




/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Label 3 : Using Links for navigation in your app
/////////////////////////////////////////////////////////////////////////////


-(IBAction)fillLabel3
{
	NSRange linkRange = [label3.text rangeOfString:@"internal navigation"];
	[label3 addCustomLink:[NSURL URLWithString:@"user://tom1362"] inRange:linkRange];
	label3.centerVertically = YES;
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Visited Links
/////////////////////////////////////////////////////////////////////////////

id objectForLinkInfo(NSTextCheckingResult* linkInfo)
{
	// Return the first non-nil property
	return (id)linkInfo.URL ?: (id)linkInfo.phoneNumber ?: (id)linkInfo.addressComponents ?: (id)linkInfo.date ?: (id)[linkInfo description];
}

-(UIColor*)colorForLink:(NSTextCheckingResult*)link underlineStyle:(int32_t*)pUnderline
{
	if ([visitedLinks containsObject:objectForLinkInfo(link)]) {
		// Visited link
		*pUnderline = kCTUnderlineStyleSingle|kCTUnderlinePatternDot;
		return [UIColor purpleColor];
	} else {
		*pUnderline = kCTUnderlineStyleSingle|kCTUnderlinePatternSolid;
		return [UIColor blueColor];
	}
}

void DisplayAlert(NSString* title, NSString* message)
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
#if ! __has_feature(objc_arc)
	[alert release];
#endif
}

-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
	[visitedLinks addObject:objectForLinkInfo(linkInfo)];
	[attributedLabel setNeedsDisplay];
	
	if ([[linkInfo.URL scheme] isEqualToString:@"user"]) {
		// We use this arbitrary URL scheme to handle custom actions
		// So URLs like "user://xxx" will be handled here instead of opening in Safari.
		// Note: in the above example, "xxx" is the 'host' part of the URL
		NSString* user = [linkInfo.URL host];
		DisplayAlert(@"User Profile",[NSString stringWithFormat:@"Here you could display the profile of user %@ on a new screen.",user]);
		
		// Prevent the URL from opening in Safari, as we handled it here manually instead
		return NO;
	} else {
		switch (linkInfo.resultType) {
			case NSTextCheckingTypeLink: // use default behavior
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
				DisplayAlert(@"Unknown link type",[NSString stringWithFormat:@"You typed on an unknown link type (NSTextCheckingType %lld)",linkInfo.resultType]);
				break;
		}
		// Execute the default behavior, which is opening the URL in Safari for URLs, starting a call for phone numbers, ...
		return YES;
	}
}

-(IBAction)resetVisitedLinks
{
	[visitedLinks removeAllObjects];
	[label1 setNeedsDisplay];
	[label2 setNeedsDisplay];
	[label3 setNeedsDisplay];
}

/////////////////////////////////////////////////////////////////////////////

#if ! __has_feature(objc_arc)
- (void)dealloc
{
    [window release];
    [super dealloc];
}
#endif

@end
