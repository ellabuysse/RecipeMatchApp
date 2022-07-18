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

@interface StreamViewController()
@property (nonatomic, strong) NSString *preferences;
@property (nonatomic, strong) DraggableViewBackground *draggableBackground;
@property NSMutableArray *recipes;
@end

@implementation StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];
    self.navigationItem.titleView = titleView;
    
    [self setupCards];
}

-(void)setupCards{
    // show spinner when waiting for recipes to load
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    spinner.center = CGPointMake(self.view.center.x, self.view.center.y);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [[APIManager shared] getRecipesWithPreferences:self.preferences andCompletion: ^(NSMutableArray *recipes, NSError *error) {
        if(recipes)
        {
            self.recipes = recipes;
            self.draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
            self.draggableBackground.recipes = self.recipes;
            [self.draggableBackground loadCards];
            [self.view addSubview:self.draggableBackground];
        } else {
            NSLog(@"😫😫😫 Error getting recipes: %@", error.localizedDescription);
        }
    }];
}

// method to be called by Preferences delegate to get user preferences
-(void)sendData:(NSString *)prefRequest{
    // check that preferences aren't empty
    if(prefRequest != (id)[NSNull null] && prefRequest.length != 0){
        self.preferences = prefRequest;
        [self.draggableBackground removeFromSuperview];
        [self setupCards];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"preferencesViewSegue"]) {
        PreferencesViewController *preferencesController = [segue destinationViewController];
        preferencesController.delegate = self;
    }
}


@end
