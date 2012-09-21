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


#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>



/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Utility Functions
/////////////////////////////////////////////////////////////////////////////////////

CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment);
CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode);

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSTextCheckingResult Extension

@interface NSTextCheckingResult(Extended)
@property(nonatomic, readonly) NSURL* extendedURL;
@end

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - OHAttributedLabel Delegate Protocol
/////////////////////////////////////////////////////////////////////////////////////

@class OHAttributedLabel;
@protocol OHAttributedLabelDelegate <NSObject>
@optional
-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo;
//! @parameter underlineStyle Combination of CTUnderlineStyle and CTUnderlineStyleModifiers
-(UIColor*)attributedLabel:(OHAttributedLabel*)attributedLabel colorForLink:(NSTextCheckingResult*)linkInfo underlineStyle:(int32_t*)underlineStyle;
@end


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants
/////////////////////////////////////////////////////////////////////////////////////

extern const int UITextAlignmentJustify
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
__attribute__((deprecated("You should use 'setTextAlignment:lineBreakMode:' on your NSAttributedString instead.")));
#else
__attribute__((unavailable("Since iOS6 SDK, you have to use 'setTextAlignment:lineBreakMode:' on your NSAttributedString instead.")));
#endif



/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public Interface
/////////////////////////////////////////////////////////////////////////////////////

@interface OHAttributedLabel : UILabel <UIAppearance>

//! Use this instead of the "text" property inherited from UILabel to set and get attributed text
@property(nonatomic, copy) NSAttributedString* attributedText;
//! rebuild the attributedString based on UILabel's text/font/color/alignment/... properties, cleaning any custom attribute
-(void)resetAttributedText;
//! Force recomputation of automatically detected links. Useful if you changed a condition that affect link colors in your delegate implementation for example.
-(void)setNeedsRecomputeLinksInText;

/* Links configuration */
//! Defaults to NSTextCheckingTypeLink, + NSTextCheckingTypePhoneNumber if "tel:" URL scheme is supported.
@property(nonatomic, assign) NSTextCheckingTypes automaticallyAddLinksForType;
//! Defaults to [UIColor blueColor]. See also OHAttributedLabelDelegate
@property(nonatomic, strong) UIColor* linkColor UI_APPEARANCE_SELECTOR;
//! Defaults to [UIColor colorWithWhite:0.2 alpha:0.5]
@property(nonatomic, strong) UIColor* highlightedLinkColor UI_APPEARANCE_SELECTOR;
//! Combination of CTUnderlineStyle and CTUnderlineStyleModifiers
@property(nonatomic, assign) uint32_t linkUnderlineStyle UI_APPEARANCE_SELECTOR;
//! Commodity setter to set the linkUnderlineStyle to CTUnderlineStyleSingle (YES) / CTUnderlineStyleNone (NO)
-(void)setUnderlineLinks:(BOOL)underlineLinks;

//! Add a link to some text in the label
-(void)addCustomLink:(NSURL*)linkUrl inRange:(NSRange)range;
//! Remove all custom links from the label
-(void)removeAllCustomLinks;

//! If YES, pointInside will only return YES if the touch is on a link. If NO, pointInside will always return YES (Defaults to YES)
@property(nonatomic, assign) BOOL onlyCatchTouchesOnLinks;
//! The delegate that gets informed when a link is touched and gives the opportunity to catch it
@property(nonatomic, assign) IBOutlet id<OHAttributedLabelDelegate> delegate;

//! Center text vertically inside the label
@property(nonatomic, assign) BOOL centerVertically;
//! Allows to draw text past the bottom of the view if need. May help in rare cases (like using Emoji)
@property(nonatomic, assign) BOOL extendBottomToFit;
@end
