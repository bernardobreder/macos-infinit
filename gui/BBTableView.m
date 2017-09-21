//
//  BBTableView.m
//  gui
//
//  Created by Bernardo Breder on 28/03/15.
//  Copyright (c) 2015 Breder Window. All rights reserved.
//

#import "BBTableView.h"

@interface BBTableView ()

@property (nonatomic, strong) NSView* view;
@property (nonatomic, assign) bool needReloadLayout;
@property (nonatomic, assign) bool needReloadData;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) NSInteger columnCount;
@property (nonatomic, strong) NSMutableArray *cellViewCached;
@property (nonatomic, strong) NSMutableArray *cellImageCached;
@property (nonatomic, strong) NSMutableArray *cellViewReused;
@property (nonatomic, strong) NSView *cellView;

@end

@implementation BBTableView

- (instancetype)initWithFrame:(NSRect)frame dataSource:(id<BBTableDataSource>)dataSource
{
    if (!(self = [super initWithFrame:frame])) return nil;
    _dataSource = dataSource;
    self.documentView = _view = [[NSView alloc] initWithFrame:frame];
    self.hasHorizontalScroller = true;
    self.hasVerticalScroller = true;
    self.usesPredominantAxisScrolling = false;
    self.drawsBackground = false;
    self.contentView.copiesOnScroll = false;
    self.contentView.drawsBackground = false;
    _needReloadLayout = true;
    _needReloadData = true;
    _cellViewCached = [[NSMutableArray alloc] init];
    _cellViewReused = [[NSMutableArray alloc] init];
    _cellImageCached = [[NSMutableArray alloc] init];
    _cellWidth = 100;
    _cellHeight = 16;
    [self _updateLayout];
    [self _updateData];
    [self _updateViews];
    return self;
}

- (void)fireStructureChanged
{
    _needReloadLayout = true;
    _needReloadData = true;
    @autoreleasepool {
        [self _updateLayoutIfNeeded];
        [self _updateDataIfNeeded];
        [self _updateViews];
    }
}

- (void)setCellWidth:(NSInteger)cellWidth
{
    _cellWidth = cellWidth;
    [self fireStructureChanged];
}

- (void)setCellHeight:(NSInteger)cellHeight
{
    _cellHeight = cellHeight;
    [self fireStructureChanged];
}

- (CGRect)rectForRow:(NSInteger)row
{
    return CGRectMake(0, row * _cellHeight, _columnCount * _cellWidth, _cellHeight);
}

- (CGRect)rectForCell:(NSInteger)row at:(NSInteger)column
{
    return CGRectMake(column * _cellWidth, row * _cellHeight, _cellWidth, _cellHeight);
}

- (CGRect)rectFromModelToView:(CGRect)rect
{
    return NSMakeRect(rect.origin.x, _view.frame.size.height - rect.size.height - rect.origin.y, rect.size.width, rect.size.height);
}

- (void)enumerateCellsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    NSView *nullView = (NSView*) [NSNull null];
    BOOL stop = false;
    for (NSInteger row = 0; !stop && row < _rowCount ; row++) {
        for (NSInteger col = 0; !stop && col < _columnCount ; col++) {
            NSInteger cellIndex = row * _columnCount + col;
            NSView *cellView = [_cellViewCached objectAtIndex:cellIndex];
            if (cellView != nullView) {
                block(cellView, cellIndex, &stop);
            }
        }
    }
}

- (void)_updateLayout
{
    _needReloadLayout = NO;
    _rowCount = _dataSource ? ([_dataSource respondsToSelector:@selector(tableViewDataSourceRowCount:)] ? [_dataSource tableViewDataSourceRowCount:self] : 0) : 0;
    _columnCount = _dataSource ? ([_dataSource respondsToSelector:@selector(tableViewDataSourceColumnCount:)] ? [_dataSource tableViewDataSourceColumnCount:self] : 0) : 0;
    _view.frame = NSMakeRect(0, 0, _columnCount * _cellWidth, _rowCount * _cellHeight);
    [self.documentView scrollPoint:NSMakePoint(0, NSMaxY(_view.frame) - NSHeight(self.contentView.bounds))];
}

- (void)_updateData
{
    _needReloadData = NO;
    NSView *nullValue = (NSView*) [NSNull null];
    for (NSView *cellView in _cellViewCached) {
        if (cellView != nullValue) {
            cellView.frame = NSMakeRect(0, 0, 0, 0);
        }
    }
    [_cellViewCached removeAllObjects];
    [_cellImageCached removeAllObjects];
    for (NSInteger row = 0; row < _rowCount ; row++) {
        for (NSInteger col = 0; col < _columnCount ; col++) {
            [_cellViewCached addObject:nullValue];
            [_cellImageCached addObject:nullValue];
        }
    }
}

