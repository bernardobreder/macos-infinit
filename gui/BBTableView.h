//
//  BBTableView.h
//  gui
//
//  Created by Bernardo Breder on 28/03/15.
//  Copyright (c) 2015 Breder Window. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BBTableView;

@protocol BBTableDataSource <NSObject>

- (NSInteger)tableViewDataSourceRowCount:(BBTableView*)tableView;

- (NSInteger)tableViewDataSourceColumnCount:(BBTableView*)tableView;

- (NSView*)tableViewDataSource:(BBTableView*)tableView atRow:(NSInteger)row atColumn:(NSInteger)column reusedCellView:(NSView*)reusedCellView withFrame:(NSRect)frame isSelected:(BOOL)selected;

@end

@interface BBTableView : NSScrollView

@property (nonatomic, weak) id<BBTableDataSource> dataSource;

@property (nonatomic, assign) NSInteger cellWidth;

@property (nonatomic, assign) NSInteger cellHeight;

- (instancetype)initWithFrame:(NSRect)frame dataSource:(id<BBTableDataSource>)dataSource;

- (void)enumerateCellsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;

- (void)reloadData;

- (CGRect)rectForRow:(NSInteger)row;

- (CGRect)rectForCell:(NSInteger)row at:(NSInteger)column;

@end
