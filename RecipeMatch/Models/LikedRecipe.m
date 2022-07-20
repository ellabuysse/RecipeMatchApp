//
//  LikedRecipe.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/15/22.
//

#import "LikedRecipe.h"
@import Parse;

@implementation LikedRecipe
@dynamic recipeId;
@dynamic name;
@dynamic image;
@dynamic username;

+ (nonnull NSString *)parseClassName {
    return @"LikedRecipe";
}
@end
