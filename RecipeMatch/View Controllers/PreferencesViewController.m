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
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *caloriesLabel;
@property (weak, nonatomic) IBOutlet UIButton *applyBtn;

@property int selectedIndex;
@end

static const float ROW_HEIGHT = 30;
static const float MENU_OFFSET = 80;
static const float TITLE_WIDTH = 100;
static const float TITLE_HEIGHT = 40;
static const float DROPDOWN_X_OFFSET = 230;
static const float DROPDOWN_Y_POS = 133;
static const float DROPDOWN_WIDTH = 200;
static const float DROPDOWN_HEIGHT = 37;
static const float CORNER_RADIUS = 15;
static NSString* const CALORIES_DEFAULT = @"1000";

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
    
    // setup slider with current value
    NSString *caloriesCount = [self.preferencesDict objectForKey:CALORIES_KEY];
    if (caloriesCount) {
        self.caloriesLabel.text = caloriesCount;
        [self.slider setValue:[caloriesCount floatValue]];
    }
    self.applyBtn.layer.cornerRadius = CORNER_RADIUS;
}

// sends preferences to stream VC and removes view
- (IBAction)didTapApplyPreferences:(id)sender {
    if (![self.caloriesLabel.text isEqualToString:@"1000"]) {
        [self.preferencesDict setObject:self.caloriesLabel.text forKey:CALORIES_KEY];
    }
    [delegate sendPreferences:self.preferencesDict];
    [self.navigationController popViewControllerAnimated:YES]; // go back to stream VC
}

// clears all preferences and resets dropdown menu titles
- (IBAction)didTapClearPreferences:(id)sender {
    [self.preferencesDict removeAllObjects];
    [self setupView];
    self.caloriesLabel.text = CALORIES_DEFAULT;
    [self.slider setValue:[CALORIES_DEFAULT floatValue]];
}

- (IBAction) sliderValueChanged:(UISlider *)sender {
    self.caloriesLabel.text = [NSString stringWithFormat:@"%.0f", [sender value]];
}

- (void)setupView {
    CGRect frame = CGRectMake((CGRectGetWidth(self.view.frame)-DROPDOWN_X_OFFSET), DROPDOWN_Y_POS, DROPDOWN_WIDTH, DROPDOWN_HEIGHT);
    self.cuisineMenu = [self getDropDownMenuWithFrame:frame type:DropdownMenuTypeCuisine];
    [self.view addSubview:self.cuisineMenu];

    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.healthMenu = [self getDropDownMenuWithFrame:frame type:DropdownMenuTypeHealth];
    [self.view addSubview:self.healthMenu];

    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.dietMenu = [self getDropDownMenuWithFrame:frame type:DropdownMenuTypeDiet];
    [self.view addSubview:self.dietMenu];
    
    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.mealMenu = [self getDropDownMenuWithFrame:frame type:DropdownMenuTypeMeal];
    [self.view addSubview:self.mealMenu];
}

// returns dropdown items based on enum type
- (NSArray *)getItemsFromType:(DropdownMenuType)type {
    switch (type) {
        case DropdownMenuTypeCuisine:
            return @[@"American", @"Asian", @"British",@"Caribbean",@"Central Europe",@"Chinese", @"Eastern Europe", @"French", @"Indian", @"Italian", @"Japanese", @"Kosher", @"Mediterranean", @"Mexican", @"Middle Eastern", @"Nordic", @"South American", @"South East Asian", @"no preference"];
            break;
        case DropdownMenuTypeHealth:
            return @[@"vegan", @"vegetarian", @"tree-nut-free",@"low-sugar",@"shellfish-free",@"pescatarian", @"paleo", @"gluten-free", @"fodmap-free", @"no preference"];
            break;
        case DropdownMenuTypeDiet:
            return @[@"balanced", @"high-fiber", @"high-protein",@"low-carb",@"low-fat",@"low-sodium",@"no preference"];
            break;
        case DropdownMenuTypeMeal:
            return @[@"breakfast", @"dinner", @"lunch",@"snack",@"teatime",@"no preference"];
            break;
    }
}

// returns dropdown title based on enum type
- (NSString *)getTitleFromType:(DropdownMenuType)type {
    NSString *title;
    switch (type) {
        case DropdownMenuTypeDiet:
            title = [self.preferencesDict objectForKey:DIET_KEY];
            break;
        case DropdownMenuTypeMeal:
            title = [self.preferencesDict objectForKey:MEAL_TYPE_KEY];
            break;
        case DropdownMenuTypeHealth:
            title = [self.preferencesDict objectForKey:HEALTH_KEY];
            break;
        case DropdownMenuTypeCuisine:
            title = [self.preferencesDict objectForKey:CUISINE_KEY];
            break;
    }
    return title;
}

// creates and returns a dropdown menu
- (ManaDropDownMenu *)getDropDownMenuWithFrame:(CGRect)frame type:(DropdownMenuType)type {
    NSArray* items = [self getItemsFromType:type];
    NSString *title = [self getTitleFromType:type];
    ManaDropDownMenu *dropDownMenu = [[ManaDropDownMenu alloc] initWithFrame:frame title:title?title:@"no preference"];
    dropDownMenu.textOfRows = items;
    dropDownMenu.numberOfRows = [dropDownMenu.textOfRows count];
    dropDownMenu.activeColor = UIColorFromRGB(0x80CB99);
    dropDownMenu.heightOfRows = ROW_HEIGHT;
    dropDownMenu.delegate = self;
    return dropDownMenu;
}

// removes preference from dictionary if it exists, otherwise adds it
- (void)updatePreferenceWithKey:(NSString *)key title:(NSString *)title {
    if(![title isEqualToString:@"no preference"]){
        [self.preferencesDict setObject:title forKey:key];
    } else {
        [self.preferencesDict removeObjectForKey:key];
    }
}

// called when drop down item is selected
- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index {
    NSString* title = ((ManaDropDownMenu *)dropDownMenu).title;
    if (dropDownMenu == self.cuisineMenu) {
        [self updatePreferenceWithKey:CUISINE_KEY title:title];
    } else if (dropDownMenu == self.healthMenu) {
        [self updatePreferenceWithKey:HEALTH_KEY title:title];
    } else if (dropDownMenu == self.dietMenu) {
        [self updatePreferenceWithKey:DIET_KEY title:title];
    } else if (dropDownMenu == self.mealMenu) {
        [self updatePreferenceWithKey:MEAL_TYPE_KEY title:title];
    }
}
@end
