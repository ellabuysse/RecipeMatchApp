//
//  DraggableViewBackground.m
//  RKSwipeCards
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "DraggableView.h"
#import "OverlayView.h"
#import "APIManager.h"
#import "StreamViewController.h"
#import "SDWebImage/SDWebImage.h"
#import "RecipeModel.h"

@interface DraggableViewBackground ()
@end

@implementation DraggableViewBackground {
    NSInteger loadedCardsIndex; // the index of the last card loaded into the loadedCards array
    NSMutableArray *loadedCards; // the array of cards loaded
    NSMutableArray *allCards; // current cards being added to loadedCards to display on screen
    NSMutableArray *preppedCards; // cards loaded and prepped to be added to allCards when it runs out of cards
    NSInteger currentCardIndex; // index of current card out of all cards
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* saveButton;
    UIButton* xButton;
    UIButton* heartButton;
}

static const int MAX_BUFFER_SIZE = 2; // max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 465; // height of the draggable card
static const float CARD_WIDTH = 350; // width of the draggable card
static const float CARD_YPOS = 150;
static const float BTN_HEIGHT = 60;
static const float MIDDLE_BTN_OFFSET = 20;
static const float BTN_YPOS = CARD_YPOS + CARD_HEIGHT + 30;
static const float LEFT_BTN_XPOS = 40;
static const float MIDDLE_BTN_XPOS = 155;
static const float RIGHT_BTN_XPOS = 290;
static const float LOAD_OFFSET = 7; // number of cards left in allCards when new cards begin loading
NSString* const HEART_FILL_IMG = @"heart-btn-filled";
NSString * const HEART_IMG = @"heart-btn";
NSString* const SAVE_FILL_IMG = @"save-btn-filled";
NSString * const SAVE_IMG = @"save-btn";

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
    }
    return self;
}

// called after recipes are loaded initially from StreamViewController
- (void)reloadView {
    loadedCards = [[NSMutableArray alloc] init];
    allCards = [[NSMutableArray alloc] init];
    preppedCards = [[NSMutableArray alloc] init];
    loadedCardsIndex = 0;
    currentCardIndex = 0;
    [self setupView];
    [self loadCards];
    [self swapCards];
    [self showLoadedCards];
    [self updateValues];
}

// called when recipe cards are needed on the screen
// swaps cards from preppedCards to allCards
- (void)swapCards {
    [allCards addObjectsFromArray:preppedCards];
    [preppedCards removeAllObjects];
}

- (void)updateValues {
    [self updateHeartBtn];
    [self updateLikeCount];
    [self updateSaveBtn];
    [self updateSaveCount];
}

// sets up the extra buttons on the screen
- (void)setupView {
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(LEFT_BTN_XPOS, BTN_YPOS, BTN_HEIGHT, BTN_HEIGHT)];
    [xButton setImage:[UIImage imageNamed:@"x-btn"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    
    heartButton = [[UIButton alloc]initWithFrame:CGRectMake(MIDDLE_BTN_XPOS, BTN_YPOS-MIDDLE_BTN_OFFSET/2, BTN_HEIGHT + MIDDLE_BTN_OFFSET, BTN_HEIGHT + MIDDLE_BTN_OFFSET)];
    [heartButton setImage:[UIImage imageNamed:HEART_IMG] forState:UIControlStateNormal];
    [heartButton addTarget:self action:@selector(tapLike:) forControlEvents:UIControlEventTouchUpInside];
    
    saveButton = [[UIButton alloc]initWithFrame:CGRectMake(RIGHT_BTN_XPOS, BTN_YPOS, BTN_HEIGHT, BTN_HEIGHT)];
    [saveButton setImage:[UIImage imageNamed:SAVE_IMG] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:xButton];
    [self addSubview:heartButton];
    [self addSubview:saveButton];
}

// creates a card and returns it
- (DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index {
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, CARD_YPOS, CARD_WIDTH, CARD_HEIGHT)];
    RecipeContainerModel *recipeContainer = [self.recipes objectAtIndex:index];
    draggableView.title.text = recipeContainer.recipe.label;
    NSString *recipeUri = recipeContainer.recipe.uri;
    draggableView.recipeId = [recipeUri componentsSeparatedByString:@"#recipe_"][1]; // recipeId is found after #recipe_ in the uri
    draggableView.imageUrl = recipeContainer.recipe.image;
    [draggableView.recipeImage sd_setImageWithURL:[NSURL URLWithString:draggableView.imageUrl] placeholderImage:nil];
    draggableView.delegate = self;
    draggableView.likeCount.text = nil;
    draggableView.saveCount.text = nil;
    draggableView.saveLabel.hidden = YES;
    draggableView.likeLabel.hidden = YES;
    return draggableView;
}

