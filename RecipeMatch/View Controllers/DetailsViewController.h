//
//  DetailsViewController.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "LikedRecipe.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property (strong, nonatomic) LikedRecipe *likedRecipe;
@end

NS_ASSUME_NONNULL_END
