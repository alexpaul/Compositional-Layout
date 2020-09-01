//
//  ViewController.swift
//  Adaptive-Layout
//
//  Created by Alex Paul on 9/1/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class AdaptiveLayoutViewController: UIViewController {
  enum SectionKind: Int, CaseIterable {
    case main
  }
  
  private var collectionView: UICollectionView!
  
  typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>
  private var dataSource: DataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    configureDataSource()
  }
  
  private func configureCollectionView() {
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
    collectionView.backgroundColor = .systemBackground
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(collectionView)
  }
  
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
  
  private func configureDataSource() {
    dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
        fatalError("could not dequeue a LabelCell")
      }
      cell.textLabel.text = "\(item)"
      cell.backgroundColor = .systemOrange
      return cell
    })
    var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Int>()
    snapshot.appendSections([.main])
    snapshot.appendItems(Array(1...100))
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}

