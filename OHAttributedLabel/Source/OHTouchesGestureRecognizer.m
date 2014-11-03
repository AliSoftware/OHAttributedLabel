/***********************************************************************************
 * This software is under the MIT License quoted below:
 ***********************************************************************************
 *
 * Copyright (c) 2013 Matt Galloway
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


#import "OHTouchesGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#include <tgmath.h>

@interface OHTouchesGestureRecognizer ()

@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation OHTouchesGestureRecognizer

@synthesize startPoint = _startPoint;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.startPoint = [(UITouch *)[touches anyObject] locationInView:self.view];
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    CGFloat distanceX = (currentPoint.x - _startPoint.x);
    CGFloat distanceY = (currentPoint.y - _startPoint.y);
    CGFloat distance = sqrt(distanceX * distanceX + distanceY * distanceY);
    if (distance > 10.0f) {
        self.state = UIGestureRecognizerStateCancelled;
    } else {
        self.state = UIGestureRecognizerStateChanged;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)reset {
    self.state = UIGestureRecognizerStatePossible;
}

@end
