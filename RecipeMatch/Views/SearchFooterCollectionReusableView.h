//
//  SearchFooterCollectionReusableView.h
//  RecipeMatch
//
//  Created by ellabuysse on 7/28/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchFooterCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refreshControl;
@end

NS_ASSUME_NONNULL_END
