# Multiple Sections 

## Objectives 

* Use `UICollectionViewCompositionalLayout` provider to configure various sections.
* Subclass `UICollectionReusableView` to create a section header. 
* Use `NSCollectionLayoutBoundarySupplementaryItem` to creaate a section header view. 
* Add a header view to the section's `boundarySupplementaryItems` property. 
* Configure the data source's `supplementaryViewProvider` property with a given closure that returns a supplementary view. 

## 1. Setup an `enum` that will hold the sections 

```swift 
enum Section: Int, CaseIterable {
  case grid
  case single
  var columnCount: Int {
    switch self {
    case .grid:
      return 4
    case .single:
      return 1
    }
  }
}
```

The `columnCount` computed property returns the number of columns for a specific section. 

## 2. Declare the collection view and the data source instance properties

```swift 
@IBOutlet weak var collectionView: UICollectionView!

typealias DataSource = UICollectionViewDiffableDataSource<Section, Int>
private var dataSource: DataSource!
```

Above we use a `typealias` so it's more efficient and quicker to write out `UICollectionViewDiffableDataSource<Section, Int>`. 

## 3. Create the compositional layout using the `UICollectionViewCompositionalLayout` provider initializer. 

This initializer has two arguments: the section index and the layout environment. The layout environment is very useful for configuring different layouts across device classes. 


```swift 
private func createLayout() -> UICollectionViewLayout {
  // 1
  let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

    // 2
    guard let sectionType = Section(rawValue: sectionIndex) else {
      return nil
    }

    // 3
    let columns = sectionType.columnCount // 1 column or 4 columns

    // 4
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

    // 5
    let groupHeight = columns == 1 ? NSCollectionLayoutDimension.absolute(200) : NSCollectionLayoutDimension.fractionalWidth(0.25)

    // 6
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns) // 1 or 4

    // 7
    let section = NSCollectionLayoutSection(group: group)

    // 8
    return section
  }
  // 9
  return layout
}
```

## 4. Configure the collection view 

```swift 
private func configureCollectionView() {
  collectionView.collectionViewLayout = createLayout()
  collectionView.backgroundColor = .systemBackground
}
``` 

## 5. Configure the data source and the initial snapshot 

```swift 
private func configureDataSource() {
  // 1
  dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "labelCell", for: indexPath) as? LabelCell else {
      fatalError()
    }
    cell.textLabel.text = "\(item)"
    if indexPath.section == 0 {
      cell.backgroundColor = .systemOrange
    } else {
      cell.backgroundColor = .systemGreen
    }
    return cell
  })

  // 2
  var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
  snapshot.appendSections([.grid, .single])
  snapshot.appendItems(Array(1...12), toSection: .grid)
  snapshot.appendItems(Array(13...20), toSection: .single)
  dataSource.apply(snapshot, animatingDifferences: false)
}
```

## 6. Subclass `UICollectionReusableView` to create the header view for the section

```swift 
class HeaderView: UICollectionReusableView {
  public var textLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    return label
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
    textLabelConstraints()
  }
  
  private func textLabelConstraints() {
    addSubview(textLabel)
    textLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
      textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
    ])
  }
}
```

## 7. Register the supplementary view to the collection view 

```swift 
private func configureCollectionView() {
  // other code
  collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
}
```

## 8. Configure the `supplementaryViewProvider` on the data source 

```swift 
private func configureDataSource() {
  // 1
  // ...

  // 3
  //https://developer.apple.com/documentation/uikit/uicollectionviewdiffabledatasourcereference/uicollectionviewdiffabledatasourcereferencesupplementaryviewprovider
  dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
    guard let headerView = self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderView else {
      fatalError()
    }
    headerView.textLabel.text = "\(Section.allCases[indexPath.section])".capitalized
    // https://developer.apple.com/documentation/uikit/uifont/scaling_fonts_automatically
    headerView.textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    return headerView
  }

  // 2
  // ...
}
```

A [closure](https://developer.apple.com/documentation/uikit/uicollectionviewdiffabledatasourcereference/uicollectionviewdiffabledatasourcereferencesupplementaryviewprovider) that configures and returns a collection view’s supplementary view, such as a header or footer, from a diffable data source.

## 9. Create the `NSCollectionLayoutBoundrySupplementaryItem` header view 

```swift 
private func createLayout() -> UICollectionViewLayout {
  // 1
  let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

    // 2
    // ...

    // 3
    // ...
    
    // 4
    // ...

    // 5
    // ...

    // 6
    // ...

    // 7
    // ...

    // 10 - setup header view
    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    section.boundarySupplementaryItems = [header]

    // 8
    // ...
  }
  // 9
  return layout
}
```

## 10. Setup configurations in `viewDidLoad()`

```swift 
override func viewDidLoad() {
  super.viewDidLoad()
  configureCollectionView()
  configureDataSource()
}
```

![multiple-sections](https://github.com/alexpaul/Compositional-Layout/blob/master/Assets/multiple-sections-update.png)

## [Video](https://youtu.be/DcVFs7jLMBs)
