//
//  ProfileCollectionReusableView.h
//  RecipeMatch
//
//  Created by ellabuysse on 8/5/22.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ProfileCollectionReusableViewDelegate <NSObject>
@required
- (void)segmentedControlDidChange;
@end

@interface ProfileCollectionReusableView : UICollectionReusableView
@property (weak) id <ProfileCollectionReusableViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

NS_ASSUME_NONNULL_END
