//
//  StreamViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/6/22.
//

#import "StreamViewController.h"
#import "Parse/Parse.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "DraggableViewBackground.h"
#import "APIManager.h"
#import "DetailsViewController.h"
#import "RecipeModel.h"
#import "PreferencesViewController.h"

@interface StreamViewController()
@property (nonatomic, strong) NSMutableDictionary *preferencesDict;
@property (nonatomic, strong) NSString *preferencesString;
@property (nonatomic, strong) DraggableViewBackground *draggableBackground;
@end

@implementation StreamViewController
static const float TITLE_WIDTH = 100;
static const float TITLE_HEIGHT = 40;
NSString* const CUISINE_KEY = @"cuisineType";
NSString* const HEALTH_KEY = @"health";
NSString* const DIET_KEY = @"diet";
NSString* const MEAL_TYPE_KEY = @"mealType";
NSString* const CALORIES_KEY = @"calories";

- (void)viewDidLoad {
    [super viewDidLoad];
    // setup top nav bar
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TITLE_WIDTH, TITLE_HEIGHT)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];
    self.navigationItem.titleView = titleView;
    [self setupCards];
    self.preferencesDict = [[NSMutableDictionary alloc] init];}

// called after returning from PreferencesViewController
- (void)viewDidAppear:(BOOL)animated {
    [self.draggableBackground updateValues];
}

- (void)setupCards {
    // show spinner when waiting for recipes to load
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    spinner.center = CGPointMake(self.view.center.x, self.view.center.y);
    [self.view addSubview:spinner];
    [spinner startAnimating];
    [self getRecipesWithPreferencesWithCompletion:^(NSArray *recipes, NSError * _Nullable error){
        if (recipes) {
            self.draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
            self.draggableBackground.delegate = self;
            self.draggableBackground.recipes = [NSMutableArray arrayWithArray:recipes];
            [self.draggableBackground reloadView];
            [self.view addSubview:self.draggableBackground];
        } else {
            //TODO: Add failure support
        }
    }];
}

