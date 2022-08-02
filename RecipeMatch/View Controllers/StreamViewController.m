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

@interface StreamViewController()
@property (nonatomic, strong) NSMutableArray *preferences;
@property (nonatomic, strong) DraggableViewBackground *draggableBackground;
@end

@implementation StreamViewController
static const float TITLE_WIDTH = 100;
static const float TITLE_HEIGHT = 40;

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
}

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

// called when there are not enought recipes from user preferences
// removes preferences one by one until enough recipes are found
- (void)handlePreferencesWithCompletion:(void (^)(NSArray *recipes, NSError *error))completion {
    if ([self.preferences count] > 0) {
        [self.preferences removeLastObject];
    }
    [self getRecipesWithPreferencesWithCompletion:^(NSArray *recipes, NSError *error) {
        if (recipes) {
            completion(recipes, nil);
        } else {
            completion(nil, error);
        }
    }];
}

- (void)getRecipesWithPreferencesWithCompletion:(void (^)(NSArray *recipes, NSError *error))completion {
    NSString *preferencesString = [self.preferences componentsJoinedByString:@""];
    [[APIManager shared] getRecipesWithPreferences:preferencesString andCompletion: ^(NSMutableArray *recipes, NSError *error) {
        if (recipes) {
            completion(recipes, nil);
        } else {
            // not enough recipes with preferences
            [self handlePreferencesWithCompletion:^(NSArray *recipes, NSError *error){
                if (recipes) {
                    completion(recipes,nil);
                } else {
                    completion(nil, error);
                }
            }];
        }
    }];
}

// called by PreferencesViewController to get user preferences
- (void)sendData:(NSMutableArray *)prefRequest {
    // check that preferences aren't empty
    if ([prefRequest count] > 0) {
        self.preferences = prefRequest;
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
    }
    if ([[segue identifier] isEqualToString:@"detailsViewSegue"]) {
        // make saved recipe object (but don't save) for DetailsViewController
        DraggableView *recipe = (DraggableView *)sender;
        DetailsViewController *detailsController = [segue destinationViewController];
        detailsController.recipeId = recipe.recipeId;
    }
}
@end
