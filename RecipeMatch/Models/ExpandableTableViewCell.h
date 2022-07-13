//
//  ExpandableTableViewCell.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExpandableTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *rowName;
@property (strong, nonatomic) IBOutlet UILabel *fruitName;

@end

NS_ASSUME_NONNULL_END
