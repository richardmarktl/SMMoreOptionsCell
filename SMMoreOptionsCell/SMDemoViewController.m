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
    if ( (indexPath.row % 3) == 1) {  // 1. Sample set your own costum buttons
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:NSLocalizedString(@"Costum", @"") forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor blueColor]];
        [button setAdjustsImageWhenHighlighted:YES];
        [button.titleLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];
        cell.deleteButton = button;
        
        UIButton *checkedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [checkedButton setBackgroundColor:[UIColor whiteColor]];
        [checkedButton setAdjustsImageWhenHighlighted:YES];
        [checkedButton.titleLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];
        [checkedButton setImage:[UIImage imageNamed:@"checked"] forState:UIControlStateNormal];
        cell.moreButton = checkedButton;
    } else if ( (indexPath.row % 3) == 2) { // 2. Sample set your costum view
        UILabel *costumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        costumLabel.backgroundColor = [UIColor lightGrayColor];
        costumLabel.text = @"A nice custom view.";
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
}

@end
