//
//  main.m
//  gui
//
//  Created by Bernardo Breder on 25/03/15.
//  Copyright (c) 2015 Breder Window. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
	AppDelegate *delegate = [[AppDelegate alloc] init];
	[NSApplication sharedApplication];
	[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
	[NSApplication.sharedApplication setDelegate:delegate];
	[NSApp run];
	return 0;
}
