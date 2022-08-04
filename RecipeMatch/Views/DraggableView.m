//
//  DraggableView.m
//  RKSwipeCards
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 // distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 // how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 // upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 // the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 // strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 // Higher = stronger rotation angle

#import "DraggableView.h"
#import "APIManager.h"
#import "DraggableViewBackground.h"

@interface DraggableView ()
@end

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

static const float SUBTITLE_Y_OFFSET = 120;
static const float TITLE_Y_OFFSET = 80;
static const float IMAGE_SIZE = 325;
static const float CORNER_RADIUS = 15;
static const float OVERLAY_SIZE = 100;
static const float LABEL_HEIGHT = 30;
static const float LABEL_X_OFFSET = 20;
static const float SAVES_X_OFFSET = 85;
static const float LABEL_WIDTH = 50;
static const float IMAGE_X_OFFSET = 10;
static const float SHORT_LABEL_WIDTH = 15;
static const float FONT_SIZE = 16;
static const float TITLE_X_OFFSET = 20;

@synthesize delegate; // delegate is instance of DraggableViewBackground
@synthesize panGestureRecognizer;
@synthesize title;
@synthesize recipeId;
@synthesize recipeImage;
@synthesize imageUrl;
@synthesize overlayView;
@synthesize likeLabel;
@synthesize likeCount;
@synthesize saveLabel;
@synthesize saveCount;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        self.backgroundColor = [UIColor whiteColor];

        likeCount = [[UILabel alloc]initWithFrame:CGRectMake(LABEL_X_OFFSET, self.frame.size.height - SUBTITLE_Y_OFFSET, SHORT_LABEL_WIDTH, LABEL_HEIGHT)];
        likeCount.textColor = [UIColor grayColor];
        [likeCount setText:@"0"];
        [[self likeCount] setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [self addSubview:likeCount];

        likeLabel = [[UILabel alloc]initWithFrame:CGRectMake(LABEL_X_OFFSET + 15, self.frame.size.height - SUBTITLE_Y_OFFSET, LABEL_WIDTH, LABEL_HEIGHT)];
        likeLabel.textColor = [UIColor grayColor];
        [likeLabel setText:@"LIKES"];
        [[self likeLabel] setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [self addSubview:likeLabel];

        title = [[UILabel alloc]initWithFrame:CGRectMake(TITLE_X_OFFSET, self.frame.size.height - TITLE_Y_OFFSET, self.frame.size.width - TITLE_X_OFFSET * 2, LABEL_HEIGHT * 2)];
        title.lineBreakMode = NSLineBreakByWordWrapping;
        title.numberOfLines = 0;
        title.textColor = [UIColor blackColor];
        [[self title] setFont:[UIFont systemFontOfSize:FONT_SIZE+2]];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];

        saveCount = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - SAVES_X_OFFSET, self.frame.size.height - SUBTITLE_Y_OFFSET, SHORT_LABEL_WIDTH, LABEL_HEIGHT)];
        saveCount.textColor = [UIColor grayColor];
        [saveCount setText:@"0"];
        [[self saveCount] setFont:[UIFont systemFontOfSize:16]];
        [self addSubview:saveCount];

        saveLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - SAVES_X_OFFSET + 15, self.frame.size.height - SUBTITLE_Y_OFFSET, LABEL_WIDTH, LABEL_HEIGHT)];
        saveLabel.textColor = [UIColor grayColor];
        [saveLabel setText:@"SAVES"];
        [[self saveLabel] setFont:[UIFont systemFontOfSize:16]];
        [self addSubview:saveLabel];
        
        recipeImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - IMAGE_SIZE)/2, IMAGE_X_OFFSET, IMAGE_SIZE, IMAGE_SIZE)];
        recipeImage.translatesAutoresizingMaskIntoConstraints = NO;
        [recipeImage setContentMode:UIViewContentModeScaleAspectFill];
        recipeImage.layer.masksToBounds = YES;
        recipeImage.layer.cornerRadius = CORNER_RADIUS;
        [self addSubview:recipeImage];
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        [self addGestureRecognizer:panGestureRecognizer];
        
        // show details on single tap
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDetails)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];

        // like recipe on double tap
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];

        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-OVERLAY_SIZE, 0, OVERLAY_SIZE, OVERLAY_SIZE)];
        overlayView.alpha = 0;
        [self addSubview:overlayView];
    }
    return self;
}

- (void)didTapDetails {
    [delegate draggableViewDidTapOnDetails];
}

- (void)didDoubleTap {
    [delegate draggableViewDidTapLike];
}

- (void)setupView {
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

// called when you move your finger across the screen.
// called many times a second
- (void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer {
    // this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; // positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; // positive for up, negative for down
    
    //checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            // just started swiping
        case UIGestureRecognizerStateBegan: {
            self.originalPoint = self.center;
            break;
        };
            // in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            // dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            // degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            // amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            // move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            // rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            // scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            // apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
        // let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

// checks to see if you are moving right or left and applies the correct overlay image
- (void)updateOverlay:(CGFloat)distance {
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
    }
    overlayView.alpha = MIN(fabs(distance)/100, 0.4);
}

// called when the card is let go
- (void)afterSwipeAction {
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             self->overlayView.alpha = 0;
        }];
    }
}

#pragma mark - DraggableViewDelegate

// called when a swipe exceeds the ACTION_MARGIN to the right
- (void)rightAction {
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate draggableViewCardSwipedRight:self];
}

// called when a swip exceeds the ACTION_MARGIN to the left
- (void)leftAction {
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate draggableViewCardSwipedLeft:self];
}
@end
