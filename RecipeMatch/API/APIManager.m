//
//  APIManager.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//

#import "APIManager.h"
#import "SavedRecipe.h"
#import "LikedRecipe.h"
@import Parse;

@interface APIManager ()
@property (nonatomic, strong) NSString *app_id;
@property (nonatomic, strong) NSString *app_key;
@end

NSString* const FULL_API_STRING = @"https://api.edamam.com/api/recipes/v2?type=public&q=&health=alcohol-free&app_id=";
NSString* const API_STRING_BEFORE_ID = @"https://api.edamam.com/api/recipes/v2/";
NSString* const API_STRING_AFTER_ID = @"?type=public&q=&diet=alcohol-free&app_id=";
NSString* const USER_KEY = @"user";
NSString* const USERNAME_KEY = @"username";
NSString* const ID_KEY = @"recipeId";
NSString* const APP_ID_KEY = @"app_id";
NSString* const APP_KEY = @"app_key";

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    self.app_id = [dict objectForKey:APP_ID_KEY];
    self.app_key = [dict objectForKey:APP_KEY];
    return self;
}

// gets initial array of recipes for home feed from recipe API
// returns recipes on success, nil on failure
- (void)getRecipesWithPreferences:(NSString * _Nullable)preferences andCompletion: (void (^)(NSMutableArray *recipe, NSError *error))completion{
    NSString *apiString = FULL_API_STRING;
    apiString = [apiString stringByAppendingString:self.app_id];
    apiString = [apiString stringByAppendingString:@"&app_key="];
    apiString = [apiString stringByAppendingString:self.app_key];
    if(preferences){
        apiString = [apiString stringByAppendingString: preferences];
    }
    NSURL *url = [NSURL URLWithString:apiString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               completion(nil, error);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSMutableArray *recipes = dataDictionary[@"hits"];
               completion(recipes, nil);
           };
    }];
    [task resume];
}

// gets specific recipe by id from recipe API
// returns recipe on success, nil on failure
- (void)getRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(NSDictionary *recipe, NSError *error))completion{
    NSString *apiString = API_STRING_BEFORE_ID;
    apiString = [apiString stringByAppendingString:recipeId];
    apiString = [apiString stringByAppendingString:API_STRING_AFTER_ID];
    apiString = [apiString stringByAppendingString:self.app_id];
    apiString = [apiString stringByAppendingString:@"&app_key="];
    NSURL *apiUrl = [NSURL URLWithString:[apiString stringByAppendingString:self.app_key]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               completion(nil, error);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               completion(dataDictionary[@"recipe"], nil);
           };
    }];
    [task resume];
}

// removes recipe from SavedRecipe Parse class
// returns YES is recipe was unsaved, NO if encountered error
+ (void)unsaveRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion{
    PFQuery *recipeQuery = [SavedRecipe query];
    [recipeQuery includeKey:USER_KEY];
    [recipeQuery whereKey:USERNAME_KEY equalTo:[[PFUser currentUser] username]];
    [recipeQuery whereKey:ID_KEY equalTo:recipeId];

    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            // do something with the data fetched
            [PFObject deleteAllInBackground:recipesFound];
            completion(YES, nil);
        }
        else {
            completion(NO, error);
        }
    }];
}

// removes recipe from LikedRecipe Parse class
// returns YES is recipe was unliked, NO if encountered error
+ (void)unlikeRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion{
    PFQuery *recipeQuery = [LikedRecipe query];
    [recipeQuery includeKey:USER_KEY];
    [recipeQuery whereKey:USERNAME_KEY equalTo:[[PFUser currentUser] username]];
    [recipeQuery whereKey:ID_KEY equalTo:recipeId];

    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            // do something with the data fetched
            [PFObject deleteAllInBackground:recipesFound];
            completion(YES, nil);
        }
        else {
            completion(NO, error);
        }
    }];
}

// adds recipe to SavedRecipe Parse class
// returns YES on success, NO on failure
+ (void)postSavedRecipeWithId:recipeId title:(NSString * _Nullable)title image:(NSString * _Nullable )image andCompletion: (PFBooleanResultBlock  _Nullable)completion{
    SavedRecipe *newRecipe = [SavedRecipe new];
    newRecipe.name = title;
    newRecipe.recipeId = recipeId;
    newRecipe.image = image;
    newRecipe.username = [PFUser currentUser].username;
    [newRecipe saveInBackgroundWithBlock: completion];
}

// adds recipe to LikedRecipe Parse class
// returns YES on success, NO on failure
+ (void)postLikedRecipeWithId:recipeId title:(NSString * _Nullable)title image:(NSString * _Nullable)image andCompletion: (PFBooleanResultBlock  _Nullable)completion{
    LikedRecipe *newRecipe = [LikedRecipe new];
    newRecipe.name = title;
    newRecipe.recipeId = recipeId;
    newRecipe.image = image;
    newRecipe.username = [[PFUser currentUser] username];
    [newRecipe saveInBackgroundWithBlock: completion];
}

// checks if recipe is liked by current user in LikedRecipe Parse class
// returns YES if recipe is liked, NO if recipe is not liked
+ (void)checkIfRecipeIsAlreadyLikedWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion{
    PFQuery *recipeQuery = [LikedRecipe query];
    [recipeQuery includeKey:USER_KEY];
    [recipeQuery whereKey:USERNAME_KEY equalTo:[[PFUser currentUser] username]];
    [recipeQuery whereKey:ID_KEY equalTo:recipeId];

    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            completion(YES, nil);
        }
        else {
            completion(NO, error);
        }
    }];
}

// check if recipe is saved by current user in SavedRecipe Parse class
// return YES if recipe is saved, NO if recipe is not saved
+ (void)checkIfRecipeIsAlreadySavedWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion{
    PFQuery *recipeQuery = [SavedRecipe query];
    [recipeQuery includeKey:USER_KEY];
    [recipeQuery whereKey:USERNAME_KEY equalTo:[[PFUser currentUser] username]];
    [recipeQuery whereKey:ID_KEY equalTo:recipeId];

    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            completion(YES, nil);
        }
        else {
            completion(NO, error);
        }
    }];
}

// counts number of times recipe is liked in LikedRecipe Parse class
// returns number of likes of recipe
+ (void)countLikesWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(int likes, NSError *error))completion{
    PFQuery *recipeQuery = [LikedRecipe query];
    [recipeQuery includeKey:USER_KEY];
    [recipeQuery whereKey:ID_KEY equalTo:recipeId];

    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if(recipesFound){
            completion(recipesFound.count, nil);
        }
        else{
            completion(0, error);
        }
    }];
}

// get all saved recipes of current user from SavedRecipe Parse class
// return recipes on success, nil on failure
+ (void)fetchSavedRecipes:(void (^)(NSArray *recipes, NSError *error))completion{
    PFQuery *recipeQuery = [SavedRecipe query];
    [recipeQuery orderByDescending:@"createdAt"];
    [recipeQuery includeKey:USER_KEY];
    [recipeQuery whereKey:USERNAME_KEY equalTo:[[PFUser currentUser] username]];

    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound) {
            completion(recipesFound,nil);
        }
        else {
            completion(nil,error);
        }
    }];
}
@end
