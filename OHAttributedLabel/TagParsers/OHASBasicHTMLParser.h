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
 *
 *  "<b>bold text</b>" to write some text in bold
 *
 *  "<u>underline text</u>" to write some text underlined
 *
 *  "<font name='fontname' size='size'>some text</font>" to change font and size of some text
 *      note that you have to specify both "name" and "size" attributes and in that exact order
 *
 *  "<font color='color'>some text</font>" to change text color
 *      where color can be an hexadecimal color of the form "#rgb", "#rgba", "#rrggbb" or "#rrggbbaa"
 *      or a color name like "red" "green" "blue", "purple"…
 *      (the supported names correspond to the [UIColor xxxColor] commodity constructors of the UIColor class)
 *
 *  "<a href='link'>some text</a>" to add some links to a text
 *
 */
@interface OHASBasicHTMLParser : OHASMarkupParserBase

@end
