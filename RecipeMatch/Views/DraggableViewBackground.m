//
//  DraggableViewBackground.m
//  RKSwipeCards
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "DraggableView.h"
#import "StreamViewController.h"
#import "OverlayView.h"
#import "APIManager.h"

@interface DraggableViewBackground ()
@property NSArray *recipes;
@end

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    UIButton* heartButton;
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 425; //%%% height of the draggable card
static const float CARD_WIDTH = 325; //%%% width of the draggable card
static const float BTN_HEIGHT = 60;

@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [super layoutSubviews];
    
    }
    return self;
}

// get recipes from API
-(void)fetchRecipes{
    [[APIManager shared] getRecipesWithPreferences:self.preferences andCompletion: ^(NSMutableArray *recipes, NSError *error) {
        if(recipes)
        {
            self.recipes = recipes;
            [self getCards];
            DraggableView *nextCard = [self->loadedCards objectAtIndex:0];
            [self updateHeartBtn:nextCard];
        } else {
            NSLog(@"😫😫😫 Error getting recipes: %@", error.localizedDescription);
        }
    }];
}

-(void)getCards
{
    [self setupView];
    loadedCards = [[NSMutableArray alloc] init];
    allCards = [[NSMutableArray alloc] init];
    cardsLoadedIndex = 0;
    [self loadCards];
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 630, BTN_HEIGHT, BTN_HEIGHT)];
    [xButton setImage:[UIImage imageNamed:@"x-btn"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    
    heartButton = [[UIButton alloc]initWithFrame:CGRectMake(155, 620, BTN_HEIGHT+20, BTN_HEIGHT+20)];
    [heartButton setImage:[UIImage imageNamed:@"heart-btn"] forState:UIControlStateNormal];
    [heartButton addTarget:self action:@selector(tapLike:) forControlEvents:UIControlEventTouchUpInside];
    
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(270, 630, BTN_HEIGHT, BTN_HEIGHT)];
    [checkButton setImage:[UIImage imageNamed:@"save-btn"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:xButton];
    [self addSubview:heartButton];
    [self addSubview:checkButton];
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT - BTN_HEIGHT-20)/2, CARD_WIDTH, CARD_HEIGHT)];
    
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

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([self.recipes count] > 0) {
        NSInteger numLoadedCardsCap =(([self.recipes count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[self.recipes count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[self.recipes count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

// update heart button for each card to show like status
-(void)updateHeartBtn:(DraggableView *)nextCard{
    NSString *shortId = [(NSString *)nextCard.recipeId substringFromIndex:51];
    [APIManager checkIfLikedWithId:shortId andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded == YES){
            [self->heartButton setImage:[UIImage imageNamed:@"heart-btn-filled"] forState:UIControlStateNormal];
        } else{
            [self->heartButton setImage:[UIImage imageNamed:@"heart-btn"] forState:UIControlStateNormal];
        }
    }];
}

// action called when the card goes to the left.
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //DraggableView *c = (DraggableView *)card;
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
        
        DraggableView *nextCard = [loadedCards objectAtIndex:0];
        [self updateHeartBtn:nextCard];
    }
}

// action called when the card goes to the right.
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    
    DraggableView *c = (DraggableView *)card;
    NSString *longId = (NSString *)c.recipeId;
    NSString *shortId = [longId substringFromIndex:51];
    
    [APIManager postSavedRecipeWithTitle:c.title.text andId:shortId andImage:c.imageUrl andCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error posting recipe: %@", error.localizedDescription);
        }
        else{
            NSLog(@"Post recipe success!");
        }
    }];
    
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    DraggableView *nextCard = [loadedCards objectAtIndex:0];
    [self updateHeartBtn:nextCard];
}

-(void)tapLike:(id)sender{
    DraggableView *card = [loadedCards firstObject];
    NSString *shortId = [(NSString *)card.recipeId substringFromIndex:51];
    
    [APIManager manageLikeWithTitle:(NSString *)card.title.text andId:shortId andImage:card.imageUrl andCompletion:^(BOOL succeeded, NSError * _Nullable error){
        if(succeeded)
        {
            [sender setImage:[UIImage imageNamed:@"heart-btn-filled"] forState:UIControlStateNormal];
            
        }else {
            [sender setImage:[UIImage imageNamed:@"heart-btn"] forState:UIControlStateNormal];
        }
    }];
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
