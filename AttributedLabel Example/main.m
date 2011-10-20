//
//  main.m
//  AttributedLabel Example
//
//  Created by Olivier on 18/02/11.
//  Copyright 2011 AliSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>

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
