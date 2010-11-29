/**********************************
* OHAttributedLabel usage example *
**********************************/

-(void)initWithHelloWorld
{
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = [NSMutableAttributedString attributedStringWithString:@"Hello World!"];
	// for those calls we don't specify a range so it affects the whole string
	[attrStr setFont:[UIFont systemFontOfSize:12]];
	[attrStr setTextColor:[UIColor grayColor]];
	// now we only change the color of "Hello"
	[attrStr setTextColor:[UIColor redColor] range:NSMakeRange(0,5)];
	
	
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	myAttributedLabel.attributedText = attrStr;
	// Use the "Justified" alignment
	myAttributedLabel.textAlignment = UITextAlignmentJustify;
	// "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.
}

-(void)makeWorldBold
{
	/**(3)** (... later ...) Modify again the existing string *******/
	// Get the current attributedString and make it a mutable copy so we can modify it
	NSMutableAttributedString* mas = [myAttributedLabel.attributedText mutableCopy];
	// Modify the the font of "World!" to bold, 14pt
	[mas setFont:[UIFont boldSystemFontOfSize:14] range:NSMakeRange(6,6)];
	// Affect back the attributed string to the label
	myAttributedLabel.attributedText = mas;
	// Cleaning: balance the "mutableCopy" call with a "release"
	[mas release];
}
	



/** NOTE **
 * we may also directly ask for the attributedString directly as a first step,
 * even if we did not initialize it before: in such cases, it will build the
 * NSAttributedString automatically (using the text/font/color/... properties
 * of the OHAttributedLabel) and return it... so building it like in the first
 * step above is not actually necessary in all situations!
 */

-(void)initWithHelloWorld_Alternative
{
	// Suppose you already have set the following properties of the myAttributedLabel object in InterfaceBuilder:
	// - 'text' set to "Hello World!"
	// - fontSize set to 12, text color set to gray
	
	/**(1)** Build the NSAttributedString *******/
	NSMutableAttributedString* attrStr = myAttributedLabel.attributedText;
	// and only change the color of "Hello"
	[attrStr setTextColor:[UIColor redColor] range:NSMakeRange(0,5)];
	
	
	/**(2)** Affect the NSAttributedString to the OHAttributedLabel *******/
	myAttributedLabel.attributedText = attrStr;
	// Use the "Justified" alignment
	myAttributedLabel.textAlignment = UITextAlignmentJustify;
	// "Hello World!" will be displayed in the label, justified, "Hello" in red and " World!" in gray.
}
