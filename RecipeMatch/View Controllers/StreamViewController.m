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
    
    /*DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];*/
}

-(void)showCards{
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];
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
