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

+ (nonnull NSString *)parseClassName {
    return @"LikedRecipe";
}

+ (void)postLikedRecipe:( NSString * _Nullable )title withId: ( NSString * _Nullable )recipeId withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    
    LikedRecipe *newRecipe = [LikedRecipe new];
    newRecipe.name = title;
    newRecipe.recipeId = recipeId;
    
    [newRecipe saveInBackgroundWithBlock: completion];
}

@end
