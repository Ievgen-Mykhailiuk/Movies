//
//  MoviesViewController.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol MoviesView: AnyObject {
    func update()
    func showError(with message: String)
    func updateWithNetworkStatus(_ isAvailable: Bool)
    func scrollToTop()
    func updateWithEmptySearchResults(for searchText: String)
}

final class MoviesViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: MoviesPresenter!
    private var currentSortType: SortType = .popular {
        didSet {
            presenter.getSortedList(currentSortType)
        }
    }
    private let itemsLeftToNextPage: Int = 2
    private let estimatedCellHeight: CGFloat = 220
    private let padding: CGFloat = 15
    private let spacing: CGFloat = 25
    private let titleFontSize: CGFloat = 26
    private let listTitle: String = "Popular Movies"
    private let noResultsViewHeight: CGFloat = 400
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .absolute(estimatedCellHeight))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size,
                                                       subitem: item,
                                                       count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: .zero,
                                                      leading: padding,
                                                      bottom: .zero,
                                                      trailing: padding)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private lazy var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(sortButtonAction))
        return button
    }()

    private lazy var searchBarContoller: UISearchController = {
        let controller = UISearchController()
        controller.searchBar.searchTextField.backgroundColor = UIColor(named: "searchBar")
        return controller
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: noResultsViewHeight / 2).isActive = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var noResultsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noResults")
        imageView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: noResultsViewHeight / 2).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var noResultsView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: view.frame.minX,
                                                  y: view.frame.midY - noResultsViewHeight / 2,
                                                  width: view.frame.width,
                                                  height: noResultsViewHeight))
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(noResultsLabel)
        stackView.addArrangedSubview(noResultsImageView)
        return stackView
    }()
    
    private lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.frame = view.bounds
        view.addSubview(backgroundView)
        backgroundView.addGradient(with: Constants.backgroundColorSet,
                                   startPoint: .bottomLeft,
                                   endPoint: .topRight)
        return backgroundView
    }()
        
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        presenter.viewDidLoad()
    }

    //MARK: - Actions
    @objc private func sortButtonAction() {
        let sortMenuController = UIAlertController(title: "Sort by",
                                                   message: nil,
                                                   preferredStyle: .actionSheet)
        sortMenuController.view.tintColor = Constants.appColor
        
        let popular = UIAlertAction(title: "popular",
                                    style: .default,
                                    handler: { SortBlock in
            self.currentSortType = .popular
        })
        let nowPlaying = UIAlertAction(title: "now playing",
                                       style: .default,
                                       handler: { SortBlock in
            self.currentSortType = .nowPlaying
        })
        let topRated = UIAlertAction(title: "top rated",
                                     style: .default,
                                     handler: { SortBlock in
            self.currentSortType = .topRated
        })
        let upcoming = UIAlertAction(title: "upcoming",
                                     style: .default,
                                     handler: { SortBlock in
            self.currentSortType = .upcoming
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        switch currentSortType {
        case .nowPlaying:
            nowPlaying.setValue(true, forKey: "checked")
        case .popular:
            popular.setValue(true, forKey: "checked")
        case .topRated:
            topRated.setValue(true, forKey: "checked")
        case .upcoming:
            upcoming.setValue(true, forKey: "checked")
        }
        
        sortMenuController.addAction(nowPlaying)
        sortMenuController.addAction(popular)
        sortMenuController.addAction(topRated)
        sortMenuController.addAction(upcoming)
        sortMenuController.addAction(cancelAction)
        
        present(sortMenuController, animated: true, completion: nil)
    }
    
    //MARK: - Private methods
    private func initialSetup() {
        CollectionViewCell.registerNib(in: collectionView)
        LoaderCell.registerClass(in: collectionView)
        setupNavigationBar()
        setupCollectionView()
        setupSearchController()
    }
    
    private func setupNavigationBar() {
        title = listTitle
        navigationController?.navigationBar.tintColor = Constants.appColor
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont(name: Constants.appFont, size: titleFontSize) as Any,
            .foregroundColor: Constants.appColor as Any
        ]
        navigationItem.searchController = searchBarContoller
        navigationItem.setRightBarButton(sortButton, animated: false)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundView = backgroundView
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchBarContoller.view.addSubview(noResultsView)
        noResultsView.isHidden = true
        searchBarContoller.searchBar.delegate = self
    }
}

//MARK: - MoviesViewProtocol
extension MoviesViewController: MoviesView {

    func showError(with message: String) {
        showAlert(title: .defaultError, message: message)
    }
    
    func update() {
        collectionView.reloadData()
    }
    
    func updateWithNetworkStatus(_ isAvailable: Bool) {
        navigationItem.setRightBarButton(isAvailable ? sortButton : nil, animated: false)
    }
    
    func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(item: .zero, section: .zero),
                                    at: .centeredVertically,
                                    animated: true)
    }
   
    func updateWithEmptySearchResults(for searchText: String) {
        noResultsLabel.attributedText = NSAttributedString(
            string: "No results for '\(searchText)'",
            attributes: [.font: UIFont(name: Constants.appFont, size: titleFontSize) as Any,
                         .foregroundColor: Constants.appColor as Any]
        )
        noResultsView.isHidden = false
    }
    
}

//MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getItemsCount(isIncremented: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == presenter.getItemsCount(isIncremented: false) {
            let cell: LoaderCell = .cell(in: self.collectionView, at: indexPath)
            cell.configure()
            return cell
        } else {
            let cell: CollectionViewCell = .cell(in: self.collectionView, at: indexPath)
            let movie = presenter.getItem(for: indexPath.item)
            cell.configure(for: movie)
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegate
extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.item == presenter.getItemsCount(isIncremented: false) - itemsLeftToNextPage {
            presenter.getNextPage(sort: currentSortType)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath.item)
    }
}

//MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.stopSearch()
        noResultsView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.search(text: searchText)
        noResultsView.isHidden = true
    }
}

//MARK: - UIScrollViewDelegate
extension MoviesViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBarContoller.searchBar.endEditing(true)
    }
}
