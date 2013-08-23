//
//  SMDemoCell.m
//  SMMoreOptionsCell
//
//  Created by Richard Marktl on 23.08.13.
//  Copyright (c) 2013 Sonico GmbH. All rights reserved.
//

#import "SMDemoCell.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SMDemoCell


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _demoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.scrollViewContentView addSubview:_demoLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _demoLabel.frame = CGRectInset(self.scrollViewContentView.bounds, 10.0f, 0.0f);
}

@end
