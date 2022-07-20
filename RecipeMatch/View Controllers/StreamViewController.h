//
//  StreamViewController.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "PreferencesViewController.h"
#import "DraggableViewBackground.h"

NS_ASSUME_NONNULL_BEGIN
@interface StreamViewController : UIViewController <PreferencesViewControllerDelegate, DraggableViewBackgroundDelegate>

- (void)checkLikeStatusFromDraggableViewBackground:(DraggableView *)nextCard withCompletion:(void (^)(BOOL liked, NSError *error))completion;
- (void)postSavedRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId title:( NSString * _Nullable )title image: (NSString * _Nullable)image andCompletion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion;
- (void)postLikedRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId recipeTitle:(NSString * _Nullable)title image: (NSString * _Nullable)image andCompletion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion;
- (void)unlikeRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId andCompletion: (void (^_Nullable)(BOOL succeeded, NSError *_Nullable error))completion;
- (void)countLikesFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId andCompletion: (void (^_Nullable)(int likes, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
