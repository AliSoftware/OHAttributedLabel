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


#import "OHAttributedLabel.h"
#import "NSAttributedString+Attributes.h"
#import "CoreTextUtils.h"

#define OHATTRIBUTEDLABEL_WARN_ABOUT_KNOWN_ISSUES 1
#define OHATTRIBUTEDLABEL_WARN_ABOUT_OLD_API 1


#if __has_feature(objc_arc)
#define BRIDGE_CAST __bridge
#define MRC_RETAIN(x) (x)
#define MRC_RELEASE(x)
#define MRC_AUTORELEASE(x) (x)
#else
#define BRIDGE_CAST
#define MRC_RETAIN(x) [x retain]
#define MRC_RELEASE(x) [x release]; x = nil
#define MRC_AUTORELEASE(x) [x autorelease]
#endif

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private interface
/////////////////////////////////////////////////////////////////////////////////////


const int UITextAlignmentJustify = ((UITextAlignment)kCTJustifiedTextAlignment);

@interface OHAttributedLabel(/* Private */)
{
	NSAttributedString* _attributedText;
    NSAttributedString* _attributedTextWithLinks;
    BOOL _needsRecomputeLinksInText;
    NSDataDetector* _linksDetector;
	CTFrameRef textFrame;
	CGRect drawingRect;
	NSMutableArray* _customLinks;
	CGPoint _touchStartPoint;
}
@property(nonatomic, retain) NSTextCheckingResult* activeLink;
-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx;
-(NSTextCheckingResult*)linkAtPoint:(CGPoint)pt;
-(void)resetTextFrame;
-(void)drawActiveLinkHighlightForRect:(CGRect)rect;
-(void)recomputeLinksInTextIfNeeded;
#if OHATTRIBUTEDLABEL_WARN_ABOUT_KNOWN_ISSUES
-(void)warnAboutKnownIssues_CheckLineBreakMode_FromXIB:(BOOL)fromXIB;
-(void)warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth_FromXIB:(BOOL)fromXIB;
#endif
@end

NSDataDetector* sharedReusableDataDetector(NSTextCheckingTypes types);



/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSDataDetector Reusable Pool
/////////////////////////////////////////////////////////////////////////////////////

NSDataDetector* sharedReusableDataDetector(NSTextCheckingTypes types)
{
    static NSCache* dataDetectorsCache = nil;
    if (!dataDetectorsCache)
    {
        dataDetectorsCache = [[NSCache alloc] init];
        dataDetectorsCache.name = @"OHAttributedLabel::DataDetectorCache";
    }
    
    NSDataDetector* dd = nil;
    if (types > 0)
    {
        // Dequeue a reusable data detector from the pool, only allocate one if none exist yet
        id typesKey = [NSNumber numberWithInteger:types];
        dd = [dataDetectorsCache objectForKey:typesKey];
        if (!dd)
        {
            dd = [NSDataDetector dataDetectorWithTypes:types error:nil];
            [dataDetectorsCache setObject:dd forKey:typesKey];
        }
    }
    return dd;
}




/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation
/////////////////////////////////////////////////////////////////////////////////////


@implementation OHAttributedLabel

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Init/Dealloc
/////////////////////////////////////////////////////////////////////////////////////

- (void)commonInit
{
    _linkColor = MRC_RETAIN([UIColor blueColor]);
    _highlightedLinkColor = MRC_RETAIN([UIColor colorWithWhite:0.4 alpha:0.3]);
	_linkUnderlineStyle = kCTUnderlineStyleSingle | kCTUnderlinePatternSolid;
    
	self.automaticallyAddLinksForType = NSTextCheckingTypeLink;
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:0"]]) {
		self.automaticallyAddLinksForType |= NSTextCheckingTypePhoneNumber;
	}
	self.onlyCatchTouchesOnLinks = YES;
	self.userInteractionEnabled = YES;
	self.contentMode = UIViewContentModeRedraw;
	[self resetAttributedText];
}

- (id) initWithFrame:(CGRect)aFrame
{
	self = [super initWithFrame:aFrame];
	if (self != nil)
    {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self != nil)
    {
		[self commonInit];
#if OHATTRIBUTEDLABEL_WARN_ABOUT_KNOWN_ISSUES
		[self warnAboutKnownIssues_CheckLineBreakMode_FromXIB:YES];
		[self warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth_FromXIB:YES];
#endif
	}
	return self;
}

