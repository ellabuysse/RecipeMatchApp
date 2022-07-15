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

    self.app_id = [dict objectForKey: @"app_id"];
    self.app_key = [dict objectForKey: @"app_key"];
    
    return self;
}

// get initial array of recipes for home feed from recipe API
- (void)getRecipesWithPreferences:( NSString * _Nullable )preferences andCompletion: (void (^)(NSMutableArray *recipe, NSError *error))completion{
    //Do any additional setup after loading the view.
    
    NSString *apiString = @"https://api.edamam.com/api/recipes/v2?type=public&q=fruit&app_id=";
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
               NSLog(@"%@", [error localizedDescription]);
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

// get specific recipe by id from recipe API
- (void)getRecipeWithId:( NSString * _Nullable )recipeId andCompletion: (void (^)(NSDictionary *recipe, NSError *error))completion{
    //Do any additional setup after loading the view.
    
    NSString *apiString = @"https://api.edamam.com/api/recipes/v2/";
    apiString = [apiString stringByAppendingString:recipeId];
    apiString = [apiString stringByAppendingString:@"?type=public&q=apple&app_id="];
    apiString = [apiString stringByAppendingString:self.app_id];
    apiString = [apiString stringByAppendingString:@"&app_key="];
    NSURL *apiUrl = [NSURL URLWithString:[apiString stringByAppendingString:self.app_key]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:apiUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               completion(nil, error);
               
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

               completion(dataDictionary[@"recipe"], nil);
           };
    }];
    [task resume];
}

// remove recipe from SavedRecipe Parse class
+ (void)unsaveRecipeWithId:( NSString * _Nullable )recipeId andCompletion: (void (^)(NSArray *recipes, NSError *error))completion{
    PFQuery *recipeQuery = [SavedRecipe query];
    [recipeQuery includeKey:@"user"];
    [recipeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [recipeQuery whereKey:@"recipeId" equalTo:recipeId];

    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            // do something with the data fetched
            [PFObject deleteAllInBackground:recipesFound];
            completion(recipesFound, nil);
        }
        else {
            // handle error
            NSLog(@"%@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}

// remove recipe from likes if it exists, otherwise add it
+ (void)didTapLike:( NSString * _Nullable )recipeId withCompletion: (void (^)(NSArray *recipes, NSError *error))completion{
    PFQuery *recipeQuery = [LikedRecipe query];
    [recipeQuery includeKey:@"user"];
    [recipeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [recipeQuery whereKey:@"recipeId" equalTo:recipeId];

    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            // delete recipe from likes
            [PFObject deleteAllInBackground:recipesFound];
            completion(nil, nil);
        }
        else {
            // no recipe found, add it to likes
            [[self shared] getRecipeWithId:recipeId andCompletion:^(NSDictionary *recipe, NSError *error){
                if(recipe){
                    LikedRecipe *newRecipe = [LikedRecipe new];
                    /*newRecipe.name = recipe.name;
                    newRecipe.recipeId = recipe.recipeId;
                    newRecipe.image = recipe.image;
                    newRecipe.user = [PFUser currentUser];

                    [newRecipe saveInBackgroundWithBlock: completion];
                } else {
                    
                }*/
                }
            }];
            
            completion(nil, error);
        }
    }];
}


// add recipe to SavedRecipe Parse class
+ (void)postSavedRecipeWithTitle:( NSString * _Nullable )title andId: ( NSString * _Nullable )recipeId andImage: (NSString * _Nullable )image andCompletion: (PFBooleanResultBlock  _Nullable)completion{
    
    [self checkIfSavedWithId:recipeId andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded == YES){
            NSLog(@"user already favorited");
            completion(NO, error);
        }
        else{
            SavedRecipe *newRecipe = [SavedRecipe new];
            newRecipe.name = title;
            newRecipe.recipeId = recipeId;
            newRecipe.image = image;
            newRecipe.user = [PFUser currentUser];

            [newRecipe saveInBackgroundWithBlock: completion];
        }
    }];
}

// check if recipe is saved by current user in SavedRecipe Parse class
+(void)checkIfSavedWithId:( NSString * _Nullable )recipeId andCompletion: (void (^)(BOOL succeeded, NSError *error))completion{
    PFQuery *recipeQuery = [SavedRecipe query];
    [recipeQuery includeKey:@"user"];
    [recipeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [recipeQuery whereKey:@"recipeId" equalTo:recipeId];

    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            // do something with the data fetched
            completion(YES, nil);
        }
        else {
            completion(NO, error);
        }
    }];
}

// get all saved recipes of current user from SavedRecipe Parse class
+ (void)fetchSavedRecipes:(void (^)(NSArray *recipes, NSError *error))completion{
    PFQuery *recipeQuery = [SavedRecipe query];
    [recipeQuery orderByDescending:@"createdAt"];
    [recipeQuery includeKey:@"user"];
    [recipeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<SavedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound) {
            // do something with the data fetched
            completion(recipesFound,nil);
        }
        else {
            // handle error
            completion(nil,error);
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

@end
