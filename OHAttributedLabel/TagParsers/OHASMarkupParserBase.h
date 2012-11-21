//
//  OHASMarkupParserBase.h
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 26/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSAttributedString*(^TagProcessorBlockType)(NSAttributedString*, NSTextCheckingResult*);

/*!
 * @class OHASTagParserBase
 * This is an Abstract class to be used for Tag parsers subclasses
 *
 * ## Subclassing notes ##
 *
 * Subclasses have to override the -(NSDictionary*)tagMappings method that
 * has to return a dictionary whose keys are regular expression patterns
 * and values are TagProcessorBlockType blocks (see typedef above).
 *
 * The blocks takes the unprocessed string and the regex match as input parameters
 * and should return the attributedString to use as the replacement for the match.
 *
 * For example for the key @"<b>(.*?)</b>" we can have a block that return the text corresponding to
 *   the substring with range [match rangeAtIndex:1] (i.e. the text matched inside the parenthesis)
 *   with its font attribute changed to the bold font variant.
 *
 * @see OHASTagParserHTML implementation for an example
 */

@interface OHASMarkupParserBase : NSObject

/*!
 * Call this on concrete subclasses to process tags in an NSMutableAttributedString
 * and apply them (by changing the corresponding attributes)
 *
 * e.g. attrStr = [OHASTagParserHTML replacTagsInAttributedString:mutAttrStr];
 */
+(void)processMarkupInAttributedString:(NSMutableAttributedString*)mutAttrString;

/*!
 * Call this on concrete subclasses to get a parsed NSAttributedString with its attributes
 * changed according to the tags in the original attributed string.
 *
 * Note: this convenience method simply create a mutableCopy of string and use it to call "processMarkupInAttributedString:".
 */
+(NSMutableAttributedString*)attributedStringByProcessingMarkupInAttributedString:(NSAttributedString*)attrString;

/*!
 * Call this on concrete subclasses to get a parsed NSAttributedString with its attributes
 * set according to the tags in the original string.
 *
 * Note: this convenience method simply create a mutableAttributedString from string and use it to call "processMarkupInAttributedString:".
 */
+(NSMutableAttributedString*)attributedStringByProcessingMarkupInString:(NSString*)string;

@end

/*! Useful common function to convert strings to colors
 * Support "#rgb", "#rgba", "#rrggbb" and "#rrggbbaa" hexadecimal representations (e.g. "#ffcc00")
 * Support also named colors exposed by UIColor class commodity "xxxColor" constructors, namely "red", "green", "blue", etc
 */
UIColor* OHUIColorFromString(NSString* colorString);
