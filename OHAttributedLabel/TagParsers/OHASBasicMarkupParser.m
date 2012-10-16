//
//  OHASBasicMarkdownParser.m
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 27/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import "OHASBasicMarkupParser.h"
#import "NSAttributedString+Attributes.h"

#if __has_feature(objc_arc)
#define MRC_AUTORELEASE(x) (x)
#else
#define MRC_AUTORELEASE(x) [(x) autorelease]
#endif

@implementation OHASBasicMarkupParser

+(NSDictionary*)tagMappings
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSRange textRange = [match rangeAtIndex:1];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                if (textRange.length>0) [foundString setTextBold:YES range:NSMakeRange(0,textRange.length)];
                return MRC_AUTORELEASE(foundString);
            }, @"\\*(.*?)\\*",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSRange textRange = [match rangeAtIndex:1];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                if (textRange.length>0) [foundString setTextIsUnderlined:YES];
                return MRC_AUTORELEASE(foundString);
            }, @"_(.*?)_",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSRange textRange = [match rangeAtIndex:1];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                CTFontRef font = [str fontAtIndex:textRange.location effectiveRange:NULL];
                if (textRange.length>0) [foundString setFontName:@"Courier" size:CTFontGetSize(font)];
                return MRC_AUTORELEASE(foundString);
            }, @"`(.*?)`",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match) {
                NSString* colorName = [str attributedSubstringFromRange:[match rangeAtIndex:1]].string;
                UIColor* color = UIColorFromString(colorName);
                NSRange textRange = [match rangeAtIndex:2];
                NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                if (textRange.length>0) [foundString setTextColor:color];
                return MRC_AUTORELEASE(foundString);
            }, @"\\{(.*?)\\|(.*?)\\}",
            
            nil];
}

@end
