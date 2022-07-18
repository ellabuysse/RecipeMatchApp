//
//  APIManager.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//

#import "APIManager.h"
#import "LikedRecipe.h"
@import Parse;

/*@interface APIManager ()
@property (nonatomic, strong) NSString *app_id;
@property (nonatomic, strong) NSString *app_key;
@end*/

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)getRecipes:( NSString * _Nullable )preferences withCompletion: (void (^)(NSMutableArray *recipe, NSError *error))completion{
    //Do any additional setup after loading the view.
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *app_id = [dict objectForKey: @"app_id"];
    NSString *app_key = [dict objectForKey: @"app_key"];

    NSString *apiString = @"https://api.edamam.com/api/recipes/v2?type=public&q=fruit&app_id=";
    apiString = [apiString stringByAppendingString:app_id];
    apiString = [apiString stringByAppendingString:@"&app_key="];
    apiString = [apiString stringByAppendingString:app_key];
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

+ (void)getIdRecipe:( NSString * _Nullable )recipeId withCompletion: (void (^)(NSDictionary *recipe, NSError *error))completion{
    //Do any additional setup after loading the view.
    
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *app_id = [dict objectForKey: @"app_id"];
    NSString *app_key = [dict objectForKey: @"app_key"];

    NSString *apiString = @"https://api.edamam.com/api/recipes/v2/";
    apiString = [apiString stringByAppendingString:recipeId];
    apiString = [apiString stringByAppendingString:@"?type=public&q=apple&app_id="];
    apiString = [apiString stringByAppendingString:app_id];
    apiString = [apiString stringByAppendingString:@"&app_key="];
    
    NSURL *apiUrl = [NSURL URLWithString:[apiString stringByAppendingString:app_key]];
    
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

+ (void)unfavorite:( NSString * _Nullable )recipeId withCompletion: (void (^)(NSArray *recipes, NSError *error))completion{
    PFQuery *recipeQuery = [LikedRecipe query];
    [recipeQuery includeKey:@"user"];
    [recipeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [recipeQuery whereKey:@"recipeId" equalTo:recipeId];

    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound) {
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

+ (void)postLikedRecipe:( NSString * _Nullable )title withId: ( NSString * _Nullable )recipeId withImage: (NSString * _Nullable )image withCompletion: (PFBooleanResultBlock  _Nullable)completion{
    
    [self beforeSave:recipeId withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded == NO){
            NSLog(@"user already favorited");
            completion(NO, error);
        }
        else{
            LikedRecipe *newRecipe = [LikedRecipe new];
            newRecipe.name = title;
            newRecipe.recipeId = recipeId;
            newRecipe.image = image;
            newRecipe.user = [PFUser currentUser];

            [newRecipe saveInBackgroundWithBlock: completion];
        }
    }];
}

+(void)beforeSave:( NSString * _Nullable )recipeId withCompletion: (void (^)(BOOL succeeded, NSError *error))completion{
    PFQuery *recipeQuery = [LikedRecipe query];
    [recipeQuery includeKey:@"user"];
    [recipeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [recipeQuery whereKey:@"recipeId" equalTo:recipeId];

    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
        if (recipesFound.count != 0) {
            // do something with the data fetched
            completion(NO, error);
        }
        else {
            completion(YES, nil);
        }
    }];
}

+ (void)fetchLikedRecipes:(void (^)(NSArray *recipes, NSError *error))completion{
    PFQuery *recipeQuery = [LikedRecipe query];
    [recipeQuery orderByDescending:@"createdAt"];
    [recipeQuery includeKey:@"user"];
    [recipeQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    // fetch data asynchronously
    [recipeQuery findObjectsInBackgroundWithBlock:^(NSArray<LikedRecipe *> * _Nullable recipesFound, NSError * _Nullable error) {
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
