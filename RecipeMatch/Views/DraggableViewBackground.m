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

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; // the index of the last card loaded into the loadedCards array
    NSMutableArray *loadedCards; // the array of card loaded
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    UIButton* heartButton;
}

static const int MAX_BUFFER_SIZE = 2; // max number of cards loaded at any given time
static const float CARD_HEIGHT = 425; // height of the draggable card
static const float CARD_WIDTH = 325; // width of the draggable card
static const float BTN_HEIGHT = 60;
static const float MIDDLE_BTN_OFFSET = 20;
static const float BTN_YPOS = CARD_HEIGHT + 225;
static const float LEFT_BTN_XPOS = 60;
static const float MIDDLE_BTN_XPOS = 155;
static const float RIGHT_BTN_XPOS = 270;
static const float ID_INDEX = 51;

@synthesize allCards;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
    }
    return self;
}

// load cards after recipes are loaded from StreamViewController
- (void)reload{
    [self setupView];
    loadedCards = [[NSMutableArray alloc] init];
    allCards = [[NSMutableArray alloc] init];
    cardsLoadedIndex = 0;
    [self loadCards];
    DraggableView *nextCard = [self->loadedCards objectAtIndex:0];
    [self updateHeartBtn:nextCard];
    [self updateLikeCount:nextCard];
}

// sets up the extra buttons on the screen
- (void)setupView{
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(LEFT_BTN_XPOS, BTN_YPOS, BTN_HEIGHT, BTN_HEIGHT)];
    [xButton setImage:[UIImage imageNamed:@"x-btn"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    
    heartButton = [[UIButton alloc]initWithFrame:CGRectMake(MIDDLE_BTN_XPOS, BTN_YPOS-MIDDLE_BTN_OFFSET/2, BTN_HEIGHT + MIDDLE_BTN_OFFSET, BTN_HEIGHT + MIDDLE_BTN_OFFSET)];
    [heartButton setImage:[UIImage imageNamed:@"heart-btn"] forState:UIControlStateNormal];
    [heartButton addTarget:self action:@selector(tapLike:) forControlEvents:UIControlEventTouchUpInside];
    
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(RIGHT_BTN_XPOS, BTN_YPOS, BTN_HEIGHT, BTN_HEIGHT)];
    [checkButton setImage:[UIImage imageNamed:@"save-btn"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:xButton];
    [self addSubview:heartButton];
    [self addSubview:checkButton];
}

// creates a card and returns it
- (DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT - MIDDLE_BTN_OFFSET)/2, CARD_WIDTH, CARD_HEIGHT)];
    draggableView.title.text = [self.recipes objectAtIndex:index][@"recipe"][@"label"];
    draggableView.recipeId = [self.recipes objectAtIndex:index][@"recipe"][@"uri"];
    draggableView.url = [self.recipes objectAtIndex:index][@"recipe"][@"url"];
    draggableView.ingredients = [self.recipes objectAtIndex:index][@"recipe"][@"ingredientLines"];
    draggableView.time = [self.recipes objectAtIndex:index][@"recipe"][@"totalTime"];
    draggableView.servings = [self.recipes objectAtIndex:index][@"recipe"][@"yield"];
    NSString *imageUrl = [self.recipes objectAtIndex:index][@"recipe"][@"image"];
    draggableView.imageUrl = imageUrl;
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
    draggableView.recipeImage.image = [UIImage imageWithData: imageData];
    draggableView.delegate = self;
    return draggableView;
}

