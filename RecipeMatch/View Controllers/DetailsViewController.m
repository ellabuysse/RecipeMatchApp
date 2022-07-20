//
//  DetailsViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/11/22.
//

#import "DetailsViewController.h"
#import "APIManager.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *recipeTitle;
@property (weak, nonatomic) IBOutlet UIImageView *recipeImage;
@property (weak, nonatomic) IBOutlet UILabel *yield;
@property (weak, nonatomic) IBOutlet UILabel *ingredients;
@property (weak, nonatomic) IBOutlet UIButton *source;
@property (strong, nonatomic) NSString *recipeUrl;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property NSDictionary *fullRecipe;
@property BOOL saved;
@property BOOL liked;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchRecipeInfo];
    [self.likeBtn addTarget:self action:@selector(didTapLike:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.saveBtn addTarget:self action:@selector(didTapSave:)
         forControlEvents:UIControlEventTouchUpInside];
    
    // setups like button
    [APIManager checkIfRecipeIsAlreadyLikedWithId:self.savedRecipe.recipeId andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded == YES){
            [self.likeBtn setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
            self.liked = YES;
        } else{
            [self.likeBtn setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
            self.liked = NO;
        }
    }];

    //setups save button
    [APIManager checkIfRecipeIsAlreadySavedWithId:self.savedRecipe.recipeId andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded == YES){
            [self.saveBtn setImage:[UIImage systemImageNamed:@"bookmark.fill"] forState:UIControlStateNormal];
            self.saved = YES;
        } else{
            [self.saveBtn setImage:[UIImage systemImageNamed:@"bookmark"] forState:UIControlStateNormal];
            self.saved = NO;
        }
    }];
}

// gets recipe details from recipe API
- (void)fetchRecipeInfo{
    [[APIManager shared] getRecipeWithId:self.savedRecipe.recipeId andCompletion: ^(NSDictionary *recipe, NSError *error){
        if(recipe){
            self.fullRecipe = recipe;
            self.recipeTitle.text = recipe[@"label"];
            [self.source setTitle:recipe[@"source"] forState:UIControlStateNormal];
            [self.source.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
            [self.source addTarget:self action:@selector(didTapSource:) forControlEvents:UIControlEventTouchUpInside];
            self.recipeUrl = recipe[@"url"];
            NSArray *ingrArray = recipe[@"ingredientLines"];
            NSString *ingrString = (NSString *)[ingrArray componentsJoinedByString:@"\r\r• "];
            self.ingredients.text = [@"• " stringByAppendingString:ingrString];
            self.yield.text = [NSString stringWithFormat:@"%@", recipe[@"yield"]];
            NSString *imageUrl = recipe[@"image"];
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
            self.recipeImage.image = [UIImage imageWithData: imageData];
            [self.view setNeedsDisplay];
        }
    }];
}

// called when recipe source is tapped to redirect to recipe site
- (void)didTapSource:(UIButton *)sender {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:self.recipeUrl];
    [application openURL:URL options:@{} completionHandler:nil];
}

// saves recipe to SavedRecipe Parse class
- (void)didTapSave:(UIButton *)sender {
    if(self.saved){
        [APIManager unsaveRecipeWithId:self.savedRecipe.recipeId andCompletion:^(BOOL succeeded, NSError *error){
            if(succeeded){
                [self.saveBtn setImage:[UIImage systemImageNamed:@"bookmark"] forState:UIControlStateNormal];
                self.saved = NO;
            }
        }];
    } else {
        [APIManager postSavedRecipeWithId:self.savedRecipe.recipeId title:self.savedRecipe.name image:self.savedRecipe.image andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                [self.saveBtn setImage:[UIImage systemImageNamed:@"bookmark.fill"] forState:UIControlStateNormal];
                self.saved = YES;
            }
        }];
    }
}

// saves recipe to LikedRecipe Parse class
- (void)didTapLike:(UIButton *)sender {
    if(self.liked){
        [APIManager unlikeRecipeWithId:self.savedRecipe.recipeId andCompletion:^(BOOL succeeded, NSError *error){
            if(succeeded){
                [self.likeBtn setImage:[UIImage systemImageNamed:@"heart"] forState:UIControlStateNormal];
                self.liked = NO;
            }
        }];
    } else {
        [APIManager postLikedRecipeWithId:self.savedRecipe.recipeId title:self.savedRecipe.name image:self.savedRecipe.image andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if(succeeded){
                [self.likeBtn setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
                self.liked = YES;
            }
        }];
    }
}
@end
