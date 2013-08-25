//
//  SMDemoViewController.m
//  SMMoreOptionsCell
//
//  Created by Richard Marktl on 23.08.13.
//  Copyright (c) 2013 Sonico GmbH. All rights reserved.
//

#import "SMDemoViewController.h"
#import "SMDemoCell.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static NSString *Identifier = @"Identifier";


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMDemoViewController () <SMMoreOptionsDelegate> {
    NSMutableArray *_data;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SMDemoViewController


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.title = @"Demo";
        _data = [NSMutableArray array];
        // generate demo data

        for ( NSString *font in [UIFont familyNames] ) {
            for ( NSString *name in [UIFont fontNamesForFamilyName:font] ) {
                [_data addObject:name];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setRowHeight:64.0f];
    [self.tableView registerClass:[SMDemoCell class] forCellReuseIdentifier:Identifier];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMDemoCell *cell = (SMDemoCell *)[tableView dequeueReusableCellWithIdentifier:Identifier];
    cell.delegate = self;
    cell.demoLabel.text = _data[indexPath.row];
    return cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:SMMoreOptionsShouldHideNotification object:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // This method is only implemented to demonstrate the didSelectRowAtIndexPath functionality
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - SMMoreOptionsDelegate

- (void)cellDidHideOptions:(SMMoreOptionsCell *)cell {
    // add here your source for optional behaviour
    NSLog(@"cellDidHideOptions");
}

- (void)cellDidShowOptions:(SMMoreOptionsCell *)cell {
    // add here your source for optional behaviour
    NSLog(@"cellDidShowOptions");
}

- (void)didTouchOnDelete:(SMDemoCell *)cell {
    NSInteger row = [_data indexOfObject:cell.demoLabel.text];
    [_data removeObjectAtIndex:row];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didTouchOnMore:(SMDemoCell *)cell {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:cell.demoLabel.text
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
