//
//  Recipe.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/6/22.
//

#import "Recipe.h"

@implementation Recipe
@dynamic recipeId;
@dynamic name;
@dynamic image;
@dynamic ingredients;
@dynamic cuisineType;
@dynamic mealType;
@dynamic dishType;

+ (nonnull NSString *)parseClassName {
    return @"Recipe";
}

+ (void) postRecipe: ( NSString * _Nullable )title withId: ( NSString * _Nullable )recipeId withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Recipe *newRecipe = [Recipe new];
    newRecipe.name = title;
    newRecipe.recipeId = recipeId;
    
    [newRecipe saveInBackgroundWithBlock: completion];
}



@end
