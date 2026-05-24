App Screens and How They Work
This section explains the main screens in the app from the user point of view.

Welcome Screen
The Welcome screen is the first screen the user sees.
The user can:

- enter their name
- press the continue button
- move to the main House List screen

Purpose of this screen:

- gives the app a simple starting point
- lets the user enter the app before managing house quotes

House List Screen
The House List screen is the main dashboard of the app.
The user can:
- view all saved houses
- add a new house
- search houses by nickname
- filter houses by progress status
- edit a house nickname
- delete a house
- open a house detail page
- see the total number of houses

The status colours show house progress:
- Grey means no rooms have been added
- Red means rooms exist but none are completed
- Yellow means some rooms are completed
- Green means all rooms are completed

This screen helps the user quickly find and manage house projects.
When the user taps the arrow button on a house, the app opens the House Detail screen.

House Detail Screen
The House Detail screen shows information about one selected house.
The user can:
- view the selected house name
- enter or edit the customer name
- enter or edit the address
- save customer and address details
- view room progress
- add a new room
- mark a room as completed
- edit a room name
- delete a room
- open a room detail page
- open the quote screen

The room progress section shows:
- total rooms
- completed rooms
- incomplete rooms

This screen is used to manage the rooms inside one house.
When the user taps the arrow button on a room, the app opens the Room Detail screen.
When the user taps View Quote, the app opens the Quote screen.

Room Detail Screen
The Room Detail screen shows the details of one selected room.
The user can:
- view the room name
- add windows
- edit windows
- delete windows
- add floor spaces
- edit floor spaces
- delete floor spaces
- choose materials
- choose one room photo from the photo library
- return to the House Detail screen

For each window, the user can enter:
- window name
- width in millimetres
- height in millimetres
- material type

For each floor space, the user can enter:
- floor name
- width in millimetres
- length in millimetres
- material type

The app checks input before saving.
The user cannot save:
- empty names
- names shorter than 2 characters
- non number measurements
- zero or negative measurements
- very large measurements over 20000 mm
This screen is important because the window and floor measurements are used later in the quote calculation.

Quote Screen
The Quote screen shows the final quote for one selected house.
The user can:
- view customer information
- view the address
- view the current date
- view quote details room by room
- view window costs
- view floor costs
- view labour costs
- view each room total
- view the final house total
- recalculate the quote
- share the quote
- return to the House Detail screen

The quote is calculated using:
- window size
- floor size
- selected material price
- labour cost
The labour cost is currently 200 dollars per room.

The Quote Status feature shows:
- Low Cost Project
- Medium Cost Project
- High Cost Project

If the quote is high, the app shows a warning message. This helps the user know when the project cost may need to be reviewed.
The Share Quote button lets the user share the quote using the iOS share menu.

The user can share the quote through:
- Mail
- Messages
- Notes
- Copy
- AirDrop
- Save to Files

Screen Flow
The app uses this general screen flow:
1. Welcome Screen
2. House List Screen
3. House Detail Screen
4. Room Detail Screen
5. Quote Screen

The main flow is:
- the user starts on the Welcome screen
- the user moves to the House List screen
- the user opens one house
- the user manages rooms in the House Detail screen
- the user opens a room to add windows and floors
- the user returns to the house and opens the Quote screen
- the user views or shares the final quote

Core Features
The app includes the following core features:
- Welcome screen where the user can enter their name
- House dashboard showing all saved houses
- Add new houses
- Edit house nicknames
- Delete houses
- Search houses by nickname
- Filter houses by progress status
- Show total number of houses
- Show house progress using colours
  - Grey means no rooms have been added
  - Red means rooms exist but none are completed
  - Yellow means some rooms are completed
  - Green means all rooms are completed
- Sort houses by latest added, opened or updated
- View and edit customer name
- View and edit customer address
- Save house details to Firebase Firestore
- Add rooms to a house
- Edit room names
- Delete rooms
- Mark rooms as completed or not completed
- Show room progress statistics
  - Total rooms
  - Completed rooms
  - Incomplete rooms
- Add windows to a room
- Edit window details
- Delete windows
- Add floor spaces to a room
- Edit floor space details
- Delete floor spaces
- Choose material type for windows and floors
- Validate user input before saving
- Choose one room photo from the photo library
- Save and load room photo using Firebase
- Save all house, room, window and floor data using Firebase Firestore
- Load saved data again when the app is reopened
- Calculate final quote for a selected house
- Show quote breakdown by room
- Show window costs
- Show floor costs
- Show labour costs
- Show room totals
- Show final house total
- Recalculate quote after changes
- Share quote using the iOS share menu

