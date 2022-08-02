//
//  GridRecipeCell.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import "GridRecipeCell.h"
#import "UIKit+AFNetworking.h"
#import "SDWebImage/SDWebImage.h"

@implementation GridRecipeCell
static const float CORNER_RADIUS = 15;
static const int PROFILE_IMAGE_TAG = 1;
static const int SEARCH_IMAGE_TAG = 3;
static const int PROFILE_TITLE_TAG = 2;
static const int SEARCH_TITLE_TAG = 4;

// clears image and title of cell
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView cancelImageDownloadTask];
    self.imageView.image = NULL;
    [self.imageView sd_cancelCurrentImageLoad];
    self.recipeTitle.text = @"";
}

- (void)setupWithRecipeTitle:(NSString *)recipeTitle recipeImageUrl:(NSString *)recipeImageURl cellType:(GridRecipeCellType)cellType {
    self.imageView = (UIImageView *)[self viewWithTag:(cellType == GridRecipeCellTypeProfile)?PROFILE_IMAGE_TAG:SEARCH_IMAGE_TAG];
    self.recipeTitle = (UILabel *)[self viewWithTag:(cellType == GridRecipeCellTypeProfile)?PROFILE_TITLE_TAG:SEARCH_TITLE_TAG];

    [self.imageView sd_setImageWithURL:[NSURL URLWithString:recipeImageURl] placeholderImage:nil];
    self.imageView.layer.cornerRadius = CORNER_RADIUS;
    self.recipeTitle.text = recipeTitle;
}
@end
