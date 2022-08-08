//
//  DetailsViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import "DetailsViewController.h"
#import "APIManager.h"
#import "SDWebImage/SDWebImage.h"
#import "FBSDKShareKit/FBSDKShareKit.h"
#import "IngredientTableViewCell.h"

@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *recipeTitle;
@property (weak, nonatomic) IBOutlet UIImageView *recipeImage;
@property (strong, nonatomic) NSString *recipeUrl;
@property (weak, nonatomic) IBOutlet UILabel *yield;
@property (weak, nonatomic) IBOutlet UIButton *source;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UILabel *saveCount;
@property (strong, nonatomic) RecipeModel *recipe;
@property (weak, nonatomic) IBOutlet UILabel *ingredients;
@property BOOL saved;
@property BOOL liked;
@end

@implementation DetailsViewController

NSString* const HEART_FILL_KEY = @"heart.fill";
NSString * const HEART_KEY = @"heart";
NSString* const BOOKMARK_FILL_KEY = @"bookmark.fill";
NSString * const BOOKMARK_KEY = @"bookmark";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x0075E3);
    [self setupButtons]; // start API calls to prevent excess loading time
    // wait for fullRecipe data before setting info on screen
    [self fetchFullRecipeWithCompletion:^(BOOL succeeded, NSError *error){
        [self fetchRecipeInfo];
    }];
}

// called initially to load setup like and save buttons
- (void)setupButtons {
    [self.likeBtn addTarget:self action:@selector(didTapLike:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.saveBtn addTarget:self action:@selector(didTapSave:)
         forControlEvents:UIControlEventTouchUpInside];

    // setups like button
    [APIManager checkIfRecipeIsAlreadyLikedWithId:self.recipeId andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self.likeBtn setImage:[UIImage systemImageNamed:HEART_FILL_KEY] forState:UIControlStateNormal];
            self.liked = YES;
        } else {
            [self.likeBtn setImage:[UIImage systemImageNamed:HEART_KEY] forState:UIControlStateNormal];
            self.liked = NO;
        }
    }];

    //setups save button
    [APIManager checkIfRecipeIsAlreadySavedWithId:self.recipeId andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self.saveBtn setImage:[UIImage systemImageNamed:BOOKMARK_FILL_KEY] forState:UIControlStateNormal];
            self.saved = YES;
        } else {
            [self.saveBtn setImage:[UIImage systemImageNamed:BOOKMARK_KEY] forState:UIControlStateNormal];
            self.saved = NO;
        }
    }];
    [self updateLikeCount];
    [self updateSaveCount];
}

- (void)fetchFullRecipeWithCompletion:(void (^)(BOOL succeeded, NSError *error))completion {
    [[APIManager shared] getRecipeWithId:self.recipeId andCompletion:^(RecipeModel *recipe, NSError *error) {
        if (recipe) {
            self.recipe = recipe;
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

// sets recipe details from fullRecipe
- (void)fetchRecipeInfo {
    self.recipeTitle.text = self.recipe.label;
    self.recipeTitle.layer.zPosition = 1;
    self.recipeUrl = self.recipe.url;
    [self.source setTitle:self.recipe.source forState:UIControlStateNormal];
    [self.source.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.source addTarget:self action:@selector(didTapSource:) forControlEvents:UIControlEventTouchUpInside];
    NSArray *ingrArray = self.recipe.ingredientLines;
    NSString *ingrString = (NSString *)[ingrArray componentsJoinedByString:@"\r\r• "];
    self.ingredients.text = [@"• " stringByAppendingString:ingrString];
    self.yield.text = [NSString stringWithFormat:@"%@", self.recipe.yield];
    [self.recipeImage sd_setImageWithURL:[NSURL URLWithString:self.recipe.image] placeholderImage:nil];
    [self.view setNeedsDisplay];
}

- (void)didTapShare:(id)sender {
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:self.recipeUrl];
    content.quote = @"Recipe matching app";
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
}

// called when recipe source is tapped to redirect to recipe site
- (void)didTapSource:(UIButton *)sender {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:self.recipe.url];
    [application openURL:URL options:@{} completionHandler:nil];
}

// if recipe is already saved, removes from Parse, otherwise adds it
- (void)didTapSave:(id)sender {
    if (self.saved) {
        [APIManager unsaveRecipeWithId:self.recipeId andCompletion:^(BOOL succeeded, NSError *error){
            if (succeeded) {
                [self.saveBtn setImage:[UIImage systemImageNamed:BOOKMARK_KEY] forState:UIControlStateNormal];
                self.saved = NO;
                [self updateSaveCount];
            } else {
                //TODO: Add failure support
            }
        }];
    } else {
        [APIManager postSavedRecipeWithId:self.recipeId title:self.recipe.label image:self.recipe.image andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self.saveBtn setImage:[UIImage systemImageNamed:BOOKMARK_FILL_KEY] forState:UIControlStateNormal];
                self.saved = YES;
                [self updateSaveCount];
            } else {
                //TODO: Add failure support
            }
        }];
    }
}

// get save count
- (void)updateSaveCount {
    [APIManager countSavesWithId:self.recipeId andCompletion:^(NSUInteger saves, NSError * _Nullable error) {
        if (saves) {
            self.saveCount.text = [[NSString alloc] initWithFormat:@"%lu", saves];
        } else {
            self.saveCount.text = nil;
        }
    }];
}

// get like count
- (void)updateLikeCount {
    [APIManager countLikesWithId:self.recipeId andCompletion:^(NSUInteger likes, NSError * _Nullable error) {
        if (likes) {
            self.likeCount.text = [[NSString alloc] initWithFormat:@"%lu", likes];
        } else {
            self.likeCount.text = nil;
        }
    }];
}

// if recipe is already liked, removes from Parse, otherwise adds it
- (void)didTapLike:(id)sender {
    if (self.liked) {
        [APIManager unlikeRecipeWithId:self.recipeId andCompletion:^(BOOL succeeded, NSError *error){
            if (succeeded) {
                [self.likeBtn setImage:[UIImage systemImageNamed:HEART_KEY] forState:UIControlStateNormal];
                self.liked = NO;
                [self updateLikeCount];
            } else {
                //TODO: Add failure support
            }
        }];
    } else {
        [APIManager postLikedRecipeWithId:self.recipeId title:self.recipe.label image:self.recipe.image andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self.likeBtn setImage:[UIImage systemImageNamed:HEART_FILL_KEY] forState:UIControlStateNormal];
                self.liked = YES;
                [self updateLikeCount];
            } else {
                //TODO: Add failure support
            }
        }];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    IngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ingredientCell" forIndexPath:indexPath];
    cell.ingredient.text = [self.recipe.ingredientLines objectAtIndex:indexPath.row];
    return  cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.recipe.ingredientLines count];
}

@end
