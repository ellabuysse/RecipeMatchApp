# YesPeas - Recipe Matching App

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
#### Video Demo: https://drive.google.com/file/d/1WYNWfSH71KTXTyjUxl2fktbc0daq5FWv/view?usp=sharing
YesPeas is a recipe swiping app that provides users with inspiration and ideas for recipes. Users can input preferences such as meal type, diet, and cuisine and swipe endlessly through recipes. Users can search for specific recipes, view recipe details, and view saved and liked recipes on their profile. Ultimately, users are able to discover new recipes quickly and in a fun and engaging way.

### App Evaluation

- **Category:** Food/Social
- **Mobile:** The swiping focus of this app is perfect for mobile use. Users swipe right if they like a recipe and swipe left if they dislike a recipe. Recipes are curated by a user's preferences such as meal-type, diet, and health restrictions. Users can view details of a recipe and go to the external recipe site for instructions to start cooking right away. Users can also view liked and saved recipes on their profile for later reference.
- **Story:** Allows users to quickly find new recipes they enjoy. Many college-aged individuals don't have go-to recipes, and this app will provide ideas and inspiration when users are looking for something delicious.
- **Market:** Anyone who is looking for new recipes.
- **Habit:** Users can explore endless recipes for any meal whenever they want. Users are already faced with at least 3 meal decision every day, and this app will make the process more fun and game-like. The ability to add your own recipes would make users even more engaged and likely to return.
- **Scope:** A somewhat narrow scope focused on recipes, but stretch features can incorporate social aspects of posting recipes/reviews and following other people. It may be technically challenging to incoporporate user-added recipes to an existing database, but a stripped down version of this project would still be interesting.


## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can login into existing account
* User can sign up for new account
* User can login with Facebook account
* User can view an endless stream of recipes
* User can swipe right to like a recipe
* User can swipe left to discard a recipe/move to the next one
* User can tap on a recipe to view details
* User can double tap to like a recipe
* User can view a grid of liked and saved recipes on their profile

**Optional Nice-to-have Stories**

* User can search for recipes by title or keyword
* User can create their own recipe that is added to their profile
* User can comment on a recipe and like or 5 star rating
* User can filter recipes by popularity
* User can view other users' profiles and see their liked recipes

### 2. Screen Archetypes

* Login/Sign up
    * User can login into existing account
    * User can sign up for new account
    * User can login with Facebook account


* Stream
    * User can view an endless stream of recipes
    * User can swipe right to like a recipe
    * User can swipe left to discard a recipe/move to the next one
    * User can tap on a recipe to view details
    * User can see total like/save count
    * User can see if they previously liked/saved recipe
    * User can double tap to like


* Detail
    * User can view recipe title, ingredients, instructions, and photo
    * User can tap button to like/save recipe
    * User can tap button to go to external website with recipe


* Profile
    * User can view grid of liked and saved recipes


* Preferences
    * User can update preferences
    * Preferences are saved when user leaves screen
    * User can clear preferences


* Search
   * User can search for recipes by title or keyword
   * User can view a grid of results and view recipe details


* **Future Version** Creation: 
    * User can create a recipe
    * User can view most popular recipes


### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Home Feed
* Search
* Profile Page


**Flow Navigation** (Screen to Screen)

* Login Screen
   * Home
* Home
    * Details by tapping on recipe
    * Preferences
 * Search
    * Details by tapping on recipe
 * Profile
    * Details by tapping on recipe
   

## Wireframes
![](https://i.imgur.com/u2GmGAx.jpg)

### Models
LikedRecipe/SavedRecipe Model
Property      | Type	           | Description
------------- | --------------- | ----------------------------------------
recipeID      | String	        | unique id for the recipe (default field)
name          | String          | recipe name
image         | String          | recipe image url
username      | String          | current user username

Recipe Model
Property        | Type	          | Description
-------------   | --------------- | ----------------------------------------
uri             | String	       | unique id for the recipe
label           | String          | recipe name
image           | String          | recipe image url
source          | String          | recipe website title
url             | String          | recipe website url
yield           | Integer         | number of servings of recipe
ingredientLines | Array           | recipe ingredients split into lines
calories        | Integer         | number of calories of entire recipe

### Networking
Recipe API
Base URL: https://api.edamam.com/api/recipes/v2?q=&app_id=YOURAPP_ID&app_key=YOURAPP_KEY