// loads all the cards and puts the first x in the "loaded cards" array
- (void)loadCards {
    if([self.recipes count] > 0) {
        // loops through the recipes array to create a card for each recipe
        for (int i = 0; i<[self.recipes count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [preppedCards addObject:newCard];
        }
    }
}

// called initially when page loads to populate loadedCards array and show loaded cards
- (void)showLoadedCards {
    // adds a small number of cards from allCards to be loaded
    NSInteger numLoadedCardsCap = (([self.recipes count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[self.recipes count]);
    NSInteger cardIndex = 0;
    while (cardIndex<numLoadedCardsCap) {
        [loadedCards addObject:[allCards objectAtIndex:cardIndex]];
        cardIndex++;
    }
    
    // displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
    // are showing at once and clogging a ton of data
    for (int i = 0; i<[loadedCards count]; i++) {
        if (i>0) {
            [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
        } else {
            [self addSubview:[loadedCards objectAtIndex:i]];
        }
        loadedCardsIndex++; // we loaded a card into loaded cards, so we have to increment
    }
}

// when you hit the right button, this is called and substitutes the swipe
- (void)swipeRight {
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [self rightClickAction];
}

// when you hit the left button, this is called and substitutes the swipe
- (void)swipeLeft {
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [self leftClickAction];
}

// swipe animation called on right click
- (void)rightClickAction {
    DraggableView *dragView = [loadedCards firstObject];
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         dragView.center = finishPoint;
                         dragView.transform = CGAffineTransformMakeRotation(1);
                     } completion:^(BOOL complete) {
                         [dragView removeFromSuperview];
                     }];
    
    [self draggableViewCardSwipedRight:dragView];
}

// swipe animation called on left click
- (void)leftClickAction {
    DraggableView *dragView = [loadedCards firstObject];
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         dragView.center = finishPoint;
                         dragView.transform = CGAffineTransformMakeRotation(-1);
                     } completion:^(BOOL complete) {
                         [dragView removeFromSuperview];
                     }];

    [self draggableViewCardSwipedLeft:dragView];
}

#pragma mark - DraggableViewBackgroundDelegate

// updates like count for each card
- (void)updateLikeCount {
    DraggableView *card = [self->loadedCards objectAtIndex:0];
    [delegate countLikesFromDraggableViewBackgroundWithId:card.recipeId andCompletion:^(NSUInteger likes, NSError * _Nullable error) {
        if (likes) {
            card.likeCount.text = [[NSString alloc] initWithFormat:@"%lu", likes];
            card.likeLabel.hidden = NO;
        } else {
            card.likeCount.text = nil;
            card.likeLabel.hidden = YES;
        }
    }];
}

// updates heart button for each card to show like status
- (void)updateHeartBtn {
    DraggableView *nextCard = [self->loadedCards objectAtIndex:0];
    [delegate checkLikeStatusFromDraggableViewBackground:nextCard withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self->heartButton setImage:[UIImage imageNamed:HEART_FILL_IMG] forState:UIControlStateNormal];
        } else {
            [self->heartButton setImage:[UIImage imageNamed:HEART_IMG] forState:UIControlStateNormal];
        }
    }];
}

// updates save count for each card
- (void)updateSaveCount {
    DraggableView *card = [self->loadedCards objectAtIndex:0];
    [delegate countSavesFromDraggableViewBackgroundWithId:card.recipeId andCompletion:^(NSUInteger saves, NSError * _Nullable error) {
        if (saves) {
            card.saveCount.text = [[NSString alloc] initWithFormat:@"%lu", saves];
            card.saveLabel.hidden = NO;
        } else {
            card.saveCount.text = nil;
            card.saveLabel.hidden = YES;
        }
    }];
}

