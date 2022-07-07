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
    
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
    [self.view addSubview:draggableBackground];
    
    
    /*CGRect frame = self.view.frame;
    frame.origin.y = -self.view.frame.size.height; //optional: if you want the view to drop down
    DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:frame];
    draggableBackground.alpha = 0; //optional: if you want the view to fade in

    [self.view addSubview:draggableBackground];

      //optional: animate down and in
    [UIView animateWithDuration:0.5 animations:^{
        draggableBackground.center = self.view.center;
        draggableBackground.alpha = 1;
    }];
    */
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
