//
//  SearchViewController.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/25/22.
//

#import "SearchViewController.h"
#import "SearchCollectionReusableView.h"
#import "GridRecipeCell.h"
#import "APIManager.h"
#import "DetailsViewController.h"
#import "DraggableView.h"
#import "EmptyCollectionReusableView.h"
#import "RecipeModel.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface SearchViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSString *searchText;
@property (strong, nonatomic) NSTimer * searchTimer;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) SearchCollectionReusableView *searchView;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@end

@implementation SearchViewController 
static const float MIN_LINE_SPACING = 10;
static const float HEIGHT_FACTOR = 1.2;
static const float MARGIN_SIZE = 7;
static const float HEADER_SIZE = 50;
static const float TIMER_INTERVAL = 0.5;
static const float TITLE_WIDTH = 100;
static const float TITLE_HEIGHT = 40;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:EmptyCollectionReusableView.self forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EmptyView"];
    
    self.collectionView.emptyDataSetSource = self;
    self.collectionView.emptyDataSetDelegate = self;
    
    // setup top nav bar
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TITLE_WIDTH, TITLE_HEIGHT)];
    imageView.frame = titleView.bounds;
    [titleView addSubview:imageView];
    self.navigationItem.titleView = titleView;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchText;
    
    // if a timer is already active, prevent it from firing
    if (self.searchTimer != nil) {
        [self.searchTimer invalidate];
        self.searchTimer = nil;
    }

    // reschedule the search: in TIMER_INTERVAL seconds, call the reloadSearch: method on the new textfield content
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval: TIMER_INTERVAL
                                target: self
                                selector: @selector(reloadSearch:)
                                userInfo: searchText
                                repeats: NO];
}

// dismisses keyboard when search button is clicked
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

// clears current recipes and updates screen
- (void)clearRecipes {
    self.recipes = NULL;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    [self.collectionView reloadEmptyDataSet];
}

// called when user stops typing to get recipes
- (void)reloadSearch:(NSTimer *)timer {
    NSString *query = timer.userInfo;    // strong reference
    [self.dataTask cancel];
    if ([query length]) {
        [self getRecipes:^(NSMutableArray *recipes, NSError *error){
            if(recipes && [self.searchText isEqualToString:query]){ // check that the returning call is for the correct current query
                self.recipes = recipes;
                // only reload section 1 to prevent search bar from losing first responder status
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
                [self.collectionView reloadEmptyDataSet];
            } else {
                [self clearRecipes];
            }
        }];
    } else {
        [self clearRecipes];
    }
} 

- (void)getRecipes:(void (^)(NSMutableArray *recipes, NSError *error))completion {
    self.dataTask = [[APIManager shared] getRecipesWithQuery:self.searchText andCompletion:^(NSMutableArray *recipes, NSError *error) {
        if (recipes) {
            completion(recipes, nil);
        } else {
            completion(nil, error);
        }
    }];
}

#pragma mark - DZNEmptyDataSetDelegate

- (UIImage *)imageForEmptyDataSet:(UICollectionView *)collectionView {
    return [UIImage imageNamed:@"search-placeholder"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UICollectionView *)collectionView {
    NSString *text = @"No results yet";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UICollectionView *)collectionView {
    NSString *text = @"Search by title, ingredient, etc.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor colorWithRed:0.85 green:0.86 blue:0.87 alpha:1.0],
                                 NSParagraphStyleAttributeName: paragraph};
                                 
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - UICollectionViewDelegate

// adds search bar to section 0 collection view header and empty view to section 1 header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section]) {
        EmptyCollectionReusableView *emptyView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EmptyView" forIndexPath:indexPath];
        return emptyView;
    } else {
        SearchCollectionReusableView *searchView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchView" forIndexPath:indexPath];
        self.searchView = searchView;
        return searchView;
    }
}

// sets section header heights
- (CGSize)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(HEADER_SIZE,HEADER_SIZE);
    } else { // hide section 1 header
        return CGSizeMake(0, 0);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumLineSpacing = MIN_LINE_SPACING;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(MARGIN_SIZE,MARGIN_SIZE,0,MARGIN_SIZE);
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return self.recipes.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

// dismisses keyboard when user scrolls
- (void)scrollViewDidScroll:(UICollectionView *)collectionView {
    [self.searchView.searchBar resignFirstResponder];
 }

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GridRecipeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridRecipeCell" forIndexPath:indexPath];
    RecipeContainerModel *recipeContainer = self.recipes[indexPath.row];
    RecipeModel *recipe = recipeContainer.recipe;
    [cell setupWithRecipeTitle:recipe.label recipeImageUrl:recipe.image cellType:GridRecipeCellTypeSearch];
    
    // when the bottom of the page is reached, adds more recipes to array for infinite scroll
    if (indexPath.row == self.recipes.count-1) {
        [self getRecipes:^(NSArray *recipes, NSError *error){
            if (recipes) {
                [self.recipes addObjectsFromArray:recipes];
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
            } else {
                UIAlertController *recipeFailure= [UIAlertController alertControllerWithTitle:@"Uh oh!" message:@"Error getting recipes. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){}];
                [recipeFailure addAction:okAction];
                [self presentViewController:recipeFailure animated:YES completion:^{}];
            }
        }];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int totalwidth = self.collectionView.bounds.size.width;
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
         NSIndexPath *indexPath = [self.collectionView indexPathForCell:tappedCell];
         RecipeContainerModel *recipeContainer = self.recipes[indexPath.row];
         detailsController.recipeId = [recipeContainer.recipe.uri componentsSeparatedByString:@"#recipe_"][1]; // recipeId is found after #recipe_ in the uri
         UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
         self.navigationItem.backBarButtonItem = backButton;
     }
 }
@end
