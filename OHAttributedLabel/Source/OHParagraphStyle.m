//
//  OHParagraphStyle.m
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 05/01/13.
//  Copyright (c) 2013 AliSoftware. All rights reserved.
//

#import "OHParagraphStyle.h"

@implementation OHParagraphStyle
@synthesize lineSpacing = _lineSpacing;
@synthesize paragraphSpacing = _paragraphSpacing;
@synthesize textAlignment = _textAlignment;
@synthesize lineBreakMode = _lineBreakMode;
@synthesize firstLineHeadIndent = _firstLineHeadIndent;
@synthesize headIndent = _headIndent;
@synthesize tailIndent = _tailIndent;
@synthesize baseWritingDirection = _baseWritingDirection;
@synthesize minimumLineHeight = _minimumLineHeight;
@synthesize maximumLineHeight = _maximumLineHeight;
@synthesize lineHeightMultiple = _lineHeightMultiple;
@synthesize paragraphSpacingBefore = _paragraphSpacingBefore;


+ (id)defaultParagraphStyle
{
    return [self paragraphStyleWithCTParagraphStyle:NULL];
}

+ (id)paragraphStyleWithCTParagraphStyle:(CTParagraphStyleRef)paragraphStyle
{
    OHParagraphStyle* paraStyle = [[OHParagraphStyle alloc] initWithCTParagraphStyle:paragraphStyle];
#if !__has_feature(objc_arc)
    [paraStyle autorelease];
#endif
    return paraStyle;
}

- (id)init
{
    return [self initWithCTParagraphStyle:NULL];
}

- (id)initWithCTParagraphStyle:(CTParagraphStyleRef)style
{
    self = [super init];
    if (self)
    {
        CTParagraphStyleRef paragraphStyle = style ?: CTParagraphStyleCreate(NULL, 0);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineSpacing,sizeof(_lineSpacing), &_lineSpacing);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierParagraphSpacing, sizeof(_paragraphSpacing), &_paragraphSpacing);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierAlignment,sizeof(_textAlignment), &_textAlignment);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineBreakMode, sizeof(_lineBreakMode), &_lineBreakMode);
        
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(_firstLineHeadIndent), &_firstLineHeadIndent);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierHeadIndent, sizeof(_headIndent), &_headIndent);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierTailIndent, sizeof(_tailIndent), &_tailIndent);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(_baseWritingDirection), &_baseWritingDirection);
        
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(_minimumLineHeight), &_minimumLineHeight);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(_maximumLineHeight), &_maximumLineHeight);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(_lineHeightMultiple), &_lineHeightMultiple);
        CTParagraphStyleGetValueForSpecifier(paragraphStyle, kCTParagraphStyleSpecifierParagraphSpacingBefore,sizeof(_paragraphSpacingBefore), &_paragraphSpacingBefore);
        if (paragraphStyle && !style) CFRelease(paragraphStyle);
    }
    return self;
}

- (CTParagraphStyleRef)createCTParagraphStyle
{
    const int kSettingsCount = 12;
    CTParagraphStyleSetting settings[kSettingsCount] =
    {
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(_lineSpacing), &_lineSpacing },
        { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(_paragraphSpacing), &_paragraphSpacing },
        { kCTParagraphStyleSpecifierAlignment, sizeof(_textAlignment), &_textAlignment },
        { kCTParagraphStyleSpecifierLineBreakMode, sizeof(_lineBreakMode), &_lineBreakMode },

        { kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(_firstLineHeadIndent), &_firstLineHeadIndent},
        { kCTParagraphStyleSpecifierHeadIndent, sizeof(_headIndent), &_headIndent},
        { kCTParagraphStyleSpecifierTailIndent, sizeof(_tailIndent), &_tailIndent},
        { kCTParagraphStyleSpecifierBaseWritingDirection, sizeof(_baseWritingDirection), &_baseWritingDirection },
        
        { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(_minimumLineHeight), &_minimumLineHeight },
        { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(_maximumLineHeight), &_maximumLineHeight },
        { kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(_lineHeightMultiple), &_lineHeightMultiple },
        { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(_paragraphSpacingBefore), &_paragraphSpacingBefore }
    };
    return CTParagraphStyleCreate(settings, kSettingsCount);
}


#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	OHParagraphStyle* copy = [[OHParagraphStyle allocWithZone:zone] init];

    copy.lineSpacing = self.lineSpacing;
	copy.paragraphSpacing = self.paragraphSpacing;
    copy.textAlignment = self.textAlignment;
    copy.headIndent = self.headIndent;
	copy.tailIndent = self.tailIndent;
	copy.firstLineHeadIndent = self.firstLineHeadIndent;
    copy.minimumLineHeight = self.minimumLineHeight;
	copy.maximumLineHeight = self.maximumLineHeight;
	copy.lineBreakMode = self.lineBreakMode;
    copy.baseWritingDirection = self.baseWritingDirection;
    copy.lineHeightMultiple = self.lineHeightMultiple;
	copy.paragraphSpacingBefore = self.paragraphSpacingBefore;
    
	return copy;
}
@end
