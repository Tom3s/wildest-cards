# Uno, but worse

## Basic idea

make a UNO game, where bunch of different house rules and special edition rules are all combined into one chaotic mess.

- extra feature: players can create their own cards
  
## Rules

### Basic rules

- i want however many players, but 2-12 is a good range
- each player starts with 5-8 cards (will see what works best)
- the top card of the deck is flipped over and placed face-up on the table
- we start clockwise
- you have to match color or number
- if you can't match, you draw a card (if drawn card can be played, you can play it)

### Special cards

- draw x: next player draws x cards and skips turn (there may be more values of x) - additionally, you can avoid drawing by playing a card of the same or higher value
- skip: next player skips turn
- reverse: reverses the direction of play
- wild: you can play this card on any card, and you can change the color to anything you want
- wild draw x: you can play this card on any card, and you can change the color to anything you want. additionally, the next player draws x cards and skips turn - they can void it with another wild draw x or a draw x of the same color and 1 value higher (ie. wild +3, that asks for red, can be avoided with min. a red +4 or a wild +3)
- swap hands (colored): you swap hand with the player of your choice
- swap colors (colored): everyone give all of your cards of a certain color to the next player

### Extra card features

- cards may be of multiple colors, and can be played on any of those colors
- cards may have multiple numbers, and can be played on any of those numbers
- wild cards can be played on any card, but may only change to a color it shows
- there are more than 4 colors

## Turn steps

- In case player has penalties:
  - Check if player has any cards that can avoid, or pass the penalty
	- if player cannot avoid, or pass the penalty, next player starts turn
- current player starts turn
- check if player has any cards that can be played
  - if player has no cards that can be played, player draws a card
  - if player has cards that can be played, 
    - player plays a card OR
    - player draws a card
- if player has selected a special card, prompt user for:
  - color (if applicable)
  - player (if applicable)
  - number (if applicable)
- if player has a signle card left, user must press "last card" button, before next player acts
- if player is in a combo (ie, same player has the turn again), he must always play a card
  - if player has no cards that can be played, player draws a card
- if player has no cards left, player wins
  

## Card Properties

- color(s)
- number(s)/type

- colors it can go on (can be black for any)
- numbers it can go on 
- types it can go on (can be any)

- can prompt for color
- can prompt for player
- can prompt for number
- can prompt for type

- can put penalty on player
  - draw x
  - skip
  - swap some or all cards
- can apply global effect
  - reverse