// loads all the cards and puts the first x in the "loaded cards" array
- (void)loadCards{
    if([self.recipes count] > 0) {
        NSInteger numLoadedCardsCap =(([self.recipes count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[self.recipes count]);
        
        // loops through the exampleCardsLabels array to create a card for each label
        for (int i = 0; i<[self.recipes count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            if (i<numLoadedCardsCap) {
                // adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        // displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; // we loaded a card into loaded cards, so we have to increment
        }
    }
}

// updates heart button for each card to show like status
- (void)updateLikeCount:(DraggableView *)card{
    NSString *shortId = [(NSString *)card.recipeId substringFromIndex:ID_INDEX];
    [delegate countLikesFromDraggableViewBackgroundWithId:shortId andCompletion:^(int likes, NSError * _Nullable error){
        if(likes){
            card.likeCount.text = [[NSString alloc] initWithFormat:@"%d", likes];
        } else{
            card.likeCount.text = [[NSString alloc] initWithFormat:@"%d", 0];
        }
    }];
}

// updates heart button for each card to show like status
- (void)updateHeartBtn:(DraggableView *)nextCard{
    [delegate checkLikeStatusFromDraggableViewBackground:nextCard withCompletion:^(BOOL succeeded, NSError * _Nullable error){
        if(succeeded){
            [self->heartButton setImage:[UIImage imageNamed:@"heart-btn-filled"] forState:UIControlStateNormal];
        } else {
            [self->heartButton setImage:[UIImage imageNamed:@"heart-btn"] forState:UIControlStateNormal];
        }
    }];
}

// action called when the card goes to the left.
- (void)cardSwipedLeft:(UIView *)card;{
    [loadedCards removeObjectAtIndex:0]; // card was swiped, so it's no longer a "loaded card"
    if (cardsLoadedIndex < [allCards count]) { // if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        DraggableView *nextCard = [loadedCards objectAtIndex:0];
        [self updateHeartBtn:nextCard];
        [self updateLikeCount:nextCard];
    }
}

// action called when the card goes to the right.
- (void)cardSwipedRight:(UIView *)cardSwiped{
    DraggableView *card = (DraggableView *)cardSwiped;
    NSString *shortId = [(NSString *)card.recipeId substringFromIndex:ID_INDEX];
    
    [delegate checkLikeStatusFromDraggableViewBackground:card withCompletion:^(BOOL liked, NSError * _Nullable error){
        if(!liked){
            [self.delegate postSavedRecipeFromDraggableViewBackgroundWithId:shortId title:card.title.text image:card.imageUrl andCompletion:^(BOOL succeeded, NSError * _Nullable error){}];
        }
    }];
    [loadedCards removeObjectAtIndex:0]; // card was swiped, so it's no longer a "loaded card"
    if (cardsLoadedIndex < [allCards count]) { // if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++; // loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    DraggableView *nextCard = [loadedCards objectAtIndex:0];
    [self updateHeartBtn:nextCard];
    [self updateLikeCount:nextCard];
}

// called when like button is tapped
- (void)tapLike:(id)sender{
    DraggableView *card = [loadedCards firstObject];
    NSString *shortId = [(NSString *)card.recipeId substringFromIndex:ID_INDEX];
    
    [delegate checkLikeStatusFromDraggableViewBackground:card withCompletion:^(BOOL liked, NSError * _Nullable error){
        if(liked){
            [self.delegate unlikeRecipeFromDraggableViewBackgroundWithId:shortId andCompletion:^(BOOL succeeded, NSError * _Nonnull error) {
                if(succeeded){
                    [sender setImage:[UIImage imageNamed:@"heart-btn"] forState:UIControlStateNormal];
                    [self updateLikeCount:card];
                }
            }];
        } else{
            [self.delegate postLikedRecipeFromDraggableViewBackgroundWithId:shortId recipeTitle:card.title.text image:card.imageUrl andCompletion:^(BOOL succeeded, NSError * _Nonnull error){
                if(succeeded){
                    [sender setImage:[UIImage imageNamed:@"heart-btn-filled"] forState:UIControlStateNormal];
                    [self updateLikeCount:card];
                }
            }];
        }
    }];
}

// when you hit the right button, this is called and substitutes the swipe
- (void)swipeRight{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

// when you hit the left button, this is called and substitutes the swipe
- (void)swipeLeft{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}
@end
