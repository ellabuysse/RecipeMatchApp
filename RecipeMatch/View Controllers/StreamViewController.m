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

@interface StreamViewController()
@property (nonatomic, strong) NSString *preferences;
@property (nonatomic, strong) DraggableViewBackground *draggableBackground;
@end

@implementation StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // add centered logo
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];

    self.navigationItem.titleView = titleView;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    spinner.center = CGPointMake(self.view.center.x, self.view.center.y);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [self showCards];
}

-(void)showCards{
    self.draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    self.draggableBackground.preferences = self.preferences;
    [self.draggableBackground fetchRecipes];
    
    [self.view addSubview:self.draggableBackground];
}

-(void)sendData:(NSString *)prefRequest{
    if(prefRequest != (id)[NSNull null] && prefRequest.length != 0){
        self.preferences = prefRequest;
        [self.draggableBackground removeFromSuperview];
        [self viewDidLoad];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PreferencesViewController *preferencesController = [segue destinationViewController];
    preferencesController.delegate = self; // Set the second view controller's
}


@end
