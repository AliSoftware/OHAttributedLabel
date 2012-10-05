//
//  OHASBasicHTMLParser.h
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 26/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import "OHASMarkupParserBase.h"

/*!
 * Supported tags:
 *  "<b>bold text</b>"
 *  "<u>underline text</u>"
 *  "<font name='fontname' size='size'>some text</font>"
 *      note that you have to specify both "name" and "size" attributes and in that exact order
 *  "<font color='color'>some text</font>"
 *      where color can be an hexadecimal color of the form "#rgb", "#rgba", "#rrggbb" or "#rrggbbaa"
 *      or a color name like "red" "green" "blue", "purple"…
 *      (the supported names correspond to the [UIColor xxxColor] commodity constructors of the UIColor class)
 */
@interface OHASBasicHTMLParser : OHASMarkupParserBase

@end
