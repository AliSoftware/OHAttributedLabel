//
//  NSTextCheckingResult+ExtendedURL.m
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 23/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import "NSTextCheckingResult+ExtendedURL.h"
#import <UIKit/UIKit.h>

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSTextCheckingResult Extension

@implementation NSTextCheckingResult(ExtendedURL)
-(NSURL*)extendedURL
{
    NSURL* url = self.URL;
    if (self.resultType == NSTextCheckingTypeAddress)
    {
        NSString* baseURL = ([UIDevice currentDevice].systemVersion.floatValue >= 6.0) ? @"maps.apple.com" : @"maps.google.com";
        NSString* mapURLString = [NSString stringWithFormat:@"http://%@/maps?q=%@", baseURL,
                                  [self.addressComponents.allValues componentsJoinedByString:@","]];
        url = [NSURL URLWithString:mapURLString];
    }
    else if (self.resultType == NSTextCheckingTypePhoneNumber)
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [self.phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""]]];
    }
    return url;
}
@end




