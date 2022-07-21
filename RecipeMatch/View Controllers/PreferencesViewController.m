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
    self.cuisineMenu = [self getDropDownMenuWithFrame:frame items:@[@"American", @"Asian", @"British",@"Caribbean",@"Central Europe",@"Chinese", @"Eastern Europe", @"French", @"Indian", @"Italian", @"Japanese", @"Kosher", @"Mediterranean", @"Mexican", @"Middle Eastern", @"Nordic", @"South American", @"South East Asian", @"no preference"]];
    [self.view addSubview:self.cuisineMenu];

    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.healthMenu = [self getDropDownMenuWithFrame:frame items:@[@"vegan", @"vegetarian", @"tree-nut-free",@"low-sugar",@"shellfish-free",@"pescatarian", @"paleo", @"gluten-free", @"fodmap-free", @"no preference"]];
    [self.view addSubview:self.healthMenu];

    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.dietMenu = [self getDropDownMenuWithFrame:frame items:@[@"balanced", @"high-fiber", @"high-protein",@"low-carb",@"low-fat",@"low-sodium",@"no preference"]];
    [self.view addSubview:self.dietMenu];
    
    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.mealMenu = [self getDropDownMenuWithFrame:frame items:@[@"breakfast", @"dinner", @"lunch",@"snack",@"teatime",@"no preference"]];
    [self.view addSubview:self.mealMenu];
}

// creates and returns a dropdown menu
- (ManaDropDownMenu *)getDropDownMenuWithFrame:(CGRect)frame items:(NSArray *)items{
    ManaDropDownMenu *dropDownMenu = [[ManaDropDownMenu alloc] initWithFrame:frame title:@"no preference"];
    dropDownMenu.textOfRows = items;
    dropDownMenu.numberOfRows = [dropDownMenu.textOfRows count];
    dropDownMenu.activeColor = UIColorFromRGB(0x80CB99);
    dropDownMenu.heightOfRows = ROW_HEIGHT;
    dropDownMenu.delegate = self;
    return dropDownMenu;
}

// called when drop down item is selected
- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index{
    NSString* title = ((ManaDropDownMenu *)dropDownMenu).title;
    if (dropDownMenu == self.cuisineMenu && ![title isEqualToString:@"no preference"]) {
        self.cuisineLabel = [NSString stringWithFormat:@"&cuisineType=%@", title];
    } else if (dropDownMenu == self.healthMenu && ![title isEqualToString:@"no preference"]) {
        self.cuisineLabel = [NSString stringWithFormat:@"&health=%@", title];
    } else if (dropDownMenu == self.dietMenu && ![title isEqualToString:@"no preference"]) {
        self.cuisineLabel = [NSString stringWithFormat:@"&diet=%@", title];
    } else if (dropDownMenu == self.mealMenu && ![title isEqualToString:@"no preference"]) {
        self.cuisineLabel = [NSString stringWithFormat:@"&mealType=%@", title];
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
