/***********************************************************************************
 * This software is under the MIT License quoted below:
 ***********************************************************************************
 *
 * Copyright (c) 2010 Olivier Halligon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/


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
            }, @"_(.+?)_", /* "_xxx_" = xxx in underline */
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                if (textRange.length>0)
                {
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    [foundString setTextItalics:YES range:NSMakeRange(0,foundString.length)];
                    return MRC_AUTORELEASE(foundString);
                } else {
                    return nil;
                }
            }, @"\\|(.+?)\\|", /* "_xxx_" = xxx in italics */
            
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