-(void)dealloc
{
	[self resetTextFrame]; // CFRelease the text frame

#if ! __has_feature(objc_arc)
    [_linksDetector release]; _linksDetector = nil;
    [_linkColor release]; _linkColor = nil;
	[_highlightedLinkColor release]; _highlightedLinkColor = nil;
	[_activeLink release]; _activeLink = nil;

	[_attributedText release]; _attributedText = nil;
    [_attributedTextWithLinks release]; _attributedTextWithLinks = nil;
	[_customLinks release]; _customLinks = nil;

	[super dealloc];
#endif
}





/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Links Managment
/////////////////////////////////////////////////////////////////////////////////////

-(void)addCustomLink:(NSURL*)linkUrl inRange:(NSRange)range
{
	NSTextCheckingResult* link = [NSTextCheckingResult linkCheckingResultWithRange:range URL:linkUrl];
	if (_customLinks == nil) {
		_customLinks = [[NSMutableArray alloc] init];
	}
	[_customLinks addObject:link];
    [self setNeedsRecomputeLinksInText];
	[self setNeedsDisplay];
}

-(void)removeAllCustomLinks
{
	[_customLinks removeAllObjects];
	[self setNeedsDisplay];
}

-(void)setNeedsRecomputeLinksInText
{
    _needsRecomputeLinksInText = YES;
    [self setNeedsDisplay];
}

-(void)recomputeLinksInTextIfNeeded
{
    if (!_needsRecomputeLinksInText) return;
    _needsRecomputeLinksInText = NO;
    
    if (!_attributedText || (self.automaticallyAddLinksForType == 0 && _customLinks.count == 0))
    {
        MRC_RELEASE(_attributedTextWithLinks);
        _attributedTextWithLinks = MRC_RETAIN(_attributedText);
        return;
	}
    
    NSMutableAttributedString* mutAS = [_attributedText mutableCopy];
	
    BOOL hasLinkColorSelector = [self.delegate respondsToSelector:@selector(attributedLabel:colorForLink:underlineStyle:)];
    
#if OHATTRIBUTEDLABEL_WARN_ABOUT_OLD_API
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL hasOldLinkColorSelector = [self.delegate respondsToSelector:@selector(colorForLink:underlineStyle:)];
        if (hasOldLinkColorSelector)
        {
            NSLog(@"[OHAttributedLabel] Warning: \"-colorForLink:underlineStyle:\" delegate method is deprecated and has been replaced"
                  "by \"-attributedLabel:colorForLink:underlineStyle:\" to be more compliant with naming conventions.");
        }
    });
#endif

	NSString* plainText = [_attributedText string];
    
    void (^applyLinkStyle)(NSTextCheckingResult*) = ^(NSTextCheckingResult* result)
    {
        int32_t uStyle = self.linkUnderlineStyle;
        UIColor* thisLinkColor = hasLinkColorSelector
        ? [self.delegate attributedLabel:self colorForLink:result underlineStyle:&uStyle]
        : self.linkColor;
        
        if (thisLinkColor)
            [mutAS setTextColor:thisLinkColor range:[result range]];
        if ((uStyle & 0xFFFF) != kCTUnderlineStyleNone)
            [mutAS setTextUnderlineStyle:uStyle range:[result range]];
        if (uStyle & kOHBoldStyleTraitMask)
            [mutAS setTextBold:((uStyle & kOHBoldStyleTraitSetBold) == kOHBoldStyleTraitSetBold) range:[result range]];
    };
    
	if (plainText && (self.automaticallyAddLinksForType > 0))
    {
		[_linksDetector enumerateMatchesInString:plainText options:0 range:NSMakeRange(0,[plainText length])
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		 {
			 applyLinkStyle(result);
		 }];
	}
	[_customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 applyLinkStyle((NSTextCheckingResult*)obj);
	 }];

    MRC_RELEASE(_attributedTextWithLinks);
    _attributedTextWithLinks = [[NSAttributedString alloc] initWithAttributedString:mutAS];

    MRC_RELEASE(mutAS);
    [self setNeedsDisplay];
}

