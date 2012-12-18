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
