//
//  RecipeModel.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/29/22.
//

#import <UIKit/UIKit.h>
#import "JSONModel/JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecipeContainerModel;

@interface SingleRecipeModel : JSONModel
@property (nonatomic) NSString *uri;
@property (nonatomic) NSString *label;
@property (nonatomic) NSString *image;
@property (nonatomic) NSString *source;
@property (nonatomic) NSString *url;
@property (nonatomic) NSString *yield;
@property (nonatomic) NSArray *ingredientLines;
@end

@interface RecipeContainerModel : JSONModel
@property SingleRecipeModel *recipe;
@end

@interface RecipeModel : JSONModel
@property (nonatomic) NSArray <RecipeContainerModel *> <RecipeContainerModel> *hits;
@property (nonatomic) int count;
@end

NS_ASSUME_NONNULL_END
