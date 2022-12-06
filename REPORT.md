



# Mobile Group Project Technical Report 

#### CSCI 4100U - Mobile Devices

*Dr. Michael Miljanovic*

December 6th 2022


### Group Members: 

1.  Alexander Naylor https://github.com/AlexNayl

2.  Dylan Moore https://github.com/Dym99

3.  Sukhpreet Bansal https://github.com/Sukhpreet-7

4.  Hamza Khan https://github.com/HKhan702


### Overview of Project 
For this project we created a social media app that allows users to upload geolocated photos (of their current location) onto a map. The app consists of several screens. All screens have a navigation bar at the bottom to traverse between screens.
The map screen consists of a map with photos posted around the area. Tapping on a photo takes the user to the view-post screen. 
The view-post screen shows the photo clicked on the map, how long ago it was posted, and a description of it if available. Additionally, it displays the address of the post, and provides functionality to save or hide the post.
The add-post screen has a mechanism to take a new photo and/or upload a photo from the user's phone, and there is a text box to add a title and description if the user desires. 
The settings screen contains app settings and localization.
The saved-posts screen contains a list of saved and hidden posts set earlier by the user in the view post screen.

### Individual Contribution  
Alexander:
 - Map
 - Geolocation
 - Geocoding
 - Graph and data tables 

Dylan:
- Cloud storage and post view
- Local storage and saved posts list
- Home screen navigation
- Settings menu and preference saving
- Internationalisation + language json files
- Map marker thumbnails

Sukhpreet:
- Dialogs
- Snackbars and other quality-of-life features throughout the app 

Hamza: 
- Add-post page
- Camera page


### Code Design  
For the sake of brevity, typical flutter page and widget code design will not be described.

The Post class contains the data for each individual posts, including the title, photo link, caption, location, and time stamp. It also has some conversion functions, the time stamp.

The PostModel class provides the tools for working with the Firebase database. This class is static in nature, so no common instance needs to be kept track of.

The SavedModel and DBUtils classes are static classes containing tools used for local storage. These classes facilitate the saving and hiding of posts per user.

The Saved class describes individual saved posts, internally it just consists of a local storage id, Firebase document reference for the post, and a boolean for if its hidden.

The SettingsModel class is a static class that contains tools for writing and retrieving settings data locally.






### User’s Guide (for non-developers) 
On startup, you will be greeted with the main map screen. You can scroll around this map to view posts in your area, tapping on a post icon will open it. At the bottom of the map screen you will find a button to centre the map on your current location, buttons to zoom in and out, and buttons to take you to the other pages of the app.

In the post viewing page, you will see the post, including its photo, location, post time, and description, At the top of the page you will see buttons to save the post to your bookmarks list, and a button to hide this post.

In the Post Stats page, you will see a graph of posting activity within the last 7 days, and a table of how many posts were made on each day. You can scroll down this page to view more of this table.

In the add post page, you will first be asked to take a photo. After that, you will need to add a title and description to the photo before being able to post. You can retake the photo at this time as well, before it's posted.

In the settings page, you can tweak various settings of the app including language.

In the saved posts page, you can review bookmarked, and hidden posts set earlier from the post viewing page.

### List of Functional Requirements and how/where they are used 

#### Multiple Screens and Navigation
The application and its function is divided among several views, such as the map view presenting all posts using mapbox, or the add post view which allows users to upload new posts to the cloud storage.

#### Dialogs and Pickers
Dialogs and pickers are used in both the add post page and setting page. On the add post page, before the user uploads the post, an alert dialog is shown asking the user  to confirm whether or not the user is ready to upload the post. The second dialog is used in the setting page named “About” under the “Legal” subheading. This dialog shows the applications name, copyrights, creators and licenses. 

#### Snackbars and Notifications
Snackbars and Notifications are used in both the add post page and the map page (the homepage). On the add post page, after the user successfully uploads the post, a snackbar will appear showing that the post has been uploaded to the map given the current location of the user. On the map page, on the bottom right corner there is a map center button. When this button is clicked, the map will center itself to the user’s current location and a snackbar will appear telling the user that the map has been centered. 

#### Local Storage
Local storage is used to store references to specific posts that get bookmarked by the user (in a sqlite database), additionally the post can also be hidden and be excluded from the mapview.
Settings are stored locally using a user-preferences plugin.

#### Cloud Storage
Firebase is used to store all posts made from the app. It holds the image, title and geolocation of the post.

#### Data Tables and Charts
In the post stats screen, a line chart shows the activity over the last 7 days, and a record of how many posts per day is kept under that in a data table.

#### Maps
The app concept revolves around posting geolocated images on a map, in this case the map is the home screen.

#### Geolocation
On the map screen it’s used to centre the map over the user, and on the add posts screen it's used to provide the position that the post belongs to.

#### Geocoding
On the post viewing screen, it's used to turn the post's latitude and longitude into an address displayed below the image.

#### Internationalization
Internationalization has been implemented to display the application to French users as well. Setting to change language is found under the settings menu.

