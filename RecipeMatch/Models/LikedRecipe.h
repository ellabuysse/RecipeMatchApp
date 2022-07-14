//
//  Recipe.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface LikedRecipe : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *recipeId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic,strong)NSString *image;
@property (nonatomic, strong) PFUser *user;

+ (void)postLikedRecipe:( NSString * _Nullable )title withId: ( NSString * _Nullable )recipeId withImage: (NSString * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion;
  
@end

NS_ASSUME_NONNULL_END
