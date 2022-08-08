//
//  ProfileCollectionReusableView.m
//  RecipeMatch
//
//  Created by ellabuysse on 8/5/22.
//

#import "ProfileCollectionReusableView.h"

@implementation ProfileCollectionReusableView
@synthesize delegate;

- (IBAction)segmentedControlDidChange:(id)sender {
    [delegate segmentedControlDidChange];
}

@end
