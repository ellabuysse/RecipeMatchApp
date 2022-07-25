//
//  SearchViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/25/22.
//

#import "SearchViewController.h"
#import "SearchCollectionReusableView.h"
#import "UIImageView+AFNetworking.h"
#import "GridRecipeCell.h"
#import "APIManager.h"
#import "DetailsViewController.h"
#import "DraggableView.h"

@interface SearchViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) SearchCollectionReusableView *searchCollectionReusableView;
@property (nonatomic, strong) NSArray *recipes;
@property (nonatomic, strong) NSString *searchText;
@end

@implementation SearchViewController 
static const float CORNER_RADIUS = 15;
static const float MIN_LINE_SPACING = 10;
static const float HEIGHT_FACTOR = 1.2;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    SearchCollectionReusableView *searchView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchView" forIndexPath:indexPath];
    return searchView;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length % 3 == 0) {
        self.searchText = searchText;
        [[APIManager shared] getRecipesWithQuery:self.searchText andCompletion: ^(NSMutableArray *recipes, NSError *error) {
            if(recipes){
                self.recipes = recipes;
                [self.collectionView reloadData];
            } else{
                //TODO: add failure support
            }
        }];

    }
}

#pragma mark - UICollectionViewDelegate

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = MIN_LINE_SPACING;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recipes.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GridRecipeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridRecipeCell" forIndexPath:indexPath];
    NSDictionary *recipe = self.recipes[indexPath.row][@"recipe"];
  
    NSString *imageUrl = recipe[@"image"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // get recipe image in background thread
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
             // set cell image on main thread
            [cell.searchImageView setImage:img];
        });
    });
 
    cell.searchImageView.layer.cornerRadius = CORNER_RADIUS;
    cell.searchRecipeTitle.text = recipe[@"label"];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int totalwidth = self.collectionView.bounds.size.width;
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
         NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
         // save recipe data as SavedRecipe object to be accessed by DetailsViewController
         NSDictionary *recipe = self.recipes[indexPath.row][@"recipe"];
         SavedRecipe *newRecipe = [SavedRecipe new];
         newRecipe.name = recipe[@"label"];
         newRecipe.recipeId = [recipe[@"uri"] componentsSeparatedByString:@"#recipe_"][1];
         newRecipe.image = recipe[@"image"];
         newRecipe.username = [PFUser currentUser].username;
         detailsController.savedRecipe = newRecipe;
     }
 }

@end