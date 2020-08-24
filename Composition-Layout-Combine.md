# Using Compositional Layout and Combine

![photo search sketch](Assets/photo-search-layout.jpg)

![photo search](Assets/photo-search.png)

## Objectives 

* Use all we've learnt so far to build a photo search application using a custom compositional layout. 
* Use the `Combine` framework to make asynchronous network requests via a `Publisher` and `Subscriber`. 
* Use `UISearchController` along with the `debounce` Combine operator to prevent multiple network requests from the search bar. 

## Starter Files 

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
