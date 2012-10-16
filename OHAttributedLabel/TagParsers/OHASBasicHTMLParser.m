//
//  OHASBasicHTMLParser.m
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 26/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import "OHASBasicHTMLParser.h"
#import "NSAttributedString+Attributes.h"

#if __has_feature(objc_arc)
#define MRC_AUTORELEASE(x) (x)
#else
#define MRC_AUTORELEASE(x) [(x) autorelease]
#endif

@implementation OHASBasicHTMLParser

+(NSDictionary*)tagMappings
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSRange textRange = [match rangeAtIndex:1];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                if (textRange.length>0) [foundString setTextBold:YES range:NSMakeRange(0,textRange.length)];
                return MRC_AUTORELEASE(foundString);
            }, @"<b>(.*?)</b>",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSRange textRange = [match rangeAtIndex:1];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                if (textRange.length>0) [foundString setTextIsUnderlined:YES];
                return MRC_AUTORELEASE(foundString);
            }, @"<u>(.*?)</u>",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSString* fontName = [str attributedSubstringFromRange:[match rangeAtIndex:2]].string;
                CGFloat fontSize = [str attributedSubstringFromRange:[match rangeAtIndex:4]].string.floatValue;
                NSRange textRange = [match rangeAtIndex:5];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                if (textRange.length>0) [foundString setFontName:fontName size:fontSize];
                return MRC_AUTORELEASE(foundString);
            }, @"<font name=(['\"])(.*?)\\1 size=(['\"])(.*?)\\3>(.*?)</font>",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSString* colorName = [str attributedSubstringFromRange:[match rangeAtIndex:2]].string;
                UIColor* color = UIColorFromString(colorName);
                NSRange textRange = [match rangeAtIndex:3];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                if (textRange.length>0) [foundString setTextColor:color];
                return MRC_AUTORELEASE(foundString);
            }, @"<font color=(['\"])(.*?)\\1>(.*?)</font>",
            
            /*
             // Disabled for now as there is no official CoreText attribute name to define links.
             // To be able to do this, we have implement a custom attribute ourselves and add support for it in OHAttributedLabel
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSString* link = [str attributedSubstringFromRange:[match rangeAtIndex:1]].string;
                NSRange textRange = [match rangeAtIndex:2];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                [foundString addAttribute:@"NSLinkAttributeName" value:link range:NSMakeRange(0,textRange.length)];
                return [foundString autorelease];
            }, @"<a href='(.*?)'>(.*?)</a>",
             */
            
            nil];
}

@end


