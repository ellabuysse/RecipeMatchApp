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
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UILabel *yield;
@property (weak, nonatomic) IBOutlet UILabel *ingredients;
@property (weak, nonatomic) IBOutlet UIButton *source;
@property (strong, nonatomic) NSString *recipeUrl;
@property NSDictionary *fullRecipe;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self fetchRecipeInfo];
}

-(void)fetchRecipeInfo{
    [APIManager getIdRecipe:self.likedRecipe.recipeId withCompletion: ^(NSDictionary *recipe, NSError *error){
        if(recipe)
        {
            self.fullRecipe = recipe;
            self.recipeTitle.text = recipe[@"label"];
            [self.source setTitle:recipe[@"source"] forState:UIControlStateNormal];
            [self.source.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
           
            [self.source addTarget:self action:@selector(didTapSource:) forControlEvents:UIControlEventTouchUpInside];
            
            self.recipeUrl = recipe[@"url"];
            NSString *time = [NSString stringWithFormat:@"%@", recipe[@"totalTime"]];
            self.totalTime.text = [time stringByAppendingString:@"m"];
            
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


- (IBAction)didUnfavorite:(id)sender {
    [APIManager unfavorite:self.likedRecipe.recipeId withCompletion: ^(NSArray *recipes, NSError *error){
        if(recipes)
        {
            NSLog(@"Successfully unfavorited");
            [self performSegueWithIdentifier:@"returnToProfile" sender:nil];
            
        }else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
    }];
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
