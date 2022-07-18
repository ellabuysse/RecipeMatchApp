//
//  Recipe.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//

#import "SavedRecipe.h"
@import Parse;

@implementation SavedRecipe
@dynamic recipeId;
@dynamic name;
@dynamic image;
@dynamic username;

+ (nonnull NSString *)parseClassName {
    return @"SavedRecipe";
}

@end