Custom Feature
The custom feature in this app is the Quote Status feature.
The Quote Status feature checks the final house total and gives the user a simple cost status.
The status can be:
- Low Cost Project
- Medium Cost Project
- High Cost Project
If the final quote is high, the app shows a warning message telling the user that the quote may need to be reviewed.
This feature is useful because it helps the user quickly understand whether the quotation is affordable, moderate, or expensive before sharing or confirming it.


References
The following resources were used or checked during development of this assignment.
Official documentation and coding references
1. Apple Developer Documentation. UIKit.
   https://developer.apple.com/documentation/uikit

2. Apple Developer Documentation. UITableView.
   https://developer.apple.com/documentation/uikit/uitableview

3. Apple Developer Documentation. UITableViewCell.
   https://developer.apple.com/documentation/uikit/uitableviewcell

4. Apple Developer Documentation. UITableViewDataSource.
   https://developer.apple.com/documentation/uikit/uitableviewdatasource

5. Apple Developer Documentation. UITableViewDelegate.
   https://developer.apple.com/documentation/uikit/uitableviewdelegate

6. Apple Developer Documentation. UIImagePickerController.
   https://developer.apple.com/documentation/uikit/uiimagepickercontroller

7. Apple Developer Documentation. UIImagePickerControllerDelegate didFinishPickingMediaWithInfo.
   https://developer.apple.com/documentation/uikit/uiimagepickercontrollerdelegate/imagepickercontroller(_:didfinishpickingmediawithinfo:)

8. Apple Developer Documentation. UIActivityViewController.
   https://developer.apple.com/documentation/uikit/uiactivityviewcontroller

9. Apple Developer Documentation. Sharing copies of data using UIActivityViewController.
   https://developer.apple.com/documentation/UIKit/collaborating-and-sharing-copies-of-your-data

10. Firebase Documentation. Cloud Firestore.
    https://firebase.google.com/docs/firestore

11. Firebase Documentation. Get started with Cloud Firestore.
    https://firebase.google.com/docs/firestore/quickstart

12. Firebase iOS SDK GitHub Repository.
    https://github.com/firebase/firebase-ios-sdk

13. Firebase iOS Codelab Swift.
    https://firebase.google.com/codelabs/firebase-ios-swift

14. The Swift Dev. Picking images with UIImagePickerController in Swift 5.
    https://theswiftdev.com/picking-images-with-uiimagepickercontroller-in-swift-5/

15. LogRocket. Firestore in Swift tutorial.
    https://blog.logrocket.com/firestore-swift-tutorial/

16. Ralf Ebert. UITableViewController iOS and Swift Tutorial.
    https://www.ralfebert.com/ios-examples/uikit/uitableviewcontroller/

17. Stack Overflow. UITableView example for Swift.
    https://stackoverflow.com/questions/33234180/uitableview-example-for-swift

18. Stack Overflow. Enabling the photo library button on UIImagePickerController.
    https://stackoverflow.com/questions/8528880/enabling-the-photo-library-button-on-the-uiimagepickercontroller

YouTube tutorials
1. iOS Academy. How to Create TableView in Xcode 15 Swift 5.
   https://www.youtube.com/watch?v=C36sb5sc6lE

2. iOS Academy. Swift TableView with Custom Cells Tutorial.
   https://www.youtube.com/watch?v=R2Ng8Vj2yhY

3. iOS Academy. Firestore Database in iOS Swift 5.
   https://www.youtube.com/watch?v=R3Wp1PWh70c

4. Firebase. Get Started with Firebase Firestore in iOS.
   https://www.youtube.com/watch?v=GRZZVXZt1IU

5. iOS Academy. Creating Share Sheet in App Swift 5 Xcode 12.
   https://www.youtube.com/watch?v=jxhq1_7HkJg

6. CodeWithChris or similar Swift tutorial content. Swift Storyboard Tutorial.
   https://www.youtube.com/watch?v=oZGAicT2zbg

7. Firebase. Getting Started With Cloud Firestore on iOS Firecasts.
   https://www.youtube.com/watch?v=rvxYRm6n_NM

8. Swift Tutorials. UIActivityViewController sharing tutorial.
   https://www.youtube.com/watch?v=utrrVUkJyH8