-(NSTextCheckingResult*)linkAtCharacterIndex:(CFIndex)idx
{
	__block NSTextCheckingResult* foundResult = nil;
	
	NSString* plainText = [_attributedText string];
	if (plainText && (self.automaticallyAddLinksForType > 0))
    {
		[_linksDetector enumerateMatchesInString:plainText options:0 range:NSMakeRange(0,[plainText length])
									usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		 {
			 NSRange r = [result range];
			 if (NSLocationInRange(idx, r))
             {
				 foundResult = MRC_AUTORELEASE(MRC_RETAIN(result));
				 *stop = YES;
			 }
		 }];
	}
	
    if (!foundResult)
    {
        [_customLinks enumerateObjectsUsingBlock:^(id obj, NSUInteger aidx, BOOL *stop)
         {
             NSRange r = [(NSTextCheckingResult*)obj range];
             if (NSLocationInRange(idx, r))
             {
                 foundResult = MRC_AUTORELEASE(MRC_RETAIN(obj));
                 *stop = YES;
             }
         }];
    }
	return foundResult;
}

-(NSTextCheckingResult*)linkAtPoint:(CGPoint)point
{
	static const CGFloat kVMargin = 5.f;
	if (!CGRectContainsPoint(CGRectInset(drawingRect, 0, -kVMargin), point)) return nil;
	
	CFArrayRef lines = CTFrameGetLines(textFrame);
	if (!lines) return nil;
	CFIndex nbLines = CFArrayGetCount(lines);
	NSTextCheckingResult* link = nil;
	
	CGPoint origins[nbLines];
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
	
	for (int lineIndex=0 ; lineIndex<nbLines ; ++lineIndex) {
		// this actually the origin of the line rect, so we need the whole rect to flip it
		CGPoint lineOriginFlipped = origins[lineIndex];
		
		CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
		CGRect lineRectFlipped = CTLineGetTypographicBoundsAsRect(line, lineOriginFlipped);
		CGRect lineRect = CGRectFlipped(lineRectFlipped, CGRectFlipped(drawingRect,self.bounds));
		
		lineRect = CGRectInset(lineRect, 0, -kVMargin);
		if (CGRectContainsPoint(lineRect, point)) {
			CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(lineRect),
												point.y-CGRectGetMinY(lineRect));
			CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
			link = ([self linkAtCharacterIndex:idx]);
			if (link) return link;
		}
	}
	return nil;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	// never return self. always return the result of [super hitTest..].
	// this takes userInteraction state, enabled, alpha values etc. into account
	UIView *hitResult = [super hitTest:point withEvent:event];
	
	// don't check for links if the event was handled by one of the subviews
	if (hitResult != self) {
		return hitResult;
	}
	
	if (self.onlyCatchTouchesOnLinks) {
		BOOL didHitLink = ([self linkAtPoint:point] != nil);
		if (!didHitLink) {
			// not catch the touch if it didn't hit a link
			return nil;
		}
	}
	return hitResult;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	
	self.activeLink = [self linkAtPoint:pt];
	_touchStartPoint = pt;
	
	// we're using activeLink to draw a highlight in -drawRect:
	[self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	
	NSTextCheckingResult *linkAtTouchesEnded = [self linkAtPoint:pt];
	
	BOOL closeToStart = (abs(_touchStartPoint.x - pt.x) < 10 && abs(_touchStartPoint.y - pt.y) < 10);

	// we can check on equality of the ranges themselfes since the data detectors create new results
	if (_activeLink && (NSEqualRanges(_activeLink.range,linkAtTouchesEnded.range) || closeToStart))
    {
        NSTextCheckingResult* linkToOpen = _activeLink;
        // In case the delegate calls recomputeLinksInText or anything that will clear the _activeLink variable, keep it around anyway
        (void)MRC_AUTORELEASE(MRC_RETAIN(linkToOpen));
		BOOL openLink = (self.delegate && [self.delegate respondsToSelector:@selector(attributedLabel:shouldFollowLink:)])
		? [self.delegate attributedLabel:self shouldFollowLink:linkToOpen] : YES;
		if (openLink) [[UIApplication sharedApplication] openURL:linkToOpen.extendedURL];
	}
	
	self.activeLink = nil;
	[self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.activeLink = nil;
	[self setNeedsDisplay];
}




/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Drawing Text
/////////////////////////////////////////////////////////////////////////////////////

-(void)resetTextFrame
{
	if (textFrame)
    {
		CFRelease(textFrame);
		textFrame = NULL;
	}
}

- (void)drawTextInRect:(CGRect)aRect
{
	if (_attributedText)
    {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		
		// flipping the context to draw core text
		// no need to flip our typographical bounds from now on
		CGContextConcatCTM(ctx, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f));
		
		if (self.shadowColor)
        {
			CGContextSetShadowWithColor(ctx, self.shadowOffset, 0.0, self.shadowColor.CGColor);
		}
		
        [self recomputeLinksInTextIfNeeded];
        NSAttributedString* attributedStringToDisplay = _attributedTextWithLinks;
		if (self.highlighted && self.highlightedTextColor != nil)
        {
            NSMutableAttributedString* mutAS = [attributedStringToDisplay mutableCopy];
			[mutAS setTextColor:self.highlightedTextColor];
            attributedStringToDisplay = mutAS;
            (void)MRC_AUTORELEASE(mutAS);
		}
		if (textFrame == NULL)
        {
            CFAttributedStringRef cfAttrStrWithLinks = (BRIDGE_CAST CFAttributedStringRef)attributedStringToDisplay;
			CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(cfAttrStrWithLinks);
			drawingRect = self.bounds;
			if (self.centerVertically || self.extendBottomToFit)
            {
				CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,CGSizeMake(drawingRect.size.width,CGFLOAT_MAX),NULL);
				if (self.extendBottomToFit)
                {
					CGFloat delta = MAX(0.f , ceilf(sz.height - drawingRect.size.height)) + 10 /* Security margin */;
					drawingRect.origin.y -= delta;
					drawingRect.size.height += delta;
				}
				if (self.centerVertically) {
					drawingRect.origin.y -= (drawingRect.size.height - sz.height)/2;
				}
			}
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddRect(path, NULL, drawingRect);
			textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
			CGPathRelease(path);
			CFRelease(framesetter);
		}
		
		// draw highlights for activeLink
		if (_activeLink)
        {
			[self drawActiveLinkHighlightForRect:drawingRect];
		}
		
		CTFrameDraw(textFrame, ctx);

		CGContextRestoreGState(ctx);
	} else {
		[super drawTextInRect:aRect];
	}
}

