//
//  OHASBasicMarkupParser.h
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 27/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import "OHASMarkupParserBase.h"

/*!
 * Supported tags:
 *  "*bold*"
 *  "_underline_"
 *  "`typewritter font`"
 * Colors:
 *  - use "{color|text}" like in "{#fc0|some purple text}" and "{#00ff00|some green text}"
 *  - It also support named colors like in "{red|some red text}" "{green|some green text}", "{blue|some blue text}"
 */
@interface OHASBasicMarkupParser : OHASMarkupParserBase

@end
