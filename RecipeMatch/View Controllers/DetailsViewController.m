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
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchRecipeInfo];

    [self.likeBtn addTarget:self action:@selector(didTapLike:)
         forControlEvents:UIControlEventTouchUpInside];
    [self.saveBtn addTarget:self action:@selector(didTapSave:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.likeBtn setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];

    [APIManager checkIfSaved:self.savedRecipe.recipeId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded == YES){
            [self.saveBtn setImage:[UIImage systemImageNamed:@"bookmark.fill"] forState:UIControlStateNormal];
        } else{
            [self.saveBtn setImage:[UIImage systemImageNamed:@"bookmark"] forState:UIControlStateNormal];
        }
    }];
}

-(void)fetchRecipeInfo{
    [[APIManager shared] getIdRecipe:self.savedRecipe.recipeId withCompletion: ^(NSDictionary *recipe, NSError *error){
        if(recipe)
        {
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
        } else {
            NSLog(@"😫😫😫 Error getting recipe info: %@", error.localizedDescription);
        }
    }];
}

- (void)didTapSource:(UIButton *)sender {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:self.recipeUrl];
    [application openURL:URL options:@{} completionHandler:nil];
}



- (void)didTapSave:(UIButton *)sender {
    [APIManager unsave:self.savedRecipe.recipeId withCompletion: ^(NSArray *recipes, NSError *error){
        if(recipes.count != 0)
        {
            // successfully unsaved recipe
            [self.saveBtn setImage:[UIImage systemImageNamed:@"bookmark"] forState:UIControlStateNormal];
           // [self performSegueWithIdentifier:@"returnToProfile" sender:nil];
            
        }else {
            // no recipe found, need to save
            [APIManager postSavedRecipe:self.savedRecipe.name withId:self.savedRecipe.recipeId withImage:self.savedRecipe.image withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
                if(error){
                    NSLog(@"Error posting recipe: %@", error.localizedDescription);
                }
                else{
                    //[self.delegate didTweet:tweet];
                    NSLog(@"Post recipe success!");
                }
            }];
            [self.saveBtn setImage:[UIImage systemImageNamed:@"bookmark.fill"] forState:UIControlStateNormal];
        }
    }];
}

- (void)didTapLike:(UIButton *)sender {
    [self.likeBtn setImage:[UIImage systemImageNamed:@"heart.fill"] forState:UIControlStateNormal];
    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
