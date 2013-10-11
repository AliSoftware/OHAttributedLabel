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


#import "OHASBasicHTMLParser.h"
#import "NSAttributedString+Attributes.h"

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
                    return foundString;
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
                    return foundString;
                } else {
                    return nil;
                }
            }, @"<u>(.+?)</u>",
            
            
            ^NSAttributedString*(NSAttributedString* str, NSTextCheckingResult* match)
            {
                NSRange textRange = [match rangeAtIndex:1];
                if (textRange.length>0)
                {
                    NSMutableAttributedString* foundString = [[str attributedSubstringFromRange:textRange] mutableCopy];
                    [foundString setTextItalics:YES range:NSMakeRange(0,foundString.length)];
                    return foundString;
                } else {
                    return nil;
                }
            }, @"<i>(.+?)</i>",
            
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
                    return foundString;
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
                    return foundString;
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
                    return foundString;
                } else {
                    return nil;
                }
            }, @"<a href=(['\"])(.+?)\\1>(.+?)</a>",
            
            nil];
}

@end


