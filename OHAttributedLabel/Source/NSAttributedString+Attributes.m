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


#import "NSAttributedString+Attributes.h"

#ifndef OHATTRIBUTEDLABEL_DEDICATED_PROJECT
// Copying files in your project and thus compiling OHAttributedLabel under different build settings
// than the one provided is not recommended abd increase risks of leaks (ARC vs. MRC) or unwanted behaviors
#warning [OHAttributedLabel integration] You should include OHAttributedLabel project in your workspace instead of copying the files in your own app project. See README for instructions.
#endif

#if __has_feature(objc_arc)
#define BRIDGE_CAST __bridge
#define BRIDGE_TRANSFER_CAST __bridge_transfer
#define MRC_AUTORELEASE(x) (x)
#else
#define BRIDGE_CAST
#define BRIDGE_TRANSFER_CAST
#define MRC_AUTORELEASE(x) [(x) autorelease]
#endif

NSString* kOHLinkAttributeName = @"NSLinkAttributeName"; // Use the same value as OSX, to be compatible in case Apple port this to iOS one day too

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSAttributedString Additions

@implementation NSAttributedString (OHCommodityConstructors)
+(NSAttributedString*)attributedStringWithString:(NSString*)string
{
    if (string)
    {
        return MRC_AUTORELEASE([[self alloc] initWithString:string]);
    } else {
        return nil;
    }
}
+(NSAttributedString*)attributedStringWithAttributedString:(NSAttributedString*)attrStr
{
    if (attrStr)
    {
        return MRC_AUTORELEASE([[self alloc] initWithAttributedString:attrStr]);
    } else {
        return nil;
    }
}

-(CGSize)sizeConstrainedToSize:(CGSize)maxSize
{
	return [self sizeConstrainedToSize:maxSize fitRange:NULL];
}

-(CGSize)sizeConstrainedToSize:(CGSize)maxSize fitRange:(NSRange*)fitRange
{
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((BRIDGE_CAST CFAttributedStringRef)self);
    CGSize sz = CGSizeMake(0.f, 0.f);
    if (framesetter)
    {
        CFRange fitCFRange = CFRangeMake(0,0);
        sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,maxSize,&fitCFRange);
        sz = CGSizeMake( floorf(sz.width+1) , floorf(sz.height+1) ); // take 1pt of margin for security
        CFRelease(framesetter);

        if (fitRange)
        {
            *fitRange = NSMakeRange((NSUInteger)fitCFRange.location, (NSUInteger)fitCFRange.length);
        }
    }
    return sz;
}

-(CTFontRef)fontAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    id attr = [self attribute:(BRIDGE_CAST NSString*)kCTFontAttributeName atIndex:index effectiveRange:aRange];
    return (BRIDGE_CAST CTFontRef)attr;
}

-(UIColor*)textColorAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    id attr = [self attribute:(BRIDGE_CAST NSString*)kCTForegroundColorAttributeName atIndex:index effectiveRange:aRange];
    return [UIColor colorWithCGColor:(BRIDGE_CAST CGColorRef)attr];
}

-(BOOL)textIsUnderlinedAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    int32_t underlineStyle = [self textUnderlineStyleAtIndex:index effectiveRange:aRange];
    return (underlineStyle & 0xFF) != kCTUnderlineStyleNone;
}

-(int32_t)textUnderlineStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    id attr = [self attribute:(BRIDGE_CAST NSString*)kCTUnderlineStyleAttributeName atIndex:index effectiveRange:aRange];
    return [(NSNumber*)attr intValue];
}

-(BOOL)textIsBoldAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    CTFontRef font = [self fontAtIndex:index effectiveRange:aRange];
    CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(font);
    return (traits & kCTFontBoldTrait) != 0;
}

