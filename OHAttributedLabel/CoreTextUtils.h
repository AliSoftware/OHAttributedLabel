//
//  CoreTextUtils.h
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 23/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Text Alignment Convertion
/////////////////////////////////////////////////////////////////////////////////////

CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment);
CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode);

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Flipping Coordinates
/////////////////////////////////////////////////////////////////////////////////////

CGPoint CGPointFlipped(CGPoint point, CGRect bounds);
CGRect CGRectFlipped(CGRect rect, CGRect bounds);

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSRange / CFRange
/////////////////////////////////////////////////////////////////////////////////////

NSRange NSRangeFromCFRange(CFRange range);

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CoreText CTLine/CTRun utils
/////////////////////////////////////////////////////////////////////////////////////

CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin);
CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin);
BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range);
BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range);
