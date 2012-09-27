//
//  CoreTextUtils.m
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 23/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import "CoreTextUtils.h"

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Text Alignment Convertion
/////////////////////////////////////////////////////////////////////////////////////


CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment)
{
    if (alignment == (UITextAlignment)kCTJustifiedTextAlignment)
    {
        /* special OOB value, so test it outside of the switch to avoid warning */
        return kCTJustifiedTextAlignment;
    }
	switch (alignment)
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
#else
		case NSTextAlignmentLeft: return kCTLeftTextAlignment;
		case NSTextAlignmentCenter: return kCTCenterTextAlignment;
		case NSTextAlignmentRight: return kCTRightTextAlignment;
#endif
		default: return kCTNaturalTextAlignment;
	}
}

CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode)
{
	switch (lineBreakMode)
    {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
		case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
		case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
		case UILineBreakModeClip: return kCTLineBreakByClipping;
		case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
		case UILineBreakModeTailTruncation: return kCTLineBreakByTruncatingTail;
		case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
#else
		case NSLineBreakByWordWrapping: return kCTLineBreakByWordWrapping;
		case NSLineBreakByCharWrapping: return kCTLineBreakByCharWrapping;
		case NSLineBreakByClipping: return kCTLineBreakByClipping;
		case NSLineBreakByTruncatingHead: return kCTLineBreakByTruncatingHead;
		case NSLineBreakByTruncatingTail: return kCTLineBreakByTruncatingTail;
		case NSLineBreakByTruncatingMiddle: return kCTLineBreakByTruncatingMiddle;
#endif
		default: return 0;
	}
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flipping Coordinates
/////////////////////////////////////////////////////////////////////////////////////

// Don't use this method for origins. Origins always depend on the height of the rect.
CGPoint CGPointFlipped(CGPoint point, CGRect bounds)
{
	return CGPointMake(point.x, CGRectGetMaxY(bounds)-point.y);
}

CGRect CGRectFlipped(CGRect rect, CGRect bounds)
{
	return CGRectMake(CGRectGetMinX(rect),
					  CGRectGetMaxY(bounds)-CGRectGetMaxY(rect),
					  CGRectGetWidth(rect),
					  CGRectGetHeight(rect));
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSRange / CFRange
/////////////////////////////////////////////////////////////////////////////////////

NSRange NSRangeFromCFRange(CFRange range)
{
	return NSMakeRange(range.location, range.length);
}

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CoreText CTLine/CTRun utils
/////////////////////////////////////////////////////////////////////////////////////

// Font Metrics: http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/FontHandling/Tasks/GettingFontMetrics.html
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin)
{
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
	CGFloat height = ascent + descent;
	
	return CGRectMake(lineOrigin.x,
					  lineOrigin.y - descent,
					  width,
					  height);
}

CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin)
{
	CGFloat ascent = 0;
	CGFloat descent = 0;
	CGFloat leading = 0;
	CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
	CGFloat height = ascent + descent;
	
	CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
	
	return CGRectMake(lineOrigin.x + xOffset,
					  lineOrigin.y - descent,
					  width,
					  height);
}

BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range)
{
	NSRange lineRange = NSRangeFromCFRange(CTLineGetStringRange(line));
	NSRange intersectedRange = NSIntersectionRange(lineRange, range);
	return (intersectedRange.length > 0);
}

BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range)
{
	NSRange runRange = NSRangeFromCFRange(CTRunGetStringRange(run));
	NSRange intersectedRange = NSIntersectionRange(runRange, range);
	return (intersectedRange.length > 0);
}



