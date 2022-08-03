//
//  PreferencesViewController.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/13/22.
//

#import <UIKit/UIKit.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

NS_ASSUME_NONNULL_BEGIN

extern NSString* const CUISINE_KEY;
extern NSString* const HEALTH_KEY;
extern NSString* const DIET_KEY;
extern NSString* const MEAL_TYPE_KEY;

@protocol PreferencesViewControllerDelegate <NSObject>
@required
- (void)sendPreferences:(NSDictionary *)preferences;
@end

@interface PreferencesViewController : UIViewController
@property(nonatomic,assign) id<PreferencesViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *preferencesDict;
@end

NS_ASSUME_NONNULL_END
