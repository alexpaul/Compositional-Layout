//
//  ViewController.swift
//  Nested-Groups-Orthogonal-Scrolling
//
//  Created by Alex Paul on 8/24/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

enum SectionKind: Int, CaseIterable {
  case first
  case second
  case third
  
  // computed property will return the number of
  // items to vertically stack
  var itemCount: Int {
    switch self { // sectionKind
    case .first:
      return 2
    default:
      return 1
    }
  }
  
  var nestedGroupHeight: NSCollectionLayoutDimension {
    switch self {
    case .first:
      return .fractionalWidth(0.9)
    default:
      return .fractionalWidth(0.45)
    }
  }
  
  var sectionTitle: String {
    switch self {
    case .first:
      return "First Section"
    case .second:
      return "Second Section"
    case .third:
      return "Third Section"
    }
  }
}

class NestedGroupsViewController: UIViewController {
  
  private var collectionView: UICollectionView!
  
  typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, Int>
  private var dataSource: DataSource!

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    configureDataSource()
    navigationItem.title = "Nested Groups and Orthogonal Scrolling"
  }
  
  private func configureCollectionView() {
    //collectionView.collectionViewLayout = createLayout()
    collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
    collectionView.backgroundColor = .systemBackground
    collectionView.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.reuseIdentifier)
    collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
    collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(collectionView)
  }
  
  private func createLayout() -> UICollectionViewLayout {
    // item -> group -> section -> layout
    
    // two ways to create a layout
    // 1. use a given section
    // 2. use a section provider which takes a closure
    //    - the section provider closure gets called
    //    - for each section
    
    let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
      // 0, 1, 2
      
      // figure out what section we are dealing with
      guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
        fatalError("could not create a sectionKind instance")
      }
      // item
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      let itemSpacing: CGFloat = 5
      item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)
      
      // group
      let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .fractionalHeight(1.0))
      let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, subitem: item, count: sectionKind.itemCount) // 2 or 1
      
      let nestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: sectionKind.nestedGroupHeight)
      let nestedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: nestedGroupSize, subitems: [innerGroup])
      
      
      // section
      let section = NSCollectionLayoutSection(group: nestedGroup)
      section.orthogonalScrollingBehavior = .groupPagingCentered
      
      // section header
      // we can setup sizes using: .fractional, .absoulte, .estimated
      // Steps to add a section header to a section
      // 1. define the size and add to the section
      // 2. register the supplementary view
      // 3. dequeue the supplementary view
      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
      let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
      section.boundarySupplementaryItems = [header]
      
      return section
    }
    // layout
    return layout
  }
  
  private func configureDataSource() {
    dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
      // configure cell and return cell
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCell.reuseIdentifier, for: indexPath) as? LabelCell else {
        fatalError("could not dequeue a LabelCell")
      }
      // item is an Int
      cell.textLabel.text = "\(item)" // e.g 1, 2
      cell.backgroundColor = .systemOrange
      cell.layer.cornerRadius = 10
      return cell
    })
    
    // dequeue the header supplementary view
    dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
      
      guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView,
        let sectionKind = SectionKind(rawValue: indexPath.section) else {
        fatalError("could not dequeue a HeaderView")
      }
      // configure the headerView
      headerView.textLabel.text = sectionKind.sectionTitle
      headerView.textLabel.textAlignment = .left
      headerView.textLabel.font = UIFont.preferredFont(forTextStyle: .headline)
      return headerView
    }
    
    // create initial snapshot
    var snapshot = NSDiffableDataSourceSnapshot<SectionKind, Int>()
    
    snapshot.appendSections([.first, .second, .third])
    
    // populate the sections (3)
    snapshot.appendItems(Array(1...20), toSection: .first)
    snapshot.appendItems(Array(21...40), toSection: .second)
    snapshot.appendItems(Array(41...60), toSection: .third)
    
    dataSource.apply(snapshot, animatingDifferences: false)
  }
}