-(void)drawActiveLinkHighlightForRect:(CGRect)rect
{
    if (!self.highlightedLinkColor) return;
    
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextConcatCTM(ctx, CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y));
	[self.highlightedLinkColor setFill];
	
	NSRange activeLinkRange = _activeLink.range;
	
	CFArrayRef lines = CTFrameGetLines(textFrame);
	CFIndex lineCount = CFArrayGetCount(lines);
	CGPoint lineOrigins[lineCount];
	CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), lineOrigins);
	for (CFIndex lineIndex = 0; lineIndex < lineCount; lineIndex++)
    {
		CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
		
		if (!CTLineContainsCharactersFromStringRange(line, activeLinkRange))
        {
			continue; // with next line
		}
		
		// we use this rect to union the bounds of successive runs that belong to the same active link
		CGRect unionRect = CGRectZero;
		
		CFArrayRef runs = CTLineGetGlyphRuns(line);
		CFIndex runCount = CFArrayGetCount(runs);
		for (CFIndex runIndex = 0; runIndex < runCount; runIndex++)
        {
			CTRunRef run = CFArrayGetValueAtIndex(runs, runIndex);
			
			if (!CTRunContainsCharactersFromStringRange(run, activeLinkRange))
            {
				if (!CGRectIsEmpty(unionRect))
                {
					CGContextFillRect(ctx, unionRect);
					unionRect = CGRectZero;
				}
				continue; // with next run
			}
			
			CGRect linkRunRect = CTRunGetTypographicBoundsAsRect(run, line, lineOrigins[lineIndex]);
			linkRunRect = CGRectIntegral(linkRunRect);		// putting the rect on pixel edges
			linkRunRect = CGRectInset(linkRunRect, -1, -1);	// increase the rect a little
			if (CGRectIsEmpty(unionRect))
            {
				unionRect = linkRunRect;
			} else {
				unionRect = CGRectUnion(unionRect, linkRunRect);
			}
		}
		if (!CGRectIsEmpty(unionRect))
        {
			CGContextFillRect(ctx, unionRect);
			//unionRect = CGRectZero;
		}
	}
	CGContextRestoreGState(ctx);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [self recomputeLinksInTextIfNeeded];
	if (!_attributedTextWithLinks) return CGSizeZero;
	return [_attributedTextWithLinks sizeConstrainedToSize:size fitRange:NULL];
}





