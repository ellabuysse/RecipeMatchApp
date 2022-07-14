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

@end

NS_ASSUME_NONNULL_END
