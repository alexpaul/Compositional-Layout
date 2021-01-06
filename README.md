# Introduction to UICollectionViewCompositionalLayout

iOS now provides a newer more flexible, composable way to construct collection views. `UICollectionViewCompositionalLayout` was introduced in iOS 13 at WWDC 2019. Prior to `UICollectionViewCompositionalLayout` we used `UICollectionViewFlowLayout`.  

## [Video Playlists of Lessons](https://www.youtube.com/watch?v=toceVnka2jo&list=PLjdVqs-1R8wHMZ-j_GP_kwB6-7PCGDdfr)

## Compositional Layout 

* Composable 
* Flexible 
* Fast 

## Objectives 

* Understand the building blocks needed in creating a compositional layout.
* Use `UICollectionViewDiffableDataSource` to configure your collection view. 
* Build a grid view with multiple columns.
* Understand and use supplementary views. 
* Understand and use `UICollectionViewCompositionalLayout` provider to return various section configurations. 
* Understand and use orthorgonal scrolling. 

## Vocabulary 

* NSCollectionLayoutSize 
* NSCollectionLayoutItem 
* NSCollectionLayoutGroup 
* NSCollectionLayoutSection 


## Compositional Layout System

> Item -> Group -> Section -> Layout

#### Figure 1. 

![layout-system](Assets/layout-system.png)

#### Figure 2. 

![compositional layout](Assets/compositional-layout-1.jpg)

Above a layout is made up of sections, a section has groups and inside groups we have items.

## Describing the size of an item 

The size is of type `NSCollectionLayoutDimension`

* .fractionalWidth
* .fractionalHeight 
* .absolute (point based values e.g 200 points) 
* .estimated (will start with an estimation and grow accordingly) 

## NSCollectionLayoutGroup 

There are three ways to layout 

* Horizontal 
* Vertical 
* Custom

## Let's build our first compositional layout 


#### 1. Declare the collection view in Storyboard or Programmatic 

```swift 
@IBOutlet weak var collectionView: UICollectionView!
```

#### 2. Create the compositional layout

A compositional layout is made of an item -> group -> section -> layout. An item is the smallest component. An item belongs to a group. A group belongs to a section. A layout is made of one or more sections. 

```swift 
private func createLayout() -> UICollectionViewLayout {
  // 1
  // setup the item
  let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
  let item = NSCollectionLayoutItem(layoutSize: itemSize)
  item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

  // 2
  // setup the group
  let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.25))
  let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

  // 3
  // setup the section
  let section = NSCollectionLayoutSection(group: group)

  // 4
  // setup the layout
  let layout = UICollectionViewCompositionalLayout(section: section)

  return layout
}
```


#### 3. Use the compositional layout to configure the collection view's layout

**Using Storyboard**

```swift 
collectionView.collectionViewLayout = createLayout()
collectionView.backgroundColor = .systemBackground
```

**Programmatically**

```swift 
collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
```

#### 4. Declare the data source using `UICollectionViewDiffableDataSource`

```swift 
private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
```

#### 5. Declare and enum that will hold the colleciton view's sections


```swift 
enum Section {
  case main
}
```

#### 6. Configure the data soruce and the snapshot 

```swift 
private func configureDataSource() {
  // 1
  dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, value) -> UICollectionViewCell? in
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
      fatalError()
    }
    cell.textLabel.text = "\(value)"
    cell.backgroundColor = .systemOrange
    return cell
  })

  // 2
  var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
  snapshot.appendSections([.main])
  snapshot.appendItems(Array(1...100), toSection: .main)
  dataSource.apply(snapshot, animatingDifferences: false)
}
```

#### 7. Call the setup code in `viewDidLoad()`

```swift 
configureCollectionView()
configureDataSource()
```

![grid-view-layout](Assets/grid-view.png)

#### [Completed Project](https://github.com/alexpaul/Compositional-Layout/tree/master/Compositional-Layout)

## Resources 

1. [Apple docs - UICollectionViewCompositionalLayout](https://developer.apple.com/documentation/uikit/uicollectionviewcompositionallayout)
2. [WWDC 2019 - Advances in Collection View Layout](https://developer.apple.com/videos/play/wwdc2019/215/)
