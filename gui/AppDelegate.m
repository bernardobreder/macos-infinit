//
//  AppDelegate.m
//  gui
//
//  Created by Bernardo Breder on 25/03/15.
//  Copyright (c) 2015 Breder Window. All rights reserved.
//

#import "AppDelegate.h"
#import "NSTimer+Block.h"
#import "BBRowTableView.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSWindow* window;

@end

@interface MapCell : NSObject

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) NSPoint point;

@property (nonatomic, strong) NSOperation *operation;

@end

@implementation MapCell

@end

@interface CanvasView ()

@property (nonatomic, strong, nonnull) NSMutableArray *cellImage;

@property (nonatomic, strong, nonnull) NSOperationQueue *queue;

@property (nonatomic, strong, nonnull) NSMutableArray *cellLoadingData;

@property (nonatomic, strong, nonnull) NSMutableIndexSet *cellLoading;

@property (nonatomic, strong, nonnull) NSMutableDictionary *cellImages;

@property (nonatomic, strong, nonnull) NSTimer *timer;

@end

@implementation CanvasView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (!(self = [super initWithFrame:frameRect])) return nil;
    _lazyDraw = [[BBLazyDraw alloc] init];
    _lazyDraw.delegate = self;
    return self;
}

- (void)setRowCount:(NSInteger)rowCount
{
    _rowCount = rowCount;
    self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, rowCount * _cellSize.height);
}

- (void)setColumnCount:(NSInteger)columnCount
{
    _columnCount = columnCount;
    self.frame = NSMakeRect(self.frame.origin.x, self.frame.origin.y, columnCount * _cellSize.width, self.frame.size.height);
}

- (void)drawRectAtLoading:(NSRect)rect
{
    [NSColor.grayColor drawSwatchInRect:rect];
}

- (NSImage*)drawRectInBackground:(NSRect)rect withOperation:(NSOperation*)operation
{
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/5580759/photo512.jpg"];
    return [[NSImage alloc] initWithContentsOfURL:url];
}

- (void) drawRect:(NSRect)rect
{
    [_lazyDraw drawRect:rect];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)mouseDown:(NSEvent *)event
{
    NSPoint clickLocation = [self convertPoint:[event locationInWindow] fromView:nil];
    NSLog(@"Clicked: %@", NSStringFromPoint(clickLocation));
}

