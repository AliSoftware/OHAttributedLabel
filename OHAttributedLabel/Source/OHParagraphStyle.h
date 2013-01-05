//
//  OHParagraphStyle.h
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 05/01/13.
//  Copyright (c) 2013 AliSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface OHParagraphStyle : NSObject <NSCopying>

////////////////////////////////////////////////////////////////////////////////

/* "Leading": distance between the bottom of one line fragment and top of next */
@property (nonatomic, assign) CGFloat lineSpacing;

/* Distance between the bottom of this paragraph and top of next (or the beginning of its paragraphSpacingBefore, if any) */
@property (nonatomic, assign) CGFloat paragraphSpacing;

@property (nonatomic, assign) CTTextAlignment textAlignment;
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;

@property (nonatomic, assign) CGFloat firstLineHeadIndent; // Distance from margin to edge appropriate for text direction
@property (nonatomic, assign) CGFloat headIndent; // Distance from margin to front edge of paragraph
@property (nonatomic, assign) CGFloat tailIndent; // Distance from margin to back edge of paragraph. Use negative values for distance to other edge.
@property (nonatomic, assign) CTWritingDirection baseWritingDirection;

/* Line height is the distance from bottom of descenders to top of ascenders; basically the line fragment height. Does not include lineSpacing (which is added after this computation). */
@property (nonatomic, assign) CGFloat minimumLineHeight;
@property (nonatomic, assign) CGFloat maximumLineHeight; // 0 implies no maximum.
/* Natural line height is multiplied by this factor (if positive) before being constrained by minimum and maximum line height. */
@property (nonatomic, assign) CGFloat lineHeightMultiple;
/* Distance between the bottom of the previous paragraph (or the end of its paragraphSpacing, if any) and the top of this paragraph. */
@property (nonatomic, assign) CGFloat paragraphSpacingBefore;




////////////////////////////////////////////////////////////////////////////////

+ (id)defaultParagraphStyle;
+ (id)paragraphStyleWithCTParagraphStyle:(CTParagraphStyleRef)paragraphStyle;
- (id)initWithCTParagraphStyle:(CTParagraphStyleRef)paragraphStyle;
- (CTParagraphStyleRef)createCTParagraphStyle;

@end
