# Steamy Pages

## Languages

In this folder, you can make a folder for each language you want to make a store-page for.

The folder should be named as such: `<code>.<name>`  
The `code` is a lowercase character code, according to
[this list](https://en.wikipedia.org/wiki/IETF_language_tag#List_of_common_primary_language_subtags).  
The `name` is the display name, what users will actually _see_.

Inside each language folder should be a file called `translations.yaml`,
which stores some commonly used translation strings.

## Games

Inside each language folder are the folders for each game.

The name of the folder will be the game-part of the final URL, so make sure there are no funny characters in it!

A game folder can either be a link to an _actual_ store page or a Steamy page.

All game folders **must** contain at least the following files:

- `title.txt`: The title of the game.
- `tags.txt`: A list of tags for the game, separated by commas.
- `store_capsule_small.jpg`: The image that is shown next to the game's details.

All game folders **may** contain these files:

- `release_date.txt`: The release date of the game.  
  If this file is not present, it will be listed as "Coming soon".  
  Specifically, the `coming-soon` translation.
- `price.txt`: The price of the game.  
  Should include the currency symbol.  
  If this file is present, a fake "buy" section will be shown on the game's page,
  and the price will also be listed on the main store list page.

### Game link

In addition to the files mentioned above, game links **need** this file:

- `link.txt`: The URL of the game's store page.

### Steamy page

In addition to the files mentioned above, Steamy pages **need** these files:

- `about.md`: The main "About This Game" section of the store page.  
  This can link to images and video in the same folder!
- `breadcrumb.txt`: The breadcrumb/category of the store page (the small text above the title at the top).  
  Will be prefixed by the `breadcrumb-all-games` translation, and followed by the game's title.
- `description.txt`: The description of the game.
- `sidebar.yaml`: Details for in the game_details sidebar.
- `store_capsule_header.jpg`: The image that is shown in the top section, above the description, next to the carousel.
