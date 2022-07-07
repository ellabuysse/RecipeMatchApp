//
//  Recipe.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/6/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Recipe : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *recipeId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *ingredients;
@property (nonatomic, strong) NSString *cuisineType;
@property (nonatomic, strong) NSString *mealType;
@property (nonatomic, strong) NSString *dishType;

+ (void) postRecipe: ( NSString * _Nullable )title withId: ( NSString * _Nullable )recipeId withCompletion: (PFBooleanResultBlock  _Nullable)completion;
    
@end

NS_ASSUME_NONNULL_END
