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
    [self.imageView sd_cancelCurrentImageLoad];
    self.recipeTitle.text = @"";
    [self.searchImageView sd_cancelCurrentImageLoad];
    self.searchRecipeTitle.text = @"";
}

- (void)setupWithRecipe:(SavedRecipe *)recipe {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:recipe.image] placeholderImage:nil];
    self.imageView.layer.cornerRadius = CORNER_RADIUS;
    self.recipeTitle.text = recipe.name;
}

- (void)searchSetupWithRecipe:(NSDictionary *)recipe {
    [self.searchImageView sd_setImageWithURL:[NSURL URLWithString:recipe[@"image"]] placeholderImage:nil];
    self.searchImageView.layer.cornerRadius = CORNER_RADIUS;
    self.searchRecipeTitle.text = recipe[@"label"];
}
@end
