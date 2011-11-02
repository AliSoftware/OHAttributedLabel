//
//  main.m
//  AttributedLabel Example
//
//  Created by Olivier on 18/02/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef OBJC_ARC_ENABLED
	#ifdef __has_feature
		#define OBJC_ARC_ENABLED __has_feature(objc_arc)
	#else
		#define OBJC_ARC_ENABLED 0
	#endif
#endif

int main(int argc, char *argv[]) {
#if OBJC_ARC_ENABLED
	@autoreleasepool {
		return UIApplicationMain(argc, argv, nil, nil);
	}
#else
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
#endif
}
