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


#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"


CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment) {
	switch (alignment) {
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
		case UITextAlignmentJustify: return kCTJustifiedTextAlignment; /* special OOB value if we decide to use it even if it's not really standard... */
		default: return kCTNaturalTextAlignment;
	}
}

CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode) {
	switch (lineBreakMode) {
		case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
		case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
		case UILineBreakModeClip: return kCTLineBreakByClipping;
		case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
		case UILineBreakModeTailTruncation: return kCTLineBreakByTruncatingTail;
		case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
		default: return 0;
	}
}

@interface OHAttributedLabel(/* Private */)
-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx;
-(NSTextCheckingResult*)linkAtPoint:(CGPoint)pt;
-(NSMutableAttributedString*)attributedTextWithLinks;
@end

/////////////////////////////////////////////////////////////////////////////


@implementation OHAttributedLabel
@synthesize linkColor, underlineLinks, centerVertically, automaticallyDetectLinks, onlyCatchTouchesOnLinks, extendBottomToFit;
@synthesize delegate;



/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Init/Dealloc
/////////////////////////////////////////////////////////////////////////////

- (void)commonInit {
	customLinks = [[NSMutableArray alloc] init];
	linkColor = [[UIColor blueColor] retain];
	underlineLinks = YES;
	automaticallyDetectLinks = YES;
	onlyCatchTouchesOnLinks = NO;
	self.userInteractionEnabled = YES;
	self.contentMode = UIViewContentModeRedraw;
	[self resetAttributedText];
}

- (id) initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	if (self != nil) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self != nil) {
		[self commonInit];
	}
	return self;
}

-(void)dealloc {
	[_attributedText release];
	[customLinks release];
	[linkColor release];
	if (textFrame) CFRelease(textFrame);
	[super dealloc];
}



/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Links Mgmt
/////////////////////////////////////////////////////////////////////////////

-(void)addCustomLink:(NSURL*)linkUrl inRange:(NSRange)range {
	NSTextCheckingResult* link = [NSTextCheckingResult linkCheckingResultWithRange:range URL:linkUrl];
	[customLinks addObject:link];
	[self setNeedsDisplay];
}
-(void)removeAllCustomLinks {
	[customLinks removeAllObjects];
	[self setNeedsDisplay];
}

-(NSMutableAttributedString*)attributedTextWithLinks {
	NSMutableAttributedString* str = [_attributedText mutableCopy];
	if (self.automaticallyDetectLinks) {
		NSError* error = nil;
		NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
		[linkDetector enumerateMatchesInString:[str string] options:0 range:NSMakeRange(0,[[str string] length])
									usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		 {
			 int32_t uStyle = self.underlineLinks ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone;
			 UIColor* thisLinkColor = (delegate && [delegate respondsToSelector:@selector(colorForLink:underlineStyle:)])
			 ? [delegate colorForLink:result underlineStyle:&uStyle] : self.linkColor;
			 
			 if (thisLinkColor)
				 [str setTextColor:thisLinkColor range:[result range]];
			 if (uStyle>0)
				 [str setTextUnderlineStyle:uStyle range:[result range]];
		 }];
	}
	[customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 NSTextCheckingResult* result = (NSTextCheckingResult*)obj;
		 
		 int32_t uStyle = self.underlineLinks ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone;
		 UIColor* thisLinkColor = (delegate && [delegate respondsToSelector:@selector(colorForLink:underlineStyle:)])
		 ? [delegate colorForLink:result underlineStyle:&uStyle] : self.linkColor;
		 
		 if (thisLinkColor)
			 [str setTextColor:thisLinkColor range:[result range]];
		 if (uStyle>0)
			 [str setTextUnderlineStyle:uStyle range:[result range]];
	 }];
	return [str autorelease];
}

