# Let's build our first compositional layout 

This app uses a collection view to lay out a grid view of items. 


## 1. Declare the collection view in Storyboard or Programmatic 

```swift 
@IBOutlet weak var collectionView: UICollectionView!
```

## 2. Create the compositional layout

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


## 3. Use the compositional layout to configure the collection view's layout

**Using Storyboard**

```swift 
collectionView.collectionViewLayout = createLayout()
collectionView.backgroundColor = .systemBackground
```

**Programmatically**

```swift 
collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
```

## 4. Declare the data source using `UICollectionViewDiffableDataSource`

```swift 
private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
```

## 5. Declare and enum that will hold the colleciton view's sections


```swift 
enum Section {
  case main
}
```

## 6. Configure the data soruce and the snapshot 

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

## 7. Call the setup code in `viewDidLoad()`

```swift 
configureCollectionView()
configureDataSource()
```

![grid-view-layout](https://github.com/alexpaul/Compositional-Layout/blob/master/Assets/grid-view.png)
