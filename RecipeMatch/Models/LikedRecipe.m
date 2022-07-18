//
//  Recipe.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//

#import "LikedRecipe.h"
@import Parse;

@implementation LikedRecipe
@dynamic recipeId;
@dynamic name;
@dynamic image;
@dynamic user;

+ (nonnull NSString *)parseClassName {
    return @"LikedRecipe";
}

@end
