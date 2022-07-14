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
#import "LikedRecipe.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *recipesCollectionView;
@property (nonatomic, strong) NSArray *recipes;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recipesCollectionView.dataSource = self;
    self.recipesCollectionView.delegate = self;

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchRecipes) forControlEvents:UIControlEventValueChanged];
    
    if (@available(iOS 10.0, *)) {
        self.recipesCollectionView.refreshControl = self.refreshControl;
    } else {
        [self.recipesCollectionView addSubview:self.refreshControl];
    }
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Logout"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(logoutBtn:)];
    self.navigationItem.leftBarButtonItem = logout;

    [self fetchRecipes];
}

-(void)viewWillAppear{
    [super viewDidLoad];
        
    [self fetchRecipes];
}

- (void) fetchRecipes{
    PFQuery *recipeQuery = [LikedRecipe query];
    [recipeQuery orderByDescending:@"createdAt"];
    [recipeQuery includeKey:@"user"];
    [recipeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound) {
            // do something with the data fetched
            self.recipes = (NSMutableArray *)recipesFound;
            [self.recipesCollectionView reloadData];
            [self.refreshControl endRefreshing];
        }
        else {
            // handle error
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = 10;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recipes.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    GridRecipeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridRecipeCell" forIndexPath:indexPath];
    NSDictionary *recipe = self.recipes[indexPath.row];
    
    NSString *imageUrl = recipe[@"image"];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    cell.imageView.layer.cornerRadius = 15;
    cell.recipeTitle.text = recipe[@"name"];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int totalwidth = self.recipesCollectionView.bounds.size.width;
    int numberOfCellsPerRow = 2;
    int widthDimensions = (CGFloat)(totalwidth / numberOfCellsPerRow);
    int heightDimensions = widthDimensions * 1.2;
    return CGSizeMake(widthDimensions, heightDimensions);
}

- (IBAction)logoutBtn:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        NSLog(@"Successfully logged out");
    }];
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    myDelegate.window.rootViewController = loginViewController;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    DetailsViewController *detailsController = [segue destinationViewController];
    UICollectionViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.recipesCollectionView indexPathForCell:tappedCell];
    LikedRecipe *recipe = self.recipes[indexPath.row];
    detailsController.likedRecipe = recipe;
}


@end
