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

// clears image and title of cell
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView cancelImageDownloadTask];
    self.imageView.image = NULL;
    [self.imageView sd_cancelCurrentImageLoad];
    self.recipeTitle.text = @"";
}

// sets up cell for profile page
- (void)setupWithRecipeFromProfile:(SavedRecipe *)recipe {
    // set outlets programmatically
    self.imageView = (UIImageView *)[self viewWithTag:1];
    self.recipeTitle = (UILabel *)[self viewWithTag:2];

    [self.imageView sd_setImageWithURL:[NSURL URLWithString:recipe.image] placeholderImage:nil];
    self.imageView.layer.cornerRadius = CORNER_RADIUS;
    self.recipeTitle.text = recipe.name;
}

// sets up cell for search page
- (void)setupWithRecipeFromSearch:(NSDictionary *)recipe {
    self.imageView = (UIImageView *)[self viewWithTag:3];
    self.recipeTitle = (UILabel *)[self viewWithTag:4];

    [self.imageView sd_setImageWithURL:[NSURL URLWithString:recipe[@"image"]] placeholderImage:nil];
    self.imageView.layer.cornerRadius = CORNER_RADIUS;
    self.recipeTitle.text = recipe[@"label"];
}
@end
