//
//  PreferencesViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/13/22.
//

#import "PreferencesViewController.h"
#import <CCDropDownMenus/CCDropDownMenus.h>

@interface PreferencesViewController () <CCDropDownMenuDelegate>
@property (nonatomic, strong) ManaDropDownMenu *cuisineMenu;
@property (nonatomic, strong) ManaDropDownMenu *healthMenu;
@property (nonatomic, strong) ManaDropDownMenu *dietMenu;
@property (nonatomic, strong) ManaDropDownMenu *mealMenu;

@property (nonatomic, strong) NSString *cuisineLabel;
@property (nonatomic, strong) NSString *healthLabel;
@property (nonatomic, strong) NSString *dietLabel;
@property (nonatomic, strong) NSString *mealLabel;
@property int selectedIndex;
@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x0075E3);

    // add centered logo
    UILabel* title = [[UILabel alloc] init];
    title.text = @"Preferences";
    title.contentMode = UIViewContentModeScaleAspectFit;

    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    title.frame = titleView.bounds;
    [title setFont:[UIFont boldSystemFontOfSize:16]];
    [titleView addSubview:title];

    self.navigationItem.titleView = titleView;

    CGRect frame = CGRectMake((CGRectGetWidth(self.view.frame)-220), 133, 200, 37);
    
    self.cuisineMenu = [[ManaDropDownMenu alloc] initWithFrame:frame title:@"no preference"];
    self.cuisineMenu.numberOfRows = 19;
    self.cuisineMenu.textOfRows = @[@"American", @"Asian", @"British",@"Caribbean",@"Central Europe",@"Chinese", @"Eastern Europe", @"French", @"Indian", @"Italian", @"Japanese", @"Kosher", @"Mediterranean", @"Mexican", @"Middle Eastern", @"Nordic", @"South American", @"South East Asian", @"no preference"];
    self.cuisineMenu.activeColor = UIColorFromRGB(0x80CB99);
    self.cuisineMenu.heightOfRows = 30;
    self.cuisineMenu.delegate = self;
    [self.view addSubview:self.cuisineMenu];
    
    
    self.healthMenu = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame, 0, 80) title:@"no preference"];
    self.healthMenu.numberOfRows = 10;
    self.healthMenu.textOfRows = @[@"vegan", @"vegetarian", @"tree-nut-free",@"low-sugar",@"shellfish-free",@"pescatarian", @"paleo", @"gluten-free", @"fodmap-free", @"no preference"];
    self.healthMenu.activeColor = UIColorFromRGB(0x80CB99);
    self.healthMenu.heightOfRows = 30;
    self.healthMenu.delegate = self;
    [self.view addSubview:self.healthMenu];

    self.dietMenu = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame,0,160) title:@"no preference"];
    self.dietMenu.numberOfRows = 7;
    self.dietMenu.textOfRows = @[@"balanced", @"high-fiber", @"high-protein",@"low-carb",@"low-fat",@"low-sodium",@"no preference"];
    self.dietMenu.activeColor = UIColorFromRGB(0x80CB99);
    self.dietMenu.heightOfRows = 30;
    self.dietMenu.delegate = self;
    [self.view addSubview:self.dietMenu];
    
    self.mealMenu = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame, 0, 240) title:@"no preference"];
    self.mealMenu.numberOfRows = 6;
    self.mealMenu.textOfRows = @[@"breakfast", @"dinner", @"lunch",@"snack",@"teatime",@"no preference"];
    self.mealMenu.activeColor = UIColorFromRGB(0x80CB99);
    self.mealMenu.heightOfRows = 30;
    self.mealMenu.delegate = self;
    [self.view addSubview:self.mealMenu];
}

- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index{
    if (dropDownMenu == self.cuisineMenu) {
        self.cuisineLabel = @"&cuisineType=";
        self.cuisineLabel = [self.cuisineLabel stringByAppendingString:((ManaDropDownMenu *)dropDownMenu).title];
    }
    if (dropDownMenu == self.healthMenu) {
        self.healthLabel = @"&health=";
        self.healthLabel = [self.healthLabel stringByAppendingString:((ManaDropDownMenu *)dropDownMenu).title];
    }
    if (dropDownMenu == self.dietMenu) {
        self.dietLabel = @"&diet=";
        self.dietLabel = [self.dietLabel stringByAppendingString:((ManaDropDownMenu *)dropDownMenu).title];
    }
    if (dropDownMenu == self.mealMenu) {
        self.mealLabel = @"&mealType=";
        self.mealLabel = [self.mealLabel stringByAppendingString:((ManaDropDownMenu *)dropDownMenu).title];
    }
}

@synthesize delegate;
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"viewWillDisappear() called");
    [super viewWillDisappear:animated];
    NSString *finalRequest = [[NSString alloc] init];
    
    if(self.cuisineLabel && ![self.cuisineLabel isEqualToString:@"no preference"]){
        finalRequest = [finalRequest stringByAppendingString:self.cuisineLabel];
    }
    if(self.healthLabel && ![self.healthLabel isEqualToString:@"no preference"]){
        finalRequest = [finalRequest stringByAppendingString:self.healthLabel];
    }
    if(self.dietLabel && ![self.dietLabel isEqualToString:@"no preference"]){
        finalRequest = [finalRequest stringByAppendingString:self.dietLabel];
    }
    if(self.mealLabel && ![self.mealLabel isEqualToString:@"no preference"]){
        finalRequest = [finalRequest stringByAppendingString:self.mealLabel];
    }
    [delegate sendData:finalRequest];
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
