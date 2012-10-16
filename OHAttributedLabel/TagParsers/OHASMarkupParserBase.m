//
//  OHASMarkupParserBase.m
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 26/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import "OHASMarkupParserBase.h"
#import "NSAttributedString+Attributes.h"

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
    
    NSRegularExpressionOptions options = NSRegularExpressionAnchorsMatchLines;
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
              NSRange offsetRange = NSMakeRange(result.range.location - offset, result.range.length);
              [mutAttrString replaceCharactersInRange:offsetRange withAttributedString:repl];
              offset += result.range.length - repl.length;
          }];
#if ! __has_feature(objc_arc)
         [processedString release];
#endif
     }];

}

+(NSAttributedString*)attributedStringByProcessingMarkupInAttributedString:(NSAttributedString*)attrString
{
    NSMutableAttributedString* mutAttrString = [attrString mutableCopy];
    [self processMarkupInAttributedString:mutAttrString];
#if ! __has_feature(objc_arc)
    return [mutAttrString autorelease];
#else
    return mutAttrString;
#endif
}

+(NSAttributedString*)attributedStringByProcessingMarkupInString:(NSString*)string
{
    NSMutableAttributedString* mutAttrString = [NSMutableAttributedString attributedStringWithString:string];
    [self processMarkupInAttributedString:mutAttrString];
    return mutAttrString;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - String to Color function

UIColor* UIColorFromString(NSString* colorString)
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
                color = [UIColor colorWithRed:((rgba>> 8)&0x0F)/15.
                                        green:((rgba>> 4)&0x0F)/15.
                                         blue:((rgba    )&0x0F)/15.
                                        alpha:1.0];
                break;
            case 5: // #rgba
                color = [UIColor colorWithRed:((rgba>>12)&0x0F)/15.
                                        green:((rgba>> 8)&0x0F)/15.
                                         blue:((rgba>> 4)&0x0F)/15.
                                        alpha:((rgba    )&0x0F)/15.];
                break;
            case 7: // #rrggbb
                color = [UIColor colorWithRed:((rgba>>16)&0xFF)/255.
                                        green:((rgba>> 8)&0xFF)/255.
                                         blue:((rgba    )&0xFF)/255.
                                        alpha:1.0];
                break;
            case 9: // #rrggbbaa
                color = [UIColor colorWithRed:((rgba>>24)&0xFF)/255.
                                        green:((rgba>>16)&0xFF)/255.
                                         blue:((rgba>> 8)&0xFF)/255.
                                        alpha:((rgba    )&0xFF)/255.];
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
            id clr = [UIColor.class performSelector:selector];
            // Check that the returned object is really an UIColor, just in case
            color = ([clr isKindOfClass:UIColor.class]) ? clr : nil;
        }
    }
    
    return color;
}
