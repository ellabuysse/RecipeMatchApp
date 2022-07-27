//
//  GridRecipeCell.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "SavedRecipe.h"
#import "SDWebImage/SDWebImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GridRecipeCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *recipeTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)setupWithRecipe:(SavedRecipe *)recipe;
@end

NS_ASSUME_NONNULL_END
