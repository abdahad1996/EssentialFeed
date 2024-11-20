# EssentialFeed App Case Study
an app to showcase a list of paginated feed with comment feature

![](https://github.com/essentialdevelopercom/essential-feed-case-study/workflows/CI-iOS/badge.svg) ![](https://github.com/essentialdevelopercom/essential-feed-case-study/workflows/CI-macOS/badge.svg) ![](https://github.com/essentialdevelopercom/essential-feed-case-study/workflows/Deploy/badge.svg)

## Code Coverage:

<img width="1228" alt="Screenshot 2024-11-20 at 2 26 51 PM" src="https://github.com/user-attachments/assets/6e878509-ca10-4b06-8cdc-c69b8d988f4a">

## Screenshot and Video
<img src="https://github.com/user-attachments/assets/5b3e323e-e96a-4f86-95be-3d991a90ed00" alt="Simulator Screenshot" width="300"/>
<img src="https://github.com/user-attachments/assets/117efacb-9074-453b-8bd4-2bde60212c1d" alt="Simulator Screenshot" width="300"/>

https://github.com/user-attachments/assets/e8aa5866-79c8-4df3-bf8b-7f1ca1c20b13


## Image Feed Feature Specs

### Story: Customer requests to see their image feed

### Narrative #1

```
As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newest images of my friends
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see their feed
 Then the app should display the latest feed from remote
  And replace the cache with the new feed
```

### Narrative #2

```
As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends
```

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is less than seven days old
 When the customer requests to see the feed
 Then the app should display the latest feed saved

Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is seven days old or more
 When the customer requests to see the feed
 Then the app should display an error message

Given the customer doesn't have connectivity
  And the cache is empty
 When the customer requests to see the feed
 Then the app should display an error message
```

## Use Cases

### Load Feed From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Feed" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates image feed from valid data.
5. System delivers image feed.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---

### Load Feed Image Data From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System delivers image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---

### Load Feed From Cache Use Case

#### Primary course:
1. Execute "Load Image Feed" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.
4. System creates image feed from cached data.
5. System delivers image feed.

#### Retrieval error course (sad path):
1. System delivers error.

#### Expired cache course (sad path): 
1. System delivers no feed images.

#### Empty cache course (sad path): 
1. System delivers no feed images.

---

### Load Feed Image Data From Cache Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System retrieves data from the cache.
3. System delivers cached image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Retrieval error course (sad path):
1. System delivers error.

#### Empty cache course (sad path):
1. System delivers not found error.

---

### Validate Feed Cache Use Case

#### Primary course:
1. Execute "Validate Cache" command with above data.
2. System retrieves feed data from cache.
3. System validates cache is less than seven days old.

#### Retrieval error course (sad path):
1. System deletes cache.

#### Expired cache course (sad path): 
1. System deletes cache.

---

### Cache Feed Use Case

#### Data:
- Image Feed

#### Primary course (happy path):
1. Execute "Save Image Feed" command with above data.
2. System deletes old cache data.
3. System encodes image feed.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.

---

### Cache Feed Image Data Use Case

#### Data:
- Image Data

#### Primary course (happy path):
1. Execute "Save Image Data" command with above data.
2. System caches image data.
3. System delivers success message.

#### Saving error course (sad path):
1. System delivers error.

---

## Flowchart

![Feed Loading Feature](feed_flowchart.png)

## Model Specs

### Feed Image

| Property      | Type                |
|---------------|---------------------|
| `id`          | `UUID`              |
| `description` | `String` (optional) |
| `location`    | `String` (optional) |
| `url`            | `URL`               |

### Payload contract

```
GET /feed

200 RESPONSE

{
    "items": [
        {
            "id": "a UUID",
            "description": "a description",
            "location": "a location",
            "image": "https://a-image.url",
        },
        {
            "id": "another UUID",
            "description": "another description",
            "image": "https://another-image.url"
        },
        {
            "id": "even another UUID",
            "location": "even another location",
            "image": "https://even-another-image.url"
        },
        {
            "id": "yet another UUID",
            "image": "https://yet-another-image.url"
        }
        ...
    ]
}
```

---

## Image Comments Feature Specs

### Story: Customer requests to see image comments

### Narrative

```
As an online customer
I want the app to load image commments
So I can see how people are engaging with images in my feed
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see comments on an image
 Then the app should display all comments for that image
```

```
Given the customer doesn't have connectivity
 When the customer requests to see comments on an image
 Then the app should display an error message
```

## Use Cases

### Load Image Comments From Remote Use Case

#### Data:
- ImageID

#### Primary course (happy path):
1. Execute "Load Image Comments" command with above data.
2. System loads data from remote service.
3. System validates data.
4. System creates comments from valid data.
5. System delivers comments.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---

## Model Specs

### Image Comment

| Property          | Type                    |
|-------------------|-------------------------|
| `id`              | `UUID`                  |
| `message`         | `String`                  |
| `created_at`      | `Date` (ISO8601 String) |
| `author`             | `CommentAuthorObject`   |

### Image Comment Author

| Property          | Type                |
|-------------------|---------------------|
| `username`         | `String`              |

### Payload contract

```
GET /image/{image-id}/comments

2xx RESPONSE

{
    "items": [
        {
            "id": "a UUID",
            "message": "a message",
            "created_at": "2020-05-20T11:24:59+0000",
            "author": {
                "username": "a username"
            }
        },
        {
            "id": "another UUID",
            "message": "another message",
            "created_at": "2020-05-19T14:23:53+0000",
            "author": {
                "username": "another username"
            }
        },
        ...
    ]
}
```

---

## Testing Strategy
<img width="1080" alt="Screenshot 2024-01-16 at 08 52 19" src="https://github.com/abdahad1996/WorldOfPAYBACK/assets/28492677/ea9d13d2-dbb1-4eb2-a8f6-b9faaa0ad739">
<img width="1067" alt="Screenshot 2024-01-16 at 08 52 05" src="https://github.com/abdahad1996/WorldOfPAYBACK/assets/28492677/58c1112b-288c-4319-acec-e55e4b8d26a1">

I tried following the testing pyramid strategy. The foundation for my testing strategy was unit tests for the system internals (without hitting external systems like the network). In addition, I used snapshot tests to validate the screen layout. Lastly, to test out the whole flow I used UI Tests with page object architecture. 

### Summary Table

### Methodology

I adopted the following naming convention for all tests: test_methodName_expectedOutputWhenGivenInput.

To ensure there was no temporal coupling between tests and prevent artifacts from being left on the disk or in memory, I enabled test randomization for all targets 

### Unit Tests

I based my testing pyramid's foundation on unit tests because they are the most reliable and cost-effective to write. Also, I can easily test each component in isolation by mocking collaborators without making any assumptions about the rest of the system.

### Integration Tests

integeration tests are used to test if the units are collaborating correctly or not. 

### Snapshot Tests

Snapshot tests are used as regression tests for the UI. It seemed like a better alternative to UItests because they are relatively fast to run, and I could check the UI for both light and dark modes and different design strategies simultaneously.

Nevertheless, I didn't test any logic with snapshot tests.

## what and why Architecture

<img width="1000" alt="Why Is architecture so important" src="https://github.com/user-attachments/assets/05ff4936-b9b3-483c-b77c-7337a6acaa1f">
<img width="1000" alt="What supports good architecture" src="https://github.com/user-attachments/assets/a97d7fab-aae6-4d60-9bd6-6ffa27a83f81">

<img width="1000" alt="Design Patterns" src="https://github.com/user-attachments/assets/c122c0af-707e-4137-bdf6-b9538c3f3749">
<img width="1000" alt="Practices" src="https://github.com/user-attachments/assets/a1fd463a-4f2c-4e6f-989d-3ed2c5217781">

## App Architecture




![](architecture.png)


### deep dive into feed scene

<img width="1471" alt="Screen Shot 2022-08-14 at 7 02 07 PM" src="https://github.com/user-attachments/assets/2385dfdf-12dd-4eab-9afa-159955d5c39a">

### zoomed out version
<img width="1491" alt="Screen Shot 2022-08-14 at 7 06 01 PM" src="https://github.com/user-attachments/assets/9ab45153-5af4-455b-b27b-706d4765a22c">

### onion/clean architecture form 
<img width="1400" alt="Screen Shot 2022-08-14 at 7 07 40 PM" src="https://github.com/user-attachments/assets/047443d0-8629-4842-954b-c48d3b2bc25f">

### plug and play architecture

<img width="1000" alt="Composition Root" src="https://github.com/user-attachments/assets/2f97f036-41e9-4f47-ac12-2a768e3718a2">


<img width="929" alt="watchOS Application" src="https://github.com/user-attachments/assets/d5c69bb9-fbdd-4459-9001-35577d052559">









