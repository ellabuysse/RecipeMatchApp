//
//  GridRecipeCell.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import "GridRecipeCell.h"
#import "UIKit+AFNetworking.h"

@implementation GridRecipeCell
static const float CORNER_RADIUS = 15;

// clears image and title of cell
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView cancelImageDownloadTask];
    self.imageView.image = NULL;
    self.recipeTitle.text = @"";
}

- (void)setupWithRecipe:(SavedRecipe *)recipe {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:recipe.image] placeholderImage:[UIImage systemImageNamed:@"photo"]];
    self.imageView.layer.cornerRadius = CORNER_RADIUS;
    self.recipeTitle.text = recipe.name;
}
@end
