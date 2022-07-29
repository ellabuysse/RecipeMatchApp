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

NSString* const BASE_API_URL = @"https://api.edamam.com/api/recipes/v2";
NSString* const BASE_API_PARAMS = @"?type=public&random=true&health=alcohol-free";
NSString* const BASE_QUERY = @"&health=alcohol-free";
NSString* const USER_KEY = @"user";
NSString* const USERNAME_KEY = @"username";
NSString* const ID_KEY = @"recipeId";
NSString* const APP_ID_KEY = @"app_id";
NSString* const APP_ID_PARAM = @"&app_id=";
NSString* const APP_KEY_PARAM = @"&app_key=";
NSString* const APP_KEY = @"app_key";
NSString* const LIKED_RECIPE_TYPE = @"LikedRecipe";
NSString* const SAVED_RECIPE_TYPE = @"SavedRecipe";
const int MIN_RECIPE_COUNT = 100; // minimum number of recipes where repetition is unlikely

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

// creates NSURL session and returns NSDictionary result on completion
- (void)requestFromAPIWithURL:(NSURL *)url andCompletion:(void (^)(NSDictionary *dataDictionary, NSError *error))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               completion(nil, error);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               completion(dataDictionary, nil);
           };
    }];
    [task resume];
}

// creates PFQuery for Parse search
+ (PFQuery *)createQueryWithID:(NSString *)recipeId type:(NSString *)type withUser:(BOOL)withUser {
    PFQuery *recipeQuery;
    if ([type isEqualToString:SAVED_RECIPE_TYPE]) {
        recipeQuery = [SavedRecipe query];
    } else if ([type isEqualToString:LIKED_RECIPE_TYPE]) {
        recipeQuery = [LikedRecipe query];
    }
    [recipeQuery includeKey:USER_KEY];
    [recipeQuery orderByDescending:@"createdAt"];
    if (withUser) {
        [recipeQuery whereKey:USERNAME_KEY equalTo:[[PFUser currentUser] username]];
    }
    if (recipeId != nil) {
        [recipeQuery whereKey:ID_KEY equalTo:recipeId];
    }
    return recipeQuery;
}

// gets initial array of recipes for home feed from recipe API
// returns recipes on success, nil on failure
- (void)getRecipesWithPreferences:(NSString * _Nullable)preferences andCompletion:(void (^)(NSMutableArray *recipe, NSError *error))completion {
    NSString *apiString = [BASE_API_URL stringByAppendingString:BASE_API_PARAMS];
    apiString = [apiString stringByAppendingString:APP_ID_PARAM];
    apiString = [apiString stringByAppendingString:self.app_id];
    apiString = [apiString stringByAppendingString:APP_KEY_PARAM];
    apiString = [apiString stringByAppendingString:self.app_key];
    if (preferences) {
        apiString = [apiString stringByAppendingString: preferences];
    }
    NSURL *url = [NSURL URLWithString:apiString];
    [self requestFromAPIWithURL:url andCompletion:^(NSDictionary *dataDictionary, NSError *error) {
        int count = [dataDictionary[@"count"] integerValue];
        if (count > MIN_RECIPE_COUNT) {
            /* if the total count of recipes returned is large enough,
               numerous random calls to the API are unlikely to produce repeated recipes.
               we want variation in the recipes, not the same ones shown repeatedly */
            completion(dataDictionary[@"hits"], nil);
        } else {
            /* if there are not enough recipes returned, handle the restricting preferences in the caller */
            completion(nil, error);
        }
    }];
}

// gets array of recipes with query from recipe API
// returns recipes on success, nil on failure
- (void)getRecipesWithQuery:(NSString * _Nullable)query andCompletion: (void (^)(NSMutableArray *recipes, NSError *error))completion{
    NSString *apiString = [BASE_API_URL stringByAppendingString:BASE_API_PARAMS];
    apiString = [apiString stringByAppendingString:APP_ID_PARAM];
    apiString = [apiString stringByAppendingString:self.app_id];
    apiString = [apiString stringByAppendingString:APP_KEY_PARAM];
    apiString = [apiString stringByAppendingString:self.app_key];
    if(query){
        apiString = [apiString stringByAppendingString:@"&q="];
        query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]]; // remove spaces and extra characters
        apiString = [apiString stringByAppendingString: query];
    }
    NSURL *url = [NSURL URLWithString:apiString];
    [self requestFromAPIWithURL:url andCompletion:^(NSDictionary *dataDictionary, NSError *error) {
        int count = (int)[dataDictionary[@"count"] integerValue];
        if(count > MIN_RECIPE_COUNT){
            completion(dataDictionary[@"hits"], nil);
        } else{
            completion(nil, error);
        }
    }];
}

