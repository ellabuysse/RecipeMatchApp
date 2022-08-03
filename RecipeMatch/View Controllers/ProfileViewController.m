//
//  ProfileViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/6/22.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "GridRecipeCell.h"
#import "SavedRecipe.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import "APIManager.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *recipesCollectionView;
@property (nonatomic, strong) NSArray *recipes;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

static const float MIN_LINE_SPACING = 10;
static const float HEIGHT_FACTOR = 1.2;
static const float MARGIN_SIZE = 7;
static const float TOP_MARGIN = 20;

@implementation ProfileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // setup scroll refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchRecipes) forControlEvents:UIControlEventValueChanged];
    self.recipesCollectionView.refreshControl = self.refreshControl;

    // setup logout button
    UIBarButtonItem *logout = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Logout"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(logoutBtn:)];
    self.navigationItem.leftBarButtonItem = logout;
    [self fetchRecipes];
}

// called after returning from PreferencesViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchRecipes];
}

// fetch all saved recipe from user in APIManager
- (void)fetchRecipes {
    [APIManager fetchSavedRecipes:^(NSArray *recipes, NSError *error) {
        if (recipes) {
            self.recipes = recipes;
            [self.recipesCollectionView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            [self.refreshControl endRefreshing];
            //TODO: Add failure support
        }
    }];
}

- (IBAction)logoutBtn:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
}

#pragma mark - DZNEmptyDataSetDelegate

- (UIImage *)imageForEmptyDataSet:(UICollectionView *)collectionView {
    return [UIImage imageNamed:@"save-placeholder"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UICollectionView *)collectionView {
    NSString *text = @"No Saves yet";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UICollectionView *)collectionView {
    NSString *text = @"Start swiping to discover recipes!";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.85 green:0.86 blue:0.87 alpha:1.0],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - UICollectionViewDelegate

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = MIN_LINE_SPACING;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(TOP_MARGIN,MARGIN_SIZE,0,MARGIN_SIZE);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recipes.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GridRecipeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridRecipeCell" forIndexPath:indexPath];
    SavedRecipe *recipe = self.recipes[indexPath.row];
    [cell setupWithRecipeTitle:recipe.name recipeImageUrl:recipe.image cellType:GridRecipeCellTypeProfile];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int totalwidth = self.recipesCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 2;
    int widthDimensions = (CGFloat)(totalwidth / numberOfCellsPerRow)-MARGIN_SIZE*2;
    int heightDimensions = widthDimensions * HEIGHT_FACTOR;
    return CGSizeMake(widthDimensions, heightDimensions);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailsViewSegue"]) {
        DetailsViewController *detailsController = [segue destinationViewController];
        UICollectionViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.recipesCollectionView indexPathForCell:tappedCell];
        SavedRecipe *recipe = self.recipes[indexPath.row];
        detailsController.recipeId = recipe.recipeId;
    }
}
@end
