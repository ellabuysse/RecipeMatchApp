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
@property (weak, nonatomic) IBOutlet UILabel *source;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UILabel *yield;
@property (weak, nonatomic) IBOutlet UILabel *ingredients;
@property (weak, nonatomic) IBOutlet UITextView *recipeUrl;
@property NSDictionary *fullRecipe;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    
    [[APIManager shared] getRecipeWithId:^(NSDictionary *recipe, NSError *error) {
        if(recipe)
        {
            self.fullRecipe = recipe;
            self.recipeTitle.text = recipe[@"label"];
            self.source.text = recipe[@"source"];
            self.recipeUrl.text = recipe[@"url"];
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
