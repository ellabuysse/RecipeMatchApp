//
//  GridRecipeCell.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import "GridRecipeCell.h"
#import "UIKit+AFNetworking.h"

@implementation GridRecipeCell

// clear image and title of cell
-(void)prepareForReuse{
    [super prepareForReuse];
    [self.imageView cancelImageDownloadTask];
    self.imageView.image = NULL;
    self.recipeTitle.text = @"";
}

@end
