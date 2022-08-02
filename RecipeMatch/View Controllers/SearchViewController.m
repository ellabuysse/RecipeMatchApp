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
#import "EmptyCollectionReusableView.h"

@interface SearchViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *recipes;
@property (nonatomic, strong) NSString *searchText;
@property (strong, nonatomic) NSTimer * searchTimer;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) SearchCollectionReusableView *searchView;
@end

@implementation SearchViewController 
static const float MIN_LINE_SPACING = 10;
static const float HEIGHT_FACTOR = 1.2;
static const float MARGIN_SIZE = 7;
static const float HEADER_SIZE = 50;
static const float TIMER_INTERVAL = 0.5;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:EmptyCollectionReusableView.self forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EmptyView"];
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


// called when user stops typing to get recipes
- (void)reloadSearch:(NSTimer *)timer {
    NSString *query = timer.userInfo;    // strong reference
    [self getRecipes:^(NSMutableArray *recipes, NSURLSessionDataTask *dataTask, NSError *error){
        if(recipes && [self.searchText isEqualToString:query]){ // check that the returning call is for the correct current query
            self.recipes = recipes;
            // only reload section 1 to prevent search bar from losing first responder status
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        } else if (recipes) {
            [dataTask cancel];
        } else {
            // TODO: add failure support
        }
    }];
}

- (void)getRecipes:(void (^)(NSMutableArray *recipes, NSURLSessionDataTask *dataTask, NSError *error))completion {
    [[APIManager shared] getRecipesWithQuery:self.searchText andCompletion:^(NSMutableArray *recipes, NSURLSessionDataTask *dataTask, NSError *error) {
        if (recipes) {
            completion(recipes, dataTask, nil);
        } else {
            completion(nil, dataTask, error);
        }
    }];
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
    NSDictionary *recipe = self.recipes[indexPath.row][@"recipe"];
    [cell setupWithRecipeTitle:recipe[@"label"] recipeImageUrl:recipe[@"image"] screenType:Search];
    
    // when the bottom of the page is reached, adds more recipes to array for infinite scroll
    if (indexPath.row == self.recipes.count-1) {
        [self getRecipes:^(NSArray *recipes, NSURLSessionDataTask *dataTask, NSError *error){
            if (recipes) {
                [self.recipes addObjectsFromArray:recipes];
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
            } else {
                //TODO: add failure support
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
         detailsController.recipeId = [self.recipes[indexPath.row][@"recipe"][@"uri"] componentsSeparatedByString:@"#recipe_"][1]; // recipeId is found after #recipe_ in the uri
     }
 }
@end
