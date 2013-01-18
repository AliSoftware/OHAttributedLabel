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


#import "OHASMarkupParserBase.h"

/*!
 * Supported tags:
 *
 *  "<b>bold text</b>" to write some text in bold
 *
 *  "<u>underline text</u>" to write some text underlined
 *
 *  "<i>italic text</i> to write some text in italics
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
