SMMoreOptionsCell
=================

A more options cell implementation, as seen in the Mail.app on iOS7.


**Cookbook**:
	
    // .h
	@interface SMDemoCell : SMMoreOptionsCell

	@property (nonatomic, strong) UILabel *demoLabel;

	@end

	// .m
	// Usage: Add your view content to the scrollViewContentView. Done
	
	- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        	_demoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	        [self.scrollViewContentView addSubview:_demoLabel];
   		}
	    return self;
	}

