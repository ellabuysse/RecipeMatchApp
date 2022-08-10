//
//  RecipeModel.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/29/22.
//

#import <UIKit/UIKit.h>
#import "JSONModel/JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RecipeContainerModel @end

@interface RecipeModel : JSONModel
@property (nonatomic) NSString *uri;
@property (nonatomic) NSString *label;
@property (nonatomic) NSString *image;
@property (nonatomic) NSString *source;
@property (nonatomic) NSString *url;
@property (nonatomic) NSInteger yield;
@property (nonatomic) NSArray *ingredientLines;
@property (nonatomic) NSArray *ingredients;
@property (nonatomic) NSInteger calories;
@end

@interface RecipeContainerModel : JSONModel
@property RecipeModel *recipe;
@end

@interface AllRecipesModel : JSONModel
@property (nonatomic) NSMutableArray <RecipeContainerModel *> <RecipeContainerModel> *hits;
@property (nonatomic) int count;
@end

NS_ASSUME_NONNULL_END
