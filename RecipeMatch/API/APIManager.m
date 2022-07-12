//
//  APIManager.m
//  RecipeMatch
//
//  Created by ellabuysse on 7/8/22.
//

#import "APIManager.h"
#import "LikedRecipe.h"
@import Parse;

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)getRecipes:(void(^)(NSArray *recipes, NSError *error))completion{
    //Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:@"https://api.edamam.com/api/recipes/v2?type=public&q=apple&app_id=00fb2355&app_key=1020f34ec9260531e5ad653a90e2d111"];
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
    NSString *url1 = @"https://api.edamam.com/api/recipes/v2/";
    NSString *url2 = [url1 stringByAppendingString:recipeId];
    NSURL *url3 = [NSURL URLWithString:[url2 stringByAppendingString:@"?type=public&q=apple&app_id=00fb2355&app_key=1020f34ec9260531e5ad653a90e2d111"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url3 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               completion(nil, error);
               
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

               //NSMutableArray *recipes = dataDictionary[@"hits"];
   
               completion(dataDictionary[@"recipe"], nil);

           };
}];
    [task resume];
}


-(void)getRecipeWithId:(void (^)(NSDictionary *recipe, NSError *error))completion{
    //Do any additional setup after loading the view.
    NSString *url1 = @"https://api.edamam.com/api/recipes/v2/";
    NSString *url2 = [url1 stringByAppendingString:@"6827973e840bf759a1b26e9431cfe0ab"];
    NSURL *url3 = [NSURL URLWithString:[url2 stringByAppendingString:@"?type=public&q=apple&app_id=00fb2355&app_key=1020f34ec9260531e5ad653a90e2d111"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url3 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               completion(nil, error);
               
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

               //NSMutableArray *recipes = dataDictionary[@"hits"];
   
               completion(dataDictionary[@"recipe"], nil);

           };
}];
    [task resume];
}

@end
