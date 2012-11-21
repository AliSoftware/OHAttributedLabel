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
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                if (textRange.length>0)
                {
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    [foundString setTextBold:YES range:NSMakeRange(0,textRange.length)];
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"\\*(.+?)\\*", /* "*xxx*" = xxx in bold */
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                if (textRange.length>0)
                {
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    [foundString setTextIsUnderlined:YES];
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"_(.+?)_", /* "_xxx_" = xxx in italics */
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                if (textRange.length>0)
                {
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    CTFontRef font = [str fontAtIndex:textRange.location effectiveRange:NULL];
                    [foundString setFontName:@"Courier" size:CTFontGetSize(font)];
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"`(.+?)`", /* "`xxx`" = xxx in Courier font */
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange colorRange = [match rangeAtIndex:1];
                NSRange textRange = [match rangeAtIndex:2];
                if ((colorRange.length>0) && (textRange.length>0))
                {
                    NSString* colorName = [str attributedSubstringFromRange:colorRange].string;
                    UIColor* color = OHUIColorFromString(colorName);
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    [foundString setTextColor:color];
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"\\{(.+?)\\|(.+?)\\}", /* "{color|text}" = text in specified color */
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                NSRange linkRange = [match rangeAtIndex:2];
                if ((linkRange.length>0) && (textRange.length>0))
                {
                    NSString* linkString = [str attributedSubstringFromRange:linkRange].string;
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    [foundString setLink:[NSURL URLWithString:linkString] range:NSMakeRange(0, foundString.length)];
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"\\[(.+?)\\]\\((.+?)\\)", /* "[text](link)" = add link to text */
            
            nil];
}

@end
