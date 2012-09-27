//
//  NSTextCheckingResult+ExtendedURL.h
//  OHAttributedLabel
//
//  Created by Olivier Halligon on 23/09/12.
//  Copyright (c) 2012 AliSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSTextCheckingResult Extension

@interface NSTextCheckingResult(ExtendedURL)
@property(nonatomic, readonly) NSURL* extendedURL;
@end