-(void) scrollWheel:(NSEvent *)theEvent
{
    [super scrollWheel:theEvent];
    @autoreleasepool {
        [self _updateLayoutIfNeeded];
        [self _updateDataIfNeeded];
        [self _updateViews];
    }
}

- (void)_updateViews
{
    const CGSize boundsSize = self.bounds.size;
    const CGFloat contentOffset = -(self.documentVisibleRect.origin.y + self.documentVisibleRect.size.height - _view.frame.size.height);
    const CGRect contentView = CGRectMake(self.documentVisibleRect.origin.x, contentOffset, boundsSize.width, boundsSize.height);
    NSView *nullView = (NSView*) [NSNull null];
    if(false){
        for (NSInteger row = 0; row < _rowCount ; row++) {
            CGRect rowRect = [self rectForRow:row];
            if (CGRectIntersectsRect(rowRect, contentView)) {
                for (NSInteger col = 0; col < _columnCount ; col++) {
                    CGRect cellRect = [self rectForCell:row at:col];
                    if (!CGRectIntersectsRect(cellRect, contentView)) {
                        NSInteger cellIndex = row * _columnCount + col;
                        NSImageView *cellView = _cellImageCached[cellIndex];
                        if (cellView != nullView) {
                            cellView.alphaValue = 0.0;
                            [_cellViewReused addObject:cellView];
                            _cellViewCached[cellIndex] = nullView;
//                            NSLog(@"Adding: %ld with count: %ld", row, _cellViewReused.count);
                        }
                    }
                }
            } else {
                for (NSInteger col = 0; col < _columnCount ; col++) {
                    NSInteger cellIndex = row * _columnCount + col;
                    NSImageView *cellView = _cellViewCached[cellIndex];
                    if (cellView != nullView) {
                        cellView.alphaValue = 0.0;
                        [_cellViewReused addObject:cellView];
                        _cellViewCached[cellIndex] = nullView;
//                        NSLog(@"Adding: %ld with count: %ld", row, _cellViewReused.count);
                    }
                }
            }
        }
    }
    {
        NSInteger low = -1, high = _rowCount;
        while (low + 1 != high) {
            NSInteger mid = (low + high) >> 1;
            if (mid * _cellHeight < contentOffset) {
                low = mid;
            }
            else {
                high = mid;
            }
        }
        low = MAX(0, high - 2);
        high = MIN(low + contentView.size.height / _cellHeight + 2, _rowCount);
        for (NSInteger row = low; row < high ; row++) {
            CGRect rowRect = [self rectForRow:row];
            if (CGRectIntersectsRect(rowRect, contentView)) {
                for (NSInteger col = 0; col < _columnCount ; col++) {
                    CGRect cellRect = [self rectForCell:row at:col];
                    if (CGRectIntersectsRect(cellRect, contentView)) {
                        cellRect = [self rectFromModelToView:cellRect];
                        NSInteger cellIndex = row * _columnCount + col;
                        NSImageView *cellView = _cellViewCached[cellIndex];
                        if (cellView == nullView) {
                            NSImageView *reusedView = [self getCellViewReused];
                            NSView *view = [_dataSource tableViewDataSource:self atRow:row atColumn:col reusedCellView:_cellView withFrame:cellRect isSelected:false];
                            if (!reusedView) {
                                reusedView = [[NSImageView alloc] initWithFrame:cellRect];
                                NSImage* image = [[NSImage alloc] initWithSize:cellRect.size];
                                [image lockFocus];
                                [view drawRect:NSMakeRect(0, 0, cellRect.size.width, cellRect.size.height)];
                                [image unlockFocus];
                                reusedView.image = image;
                                [_view addSubview:reusedView];
                            } else {
                                reusedView.alphaValue = 1.0;
                                [reusedView.image lockFocus];
                                [[NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] setFill];
                                [view drawRect:NSMakeRect(0, 0, cellRect.size.width, cellRect.size.height)];
                                [reusedView.image unlockFocus];
                            }
                            reusedView.frame = cellRect;
                            _cellViewCached[cellIndex] = reusedView;
                        }
                    }
                }
            }
        }
    }
}

- (NSImageView*)getCellViewReused
{
    if (_cellViewReused.count == 0) {
        return nil;
    }
    NSImageView *view = _cellViewReused.lastObject;
    [_cellViewReused removeLastObject];
    return view;
}

- (void)reloadData
{
    _needReloadLayout = true;
    _needReloadData = true;
    [self layout];
}

- (void)_updateLayoutIfNeeded
{
    if (_needReloadLayout || CGSizeEqualToSize(_size, self.frame.size)) {
        [self _updateLayout];
    }
}

- (void)_updateDataIfNeeded
{
    if (_needReloadData) {
        [self _updateData];
    }
}

@end
