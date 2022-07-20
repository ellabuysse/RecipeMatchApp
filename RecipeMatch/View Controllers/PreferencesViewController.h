//
//  PreferencesViewController.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/13/22.
//

#import <UIKit/UIKit.h>
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

NS_ASSUME_NONNULL_BEGIN

@protocol PreferencesViewControllerDelegate <NSObject>
@required
- (void)sendData:(NSString *)request;
@end

@interface PreferencesViewController : UIViewController
@property(nonatomic,assign)id<PreferencesViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
