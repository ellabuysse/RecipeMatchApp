//
//  DetailsViewController.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "SavedRecipe.h"
#import "RecipeModel.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property (strong, nonatomic) NSString *recipeId;
@end

NS_ASSUME_NONNULL_END
