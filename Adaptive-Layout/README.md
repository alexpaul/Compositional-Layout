# Using Layout Environment 

In this project we make use of the `layoutEnvironment` argument in the section provider closure to return item count base on the orientation width of the device. 

## [YouTube Video](https://www.youtube.com/watch?v=xl1sdrze_a4)

![adaptive layout](https://github.com/alexpaul/Compositional-Layout/blob/master/Assets/adaptive-layout.png)

```swift 
private func createLayout() -> UICollectionViewLayout {
  let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let spacing: CGFloat = 5
    item.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)

    let containerWidth = layoutEnvironment.container.effectiveContentSize.width
    let itemCount = containerWidth > 800 ? 5 : 3
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.20))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemCount)

    let section = NSCollectionLayoutSection(group: group)

    return section
  }
  return layout
}
```
