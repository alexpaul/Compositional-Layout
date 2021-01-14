# Nested Groups and Orthogonal Scrolling

## Objectives

* Nesting groups using compositional layout. 
* Using orthogonal scrolling within sections. 
* Adding header views to sections using `NSCollectionLayoutBoundarySupplementaryItem`. 
* Be familiar with the types of orthogonal scrolling. 

## [YouTube Video](https://youtu.be/y-WKeFkbEoc)


![sketch of nested groups](https://github.com/alexpaul/Compositional-Layout/blob/master/Assets/nested-groups-sketch.jpg)

![app](https://github.com/alexpaul/Compositional-Layout/blob/master/Assets/nested-groups-orthogonal-scrolling.png)

## Starter Files 

#### Label.swift 

```swift 
import UIKit

class LabelCell: UICollectionViewCell {
  static let reuseIdentifier = "labelCell"
  
  public lazy var textLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
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
      textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
    ])
  }
}
```

#### HeaderView.swift 

```swift 
import UIKit

class HeaderView: UICollectionReusableView {
  static let reuseIdentifier = "headerView"
  
  public lazy var textLabel: UILabel = {
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
    setupLabelConstraints()
  }
  
  private func setupLabelConstraints() {
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

## 1. Add collection view programmatically or using Storyboards

```swift 
private var collectionView: UICollectionView!
```

## 2. Create an `enum` that will be responsible for the sections of the collection view 

```swift 
enum SectionKind: Int, CaseIterable {
  case first
  case second
  case third

  var itemCount: Int {
    switch self {
    case .first:
      return 2
    default:
      return 1
    }
  }

  var innerGroupHeight: NSCollectionLayoutDimension {
    switch self {
    case .first:
      return .fractionalWidth(0.90)
    default:
      return .fractionalWidth(0.45)
    }
  }

  var orthogonalBehaviour: UICollectionLayoutSectionOrthogonalScrollingBehavior {
    switch self {
    case .first:
      return .continuous
    case .second:
      return .groupPaging
    case .third:
      return .groupPagingCentered
    }
  }
}
```

## 3. Create the compositional layout 

```swift 
private func createLayout() -> UICollectionViewLayout {
  let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

    guard let sectionKind = SectionKind(rawValue: sectionIndex) else { return nil }

    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let itemSpacing: CGFloat = 10
    item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)

    let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .fractionalHeight(1.0))
    let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: sectionKind.itemCount)

    let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.90), heightDimension: sectionKind.innerGroupHeight)
    let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])

    let section = NSCollectionLayoutSection(group: nestedGroup)
    section.orthogonalScrollingBehavior = sectionKind.orthogonalBehaviour

    let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    section.boundarySupplementaryItems = [header]

    return section
  }
  return layout
}
```

## 4. Configure the collection view 

```swift 
collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
collectionView.backgroundColor = .systemBackground
collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
view.addSubview(collectionView)
```

## 5. Declare the data source 

```swift 
private var collectionView: UICollectionView!

typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>
```

## 6. Configure the data soruce and the initial snapshot 

```swift 
private func configureDataSource() {
  dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
      fatalError()
    }
    cell.textLabel.text = "\(item)"
    cell.backgroundColor = .systemOrange
    cell.layer.cornerRadius = 10
    return cell
  })

  dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
    guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView,
      let _ = SectionKind(rawValue: indexPath.section) else {
        fatalError()
    }
    headerView.textLabel.textAlignment = .left
    headerView.textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    headerView.textLabel.text = "\(SectionKind.allCases[indexPath.section])".capitalized
    return headerView
  }

  var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Int>()
  snapshot.appendSections([.first, .second, .third])
  snapshot.appendItems(Array(1...20), toSection: .first)
  snapshot.appendItems(Array(21...40), toSection: .second)
  snapshot.appendItems(Array(41...60), toSection: .third)
  dataSource.apply(snapshot, animatingDifferences: false)
}
```

## 7. Challenge 

#### App Store Layout 

This layout is inspired from the Apple App Store redesign from iOS 13. To work on this challenge navigate to the `Apps` tab in App Store iOS app. Three sections as illustrated below is sufficient for this challenge.

![app store](https://github.com/alexpaul/Compositional-Layout/blob/master/Assets/app-store.png)

![app store](https://github.com/alexpaul/Compositional-Layout/blob/master/Assets/app-store-continued.png)

## [Video](https://youtu.be/y-WKeFkbEoc)

