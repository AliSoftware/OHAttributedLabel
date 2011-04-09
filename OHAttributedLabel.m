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
@synthesize centerVertically, automaticallyDetectLinks;
@synthesize delegate;



/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: Init/Dealloc
/////////////////////////////////////////////////////////////////////////////

- (void)commonInit {
	customLinks = [[NSMutableArray alloc] init];
	automaticallyDetectLinks = YES;
	self.userInteractionEnabled = YES;
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
	if (frame) CFRelease(frame);
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
		NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
		[linkDetector enumerateMatchesInString:[str string] options:0 range:NSMakeRange(0,[[str string] length])
									usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		 {
			 UIColor* linkColor = (delegate && [delegate respondsToSelector:@selector(colorForLink:)])
			 ? [delegate colorForLink:result] : [UIColor blueColor];
			 [str setTextColor:linkColor range:[result range]];
			 [str setTextIsUnderlined:YES range:[result range]];
		 }];
		[customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
		 {
			 NSTextCheckingResult* result = (NSTextCheckingResult*)obj;
			 UIColor* linkColor = (delegate && [delegate respondsToSelector:@selector(colorForLink:)])
			 ? [delegate colorForLink:result] : [UIColor blueColor];
			 [str setTextColor:linkColor range:[result range]];
			 [str setTextIsUnderlined:YES range:[result range]];
		 }];
	}
	return [str autorelease];
}

-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx {
	__block NSTextCheckingResult* foundResult = nil;
	
	NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
	[linkDetector enumerateMatchesInString:[_attributedText string] options:0 range:NSMakeRange(0,[[_attributedText string] length])
								usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
	 {
		 NSRange r = [result range];
		 if ((r.location<idx) && (idx<=r.location+r.length)) {
			 foundResult = [[result retain] autorelease];
			 *stop = YES;
		 }
	 }];
	if (foundResult) return foundResult;
	
	[customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 NSRange r = [(NSTextCheckingResult*)obj range];
		 if ((r.location<idx) && (idx<=r.location+r.length)) {
			 foundResult = [[obj retain] autorelease];
			 *stop = YES;
		 }
	 }];
	return foundResult;
}
-(NSTextCheckingResult*)linkAtPoint:(CGPoint)pt {
	static CGFloat kDeltaY = 5.f; // Because we generally tap a bit below the line
	if (!CGRectContainsPoint(CGRectInset(self.bounds, 0, -kDeltaY), pt)) return nil;
	
	CFArrayRef lines = CTFrameGetLines(frame);
	int nbLines = CFArrayGetCount(lines);
	//CGFloat lineHeight = 0;
	CGPoint origins[nbLines];
	CTFrameGetLineOrigins(frame, CFRangeMake(0,0), origins);
	for (int i=0;i<nbLines;++i) {
		CGFloat lineY = (self.bounds.size.height-origins[i].y); // convert to "origin on top" coords
		if (lineY+kDeltaY > pt.y) {
			CTLineRef line = CFArrayGetValueAtIndex(lines, i);
			//(void)CTLineGetTypographicBounds(line, &lineHeight, NULL, NULL);
			CGPoint relativePoint = CGPointMake(pt.x-origins[i].x, pt.y-lineY);
			CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
			return [self linkAtCharacterIndex:idx];
		}
	}
	return nil;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return ([self linkAtPoint:point] != nil);
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
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
		
		NSMutableAttributedString* attrStrWithLinks = [self attributedTextWithLinks];
		if (self.highlighted && self.highlightedTextColor != nil) {
			[attrStrWithLinks setTextColor:self.highlightedTextColor];
		}
		
		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStrWithLinks);
		CGRect rect = self.bounds;
		if (self.centerVertically) {
			CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,self.bounds.size,NULL);
			rect.origin.y -= (rect.size.height - sz.height)/2;
			//rect.size.height = sz.height; // no real need, and actually may introduce a risk of bottom cropping if some rounding error
		}
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, rect);
		if (frame) CFRelease(frame);		
		frame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
		CFRelease(framesetter);
		CTFrameDraw(frame, ctx);
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
	return CGSizeMake(w,sz.height+1); // take 1pt of margin
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
	NSString* cleanedText = [text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
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

/////////////////////////////////////////////////////////////////////////////


@end
