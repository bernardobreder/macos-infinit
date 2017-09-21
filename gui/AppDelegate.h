//
//  AppDelegate.h
//  gui
//
//  Created by Bernardo Breder on 25/03/15.
//  Copyright (c) 2015 Breder Window. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BBTableView.h"
#import "BBLazyDraw.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, BBTableDataSource>

@end

@interface CanvasView : NSView <BBLazyDrawDelegate>

@property (nonatomic, assign) NSInteger rowCount;

@property (nonatomic, assign) NSInteger columnCount;

@property (nonatomic, assign) NSSize cellSize;

@property (nonatomic, strong) BBLazyDraw *lazyDraw;

@end