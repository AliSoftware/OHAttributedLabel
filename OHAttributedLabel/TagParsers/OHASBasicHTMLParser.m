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
            }, @"<b>(.+?)</b>",
            
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
            }, @"<u>(.+?)</u>",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange fontNameRange = [match rangeAtIndex:2];
                NSRange fontSizeRange = [match rangeAtIndex:4];
                NSRange textRange = [match rangeAtIndex:5];
                if ((fontNameRange.length>0) && (fontSizeRange.length>0) && (textRange.length>0))
                {
                    NSString* fontName = [str attributedSubstringFromRange:fontNameRange].string;
                    CGFloat fontSize = [str attributedSubstringFromRange:fontSizeRange].string.floatValue;
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    [foundString setFontName:fontName size:fontSize];
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"<font name=(['\"])(.+?)\\1 size=(['\"])(.+?)\\3>(.+?)</font>",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange colorRange = [match rangeAtIndex:2];
                NSRange textRange = [match rangeAtIndex:3];
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
            }, @"<font color=(['\"])(.+?)\\1>(.+?)</font>",
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange linkRange = [match rangeAtIndex:2];
                NSRange textRange = [match rangeAtIndex:3];
                if ((linkRange.length>0) && (textRange.length>0))
                {
                    NSString* link = [str attributedSubstringFromRange:linkRange].string;
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    [foundString setLink:[NSURL URLWithString:link] range:NSMakeRange(0,textRange.length)];
                    return [foundString autorelease];
                } else {
                    return nil;
                }
            }, @"<a href=(['\"])(.+?)\\1>(.+?)</a>",
            
            nil];
}

@end