@end

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSRect screenRect = NSScreen.mainScreen.frame;
    NSRect frame = NSMakeRect(0, 0, screenRect.size.width, screenRect.size.height);
    frame = NSScreen.mainScreen.frame;
    _window  = [[NSWindow alloc] initWithContentRect:frame
                                           styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask)
                                             backing:NSBackingStoreBuffered
                                               defer:YES];
    [_window setBackgroundColor:[NSColor blueColor]];
    
    if(false) {
        NSButton* button = [[NSButton alloc]
                            initWithFrame:NSMakeRect(0, 30, 150, 40)];
        [button setTitle: @"Click me"];
        [button setBezelStyle:NSRoundedBezelStyle];
        
        [_window.contentView addSubview:button];
    }
    if (false) {
        NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(200,0,frame.size.width - 200, frame.size.height)];
        scrollView.hasVerticalScroller = true;
        scrollView.hasHorizontalScroller = true;
        scrollView.borderType = NSNoBorder;
        [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        
        NSView* view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, 1024 * 16)];
        NSTextView* text = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 1024, 16 * 1024)];
        text.drawsBackground = false;
        NSMutableAttributedString * fieldValue = [[NSMutableAttributedString alloc] initWithString: @""];
        for (NSInteger n = 0 ; n < 1024 ; n++) {
            [fieldValue.mutableString appendString:@"Bernardo Breder\n"];
        }
        [fieldValue beginEditing];
        for (NSInteger n = 0 ; n < 1024 ; n++) {
            [fieldValue addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(n*16, 8)];
            [fieldValue addAttribute:NSForegroundColorAttributeName value:[NSColor greenColor] range:NSMakeRange(n*16+9, 6)];
        }
        [fieldValue endEditing];
        [text.textStorage setAttributedString:fieldValue];
        [view addSubview:text];
        scrollView.documentView = view;
        [scrollView.documentView scrollPoint:NSMakePoint(0, NSMaxY(view.frame) - NSHeight(scrollView.contentView.bounds))];
        
        [_window.contentView addSubview:scrollView];
        
        NSVisualEffectView* leftView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, 200, frame.size.height)];
        leftView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
        leftView.state = NSVisualEffectStateFollowsWindowActiveState;
        leftView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        leftView.material = NSVisualEffectMaterialLight;
        [_window.contentView addSubview:leftView];
    }
    
    if (false) {
        NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        scrollView.hasVerticalScroller = true;
        scrollView.hasHorizontalScroller = true;
        scrollView.borderType = NSNoBorder;
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.backgroundColor = [NSColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
        scrollView.usesPredominantAxisScrolling = false;
        [_window.contentView addSubview:scrollView];
        
        NSView* view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.documentView = view;
        
        NSTableView* tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        tableView.backgroundColor = nil;
        for (NSInteger n = 0 ; n < 20 ; n++) {
            NSTableColumn* column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"%ld", n]];
            column.width = 100;
            [tableView addTableColumn:column];
        }
        tableView.dataSource = self;
        //		tableView.delegate = self;
        tableView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        tableView.allowsColumnSelection = true;
        [view addSubview:tableView];
        
        view.frame = NSMakeRect(0, 0, 10 * 100, tableView.rowHeight * 1000);
    }
    
    if (false) {
        NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        scrollView.hasVerticalScroller = true;
        scrollView.hasHorizontalScroller = true;
        scrollView.borderType = NSNoBorder;
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.backgroundColor = [NSColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
        [_window.contentView addSubview:scrollView];
        
        NSView* view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.documentView = view;
        
        NSInteger rmax = 1000, cmax = 50;
        for (NSInteger r = 0 ; r < rmax ; r++) {
            for (NSInteger c = 0 ; c < cmax ; c++) {
                NSTextView* text = [[NSTextView alloc] initWithFrame:NSMakeRect(c * 100, r * 16, 100, 16)];
                text.string = [NSString stringWithFormat:@"Cell %ldx%ld", r+1, c+1];
                text.drawsBackground = false;
                text.editable = false;
                text.selectable = false;
                [view addSubview:text];
            }
        }
        view.frame = NSMakeRect(0, 0, cmax * 100, rmax * 16);
    }
    
    if (false) {
        NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        scrollView.hasVerticalScroller = true;
        scrollView.hasHorizontalScroller = true;
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.backgroundColor = [NSColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
        scrollView.usesPredominantAxisScrolling = true;
        scrollView.wantsLayer = false;
        [_window.contentView addSubview:scrollView];
        
        NSView* view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        view.wantsLayer = false;
        scrollView.documentView = view;
        
        NSInteger rmax = 500, cmax = 15;
        NSInteger width = 100, height = 16;
        for (NSInteger r = 0 ; r < rmax ; r++) {
            for (NSInteger c = 0 ; c < cmax ; c++) {
                NSTextView* text = [[NSTextView alloc] initWithFrame:NSMakeRect(c * (width+1), r * (height+1), width, height)];
                text.string = [NSString stringWithFormat:@"Cell %ldx%ld", r+1, c+1];
                text.backgroundColor = NSColor.whiteColor;
                text.editable = false;
                text.selectable = false;
                [view addSubview:text];
            }
        }
        view.frame = NSMakeRect(0, 0, cmax * (width+1), rmax * (height+1));
    }
    
    if (false) {
        NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        scrollView.hasVerticalScroller = true;
        scrollView.hasHorizontalScroller = true;
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.backgroundColor = [NSColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
        scrollView.usesPredominantAxisScrolling = true;
        scrollView.wantsLayer = false;
        [_window.contentView addSubview:scrollView];
        
        NSView* view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        view.wantsLayer = false;
        scrollView.documentView = view;
        
        NSInteger rmax = 500, cmax = 15;
        NSInteger width = 100, height = 16;
        for (NSInteger r = 0 ; r < rmax ; r++) {
            for (NSInteger c = 0 ; c < cmax ; c++) {
                NSPoint point = NSMakePoint(c * (width+1), r * (height+1));
                NSRect rect = NSMakeRect(0, 0, width, height);
                CALayer *layer = [[CALayer alloc] init];
                layer.backgroundColor = NSColor.whiteColor.CGColor;
                layer.bounds = rect;
                layer.position = point;
                [view.layer addSublayer:layer];
            }
        }
        view.frame = NSMakeRect(0, 0, cmax * (width+1), rmax * (height+1));
    }
    
    if (false) {
        NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        scrollView.hasVerticalScroller = true;
        scrollView.hasHorizontalScroller = true;
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.backgroundColor = [NSColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
        [_window.contentView addSubview:scrollView];
        
        NSView* view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.documentView = view;
        
        NSInteger rmax = 100, cmax = 15;
        NSInteger width = 100, height = 16;
        for (NSInteger r = 0 ; r < rmax ; r++) {
            for (NSInteger c = 0 ; c < cmax ; c++) {
                NSRect rect = NSMakeRect(c * (width+1), r * (height+1), width, height);
                NSTextView* text = [[NSTextView alloc] initWithFrame:rect];
                text.string = [NSString stringWithFormat:@"Cell %ldx%ld", r+1, c+1];
                text.backgroundColor = NSColor.whiteColor;
                text.editable = false;
                text.selectable = false;
                NSImageView *imageView = [[NSImageView alloc] initWithFrame:rect];
                NSImage* image = [[NSImage alloc] initWithSize:rect.size];
                [image lockFocus];
                [text drawRect:NSMakeRect(0, 0, rect.size.width, rect.size.height)];
                [image unlockFocus];
                imageView.image = image;
                [view addSubview:imageView];
            }
        }
        view.frame = NSMakeRect(0, 0, cmax * (width+1), rmax * (height+1));
    }
    
    if (false) {
        BBTableView* table = [[BBTableView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.width) dataSource:self];
        table.cellWidth = 100;
        table.cellHeight = 16;
        table.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [_window.contentView addSubview:table];
    }
    
    if (false) {
        NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        scrollView.hasVerticalScroller = true;
        scrollView.hasHorizontalScroller = true;
        scrollView.autohidesScrollers = false;
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.backgroundColor = [NSColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
        scrollView.usesPredominantAxisScrolling = false;
        [_window.contentView addSubview:scrollView];
        
        CanvasView* view = [[CanvasView alloc] initWithFrame:NSMakeRect(0, 0, 5000, 5000)];
        view.cellSize = CGSizeMake(1024, 1024);
        view.rowCount = 1000;
        view.columnCount = 1000;
        scrollView.documentView = view;
        view.lazyDraw.scrollView = scrollView;
    }

    if (true) {
        NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, frame.size.width, frame.size.height)];
        scrollView.hasVerticalScroller = true;
        scrollView.hasHorizontalScroller = true;
        scrollView.autohidesScrollers = false;
        scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        scrollView.backgroundColor = [NSColor colorWithRed:1.0 green:0.9 blue:0.9 alpha:1.0];
        scrollView.usesPredominantAxisScrolling = false;
        [_window.contentView addSubview:scrollView];
        
        BBRowTableView* view = [[BBRowTableView alloc] initWithFrame:NSMakeRect(0, 0, 5000, 5000)];
        view.cellSize = CGSizeMake(1024, 1024);
        view.rowCount = 1000;
        view.columnCount = 1000;
        scrollView.documentView = view;
        view.lazyDraw.scrollView = scrollView;
    }

    [_window makeKeyAndOrderFront:NSApp];
    [_window makeMainWindow];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 1000;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [NSString stringWithFormat:@"Cell %ldx%ld", row, [tableView columnWithIdentifier:tableColumn.identifier]];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *cellIdentifier = @"Name";
    NSTextView *cellView = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
    NSString* value = (NSString*) [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    if (cellView == nil)
    {
        //		NSLog(value);
        cellView = [[NSTextView alloc] init];
        [cellView setIdentifier:cellIdentifier];
    }
    cellView.string = value;
    return cellView;
}

- (NSInteger)tableViewDataSourceRowCount:(BBTableView*)tableView
{
    return 100;
}

- (NSInteger)tableViewDataSourceColumnCount:(BBTableView*)tableView
{
    return 5;
}

- (NSView*)tableViewDataSource:(BBTableView*)tableView atRow:(NSInteger)row atColumn:(NSInteger)column reusedCellView:(NSView*)reusedCellView withFrame:(NSRect)frame isSelected:(BOOL)selected
{
    NSTextView* textView = (NSTextView*)reusedCellView;
    if (!textView) {
        textView = [[NSTextView alloc] initWithFrame:frame];
        textView.drawsBackground = false;
        textView.editable = false;
        textView.selectable = false;
    }
    textView.string = [NSString stringWithFormat:@"(%ld,%ld)", row, column];
    return textView;
}

- (NSObject*)tableViewDataSource:(BBTableView*)tableView valueAtRow:(NSInteger)row andColumn:(NSInteger)column
{
    return [NSString stringWithFormat:@"Cell %ldx%ld", row+1, column+1];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
