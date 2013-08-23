SMMoreOptionsCell
=================

A more options cell implementation, as seen in the Mail app on iOS7.


**UITableViewCell**:
	
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

**View Controller**:

	- (void)viewDidLoad {
	    ...
    	[self.tableView registerClass:[SMDemoCell class] forCellReuseIdentifier:Identifier];
    	...
    }
        
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        SMDemoCell *cell = (SMDemoCell *)[tableView dequeueReusableCellWithIdentifier:Identifier];
        cell.delegate = self;
        cell.demoLabel.text = _data[indexPath.row];
        return cell;
    }
        
    - (void)didTouchOnDelete:(SMDemoCell *)cell {
		// add your source code
    }
    
    - (void)didTouchOnMore:(SMDemoCell *)cell {
		// add your source code
	}
