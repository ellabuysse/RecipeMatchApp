//
//  StreamViewController.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "PreferencesViewController.h"
#import "DraggableViewBackground.h"

NS_ASSUME_NONNULL_BEGIN

@interface StreamViewController : UIViewController <PreferencesViewControllerDelegate>
@property NSMutableArray *recipes;

@end


NS_ASSUME_NONNULL_END