/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setters/Getters
/////////////////////////////////////////////////////////////////////////////////////

@synthesize activeLink = _activeLink;
@synthesize linkColor = _linkColor;
@synthesize highlightedLinkColor = _highlightedLinkColor;
@synthesize linkUnderlineStyle = _linkUnderlineStyle;
@synthesize centerVertically = _centerVertically;
@synthesize automaticallyAddLinksForType = _automaticallyAddLinksForType;
@synthesize onlyCatchTouchesOnLinks = _onlyCatchTouchesOnLinks;
@synthesize extendBottomToFit = _extendBottomToFit;
@synthesize delegate = _delegate;


-(void)resetAttributedText
{
	NSMutableAttributedString* mutAttrStr = [NSMutableAttributedString attributedStringWithString:self.text];
	if (self.font) [mutAttrStr setFont:self.font];
	if (self.textColor) [mutAttrStr setTextColor:self.textColor];
	CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
	CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
	[mutAttrStr setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
    
	self.attributedText = [NSAttributedString attributedStringWithAttributedString:mutAttrStr];
}

-(NSAttributedString*)attributedText
{
	if (!_attributedText)
    {
		[self resetAttributedText];
	}
    return _attributedText;
}

-(void)setAttributedText:(NSAttributedString*)newText
{
	MRC_RELEASE(_attributedText);
	_attributedText = MRC_RETAIN(newText);
	[self setAccessibilityLabel:_attributedText.string];
	[self removeAllCustomLinks];
    [self setNeedsRecomputeLinksInText];
}


/////////////////////////////////////////////////////////////////////////////////////

-(void)setText:(NSString *)text
{
	NSString* cleanedText = [[text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]
							 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[super setText:cleanedText]; // will call setNeedsDisplay too
	[self resetAttributedText];
}

-(void)setFont:(UIFont *)font
{
    if (_attributedText)
    {
        NSMutableAttributedString* mutAS = [NSMutableAttributedString attributedStringWithAttributedString:_attributedText];
        [mutAS setFont:font];
        MRC_RELEASE(_attributedText);
        _attributedText = [[NSAttributedString alloc] initWithAttributedString:mutAS];
    }
	[super setFont:font]; // will call setNeedsDisplay too
}

-(void)setTextColor:(UIColor *)color
{
    if (_attributedText)
    {
        NSMutableAttributedString* mutAS = [NSMutableAttributedString attributedStringWithAttributedString:_attributedText];
        [mutAS setTextColor:color];
        MRC_RELEASE(_attributedText);
        _attributedText = [[NSAttributedString alloc] initWithAttributedString:mutAS];
    }
	[super setTextColor:color]; // will call setNeedsDisplay too
}

-(void)setTextAlignment:(UITextAlignment)alignment
{
    if (_attributedText)
    {
        CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(alignment);
        CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(self.lineBreakMode);
        NSMutableAttributedString* mutAS = [NSMutableAttributedString attributedStringWithAttributedString:_attributedText];
        [mutAS setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
        MRC_RELEASE(_attributedText);
        _attributedText = [[NSAttributedString alloc] initWithAttributedString:mutAS];
    }
	[super setTextAlignment:alignment]; // will call setNeedsDisplay too
}

-(void)setLineBreakMode:(UILineBreakMode)lineBreakMode
{
    if (_attributedText)
    {
        CTTextAlignment coreTextAlign = CTTextAlignmentFromUITextAlignment(self.textAlignment);
        CTLineBreakMode coreTextLBMode = CTLineBreakModeFromUILineBreakMode(lineBreakMode);
        NSMutableAttributedString* mutAS = [NSMutableAttributedString attributedStringWithAttributedString:_attributedText];
        [mutAS setTextAlignment:coreTextAlign lineBreakMode:coreTextLBMode];
        MRC_RELEASE(_attributedText);
        _attributedText = [[NSAttributedString alloc] initWithAttributedString:mutAS];
    }
	[super setLineBreakMode:lineBreakMode]; // will call setNeedsDisplay too
	
#if OHATTRIBUTEDLABEL_WARN_ABOUT_KNOWN_ISSUES
	[self warnAboutKnownIssues_CheckLineBreakMode_FromXIB:NO];
#endif	
}

-(void)setCenterVertically:(BOOL)val
{
	_centerVertically = val;
	[self setNeedsDisplay];
}

-(void)setAutomaticallyAddLinksForType:(NSTextCheckingTypes)types
{
	_automaticallyAddLinksForType = types;

    NSDataDetector* dd = sharedReusableDataDetector(types);
    MRC_RELEASE(_linksDetector);
    _linksDetector = MRC_RETAIN(dd);
    [self setNeedsRecomputeLinksInText];
}
-(NSDataDetector*)linksDataDetector
{
    return _linksDetector;
}

-(void)setLinkColor:(UIColor *)newLinkColor
{
    MRC_RELEASE(_linkColor);
    _linkColor = MRC_RETAIN(newLinkColor);
    
    [self setNeedsRecomputeLinksInText];
}

-(void)setLinkUnderlineStyle:(uint32_t)newValue
{
    _linkUnderlineStyle = newValue;
    [self setNeedsRecomputeLinksInText];
}

-(void)setUnderlineLinks:(BOOL)newValue
{
    self.linkUnderlineStyle = (self.linkUnderlineStyle & ~0xFF) | ((newValue ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone) & 0xFF);
}

-(void)setExtendBottomToFit:(BOOL)val
{
	_extendBottomToFit = val;
	[self setNeedsDisplay];
}

-(void)setNeedsDisplay
{
	[self resetTextFrame];
	[super setNeedsDisplay];
}




/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UILabel unsupported features/known issues warnings
/////////////////////////////////////////////////////////////////////////////////////

#if OHATTRIBUTEDLABEL_WARN_ABOUT_KNOWN_ISSUES
-(void)warnAboutKnownIssues_CheckLineBreakMode_FromXIB:(BOOL)fromXIB
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
	BOOL truncationMode = (self.lineBreakMode == UILineBreakModeHeadTruncation)
	|| (self.lineBreakMode == UILineBreakModeMiddleTruncation)
	|| (self.lineBreakMode == UILineBreakModeTailTruncation);
#else
	BOOL truncationMode = (self.lineBreakMode == NSLineBreakByTruncatingHead)
	|| (self.lineBreakMode == NSLineBreakByTruncatingMiddle)
	|| (self.lineBreakMode == NSLineBreakByTruncatingTail);
#endif
	if (truncationMode)
    {
		NSLog(@"[OHAttributedLabel] Warning: \"UILineBreakMode...Truncation\" lineBreakModes are not yet fully supported"
              "by CoreText and OHAttributedLabel. See https://github.com/AliSoftware/OHAttributedLabel/issues/3");
        if (fromXIB)
        {
            NSLog(@"  (To avoid this warning, change this property in your XIB file to another lineBreakMode value)");
        }
	}
}

-(void)warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth_FromXIB:(BOOL)fromXIB
{
	if (self.adjustsFontSizeToFitWidth)
    {
		NSLog(@"[OHAttributedLabel] Warning: the \"adjustsFontSizeToFitWidth\" property is not supported by CoreText. "
              "It will be ignored by OHAttributedLabel.");
        if (fromXIB)
        {
            NSLog(@"  (To avoid this warning, uncheck the 'Autoshrink' property in your XIB file)");
        }

	}
}

-(void)setAdjustsFontSizeToFitWidth:(BOOL)value
{
	[super setAdjustsFontSizeToFitWidth:value];
	[self warnAboutKnownIssues_CheckAdjustsFontSizeToFitWidth_FromXIB:NO];
}

-(void)setNumberOfLines:(NSInteger)nbLines
{
    if (nbLines > 0)
    {
        NSLog(@"[OHAttributedLabel] Warning: the \"numberOfLines\" property is not yet supported by CoreText. "
              "It will be ignored by OHAttributedLabel. See https://github.com/AliSoftware/OHAttributedLabel/issues/34");
        NSLog(@"  (To avoid this warning, set the numberOfLines property to 0)");
    }

	[super setNumberOfLines:nbLines];
}
#endif

@end