-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx {
	__block NSTextCheckingResult* foundResult = nil;
	NSError* error = nil;
	NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
	[linkDetector enumerateMatchesInString:[_attributedText string] options:0 range:NSMakeRange(0,[[_attributedText string] length])
								usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
	 {
		 NSRange r = [result range];
		 if (NSLocationInRange(idx, r)) {
			 foundResult = [[result retain] autorelease];
			 *stop = YES;
		 }
	 }];
	if (foundResult) return foundResult;
	
	[customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop)
	 {
		 NSRange r = [(NSTextCheckingResult*)obj range];
		 if (NSLocationInRange(idx, r)) {
			 foundResult = [[obj retain] autorelease];
			 *stop = YES;
		 }
	 }];
	return foundResult;
}
-(NSTextCheckingResult*)linkAtPoint:(CGPoint)pt {
	static const CGFloat kVMargin = 5.f;
	if (!CGRectContainsPoint(CGRectInset(self.bounds, 0, -kVMargin), pt)) return nil;
	
	CFArrayRef lines = CTFrameGetLines(textFrame);
	int nbLines = CFArrayGetCount(lines);
	CGFloat lineHeight = 0;
	NSTextCheckingResult* link = nil;
	CGPoint origins[nbLines];
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
	for (int i=0;i<nbLines;++i) {
		CGFloat lineY = (self.bounds.size.height-origins[i].y); // convert to "origin on top" coords
		CTLineRef line = CFArrayGetValueAtIndex(lines, i);
		(void)CTLineGetTypographicBounds(line, &lineHeight, NULL, NULL);
		if ((lineY-kVMargin < pt.y) && (pt.y < lineY+lineHeight+kVMargin)){
			CGPoint relativePoint = CGPointMake(pt.x-origins[i].x, pt.y-lineY);
			CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
			link = ([self linkAtCharacterIndex:idx]);
			if (link) return link;
		}
	}
	return nil;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (self.onlyCatchTouchesOnLinks) {
		return ([self linkAtPoint:point] != nil);
	} else {
		return [super pointInside:point withEvent:event];
	}
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	
	NSTextCheckingResult* link = [self linkAtPoint:pt];
	
	if (link) {
		BOOL openLink = (delegate && [delegate respondsToSelector:@selector(attributedLabel:shouldFollowLink:)])
		? [delegate attributedLabel:self shouldFollowLink:link] : YES;
		if (openLink) [[UIApplication sharedApplication] openURL:link.URL];
	}
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Drawing Text
/////////////////////////////////////////////////////////////////////////////

- (void)drawTextInRect:(CGRect)aRect
{
	if (_attributedText) {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f));
		
		if (self.shadowColor) {
			CGContextSetShadowWithColor(ctx, self.shadowOffset, 0.0, self.shadowColor.CGColor);
		}
		
		NSMutableAttributedString* attrStrWithLinks = [self attributedTextWithLinks];
		if (self.highlighted && self.highlightedTextColor != nil) {
			[attrStrWithLinks setTextColor:self.highlightedTextColor];
		}
		
		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStrWithLinks);
		CGRect rect = self.bounds;
		if (self.centerVertically || self.extendBottomToFit) {
			CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,CGSizeMake(rect.size.width,CGFLOAT_MAX),NULL);
			if (self.extendBottomToFit) {
				CGFloat delta = MAX(0.f , ceilf(sz.height - rect.size.height)) + 10 /* Security margin */;
				rect.origin.y -= delta;
				rect.size.height += delta;
			}
			if (self.centerVertically) {
				rect.origin.y -= (rect.size.height - sz.height)/2;
			}
		}
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, rect);
		if (textFrame) CFRelease(textFrame);		
		textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
		CFRelease(framesetter);
		CTFrameDraw(textFrame, ctx);
		CGPathRelease(path);
		
		CGContextRestoreGState(ctx);
	} else {
		[super drawTextInRect:aRect];
	}
}

- (CGSize)sizeThatFits:(CGSize)size {
	NSMutableAttributedString* attrStrWithLinks = [self attributedTextWithLinks];
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStrWithLinks);
	CGFloat w = size.width;
	CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,CGSizeMake(w,CGFLOAT_MAX),NULL);
	if (framesetter) CFRelease(framesetter);
	return CGSizeMake(sz.height,sz.height+1); // take 1pt of margin for security
}


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Setters/Getters
/////////////////////////////////////////////////////////////////////////////


-(void)resetAttributedText {
	NSMutableAttributedString* mutAttrStr = [NSMutableAttributedString attributedStringWithString:self.text];
	[mutAttrStr setFont:self.font];
	[mutAttrStr setTextColor:self.textColor];
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[mutAttrStr setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	self.attributedText = mutAttrStr;
}

-(NSAttributedString*)attributedText {
	if (!_attributedText) {
		[self resetAttributedText];
	}
	return [[_attributedText copy] autorelease]; // immutable autoreleased copy
}
-(void)setAttributedText:(NSAttributedString*)attributedText {
	[_attributedText release];
	_attributedText = [attributedText mutableCopy];
	[self setNeedsDisplay];
}

/////////////////////////////////////////////////////////////////////////////

-(void)setText:(NSString *)text {
	NSString* cleanedText = [[text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]
							 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[super setText:cleanedText]; // will call setNeedsDisplay too
	[self resetAttributedText];
}
-(void)setFont:(UIFont *)font {
	[_attributedText setFont:font];
	[super setFont:font]; // will call setNeedsDisplay too
}
-(void)setTextColor:(UIColor *)color {
	[_attributedText setTextColor:color];
	[super setTextColor:color]; // will call setNeedsDisplay too
}
-(void)setTextAlignment:(UITextAlignment)alignment {
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(alignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	[super setTextAlignment:alignment]; // will call setNeedsDisplay too
}
-(void)setLineBreakMode:(UILineBreakMode)lineBreakMode {
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(lineBreakMode);
	[_attributedText setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
	[super setLineBreakMode:lineBreakMode]; // will call setNeedsDisplay too
}
-(void)setCenterVertically:(BOOL)val {
	centerVertically = val;
	[self setNeedsDisplay];
}

-(void)setAutomaticallyDetectLinks:(BOOL)detect {
	automaticallyDetectLinks = detect;
	[self setNeedsDisplay];
}

-(void)setExtendBottomToFit:(BOOL)val {
	extendBottomToFit = val;
	[self setNeedsDisplay];
}

/////////////////////////////////////////////////////////////////////////////


@end
