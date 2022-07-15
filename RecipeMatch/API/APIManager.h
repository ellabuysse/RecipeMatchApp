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

- (void)getRecipes:( NSString * _Nullable )preferences withCompletion: (void (^)(NSMutableArray *recipe, NSError *error))completion;
- (void)getIdRecipe:( NSString * _Nullable )recipeId withCompletion: (void (^)(NSDictionary *recipe, NSError *error))completion;
+ (void)unsave:( NSString * _Nullable )recipeId withCompletion: (void (^)(NSArray *recipes, NSError *error))completion;
+ (void)postSavedRecipe:( NSString * _Nullable )title withId: ( NSString * _Nullable )recipeId withImage: (NSString * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (void) fetchSavedRecipes:(void (^)(NSArray *, NSError *))completion;
+(void)checkIfSaved:( NSString * _Nullable )recipeId withCompletion: (void (^)(BOOL succeeded, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
