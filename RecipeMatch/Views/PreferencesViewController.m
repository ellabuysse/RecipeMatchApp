//
//  PreferencesViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/13/22.
//

#import "PreferencesViewController.h"
#import "ExpandableTableViewCell.h"
#import <CCDropDownMenus/CCDropDownMenus.h>

@interface PreferencesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray *arrayTitle;
@property (strong,nonatomic) NSMutableArray *arraySecond;
@property (strong,nonatomic) NSMutableArray *arrayName;
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
    
    ManaDropDownMenu *menu3 = [[ManaDropDownMenu alloc] initWithFrame:frame title:@"no preference"];
    menu3.delegate = self;
    menu3.numberOfRows = 19;
    menu3.textOfRows = @[@"American", @"Asian", @"British",@"Caribbean",@"Central Europe",@"Chinese", @"Eastern Europe", @"French", @"Indian", @"Italian", @"Japanese", @"Kosher", @"Mediterranean", @"Mexican", @"Middle Eastern", @"Nordic", @"South American", @"South East Asian", @"no preference"];
    menu3.activeColor = UIColorFromRGB(0x80CB99);
    menu3.heightOfRows = 30;
    [self.view addSubview:menu3];
    
    
    ManaDropDownMenu *menu4 = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame, 0, 80) title:@"no preference"];
    menu4.delegate = self;
    menu4.numberOfRows = 10;
    menu4.textOfRows = @[@"vegan", @"vegetarian", @"tree-nut-free",@"low-sugar",@"shellfish-free",@"pescatarian", @"paleo", @"gluten-free", @"fodmap-free", @"no preference"];
    menu4.activeColor = UIColorFromRGB(0x80CB99);
    menu4.heightOfRows = 30;
    [self.view addSubview:menu4];

    ManaDropDownMenu *menu1 = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame,0,160) title:@"no preference"];
    menu1.delegate = self;
    menu1.numberOfRows = 7;
    menu1.textOfRows = @[@"balanced", @"high-fiber", @"high-protein",@"low-carb",@"low-fat",@"low-sodium",@"no preference"];
    menu1.activeColor = UIColorFromRGB(0x80CB99);
    menu1.heightOfRows = 30;
    [self.view addSubview:menu1];
    
    ManaDropDownMenu *menu2 = [[ManaDropDownMenu alloc] initWithFrame:CGRectOffset(frame, 0, 240) title:@"no preference"];
    menu2.delegate = self;
    menu2.numberOfRows = 6;
    menu2.textOfRows = @[@"breakfast", @"dinner", @"lunch",@"snack",@"teatime",@"no preference"];
    menu2.activeColor = UIColorFromRGB(0x80CB99);
    menu2.heightOfRows = 30;
    [self.view addSubview:menu2];
    
    
    
    
}

- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index {
    /*if (dropDownMenu == self.menu1 || dropDownMenu == self.menu2) {
        NSLog(@"%@", ((ManaDropDownMenu *)dropDownMenu).title);
    }
    
    if (dropDownMenu == self.menu3) {
        NSLog(@"%lu", (long)index);
    }*/
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
