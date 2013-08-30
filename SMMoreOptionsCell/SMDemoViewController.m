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
static NSString *IdentifierOne = @"IdentifierOne";
static NSString *IdentifierTwo = @"IdentifierTwo";

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface SMDemoViewController () <SMMoreOptionsDelegate> {
    NSMutableArray *_data;
    SMMoreOptionsCell *_cell;
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
    [self.tableView registerClass:[SMDemoCell class] forCellReuseIdentifier:IdentifierOne];
    [self.tableView registerClass:[SMDemoCell class] forCellReuseIdentifier:IdentifierTwo];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                          target:self
                                                                          action:@selector(_touchOnEdit:)];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
}

- (NSString *)identiferForIndexPath:(NSIndexPath *)path {
   if ( (path.row % 3) == 1) {
       return IdentifierOne;
    } else if ( (path.row % 3) == 2) {
        return IdentifierTwo;
    }
    return Identifier;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifer = [self identiferForIndexPath:indexPath];
    SMDemoCell *cell = (SMDemoCell *)[tableView dequeueReusableCellWithIdentifier:identifer];
    cell.delegate = self;
    cell.demoLabel.text = _data[indexPath.row];
    
    if ( identifer == IdentifierOne ) {  // 1. Sample set your own costum buttons
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:NSLocalizedString(@"Custom", @"") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor blueColor]];
        [button setAdjustsImageWhenHighlighted:YES];
        [button.titleLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];
        cell.deleteButton = button;
        
        UIButton *checkedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [checkedButton setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0f]];
        [checkedButton setAdjustsImageWhenHighlighted:YES];
        [checkedButton.titleLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];
        [checkedButton setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        cell.moreButton = checkedButton;
    } else if ( identifer == IdentifierTwo ) { // 2. Sample set your costum view
        UILabel *costumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        costumLabel.backgroundColor = [UIColor lightGrayColor];
        costumLabel.text = @" A custom view. ";
        cell.scrollViewOptionsView = costumLabel;
    }
    
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
    _cell = cell;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_cell dismissOptionsAnimated:YES];
    _cell = nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action Methods

- (void)_touchOnEdit:(UIBarButtonItem *)item {
    [self setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_touchOnCancel:)];
}

- (void)_touchOnCancel:(UIBarButtonItem *)item {
    [self setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(_touchOnEdit:)];
}



@end
