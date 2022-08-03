//
//  GridRecipeCell.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "SavedRecipe.h"
#import "SDWebImage/SDWebImage.h"
#import "RecipeModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GridRecipeCellType) {
    GridRecipeCellTypeProfile,
    GridRecipeCellTypeSearch,
};

@interface GridRecipeCell : UICollectionViewCell
@property (weak, nonatomic) UILabel *recipeTitle;
@property (weak, nonatomic) UIImageView *imageView;

- (void)setupWithRecipeTitle:(NSString *)recipeTitle recipeImageUrl:(NSString *)recipeImageURl cellType:(GridRecipeCellType)cellType;
@end

NS_ASSUME_NONNULL_END
