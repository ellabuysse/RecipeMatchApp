//
//  APIManager.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//
#import "BDBOAuth1SessionManager.h"
#import "LikedRecipe.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : BDBOAuth1SessionManager
+ (instancetype)shared;

- (void)getRecipes:(void(^)(NSArray *recipes, NSError *error))completion;
+ (void)getIdRecipe:( NSString * _Nullable )recipeId withCompletion: (void (^)(NSDictionary *recipe, NSError *error))completion;
+ (void)unfavorite:( NSString * _Nullable )recipeId withCompletion: (void (^)(NSArray *recipes, NSError *error))completion;
+ (void)postLikedRecipe:( NSString * _Nullable )title withId: ( NSString * _Nullable )recipeId withImage: (NSString * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
