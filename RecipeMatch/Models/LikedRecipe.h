//
//  LikedRecipe.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/15/22.
//

#import <Foundation/Foundation.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface LikedRecipe : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *recipeId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic,strong)NSString *image;
@property (nonatomic, strong) PFUser *user;
@end

NS_ASSUME_NONNULL_END
