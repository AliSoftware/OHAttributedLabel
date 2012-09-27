//
//  AttributedLabel_ExampleAppDelegate.m
//  AttributedLabel Example
//
//  Created by Olivier on 18/02/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import "UIAlertView+Commodity.h"

@implementation UIAlertView(Commodity)

+(void)showWithTitle:(NSString*)title message:(NSString*)message
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
#if ! __has_feature(objc_arc)
	[alert release];
#endif
}

@end