-(CTTextAlignment)textAlignmentAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    id attr = [self attribute:(BRIDGE_CAST NSString*)kCTParagraphStyleAttributeName atIndex:index effectiveRange:aRange];
    CTParagraphStyleRef style = (BRIDGE_CAST CTParagraphStyleRef)attr;
    CTTextAlignment textAlign = kCTNaturalTextAlignment;
    CTParagraphStyleGetValueForSpecifier(style, kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &textAlign);
    return textAlign;
}

-(CTLineBreakMode)lineBreakModeAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    id attr = [self attribute:(BRIDGE_CAST NSString*)kCTParagraphStyleAttributeName atIndex:index effectiveRange:aRange];
    CTParagraphStyleRef style = (BRIDGE_CAST CTParagraphStyleRef)attr;
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    CTParagraphStyleGetValueForSpecifier(style, kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode);
    return lineBreakMode;
}

-(OHParagraphStyle*)paragraphStyleAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    id attr = [self attribute:(BRIDGE_CAST NSString*)kCTParagraphStyleAttributeName atIndex:index effectiveRange:aRange];
    CTParagraphStyleRef style = (BRIDGE_CAST CTParagraphStyleRef)attr;
    return [OHParagraphStyle paragraphStyleWithCTParagraphStyle:style];
}

-(NSURL*)linkAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
    return [self attribute:kOHLinkAttributeName atIndex:index effectiveRange:aRange];
}

@end







/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSMutableAttributedString Additions

@implementation NSMutableAttributedString (OHCommodityStyleModifiers)