// gets specific recipe by id from recipe API
// returns recipe on success, nil on failure
- (void)getRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(NSDictionary *recipe, NSError *error))completion {
    NSString *apiString = BASE_API_URL;
    apiString = [apiString stringByAppendingString:@"/"];
    apiString = [apiString stringByAppendingString:recipeId];
    apiString = [apiString stringByAppendingString:BASE_API_PARAMS];
    apiString = [apiString stringByAppendingString:APP_ID_PARAM];
    apiString = [apiString stringByAppendingString:self.app_id];
    apiString = [apiString stringByAppendingString:APP_KEY_PARAM];
    NSURL *apiUrl = [NSURL URLWithString:[apiString stringByAppendingString:self.app_key]];
    [self requestFromAPIWithURL:apiUrl andCompletion:^(NSDictionary *dataDictionary, NSError *error) {
        if (dataDictionary) {
            completion(dataDictionary[@"recipe"], nil);
        } else {
            completion(nil, error);
        }
    }];
}

// removes recipe from SavedRecipe Parse class
// returns YES is recipe was unsaved, NO if encountered error
+ (void)unsaveRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion {
    PFQuery *recipeQuery = [self createQueryWithID:recipeId type:SAVED_RECIPE_TYPE withUser:YES];
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            [PFObject deleteAllInBackground:recipesFound];
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

// removes recipe from LikedRecipe Parse class
// returns YES is recipe was unliked, NO if encountered error
+ (void)unlikeRecipeWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion{
    PFQuery *recipeQuery = [self createQueryWithID:recipeId type:LIKED_RECIPE_TYPE withUser:YES];
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            [PFObject deleteAllInBackground:recipesFound];
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

// adds recipe to SavedRecipe Parse class
// returns YES on success, NO on failure
+ (void)postSavedRecipeWithId:recipeId title:(NSString * _Nullable)title image:(NSString * _Nullable )image andCompletion: (PFBooleanResultBlock  _Nullable)completion {
    SavedRecipe *newRecipe = [SavedRecipe new];
    newRecipe.name = title;
    newRecipe.recipeId = recipeId;
    newRecipe.image = image;
    newRecipe.username = [PFUser currentUser].username;
    [newRecipe saveInBackgroundWithBlock: completion];
}

// adds recipe to LikedRecipe Parse class
// returns YES on success, NO on failure
+ (void)postLikedRecipeWithId:recipeId title:(NSString * _Nullable)title image:(NSString * _Nullable)image andCompletion: (PFBooleanResultBlock  _Nullable)completion {
    LikedRecipe *newRecipe = [LikedRecipe new];
    newRecipe.name = title;
    newRecipe.recipeId = recipeId;
    newRecipe.image = image;
    newRecipe.username = [[PFUser currentUser] username];
    [newRecipe saveInBackgroundWithBlock: completion];
}

// checks if recipe is liked by current user in LikedRecipe Parse class
// returns YES if recipe is liked, NO if recipe is not liked
+ (void)checkIfRecipeIsAlreadyLikedWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion {
    PFQuery *recipeQuery = [self createQueryWithID:recipeId type:LIKED_RECIPE_TYPE withUser:YES];
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

// count number of times recipe is saved in SavedRecipe Parse class
// return number of saves of recipe
+ (void)countSavesWithId:(NSString * _Nullable )recipeId andCompletion:(void (^)(int likes, NSError *error))completion {
    PFQuery *recipeQuery = [self createQueryWithID:recipeId type:SAVED_RECIPE_TYPE withUser:NO];
    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound) {
            completion(recipesFound.count, nil);
        } else{
            completion(0, error);
        }
    }];
}

// check if recipe is saved by current user in SavedRecipe Parse class
// return YES if recipe is saved, NO if recipe is not saved
+ (void)checkIfRecipeIsAlreadySavedWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(BOOL succeeded, NSError *error))completion {
    PFQuery *recipeQuery = [self createQueryWithID:recipeId type:SAVED_RECIPE_TYPE withUser:YES];
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            completion(YES, nil);
        } else {
            completion(NO, error);
        }
    }];
}

// counts number of times recipe is liked in LikedRecipe Parse class
// returns number of likes of recipe
+ (void)countLikesWithId:(NSString * _Nullable)recipeId andCompletion:(void (^)(int likes, NSError *error))completion {
    PFQuery *recipeQuery = [self createQueryWithID:recipeId type:LIKED_RECIPE_TYPE withUser:NO];
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound) {
            completion(recipesFound.count, nil);
        } else{
            completion(0, error);
        }
    }];
}

// get all saved recipes of current user from SavedRecipe Parse class
// return recipes on success, nil on failure
+ (void)fetchSavedRecipes:(void (^)(NSArray *recipes, NSError *error))completion {
    PFQuery *recipeQuery = [self createQueryWithID:nil type:SAVED_RECIPE_TYPE withUser:YES];
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound) {
            completion(recipesFound,nil);
        } else {
            completion(nil,error);
        }
    }];
}
@end
