Original App Design Project - README Template
===

# Recipe Matching App

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
This app allows users to view a stream of curated recipes based on their preferences and filter by meal-type. Users will swipe between recipes in order to select the one they want to cook.


### App Evaluation

- **Category:** Food/Social
- **Mobile:** Users swipe right if they like a recipe and swipe left if they dislike a recipe. Recipes will be curated by a user's profile of likes, diet, and preferences. Users can select categories such as meal-type and when they select a recipe, they are taken to that recipe's website so they can easily start cooking. Each liked recipe will be saved to a collection they can return to.
- **Story:** Allows users to quickly find new recipes they enjoy. Many college-aged individuals don't have go-to recipes, and this app will provide ideas and inspiration when users are looking for something delicious.
- **Market:** Young people who are looking for new recipes.
- **Habit:** Users can explore endless recipes for any meal whenever they want. Users are already faced with at least 3 meal decision every day, and this app will make the process more fun and game-like. The ability to add your own recipes would make users even more engaged and likely to return.
- **Scope:** A somewhat narrow scope focused on recipes, but stretch features can incorporate social aspects of posting recipes/reviews and following other people. It may be technically challenging to incoporporate user-added recipes to an existing database, but a stripped down version of this project would still be interesting.


## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can create a new account
* User can login
* User can view a feed of curated recipes based on preferences
* User can filter recipes by category
* User can swipe right/left to like/discard a recipe
    * Liked recipes are saved to grid on profile for later use
* User can view details of recipe and go to external recipe site
* User can share recipe to Facebook profile

**Optional Nice-to-have Stories**


* User can create their own recipe that is added to their profile
* User can comment on a recipe and like or 5 star rating
* Search bar
* User can filter recipes by popularity
* User can view other users' profiles and see their liked recipes

### 2. Screen Archetypes

* Login/Sign up
    * User can login into existing account
    * User can sign up for new account

* Stream
    * User can view a stream of recipes
    * User can swipe right to like a recipe
    * User can swipe left to discard a recipe/move to the next one
    * User can swipe up to view details of recipe and favorite
    * User can select meal category 

* Detail
    * User can view recipe title, ingredients, instructions, and photo
    * User can tap button to favorite recipe
    * User can tap button to go to external website with recipe


* Profile
    * User can view grid of liked recipes
    * User can tap button to go to settings to update preferences and profile photo


* Settings
    * User can update preferences
    * User can update profile photo and name


* **Future Version** Creation: 
    * User can input recipe title, ingredients, instructions, and photo
    * User can post recipe to Home feed and Profile


### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home Feed
* Post a Recipe
* Profile Page


**Flow Navigation** (Screen to Screen)

* Login Screen
   * Home Feed
* Registration Screen
    * Home Feed
* Stream
    * Detail screen with ingredients and instructions
* Creation
    * Home (after you finish posting the recipe)

## Wireframes
![](https://i.imgur.com/u2GmGAx.jpg)

## Schema 
[This section will be completed in Unit 9]
### Models
Favorites Model
Property      | Type	        | Description
------------- | -------------   | ----------------------------------------
recipeID      | String	        | unique id for the recipe (default field)
user          | Pointer to User | current user

### Networking
Recipe API
Base URL: https://api.edamam.com/api/recipes/v2?q=&app_id=YOURAPP_ID&app_key=YOURAPP_KEY