// updates save button for each card to show save status
- (void)updateSaveBtn {
    DraggableView *nextCard = [self->loadedCards objectAtIndex:0];
    [delegate checkSaveStatusFromDraggableViewBackground:nextCard withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self->saveButton setImage:[UIImage imageNamed:SAVE_FILL_IMG] forState:UIControlStateNormal];
        } else {
            [self->saveButton setImage:[UIImage imageNamed:SAVE_IMG] forState:UIControlStateNormal];
        }
    }];
}

// called after each card swipe to determine if more cards are needed
- (void)checkCardIndexStatus {
    if (currentCardIndex == [allCards count]-LOAD_OFFSET) { // start loading more cards into preppedCards
        [delegate getMoreRecipesFromDraggableViewBackgroundWithCompletion:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self loadCards];
            } else {
                [self->delegate showAlertWithMessage:@"Error loading recipes. Please try again later."];
            }
        }];
    } else if (currentCardIndex == [allCards count]-1) { // no cards left -> reset indices and swap new cards in
        loadedCardsIndex = 0;
        currentCardIndex = 0;
        [allCards removeAllObjects];
        [self swapCards];
    }
}

#pragma mark - DraggableViewDelegate methods

// action called when the card goes to the left.
- (void)draggableViewCardSwipedLeft:(UIView *)card {
    [loadedCards removeObjectAtIndex:0]; // card was swiped, so it's no longer a "loaded card"
    self->currentCardIndex++;
    [self checkCardIndexStatus];
    if (loadedCardsIndex < [allCards count]) { // if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:loadedCardsIndex]];
        loadedCardsIndex++;// loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        [self updateValues];
    }
}

// action called when the card goes to the right.
- (void)draggableViewCardSwipedRight:(UIView *)cardSwiped {
    DraggableView *card = (DraggableView *)cardSwiped;
    [delegate checkSaveStatusFromDraggableViewBackground:card withCompletion:^(BOOL saved, NSError * _Nullable error){
        if (!saved) {
            [self.delegate postSavedRecipeFromDraggableViewBackgroundWithId:card.recipeId title:card.title.text image:card.imageUrl andCompletion:^(BOOL succeeded, NSError * _Nullable error){}];
        }
    }];
    [loadedCards removeObjectAtIndex:0]; // card was swiped, so it's no longer a "loaded card"
    if (loadedCardsIndex < [allCards count]) { // if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:loadedCardsIndex]];
        loadedCardsIndex++; // loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    self->currentCardIndex++;
    [self checkCardIndexStatus];
    [self updateValues];
}

// called when like button is tapped
- (void)tapLike:(id)sender {
    DraggableView *card = [loadedCards firstObject];
    [delegate checkLikeStatusFromDraggableViewBackground:card withCompletion:^(BOOL liked, NSError * _Nullable error){
        if (liked) {
            [self.delegate unlikeRecipeFromDraggableViewBackgroundWithId:card.recipeId andCompletion:^(BOOL succeeded, NSError * _Nonnull error) {
                if (succeeded) {
                    [self->heartButton setImage:[UIImage imageNamed:HEART_IMG] forState:UIControlStateNormal];
                    [self updateLikeCount];
                }
            }];
        } else {
            [self.delegate postLikedRecipeFromDraggableViewBackgroundWithId:card.recipeId recipeTitle:card.title.text image:card.imageUrl andCompletion:^(BOOL succeeded, NSError * _Nonnull error) {
                if (succeeded) {
                    [self->heartButton setImage:[UIImage imageNamed:HEART_FILL_IMG] forState:UIControlStateNormal];
                    [self updateLikeCount];
                }
            }];
        }
    }];
}

- (void)draggableViewDidTapOnDetails {
    DraggableView *card = [loadedCards firstObject];
    [delegate showDetailsFromDraggableViewBackground:card];
}

- (void)draggableViewDidTapLike {
    DraggableView *card = [loadedCards firstObject];
    [self tapLike:card];
}
@end
