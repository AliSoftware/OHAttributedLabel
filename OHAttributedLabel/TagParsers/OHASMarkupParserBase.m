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


#import "OHASMarkupParserBase.h"
#import "NSAttributedString+Attributes.h"

#ifndef OHATTRIBUTEDLABEL_DEDICATED_PROJECT
// Copying files in your project and thus compiling OHAttributedLabel under different build settings
// than the one provided is not recommended abd increase risks of leaks (ARC vs. MRC) or unwanted behaviors
#warning [OHAttributedLabel integration] You should include OHAttributedLabel project in your workspace instead of copying the files in your own app project. See README for instructions.
#endif

@interface OHASMarkupParserBase ()
+(NSDictionary*)tagMappings; // To be overloaded by subclasses
@end

@implementation OHASMarkupParserBase

+(NSDictionary*)tagMappings
{
    [NSException raise:@"OHASMarkupParserBase" format:@"This method should be overridden in sublcasses"];
    return nil;
}

+(void)processMarkupInAttributedString:(NSMutableAttributedString*)mutAttrString
{
    NSDictionary* mappings = [self tagMappings];
    NSRegularExpressionOptions options = NSRegularExpressionAnchorsMatchLines
    | NSRegularExpressionDotMatchesLineSeparators | NSRegularExpressionUseUnicodeWordBoundaries;
    [mappings enumerateKeysAndObjectsUsingBlock:^(id pattern, id obj, BOOL *stop1)
     {
         TagProcessorBlockType block = (TagProcessorBlockType)obj;
         NSRegularExpression* regEx = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
         
         NSAttributedString* processedString = [mutAttrString copy];
         __block NSUInteger offset = 0;
         NSRange range = NSMakeRange(0, processedString.length);
         [regEx enumerateMatchesInString:processedString.string options:0 range:range
                              usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop2)
          {
              NSAttributedString* repl = block(processedString, result);
              if (repl)
              {
                  NSRange offsetRange = NSMakeRange(result.range.location - offset, result.range.length);
                  [mutAttrString replaceCharactersInRange:offsetRange withAttributedString:repl];
                  offset += result.range.length - repl.length;
              }
          }];
#if ! __has_feature(objc_arc)
         [processedString release];
#endif
     }];

}

+(NSMutableAttributedString*)attributedStringByProcessingMarkupInAttributedString:(NSAttributedString*)attrString
{
    NSMutableAttributedString* mutAttrString = [attrString mutableCopy];
    [self processMarkupInAttributedString:mutAttrString];
#if ! __has_feature(objc_arc)
    return [mutAttrString autorelease];
#else
    return mutAttrString;
#endif
}

+(NSMutableAttributedString*)attributedStringByProcessingMarkupInString:(NSString*)string
{
    NSMutableAttributedString* mutAttrString = [NSMutableAttributedString attributedStringWithString:string];
    [self processMarkupInAttributedString:mutAttrString];
    return mutAttrString;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - String to Color function

UIColor* OHUIColorFromString(NSString* colorString)
{
    UIColor* color = nil;
    if ([colorString hasPrefix:@"#"])
    {
        NSScanner * hexScanner = [NSScanner scannerWithString:colorString];
        [hexScanner setScanLocation:1];
        unsigned int rgba;
        [hexScanner scanHexInt:&rgba];
        switch(colorString.length)
        {
            case 4: // #rgb
                color = [UIColor colorWithRed:((rgba>> 8)&0x0F)/15.f
                                        green:((rgba>> 4)&0x0F)/15.f
                                         blue:((rgba    )&0x0F)/15.f
                                        alpha:1.0f];
                break;
            case 5: // #rgba
                color = [UIColor colorWithRed:((rgba>>12)&0x0F)/15.f
                                        green:((rgba>> 8)&0x0F)/15.f
                                         blue:((rgba>> 4)&0x0F)/15.f
                                        alpha:((rgba    )&0x0F)/15.f];
                break;
            case 7: // #rrggbb
                color = [UIColor colorWithRed:((rgba>>16)&0xFF)/255.f
                                        green:((rgba>> 8)&0xFF)/255.f
                                         blue:((rgba    )&0xFF)/255.f
                                        alpha:1.0f];
                break;
            case 9: // #rrggbbaa
                color = [UIColor colorWithRed:((rgba>>24)&0xFF)/255.f
                                        green:((rgba>>16)&0xFF)/255.f
                                         blue:((rgba>> 8)&0xFF)/255.f
                                        alpha:((rgba    )&0xFF)/255.f];
                break;
        }
    }
    else
    {
        // Allow "red", "green", "blue", etc… and use the corresponding redColor, greenColor, blueColor, etc… class methods of UIColor
        NSString* selectorName = [NSString stringWithFormat:@"%@Color", colorString.lowercaseString];
        SEL selector = NSSelectorFromString(selectorName);
        NSMethodSignature* sign = [UIColor.class methodSignatureForSelector:selector];
        // Check that the selector exists and return an NSObject/id, so that we can call it and retrieve the return value
        if ([UIColor.class respondsToSelector:selector] && (0 == strcmp([sign methodReturnType],@encode(id))) )
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks" // "xxxColor" selectors return autoreleased object so we're cool
            id clr = [UIColor.class performSelector:selector];
#pragma clang diagnostic pop
            // Check that the returned object is really an UIColor, just in case
            color = ([clr isKindOfClass:UIColor.class]) ? clr : nil;
        }
    }
    
    return color;
}
