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
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

#import "OHParagraphStyle.h"
extern NSString* kOHLinkAttributeName;

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSAttributedString Additions

@interface NSAttributedString (OHCommodityConstructors)
+(id)attributedStringWithString:(NSString*)string;
+(id)attributedStringWithAttributedString:(NSAttributedString*)attrStr;

//! Commodity method that call the following sizeConstrainedToSize:fitRange: method with NULL for the fitRange parameter
-(CGSize)sizeConstrainedToSize:(CGSize)maxSize;
//! if fitRange is not NULL, on return it will contain the used range that actually fits the constrained size.
//! Note: Use CGFLOAT_MAX for the CGSize's height if you don't want a constraint for the height.
-(CGSize)sizeConstrainedToSize:(CGSize)maxSize fitRange:(NSRange*)fitRange;

-(CTFontRef)fontAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
-(UIColor*)textColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
-(BOOL)textIsUnderlinedAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
//! @return a combination of CTUnderlineStyle & CTUnderlineStyleModifiers
-(int32_t)textUnderlineStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
-(BOOL)textIsBoldAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
-(CTTextAlignment)textAlignmentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
-(CTLineBreakMode)lineBreakModeAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
-(OHParagraphStyle*)paragraphStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;

-(NSURL*)linkAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange;
@end


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSMutableAttributedString Additions

@interface NSMutableAttributedString (OHCommodityStyleModifiers)
-(void)setFont:(UIFont*)font;
-(void)setFont:(UIFont*)font range:(NSRange)range;
-(void)setFontName:(NSString*)fontName size:(CGFloat)size;
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range;
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range;

-(void)setTextColor:(UIColor*)color;
-(void)setTextColor:(UIColor*)color range:(NSRange)range;
-(void)setTextIsUnderlined:(BOOL)underlined;
-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range;
//! @param style is a combination of CTUnderlineStyle & CTUnderlineStyleModifiers
-(void)setTextUnderlineStyle:(int32_t)style range:(NSRange)range;
-(void)setTextBold:(BOOL)isBold range:(NSRange)range;
-(void)setTextItalics:(BOOL)isItalics range:(NSRange)range;

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode;
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range;

/* Allows you to modify only certain Paragraph Styles without changing the others (for example changing the firstLineHeadIndent without overriding the textAlignment) */
-(void)modifyParagraphStylesWithBlock:(void(^)(OHParagraphStyle* paragraphStyle))block;
-(void)modifyParagraphStylesInRange:(NSRange)range withBlock:(void(^)(OHParagraphStyle* paragraphStyle))block;
/* Override the Paragraph Styles, dropping the ones previously set if any.
 Be aware that this will override the text alignment, linebreakmode, and all other paragraph styles with the new values */
-(void)setParagraphStyle:(OHParagraphStyle *)style;
-(void)setParagraphStyle:(OHParagraphStyle*)style range:(NSRange)range;

-(void)setLink:(NSURL*)link range:(NSRange)range;
@end


