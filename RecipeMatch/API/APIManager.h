//
//  APIManager.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//
#import "BDBOAuth1SessionManager.h"
#import "SavedRecipe.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : BDBOAuth1SessionManager
+ (instancetype)shared;

- (void)getRecipesWithPreferences:( NSString * _Nullable )preferences andCompletion: (void (^)(NSMutableArray *recipe, NSError *error))completion;
- (void)getRecipeWithId:( NSString * _Nullable )recipeId andCompletion: (void (^)(NSDictionary *recipe, NSError *error))completion;
+ (void)unsaveRecipeWithId:( NSString * _Nullable )recipeId andCompletion: (void (^)(NSArray *recipes, NSError *error))completion;
+ (void)postSavedRecipeWithTitle:( NSString * _Nullable )title andId: ( NSString * _Nullable )recipeId andImage: (NSString * _Nullable )image andCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void) fetchSavedRecipes:(void (^)(NSArray *, NSError *))completion;
+(void)checkIfSavedWithId:( NSString * _Nullable )recipeId andCompletion: (void (^)(BOOL succeeded, NSError *error))completion;
+ (void)manageLikeWithTitle:( NSString * _Nullable )title andId: ( NSString * _Nullable )recipeId andImage: (NSString * _Nullable )image andCompletion: (PFBooleanResultBlock  _Nullable)completion;
+(void)checkIfLikedWithId:( NSString * _Nullable )recipeId andCompletion: (void (^)(BOOL succeeded, NSError *error))completion;
+(void)countLikesWithId:( NSString * _Nullable )recipeId andCompletion: (void (^)(int likes, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