- (void)showAlert {
    UIAlertController *recipeFailure= [UIAlertController alertControllerWithTitle:@"Uh oh!" message:@"Ran out of results with these preferences! Showing recipes that match most of your preferences." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
    [recipeFailure addAction:okAction];
    [self presentViewController:recipeFailure animated:YES completion:^{}];
}

// called when there are not enought recipes from user preferences
// removes preferences one by one until enough recipes are found
- (void)handlePreferencesWithCompletion:(void (^)(NSArray *recipes, NSError *error))completion {
    if ([self.preferencesDict objectForKey:MEAL_TYPE_KEY]) {
        [self.preferencesDict removeObjectForKey:MEAL_TYPE_KEY];
    } else if ([self.preferencesDict objectForKey:DIET_KEY]) {
        [self.preferencesDict removeObjectForKey:DIET_KEY];
    } else if ([self.preferencesDict objectForKey:HEALTH_KEY]) {
        [self.preferencesDict removeObjectForKey:HEALTH_KEY];
    }
    
    [self showAlert];
    [self getRecipesWithPreferencesWithCompletion:^(NSArray *recipes, NSError *error) {
        if (recipes) {
            completion(recipes, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)addPreferenceToStringWithKey:(NSString *)key {
    NSString *object = [self.preferencesDict objectForKey:key];
    if (object) {
        NSString *preference = [NSString stringWithFormat: @"&%@=%@", key, object];
        self.preferencesString = [self.preferencesString stringByAppendingString:preference];
    }
}

- (void)convertPreferencesDictToString {
    self.preferencesString = @"";
    [self addPreferenceToStringWithKey: CUISINE_KEY];
    [self addPreferenceToStringWithKey: DIET_KEY];
    [self addPreferenceToStringWithKey: HEALTH_KEY];
    [self addPreferenceToStringWithKey: MEAL_TYPE_KEY];
    [self addPreferenceToStringWithKey: CALORIES_KEY];
}

- (void)getRecipesWithPreferencesWithCompletion:(void (^)(NSArray *recipes, NSError *error))completion {
    [self convertPreferencesDictToString];
    [[APIManager shared] getRecipesWithPreferences:self.preferencesString andCompletion: ^(NSMutableArray *recipes, NSError *error) {
        if (recipes) {
            completion(recipes, nil);
        } else {
            // not enough recipes with preferences
            [self handlePreferencesWithCompletion:^(NSArray *recipes, NSError *error){
                if (recipes) {
                    completion(recipes, nil);
                } else {
                    completion(nil, error);
                }
            }];
        }
    }];
}

#pragma mark - PreferencesViewController method

- (void)sendPreferences:(NSMutableDictionary *)preferences {
    // check that there are new preferences before reloading
    if (![preferences isEqualToDictionary:self.preferencesDict]) {
        self.preferencesDict = preferences;
        [self.draggableBackground removeFromSuperview];
        [self setupCards];
    }
}

#pragma mark - DraggableViewBackground methods

- (void)checkLikeStatusFromDraggableViewBackground:(DraggableView *)nextCard withCompletion:(void (^)(BOOL liked, NSError *error))completion {
    [APIManager checkIfRecipeIsAlreadyLikedWithId:nextCard.recipeId andCompletion:^(BOOL liked, NSError * _Nullable error) {
        if (liked == YES) {
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

- (void)checkSaveStatusFromDraggableViewBackground:(DraggableView *)nextCard withCompletion:(void (^)(BOOL liked, NSError *error))completion {
    [APIManager checkIfRecipeIsAlreadySavedWithId:nextCard.recipeId andCompletion:^(BOOL saved, NSError * _Nullable error) {
        if (saved == YES) {
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

- (void)postLikedRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId recipeTitle:(NSString * _Nullable)title image: (NSString * _Nullable)image andCompletion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion {
    [APIManager postLikedRecipeWithId:recipeId title:title image:image andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

- (void)unlikeRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId andCompletion:(void (^_Nullable)(BOOL succeeded, NSError *_Nullable error))completion {
    [APIManager unlikeRecipeWithId:recipeId andCompletion:^(BOOL succeeded, NSError * _Nonnull error) {
        if (succeeded) {
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

- (void)postSavedRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId title:( NSString * _Nullable )title image: (NSString * _Nullable)image andCompletion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion {
    [APIManager postSavedRecipeWithId:recipeId title:title image:image andCompletion:^(BOOL succeeded, NSError * _Nullable error) {}];
}

- (void)countLikesFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId andCompletion: (void (^_Nullable)(int likes, NSError * _Nullable error))completion {
    [APIManager countLikesWithId:recipeId andCompletion:^(int likes, NSError * _Nullable error) {
        completion(likes, nil);
    }];
}

- (void)countSavesFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId andCompletion: (void (^_Nullable)(int likes, NSError * _Nullable error))completion {
    [APIManager countSavesWithId:recipeId andCompletion:^(int likes, NSError * _Nullable error) {
        completion(likes, nil);
    }];
}

- (void)showDetailsFromDraggableViewBackground:(DraggableView *_Nonnull)card {
    [self performSegueWithIdentifier:@"detailsViewSegue" sender:card];
}

- (void)getMoreRecipesFromDraggableViewBackgroundWithCompletion:(void (^_Nullable)(BOOL succeeded, NSError *_Nullable error))completion {
    [self getRecipesWithPreferencesWithCompletion:^(NSArray *recipes, NSError * _Nullable error){
        if (recipes) {
            self.draggableBackground.recipes = (NSMutableArray*)recipes;
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"preferencesViewSegue"]) {
        PreferencesViewController *preferencesController = [segue destinationViewController];
        preferencesController.delegate = self;
        preferencesController.preferencesDict = [NSMutableDictionary dictionaryWithDictionary:self.preferencesDict];
    }
    if ([[segue identifier] isEqualToString:@"detailsViewSegue"]) {
        // make saved recipe object (but don't save) for DetailsViewController
        DraggableView *recipe = (DraggableView *)sender;
        DetailsViewController *detailsController = [segue destinationViewController];
        detailsController.recipeId = recipe.recipeId;
    }
}
@end