-(void)setFont:(UIFont*)font
{
	[self setFontName:font.fontName size:font.pointSize];
}
-(void)setFont:(UIFont*)font range:(NSRange)range
{
	[self setFontName:font.fontName size:font.pointSize range:range];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size
{
	[self setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range
{
	// kCTFontAttributeName
	CTFontRef aFont = CTFontCreateWithName((BRIDGE_CAST CFStringRef)fontName, size, NULL);
	if (aFont)
    {
        [self removeAttribute:(BRIDGE_CAST NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
        [self addAttribute:(BRIDGE_CAST NSString*)kCTFontAttributeName value:(BRIDGE_CAST id)aFont range:range];
        CFRelease(aFont);
    }
}
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range
{
	// kCTFontFamilyNameAttribute + kCTFontTraitsAttribute
	CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
	NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:symTrait]
                                                      forKey:(BRIDGE_CAST NSString*)kCTFontSymbolicTrait];
	NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
						  fontFamily,kCTFontFamilyNameAttribute,
						  trait,kCTFontTraitsAttribute,nil];
	
	CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((BRIDGE_CAST CFDictionaryRef)attr);
	if (!desc) return;
	CTFontRef aFont = CTFontCreateWithFontDescriptor(desc, size, NULL);
	CFRelease(desc);
	if (!aFont) return;

	[self removeAttribute:(BRIDGE_CAST NSString*)kCTFontAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(BRIDGE_CAST NSString*)kCTFontAttributeName value:(BRIDGE_CAST id)aFont range:range];
	CFRelease(aFont);
}

-(void)setTextColor:(UIColor*)color
{
	[self setTextColor:color range:NSMakeRange(0,[self length])];
}
-(void)setTextColor:(UIColor*)color range:(NSRange)range
{
	// kCTForegroundColorAttributeName
	[self removeAttribute:(BRIDGE_CAST NSString*)kCTForegroundColorAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(BRIDGE_CAST NSString*)kCTForegroundColorAttributeName value:(BRIDGE_CAST id)color.CGColor range:range];
}

-(void)setTextIsUnderlined:(BOOL)underlined
{
	[self setTextIsUnderlined:underlined range:NSMakeRange(0,[self length])];
}
-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range
{
	int32_t style = underlined ? (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid) : kCTUnderlineStyleNone;
	[self setTextUnderlineStyle:style range:range];
}
-(void)setTextUnderlineStyle:(int32_t)style range:(NSRange)range
{
	[self removeAttribute:(BRIDGE_CAST NSString*)kCTUnderlineStyleAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(BRIDGE_CAST NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:range];
}

-(void)changeFontWithTraits:(CTFontSymbolicTraits)traits
                       mask:(CTFontSymbolicTraits)traitsMask
                      range:(NSRange)range
              newFontFinder:( NSString*(^)(NSString* currentFontPostscriptName) )fontFinderBlock
{
    NSUInteger startPoint = range.location;
	NSRange effectiveRange;
    [self beginEditing];
	do {
		// Get font at startPoint
		CTFontRef currentFont = (BRIDGE_CAST CTFontRef)[self attribute:(BRIDGE_CAST NSString*)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange];
        if (!currentFont)
        {
            currentFont = CTFontCreateUIFontForLanguage(kCTFontLabelFontType, 0.0, NULL);
            (void)MRC_AUTORELEASE((BRIDGE_TRANSFER_CAST id)currentFont);
        }
		// The range for which this font is effective
		NSRange fontRange = NSIntersectionRange(range, effectiveRange);
		// Create the font variant for this font according to new traits
		CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(currentFont, 0.0, NULL, traits, traitsMask);
        if (!newFont)
        {
            CFStringRef fontNameRef = CTFontCopyPostScriptName(currentFont);
            // Give a chance to try a hack for the private ".HelveticaNeueUI" font family, which is the default
            // font for labels in XIB, but fail to detect its italic variant correctly prior to iOS 6.1
            if (fontFinderBlock)
            {
                NSString* newFontName = fontFinderBlock((BRIDGE_CAST NSString*)fontNameRef);
                if (newFontName)
                {
                    CTFontDescriptorRef fontDesc = CTFontCopyFontDescriptor(currentFont);
                    NSDictionary* nameAttr = [NSDictionary dictionaryWithObject:newFontName forKey:@"NSFontNameAttribute"];
                    CTFontDescriptorRef newFontDesc = CTFontDescriptorCreateCopyWithAttributes(fontDesc, (BRIDGE_CAST CFDictionaryRef)nameAttr);
                    newFont = CTFontCreateWithFontDescriptor(newFontDesc, CTFontGetSize(currentFont), NULL);
                    CFRelease(fontDesc);
                    CFRelease(newFontDesc);
                }
            }
            // If still no luck, display a warning message in console
            if (!newFont)
            {
                NSLog(@"[OHAttributedLabel] Warning: can't find an italic font variant for font family %@. "
                      @"Try another font family (like Helvetica) instead.", (BRIDGE_CAST NSString*)fontNameRef);
            }
            if (fontNameRef) CFRelease(fontNameRef);
        }
        
        // Apply the new font with new traits
		if (newFont)
        {
			[self removeAttribute:(BRIDGE_CAST NSString*)kCTFontAttributeName range:fontRange]; // Work around for Apple leak
			[self addAttribute:(BRIDGE_CAST NSString*)kCTFontAttributeName value:(BRIDGE_CAST id)newFont range:fontRange];
			CFRelease(newFont);
		}
		
		// If the fontRange was not covering the whole range, continue with next run
		startPoint = NSMaxRange(effectiveRange);
	} while(startPoint<NSMaxRange(range));
    [self endEditing];
}

static NSString* const kHelveticaNeueUI             = @".HelveticaNeueUI";
static NSString* const kHelveticaNeueUI_Bold        = @".HelveticaNeueUI-Bold";
static NSString* const kHelveticaNeueUI_Italic      = @".HelveticaNeueUI-Italic";
static NSString* const kHelveticaNeueUI_Bold_Italic = @".HelveticaNeueUI-BoldItalic";

-(void)setTextBold:(BOOL)isBold range:(NSRange)range
{
	[self changeFontWithTraits:(isBold?kCTFontTraitBold:0)
                          mask:kCTFontTraitBold
                         range:range newFontFinder:^NSString *(NSString *currentFontName)
    {
        if ([currentFontName isEqualToString:kHelveticaNeueUI_Italic] || [currentFontName isEqualToString:kHelveticaNeueUI_Bold_Italic])
        {
            // Italic private font
            return isBold ? kHelveticaNeueUI_Bold_Italic : kHelveticaNeueUI_Italic;
        } else if ([currentFontName isEqualToString:kHelveticaNeueUI] || [currentFontName isEqualToString:kHelveticaNeueUI_Bold]) {
            // Non-Italic private font
            return isBold ? kHelveticaNeueUI_Bold : kHelveticaNeueUI;
        } else {
            return nil;
        }
    }];
}

-(void)setTextItalics:(BOOL)isItalics range:(NSRange)range
{
    [self changeFontWithTraits:(isItalics?kCTFontTraitItalic:0)
                          mask:kCTFontTraitItalic
                         range:range
                 newFontFinder:^NSString *(NSString *currentFontName)
     {
         if ([currentFontName isEqualToString:kHelveticaNeueUI_Bold] || [currentFontName isEqualToString:kHelveticaNeueUI_Bold_Italic])
         {
             // Bold private font
             return isItalics ? kHelveticaNeueUI_Bold_Italic : kHelveticaNeueUI_Bold;
         } else if ([currentFontName isEqualToString:kHelveticaNeueUI] || [currentFontName isEqualToString:kHelveticaNeueUI_Italic]) {
             // Non-Bold private font
             return isItalics ? kHelveticaNeueUI_Italic : kHelveticaNeueUI;
         } else {
             return nil;
         }
     }];
}

-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode
{
	[self setTextAlignment:alignment lineBreakMode:lineBreakMode range:NSMakeRange(0,[self length])];
}
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range
{
    [self modifyParagraphStylesInRange:range withBlock:^(OHParagraphStyle *paragraphStyle) {
        paragraphStyle.textAlignment = alignment;
        paragraphStyle.lineBreakMode = lineBreakMode;
    }];
}

-(void)modifyParagraphStylesWithBlock:(void(^)(OHParagraphStyle* paragraphStyle))block
{
    [self modifyParagraphStylesInRange:NSMakeRange(0,[self length]) withBlock:block];
}

-(void)modifyParagraphStylesInRange:(NSRange)range withBlock:(void(^)(OHParagraphStyle* paragraphStyle))block
{
    NSParameterAssert(block != nil);
    
    NSRangePointer rangePtr = &range;
    NSUInteger loc = range.location;
    [self beginEditing];
    while (NSLocationInRange(loc, range))
    {
        CTParagraphStyleRef currentCTStyle = (BRIDGE_CAST CTParagraphStyleRef)[self attribute:(BRIDGE_CAST NSString*)kCTParagraphStyleAttributeName
                                                     atIndex:loc longestEffectiveRange:rangePtr inRange:range];
        __block OHParagraphStyle* paraStyle = [OHParagraphStyle paragraphStyleWithCTParagraphStyle:currentCTStyle];
        block(paraStyle);        
        [self setParagraphStyle:paraStyle range:*rangePtr];
        
        loc = NSMaxRange(*rangePtr);
    }
    [self endEditing];
}

-(void)setParagraphStyle:(OHParagraphStyle *)style
{
    [self setParagraphStyle:style range:NSMakeRange(0,[self length])];
}

-(void)setParagraphStyle:(OHParagraphStyle*)style range:(NSRange)range
{
    CTParagraphStyleRef newParaStyle = [style createCTParagraphStyle];
    [self removeAttribute:(BRIDGE_CAST NSString*)kCTParagraphStyleAttributeName range:range]; // Work around for Apple leak
    [self addAttribute:(BRIDGE_CAST NSString*)kCTParagraphStyleAttributeName value:(BRIDGE_CAST id)newParaStyle range:range];
    CFRelease(newParaStyle);
}

-(void)setLink:(NSURL*)link range:(NSRange)range
{
    [self removeAttribute:kOHLinkAttributeName range:range]; // Work around for Apple leak
    if (link)
    {
        [self addAttribute:kOHLinkAttributeName value:(id)link range:range];
    }
}

@end


