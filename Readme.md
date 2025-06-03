# Netgear interview assessment project

This is an assessment project that allows a user to search for a list of books, displays the relevant results, and shows detailed information for each book on selection.

## Setup

The project should compile as-is, the only setup step is to add an API key. 

**Edit:** From some testing, I seem to be able to get some responses without having to provide an API Key, so to get results back you might not have to have one. 

In any case, if you do run into errors, you can add an API key In the NetgearSampleApplication/Dependencies/Constants.swift file, there's a API_KEY variable where you can include your google API key with books access. If you don't have an API key, please reach out and I can provide one.

## Project structure / details

- The project uses SwiftUI as the UI framework, and MVVM as the architecture for structuring screens and views. 

- There is some structuring for the network layer - there is a small HTTP client class that contains the logic for making requests, and these requests are made from 'Service' clases, which are small protocols that are used to hide the implementation details of the network request. eg: there is a 'BookSearchService' protocol which has a `searchBooks(query: String) -> [Book]` function, which is then passed into the view model, then a concrete implementation will do the actual network requests. The view model will call the protocol method, then do some mapping to format the response before passing it to the view.

- Dependencies are created and passed through the application in an `AppSession` class which is initialised on application start, and holds the dependencies for each view / view model. Details can be found in the `NetgearSampleApplicationApp`

- There are tests in place for the search and detail view models - I included them as a reference for how I would go about testing the functionality, but there is definitely more that can be tested in the application. eg: checking that the search query passed to the server is encoded (formatting spaces, special characters, etc.), checking that the api key is attached to every request, and potentially some UI tests as well to check user interactions.

## Future work / other features

- As mentioned above, there could be more in-depth testing in place for components outside of the view models.
- There is no caching in place in the application - images are loaded using `AsyncImage` which retrieves the image each time, and details of a book are also retrieved every time. These are areas that could benefit from caching to improve performance / network use.
- Error handling is very basic - all errors are treated the same and essentially just display a generic 'something went wrong' message to the user.
- The UI could definitely be more aesthetically pleasing - the implementation here is simple enough to meet the requirements and to demonstrate my approach in the time frame given.
- Existing strings could be localized - currently they are hard-coded in the views / view models.
