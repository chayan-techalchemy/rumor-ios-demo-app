
# Rumor - iOS Demo App

Created a simple social media dashboard application using MVVM Architecture for iOS using Swift. This application will display posts from a mock API, allow users to like and comment on posts, and create new posts.

## Installation

Following are the installation steps to follow:

- Clone the repository
- Open the project using Xcode 15
- Open the project file (RumorDemo.xcodeproj)
- Swift Packages will install automatically
- Run the application using Command(⌘) + R
- Run the test cases using Command(⌘) + U

The application works on both Light and Dark mode.

### Demo Video
https://vimeo.com/933622869

## API Reference

API calling was done using a Mock API provider which provided APIs for Social Media posts with Images, Title and User data. Dummy API (https://dummyapi.io/) was used for the same.

There were some shortcomings with the APIs:
- **Lack of Authentication APIs:** There are no Auth APIs, and it does not keep track if a user has liked a post already, thus every time the app is restarted, all the posts appear as if they were not liked by us, although it does persist the likes count.
- **Missing Comments Count:** In the post list API, we are not receiving the count of total comments on that post, which is why we have not shown that number on the posts. To achieve that, we would need to call a get comments for post API for each of those posts, which would not have been a good practice ideally.
- **Hardcoded Values:** The APP ID provided by the Dummy API is also added in the constants file for Demo task purpose, ideally access tokens are received from Auth APIs, which are saved in the Keychain. When we add a comment, we need to provide a user ID, we have hardcoded this user ID in the constants for demo purpose.
- **Image Upload:** When we create a new post, it requires the URL of an image. As we do not have a bucket / server where we could upload images, initially it might appear as if the user is selecting an image for creating a post but in the code we are randomly picking an image from our Constants.

## Data Binding

There are different data binding techniques for updating the UI based on changes in the Model or ViewModel. We have showcased two of them:
1. When we call an API from the ViewModel, it calls a Service which in turn calls a Network Manager. The communication here happens using Combine framework.
2. When we have to communicate between the View and ViewModel, we have used protocols as it enables high level of abstraction. Our previous experience with Clean Architecture (VIP) has fostered a preference for this technique due to its notable features and advantages.

## Test Cases

The Test Cases currently cover only the ViewModel files which in turn do test the data fetching and parsing as well. A MockNetworkRequest was created to achieve this behaviour.

The current coverage is ~60% for the RumorDemo Target, overall it appears low because it considers the Kingfisher package in the Test coverage as well.

The Test Case coverage can be increased by writing snapshot test cases using iOSSnapshotTestCase (previously FBSnapshotTestCase). This keeps a check on the changes made, by checking if they would affect the UI by small pixels.
The coverage can also be increased further using Automation tests on the application.
