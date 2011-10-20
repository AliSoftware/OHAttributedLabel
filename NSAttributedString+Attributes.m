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
 *
 * Any comment or suggestion welcome. Please contact me before using this class in
 * your projects. Referencing this project in your AboutBox/Credits is appreciated.
 *
 ***********************************************************************************/


#import "NSAttributedString+Attributes.h"


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: NS(Mutable)AttributedString Additions
/////////////////////////////////////////////////////////////////////////////

@implementation NSAttributedString (OHCommodityConstructors)
+(id)attributedStringWithString:(NSString*)string {
	id attributedString = string ? [[self alloc] initWithString:string] : nil;
#if OBJC_ARC_ENABLED
	return attributedString;
#else
	return [attributedString autorelease];
#endif
}
+(id)attributedStringWithAttributedString:(NSAttributedString*)attrStr {
	id attributedString = attrStr ? [[self alloc] initWithAttributedString:attrStr] : nil;
#if OBJC_ARC_ENABLED
	return attributedString;
#else
	return [attributedString autorelease];
#endif
}

-(CGSize)sizeConstrainedToSize:(CGSize)maxSize {
	return [self sizeConstrainedToSize:maxSize fitRange:NULL];
}
-(CGSize)sizeConstrainedToSize:(CGSize)maxSize fitRange:(NSRange*)fitRange {
#if OBJC_ARC_ENABLED
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
#else
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
#endif
	CFRange fitCFRange = CFRangeMake(0,0);
	CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,maxSize,&fitCFRange);
	if (framesetter) CFRelease(framesetter);
	if (fitRange) *fitRange = NSMakeRange(fitCFRange.location, fitCFRange.length);
	return CGSizeMake( floorf(sz.width+1) , floorf(sz.height+1) ); // take 1pt of margin for security
}
@end




@implementation NSMutableAttributedString (OHCommodityStyleModifiers)

-(void)setFont:(UIFont*)font {
	[self setFontName:font.fontName size:font.pointSize];
}
-(void)setFont:(UIFont*)font range:(NSRange)range {
	[self setFontName:font.fontName size:font.pointSize range:range];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size {
	[self setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range {
	// kCTFontAttributeName
#if OBJC_ARC_ENABLED
	CTFontRef aFont = CTFontCreateWithName((__bridge CFStringRef)fontName, size, NULL);
	if (!aFont) return;
	[self removeAttribute:(__bridge NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge_transfer id)aFont range:range];
#else
	CTFontRef aFont = CTFontCreateWithName((CFStringRef)fontName, size, NULL);
	if (!aFont) return;
	[self removeAttribute:(NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString*)kCTFontAttributeName value:(id)aFont range:range];
	CFRelease(aFont);
#endif
}
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range {
	// kCTFontFamilyNameAttribute + kCTFontTraitsAttribute
	CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
	NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:symTrait] forKey:(NSString*)kCTFontSymbolicTrait];
	NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
						  fontFamily,kCTFontFamilyNameAttribute,
						  trait,kCTFontTraitsAttribute,nil];
	
#if OBJC_ARC_ENABLED
	CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attr);
#else
	CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attr);
#endif
	if (!desc) return;
	CTFontRef aFont = CTFontCreateWithFontDescriptor(desc, size, NULL);
	CFRelease(desc);
	if (!aFont) return;

	[self removeAttribute:(NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
#if OBJC_ARC_ENABLED
	[self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge_transfer id)aFont range:range];
#else
	[self addAttribute:(NSString*)kCTFontAttributeName value:(id)aFont range:range];
	CFRelease(aFont);
#endif
}

-(void)setTextColor:(UIColor*)color {
	[self setTextColor:color range:NSMakeRange(0,[self length])];
}
-(void)setTextColor:(UIColor*)color range:(NSRange)range {
	// kCTForegroundColorAttributeName
	[self removeAttribute:(NSString*)kCTForegroundColorAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
}

-(void)setTextIsUnderlined:(BOOL)underlined {
	[self setTextIsUnderlined:underlined range:NSMakeRange(0,[self length])];
}
-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range {
	int32_t style = underlined ? (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid) : kCTUnderlineStyleNone;
	[self setTextUnderlineStyle:style range:range];
}
-(void)setTextUnderlineStyle:(int32_t)style range:(NSRange)range {
	[self removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:range];
}

-(void)setTextBold:(BOOL)bold range:(NSRange)range {
	NSUInteger startPoint = range.location;
	NSRange effectiveRange;
	do {
		// Get font at startPoint
#if OBJC_ARC_ENABLED
		CTFontRef currentFont = (__bridge CTFontRef)[self attribute:(__bridge NSString*)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange];
#else
		CTFontRef currentFont = (CTFontRef)[self attribute:(NSString*)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange];
#endif
		// The range for which this font is effective
		NSRange fontRange = NSIntersectionRange(range, effectiveRange);
		// Create bold/unbold font variant for this font and apply
		CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(currentFont, 0.0, NULL, (bold?kCTFontBoldTrait:0), kCTFontBoldTrait);
		if (newFont) {
			[self removeAttribute:(NSString*)kCTFontAttributeName range:fontRange]; // Work around for Apple leak
#if OBJC_ARC_ENABLED
			[self addAttribute:(__bridge NSString*)kCTFontAttributeName value:(__bridge_transfer id)newFont range:fontRange];
#else
			[self addAttribute:(NSString*)kCTFontAttributeName value:(id)newFont range:fontRange];
			CFRelease(newFont);
#endif
		}
		// If the fontRange was not covering the whole range, continue with next run
		startPoint = NSMaxRange(effectiveRange);
	} while(startPoint<NSMaxRange(range));
}

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode {
	[self setTextAlignment:alignment lineBreakMode:lineBreakMode range:NSMakeRange(0,[self length])];
}
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range {
	// kCTParagraphStyleAttributeName > kCTParagraphStyleSpecifierAlignment
	CTParagraphStyleSetting paraStyles[2] = {
		{.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
		{.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode},
	};
	CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 2);
	[self removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range]; // Work around for Apple leak
	
#if OBJC_ARC_ENABLED
	[self addAttribute:(__bridge NSString*)kCTParagraphStyleAttributeName value:(__bridge_transfer id)aStyle range:range];
#else
	[self addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(id)aStyle range:range];
	CFRelease(aStyle);
#endif
}

@end


