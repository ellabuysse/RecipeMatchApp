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
}

- (IBAction) sliderValueChanged:(UISlider *)sender {
    self.caloriesLabel.text = [NSString stringWithFormat:@"%.0f", [sender value]];
}

- (void)setupView {
    CGRect frame = CGRectMake((CGRectGetWidth(self.view.frame)-DROPDOWN_X_OFFSET), DROPDOWN_Y_POS, DROPDOWN_WIDTH, DROPDOWN_HEIGHT);
    self.cuisineMenu = [self getDropDownMenuWithFrame:frame key:CUISINE_KEY items:@[@"American", @"Asian", @"British",@"Caribbean",@"Central Europe",@"Chinese", @"Eastern Europe", @"French", @"Indian", @"Italian", @"Japanese", @"Kosher", @"Mediterranean", @"Mexican", @"Middle Eastern", @"Nordic", @"South American", @"South East Asian", @"no preference"]];
    [self.view addSubview:self.cuisineMenu];

    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.healthMenu = [self getDropDownMenuWithFrame:frame key:HEALTH_KEY items:@[@"vegan", @"vegetarian", @"tree-nut-free",@"low-sugar",@"shellfish-free",@"pescatarian", @"paleo", @"gluten-free", @"fodmap-free", @"no preference"]];
    [self.view addSubview:self.healthMenu];

    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.dietMenu = [self getDropDownMenuWithFrame:frame key:DIET_KEY items:@[@"balanced", @"high-fiber", @"high-protein",@"low-carb",@"low-fat",@"low-sodium",@"no preference"]];
    [self.view addSubview:self.dietMenu];
    
    frame = CGRectOffset(frame, 0, MENU_OFFSET);
    self.mealMenu = [self getDropDownMenuWithFrame:frame key:MEAL_TYPE_KEY  items:@[@"breakfast", @"dinner", @"lunch",@"snack",@"teatime",@"no preference"]];
    [self.view addSubview:self.mealMenu];
}

// creates and returns a dropdown menu
- (ManaDropDownMenu *)getDropDownMenuWithFrame:(CGRect)frame key:(NSString *)key items:(NSArray *)items {
    NSString *title = [self.preferencesDict objectForKey:key];
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
