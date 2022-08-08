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
#import "DetailsViewController.h"
#import "APIManager.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "ProfileCollectionReusableView.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ProfileCollectionReusableViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *recipesCollectionView;
@property (nonatomic, strong) NSArray *savedRecipes;
@property (nonatomic, strong) NSArray *likedRecipes;
@property (nonatomic, strong) NSArray *currentRecipes;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (strong, nonatomic) ProfileCollectionReusableView *profileHeaderView;
@end

static const float MIN_LINE_SPACING = 10;
static const float HEIGHT_FACTOR = 1.2;
static const float MARGIN_SIZE = 7;
static const float SAVED_CONTROL_INDEX = 0;

@implementation ProfileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // setup scroll refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
   // [self.refreshControl addTarget:self action:@selector(fetchRecipes) forControlEvents:UIControlEventValueChanged];
   // self.recipesCollectionView.refreshControl = self.refreshControl;
    
    self.recipesCollectionView.emptyDataSetSource = self;
    self.recipesCollectionView.emptyDataSetDelegate = self;
    
    // setup logout button
    UIBarButtonItem *logout = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Logout"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(logoutBtn:)];
    self.navigationItem.leftBarButtonItem = logout;
    [self reloadData];
    
    PFUser *user = [PFUser currentUser];
    NSString *title = [@"@" stringByAppendingString:user.username];
    self.navigationItem.title = title;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

// fetches recipes from API and sets currentRecipes
- (void)reloadData {
    [self fetchSavedRecipesWithCompletion:^(BOOL succeeded, NSError *error){
        if(succeeded) {
            [self fetchLikedRecipesWithCompletion:^(BOOL succeeded, NSError *error){
                if (succeeded) {
                    [self segmentedControlDidChange];
                } else {
                    //TODO: add failure support
                }
            }];
        } else {
            //TODO: add failure support
        }
    }];
}

// fetch all saved recipes from user in APIManager
- (void)fetchSavedRecipesWithCompletion:(void (^)(BOOL succeeded, NSError *error))completion{
    [APIManager fetchSavedRecipes:^(NSArray *recipes, NSError *error) {
        if (recipes) {
            self.savedRecipes = recipes;
            completion(YES, nil);
        } else {
            [self.refreshControl endRefreshing];
            completion(NO, error);
        }
    }];
}

// fetch all liked recipes from user in APIManager
- (void)fetchLikedRecipesWithCompletion:(void (^)(BOOL succeeded, NSError *error))completion{
    [APIManager fetchLikedRecipes:^(NSArray *recipes, NSError *error) {
        if (recipes) {
            self.likedRecipes = recipes;
            completion(YES, nil);
        } else {
            [self.refreshControl endRefreshing];
            completion(NO, error);
        }
    }];
}

// sets currentRecipes to savedRecipes and reloads collection view
- (void)showSavedRecipes {
    self.currentRecipes = self.savedRecipes;
    [self.recipesCollectionView reloadData];
}

// sets currentRecipes to likedRecipes and reloads collection view
- (void)showLikedRecipes {
    self.currentRecipes = self.likedRecipes;
    [self.recipesCollectionView reloadData];
}

- (IBAction)logoutBtn:(id)sender {
    [PFUser logOutInBackground];
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
}

#pragma mark - ProfileCollectionReusableViewDelegate

// sets currentRecipes based on segmentedControl
- (void)segmentedControlDidChange {
    if (self.profileHeaderView.segmentedControl.selectedSegmentIndex == SAVED_CONTROL_INDEX) {
        [self showSavedRecipes];
    } else {
        [self showLikedRecipes];
    }
}

#pragma mark - DZNEmptyDataSetDelegate

- (UIImage *)imageForEmptyDataSet:(UICollectionView *)collectionView {
    return [UIImage imageNamed:@"profile-placeholder"];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ProfileCollectionReusableView *profileHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileHeader" forIndexPath:indexPath];
    self.profileHeaderView = profileHeaderView;
    self.profileHeaderView.delegate = self;
    return profileHeaderView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = MIN_LINE_SPACING;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(MARGIN_SIZE,MARGIN_SIZE,0,MARGIN_SIZE);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentRecipes.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GridRecipeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridRecipeCell" forIndexPath:indexPath];
    SavedRecipe *recipe = self.currentRecipes[indexPath.row];
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
        SavedRecipe *recipe = self.currentRecipes[indexPath.row];
        detailsController.recipeId = recipe.recipeId;
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
    }
}
@end
