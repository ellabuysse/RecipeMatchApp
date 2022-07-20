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

static const float ROW_HEIGHT = 30;
static const float MENU_OFFSET = 80;
static const float TITLE_WIDTH = 100;
static const float TITLE_HEIGHT = 40;
static const float DROPDOWN_X_OFFSET = 220;
static const float DROPDOWN_Y_POS = 133;
static const float DROPDOWN_WIDTH = 200;
static const float DROPDOWN_HEIGHT = 37;

@implementation PreferencesViewController
@synthesize delegate; // delegate is instance of StreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // setup top nav bar
    self.navigationController.navigationBar.tintColor = UIColorFromRGB(0x0075E3);
    UILabel* title = [[UILabel alloc] init];
    title.text = @"Preferences";
    title.contentMode = UIViewContentModeScaleAspectFit;
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TITLE_WIDTH, TITLE_HEIGHT)];
    title.frame = titleView.bounds;
    [title setFont:[UIFont boldSystemFontOfSize:16]];
    [titleView addSubview:title];
    self.navigationItem.titleView = titleView;
    [self setupView];
}

- (void)setupView{
    CGRect frame = CGRectMake((CGRectGetWidth(self.view.frame)-DROPDOWN_X_OFFSET), DROPDOWN_Y_POS, DROPDOWN_WIDTH, DROPDOWN_HEIGHT);
    self.cuisineMenu = [[ManaDropDownMenu alloc] initWithFrame:frame title:@"no preference"];
    self.cuisineMenu.textOfRows = @[@"American", @"Asian", @"British",@"Caribbean",@"Central Europe",@"Chinese", @"Eastern Europe", @"French", @"Indian", @"Italian", @"Japanese", @"Kosher", @"Mediterranean", @"Mexican", @"Middle Eastern", @"Nordic", @"South American", @"South East Asian", @"no preference"];
    self.cuisineMenu.numberOfRows = [self.cuisineMenu.textOfRows count];
    self.cuisineMenu.activeColor = UIColorFromRGB(0x80CB99);
    self.cuisineMenu.heightOfRows = ROW_HEIGHT;
    self.cuisineMenu.delegate = self;
    [self.view addSubview:self.cuisineMenu];
    
    self.healthMenu = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame, 0, MENU_OFFSET) title:@"no preference"];
    self.healthMenu.textOfRows = @[@"vegan", @"vegetarian", @"tree-nut-free",@"low-sugar",@"shellfish-free",@"pescatarian", @"paleo", @"gluten-free", @"fodmap-free", @"no preference"];
    self.healthMenu.numberOfRows = [self.healthMenu.textOfRows count];
    self.healthMenu.activeColor = UIColorFromRGB(0x80CB99);
    self.healthMenu.heightOfRows = ROW_HEIGHT;
    self.healthMenu.delegate = self;
    [self.view addSubview:self.healthMenu];

    self.dietMenu = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame, 0, MENU_OFFSET * 2) title:@"no preference"];
    self.dietMenu.textOfRows = @[@"balanced", @"high-fiber", @"high-protein",@"low-carb",@"low-fat",@"low-sodium",@"no preference"];
    self.dietMenu.numberOfRows = [self.dietMenu.textOfRows count];
    self.dietMenu.activeColor = UIColorFromRGB(0x80CB99);
    self.dietMenu.heightOfRows = ROW_HEIGHT;
    self.dietMenu.delegate = self;
    [self.view addSubview:self.dietMenu];
    
    self.mealMenu = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame, 0, MENU_OFFSET * 3) title:@"no preference"];
    self.mealMenu.textOfRows = @[@"breakfast", @"dinner", @"lunch",@"snack",@"teatime",@"no preference"];
    self.mealMenu.numberOfRows = [self.mealMenu.textOfRows count];
    self.mealMenu.activeColor = UIColorFromRGB(0x80CB99);
    self.mealMenu.heightOfRows = ROW_HEIGHT;
    self.mealMenu.delegate = self;
    [self.view addSubview:self.mealMenu];
}

// called when drop down item is selected
- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index{
    NSString* title = ((ManaDropDownMenu *)dropDownMenu).title;
    if (dropDownMenu == self.cuisineMenu && ![title isEqualToString:@"no preference"]) {
        self.cuisineLabel = @"&cuisineType=";
        self.cuisineLabel = [self.cuisineLabel stringByAppendingString:title];
    } else if (dropDownMenu == self.healthMenu && ![title isEqualToString:@"no preference"]) {
        self.healthLabel = @"&health=";
        self.healthLabel = [self.healthLabel stringByAppendingString:title];
    } else if (dropDownMenu == self.dietMenu && ![title isEqualToString:@"no preference"]) {
        self.dietLabel = @"&diet=";
        self.dietLabel = [self.dietLabel stringByAppendingString:title];
    } else if (dropDownMenu == self.mealMenu && ![title isEqualToString:@"no preference"]) {
        self.mealLabel = @"&mealType=";
        self.mealLabel = [self.mealLabel stringByAppendingString:title];
    }
}

//called when back button is pressed
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSString *preferences = [[NSString alloc] init];
    if(self.cuisineLabel){
        preferences = [preferences stringByAppendingString:self.cuisineLabel];
    }
    if(self.healthLabel){
        preferences = [preferences stringByAppendingString:self.healthLabel];
    }
    if(self.dietLabel){
        preferences = [preferences stringByAppendingString:self.dietLabel];
    }
    if(self.mealLabel){
        preferences = [preferences stringByAppendingString:self.mealLabel];
    }
    [delegate sendData:preferences];
}
@end
