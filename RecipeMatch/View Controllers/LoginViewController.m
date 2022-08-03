//
//  LoginViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/6/22.
//

#import "LoginViewController.h"
@import Parse;
#import "FBSDKLoginKit/FBSDKLoginKit.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UIButton *signupBtn;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginBtn;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@end

static const float CORNER_RADIUS = 15;
static const float BORDER_WIDTH = 0.5;

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.fbLoginBtn.layer.borderWidth = BORDER_WIDTH;
    self.fbLoginBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.fbLoginBtn.layer.cornerRadius = CORNER_RADIUS;
    self.signupBtn.layer.cornerRadius = CORNER_RADIUS;
    self.loginBtn.layer.cornerRadius = CORNER_RADIUS;
}

// called when Facebook Login button is pressed
- (IBAction)facebookLogin:(id)sender {
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email"] block:^(PFUser *user, NSError *error) {
        if (!user) {
        } else if (user.isNew) {
            [self performSegueWithIdentifier:@"mainSegue" sender:nil];
            
        } else {
            [self performSegueWithIdentifier:@"mainSegue" sender:nil];
        }
    }];
}

// called when Signup button is pressed
- (IBAction)signupBtn:(id)sender {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            UIAlertController *signupFailure= [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [signupFailure addAction:okAction];
            [self presentViewController:signupFailure animated:YES completion:^{}];
        } else {
            UIAlertController *signupSuccess = [UIAlertController alertControllerWithTitle:@"Success!" message:@"User registered. You can now login." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [signupSuccess addAction:okAction];
            [self presentViewController:signupSuccess animated:YES completion:^{}];
        }
    }];
}

// called when Login button is pressed
- (IBAction)loginBtn:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error){
        if (error != nil) {
            UIAlertController *loginFailure= [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [loginFailure addAction:okAction];
            
            [self presentViewController:loginFailure animated:YES completion:^{
            }];
        } else {
            [self performSegueWithIdentifier:@"mainSegue" sender:nil];
        }
    }];
}
@end
