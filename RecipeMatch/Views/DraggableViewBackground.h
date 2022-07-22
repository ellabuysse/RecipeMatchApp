//
//  DraggableViewBackground.h
//  RKSwipeCards
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

/*
 
 Copyright (c) 2014 Choong-Won Richard Kim <cwrichardkim@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "DraggableView.h"

@protocol DraggableViewBackgroundDelegate <NSObject>
@required
- (void)checkLikeStatusFromDraggableViewBackground:(DraggableView *_Nullable)card withCompletion:(void (^_Nullable)(BOOL liked, NSError *_Nullable error))completion;
- (void)checkSaveStatusFromDraggableViewBackground:(DraggableView *_Nullable)card withCompletion:(void (^_Nullable)(BOOL liked, NSError *_Nullable error))completion;
- (void)postSavedRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId title:(NSString * _Nullable)title image:(NSString * _Nullable)image andCompletion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion;
- (void)postLikedRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId recipeTitle:(NSString * _Nullable)title image: (NSString * _Nullable)image andCompletion:(void (^_Nullable)(BOOL succeeded, NSError * _Nullable error))completion;
- (void)unlikeRecipeFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId andCompletion:(void (^_Nullable)(BOOL succeeded, NSError *_Nullable error))completion;
- (void)countLikesFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId andCompletion:(void (^_Nullable)(int likes, NSError * _Nullable error))completion;
- (void)countSavesFromDraggableViewBackgroundWithId:(NSString * _Nullable)recipeId andCompletion:(void (^_Nullable)(int likes, NSError * _Nullable error))completion;
- (void)showDetailsFromDraggableViewBackground:(DraggableView *_Nonnull)card;
- (void)getMoreRecipesFromDraggableViewBackgroundWithCompletion:(void (^_Nullable)(BOOL succeeded, NSError *_Nullable error))completion;
@end

@interface DraggableViewBackground : UIView <DraggableViewDelegate>
- (void)reloadView;
- (void)updateValues;

@property (weak) id <DraggableViewBackgroundDelegate> _Nullable delegate;
@property (retain,nonatomic)NSMutableArray* _Nullable allCards;
@property NSMutableArray * _Nullable recipes; // current array of recipes
@end
