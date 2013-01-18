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
 *  "*bold*" to write text in bold
 *
 *  "_underline_" to write text underlined
 *
 *  "|italics|" to write text in italics
 *
 *  "`typewritter font`" to write text in Courier (fixed-width) font
 *
 *  "[some text](some URL)" to create a link to "some URL" with displayed text "some text"
 *
 * Colors:
 *  - use "{color|text}" like in "{#fc0|some purple text}" and "{#00ff00|some green text}"
 *  - It also support named colors like in "{red|some red text}" "{green|some green text}", "{blue|some blue text}"
 *
 * 
 */
@interface OHASBasicMarkupParser : OHASMarkupParserBase

@end
