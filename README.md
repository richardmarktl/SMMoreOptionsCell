SMMoreOptionsCell
=================

A more options cell implementation, as seen in the Mail app on iOS7.

- The implementation is not blocking the UITableView row selection functionality.
- The implementations supports customizing of the delete and more button.

For more information look at the SMMoreOptionsCell.xcodeproj it contains a demo project.

## Delegate

```objective-c
@protocol SMMoreOptionsDelegate <NSObject>
@required
- (void)didTouchOnDelete:(SMMoreOptionsCell *)cell;
- (void)didTouchOnMore:(SMMoreOptionsCell *)cell;

@optional
- (void)cellDidHideOptions:(SMMoreOptionsCell *)cell;
- (void)cellDidShowOptions:(SMMoreOptionsCell *)cell;

@end
```


## Integration

1. Copy the SMMoreOptionsCell source files in your project.
2. Add frameworks (UIKit.framework, CoreGraphics.framework, Founddation.framework)

### Usage

**The Table Cell .h file**
```objective-c
	@interface SMDemoCell : SMMoreOptionsCell

	@property (nonatomic, strong) UILabel *demoLabel;

	@end
```	

**The Table Cell .m file**	
```objective-c
// Usage: Add your view content to the scrollViewContentView.

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    	// Add here your stuff
        _demoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	    [self.scrollViewContentView addSubview:_demoLabel];
   	}
	return self;
}
```	

**View Controller**:
```objective-c
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

// required methods 
- (void)didTouchOnDelete:(SMDemoCell *)cell {
	// add your source code
}

- (void)didTouchOnMore:(SMDemoCell *)cell {
	// add your source code
}
```

## License

The SMMoreOptionsCell is available under the MIT license. See the LICENSE file for more info.