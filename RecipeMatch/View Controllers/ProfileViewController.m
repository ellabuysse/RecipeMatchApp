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
#import "SDWebImage/SDWebImage.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *recipesCollectionView;
@property (nonatomic, strong) NSArray *recipes;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

static const float CORNER_RADIUS = 15;
static const float MIN_LINE_SPACING = 10;
static const float HEIGHT_FACTOR = 1.2;

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

#pragma mark - UICollectionViewDelegate

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = MIN_LINE_SPACING;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recipes.count;
}

// called by cellForItemAtIndexPath to set up cell with image and title
- (GridRecipeCell *)setupCell:(GridRecipeCell *)cell withRecipe:(SavedRecipe *)recipe {
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:recipe[@"image"]] placeholderImage:[UIImage systemImageNamed:@"photo"]];
    cell.imageView.layer.cornerRadius = CORNER_RADIUS;
    cell.recipeTitle.text = recipe[@"name"];
    return cell;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GridRecipeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridRecipeCell" forIndexPath:indexPath];
    SavedRecipe *recipe = self.recipes[indexPath.row];
    cell = [self setupCell:cell withRecipe:recipe];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int totalwidth = self.recipesCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 2;
    int widthDimensions = (CGFloat)(totalwidth / numberOfCellsPerRow);
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
        detailsController.savedRecipe = recipe;
    }
}
@end
