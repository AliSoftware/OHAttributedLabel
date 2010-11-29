/***********************************************************************************
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
 ***********************************************************************************
 *
 * Created by Olivier Halligon  (AliSoftware) on 20 Jul. 2010.
 * Any comment or suggestion welcome. Referencing this project in your AboutBox is appreciated.
 * Please tell me if you use this class so we can cross-reference our projects.
 *
 ***********************************************************************************/



#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: NS(Mutable)AttributedString Additions
/////////////////////////////////////////////////////////////////////////////

@interface NSAttributedString (OHCommodityConstructors)
+(id)attributedStringWithString:(NSString*)string;
+(id)attributedStringWithAttributedString:(NSAttributedString*)attrStr;
@end

@interface NSMutableAttributedString (OHCommodityStyleModifiers)
-(void)setFont:(UIFont*)font;
-(void)setFont:(UIFont*)font range:(NSRange)range;
-(void)setFontName:(NSString*)fontName size:(CGFloat)size;
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range;
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range;

-(void)setTextColor:(UIColor*)color;
-(void)setTextColor:(UIColor*)color range:(NSRange)range;

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode;
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range;
@end



/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: OHAttributedLabel
/////////////////////////////////////////////////////////////////////////////

#define UITextAlignmentJustify ((UITextAlignment)kCTJustifiedTextAlignment)

@interface OHAttributedLabel : UILabel {
	NSMutableAttributedString* _attributedText; //!< Internally mutable, but externally immutable copy access only
}
@property(nonatomic, copy) NSAttributedString* attributedText; //!< Use this instead of the "text" property inherited from UILabel to set and get text
-(void)resetAttributedText; //!< rebuild the attributedString based on UILabel's text/font/color/alignment/... properties
@end
