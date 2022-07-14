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
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *login;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.login.layer.borderWidth = 0.5;
    self.login.layer.borderColor = [UIColor blackColor].CGColor;
    self.login.layer.cornerRadius = 10;
}


- (IBAction)facebookLogin:(id)sender {
    [self loginWithFacebook];
}

- (IBAction)signupBtn:(id)sender {
    [self registerUser];
    
}
- (IBAction)loginBtn:(id)sender {
    [self loginUser];
}

- (void)registerUser {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            UIAlertController *signupFailure= [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [signupFailure addAction:okAction];
            
            [self presentViewController:signupFailure animated:YES completion:^{
            }];
            
        } else {
            NSLog(@"User registered successfully");

            UIAlertController *signupSuccess = [UIAlertController alertControllerWithTitle:@"Success!" message:@"User registered. You can now login." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [signupSuccess addAction:okAction];

            [self presentViewController:signupSuccess animated:YES completion:^{
            }];
        }
    }];
}

- (void)loginUser {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            UIAlertController *loginFailure= [UIAlertController alertControllerWithTitle:@"Error!" message:[NSString stringWithFormat:@"%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
            [loginFailure addAction:okAction];
            
            [self presentViewController:loginFailure animated:YES completion:^{
            }];
            
        } else {
            NSLog(@"User logged in successfully");
            
            // display view controller that needs to shown after successful login
            [self performSegueWithIdentifier:@"mainSegue" sender:nil];
        }
    }];
}

- (void)loginWithFacebook{
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            
        } else if (user.isNew) {
            [self performSegueWithIdentifier:@"mainSegue" sender:nil];
            
        } else {
            NSLog(@"User logged in through Facebook!");
            [self performSegueWithIdentifier:@"mainSegue" sender:nil];
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
