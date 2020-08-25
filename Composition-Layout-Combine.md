# Using Compositional Layout and Combine

![photo search sketch](Assets/photo-search-layout.jpg)

![photo search](Assets/photo-search.png)

## 1. Objectives 

* Use all we've learnt so far to build a photo search application using a custom compositional layout. 
* Use the `Combine` framework to make asynchronous network requests via a `Publisher` and `Subscriber`. 
* Use `UISearchController` along with the `debounce` Combine operator to prevent multiple network requests from the search bar. 

## 2. Starter Files 

#### ImageCell

```swift 
import UIKit

class ImageCell: UICollectionViewCell {
  
  static let reuseIdentifier = "imageCell"
  
  public lazy var imageView: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(systemName: "photo")
    iv.layer.cornerRadius = 8
    iv.clipsToBounds = true
    return iv
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  private func commonInit() {
    imageViewConstraints()
  }
  
  private func imageViewConstraints() {
    addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}
```

#### Config.swift 

```swift 
struct Config {
  static let apikey = "API KEY GOES HERE FOR THE PIXABAY API"
}
```

#### Photo.swift 

```swift 
struct PhotoResultsWrapper: Decodable {
  let hits: [Photo]
}

struct Photo: Decodable, Hashable {
  let id: Int
  let webformatURL: String
}
```

## 3. Combine APIs we will be using in this lesson 

#### `@Published`

Allows any property to be a `Publisher` and emit values over time. e.g in this app as the user enters text into the search bar the subscriber will have access to the values the user enters. This user entered input will then be passed over to the api client to perform the photo search from Pixabay. 

#### `URLSession.shared.dataTaskPublisher(url:_)`

This is a wrapper around `URLSession` that Combine provides and allows us to create a `Publisher` that we will be subscribing on in our view controller to get the results of the photo search. 

#### `debounce`

Allows a scheduled time before carrying out a specific task. In the case of our app we will add a second delay after the user finishes to type before running the network request of their search. This will prevent multiple requests from going to the Pixabay API as the user is typing. 

## 4. `UISearchController` 

Allows you to embed a search bar into the navigation bar item and is a more modern way to carry out searches with some more flexibility as opposed to your standard `UISearchBar` api. Also you can assign a specific view controller to be the results controller among other features `UISearchController` provides. 

## 5. Create an `enum` to hold the collection view's sections 

In this app we will have only 1 section. 

```swift 
enum SectionKind: Int, CaseIterable {
  case main
}
```

## 6. Declare the collection view 

```swift 
private var collectionView: UICollectionView!
```

## 7. Declare the data source 

```swift 
typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Photo>
private var dataSource: DataSource!
```

## 8. Declare the search controller 

```swift 
private var searchController: UISearchController!
```

## 9. Declare a search text `@Published` property 

This property will be a `Publisher` and be able to emit values as it's changed. 

```swift
@Published private var searchText: String? = "paris"
```

## 10. Declare a property the will hold references to all the subscriptions in our app

Those subscriptions will be released from memory when `deinit` is called on the view controller. 

```swift 
private var subscriptions: Set<AnyCancellable> = []
```

## 11. Declare an instance of the API client 

```swift 
private let apiClient = APIClient() 
```

