//
//  APIManager.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//
#import "BDBOAuth1SessionManager.h"
#import "SavedRecipe.h"
#import "RecipeModel.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : BDBOAuth1SessionManager
+ (instancetype)shared;
- (void)getRecipesWithPreferences:(NSString * _Nullable)preferences andCompletion:(void (^)(NSMutableArray *recipe, NSError *error))completion;
- (NSURLSessionDataTask *)getRecipesWithQuery:(NSString * _Nullable)preferences andCompletion: (void (^)(NSMutableArray *recipe, NSError *error))completion;
- (void)getRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(RecipeModel *recipe, NSError *error))completion;
+ (void)unsaveRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion;
+ (void)unlikeRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion;
+ (void)postSavedRecipeWithId:recipeId title:( NSString * _Nullable )title image:(NSString * _Nullable )image andCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void)fetchSavedRecipes:(void (^)(NSArray *, NSError *))completion;
+ (void)checkIfRecipeIsAlreadySavedWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion;
+ (void)checkIfRecipeIsAlreadyLikedWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion;
+ (void)countLikesWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(int likes, NSError *error))completion;
+ (void)postLikedRecipeWithId:recipeId title:(NSString * _Nullable)title image: (NSString * _Nullable )image andCompletion:(PFBooleanResultBlock  _Nullable)completion;
+ (void)countSavesWithId:( NSString * _Nullable )recipeId andCompletion:(void (^)(int likes, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
