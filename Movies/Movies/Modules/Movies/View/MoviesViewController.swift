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
    func updateWithNetworkStatus(isAvailable: Bool)
}

final class MoviesViewController: UIViewController {
    
    //MARK: - Properties
    var presenter: MoviesPresenter!
    private var currentSortType: SortType = .popular {
        didSet {
            scrollToTop()
            presenter.getSortedMovies(currentSortType)
        }
    }
    private let itemsLeftToNextPage: Int = 2
    private let estimatedCellHeight: CGFloat = 200
    private let padding: CGFloat = 10
    
    private lazy var layout: UICollectionViewCompositionalLayout = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .estimated(estimatedCellHeight))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size,
                                                       subitem: item,
                                                       count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: .zero,
                                                      leading: padding,
                                                      bottom: .zero,
                                                      trailing: padding)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = padding
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
                                     action: #selector(sortingAction))
        return button
    }()
    
    private lazy var defaultTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular Movies"
        label.textColor = Constants.appShadowColor
        return label
    }()
    
    private lazy var searchBarContoller: UISearchController = {
        let controller = UISearchController()
        return controller
    }()
    
    private lazy var scrollToTopButton: UIImageView = {
        let arrowView = UIImageView()
        arrowView.backgroundColor = .white
        arrowView.image = UIImage(systemName: "arrow.up.circle.fill")
        arrowView.tintColor = Constants.appShadowColor
        arrowView.cornerRadius = 25
        arrowView.isUserInteractionEnabled = true
        return arrowView
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        presenter.viewDidLoad()
    }
    
    //MARK: - Actions
    @objc func scrollToTopButtonTapped(_ sender: UITapGestureRecognizer) {
        scrollToTop()
    }
 
    @objc private func sortingAction() {
        let sortMenuController = UIAlertController(title: "Sort by",
                                                   message: nil,
                                                   preferredStyle: .actionSheet)
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
        sortMenuController.view.tintColor = Constants.appShadowColor
        self.present(sortMenuController, animated: true, completion: nil)
    }
    
    //MARK: - Private methods
    private func initialSetup() {
        CollectionViewCell.registerNib(in: collectionView)
        setupNavigationBar()
        setupCollectionView()
        setupSearchController()
        setupScrollToTopButton()
    }
    
    private func setupNavigationBar() {
        navigationItem.searchController = searchBarContoller
        navigationItem.titleView = defaultTitleLabel
        navigationItem.setRightBarButton(sortButton, animated: false)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = Constants.appBackgroundColor
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
        searchBarContoller.searchBar.delegate = self
    }
    
    private func setupScrollToTopButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(scrollToTopButtonTapped(_:)))
        scrollToTopButton.addGestureRecognizer(tap)
        scrollToTopButton.isHidden = true
        view.addSubview(scrollToTopButton)
        
        scrollToTopButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollToTopButton.widthAnchor.constraint(equalToConstant: 50),
            scrollToTopButton.heightAnchor.constraint(equalToConstant: 50),
            scrollToTopButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -75),
            scrollToTopButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25)
        ])
    }
    
    private func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(item: .zero, section: .zero),
                                    at: .centeredVertically,
                                    animated: true)
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
    
    func updateWithNetworkStatus(isAvailable: Bool) {
        isAvailable ?
        navigationItem.setRightBarButton(sortButton, animated: false) : navigationItem.setRightBarButton(nil, animated: false)
    }
}

//MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getItemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = .cell(in: self.collectionView, at: indexPath)
        let movie = presenter.getMovie(for: indexPath.item)
        cell.configure(for: movie)
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == presenter.getItemsCount() - itemsLeftToNextPage {
            presenter.getNextPage(sort: currentSortType)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.movieTapped(at: indexPath.item)
    }
}

//MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.stopSearch()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.search(text: searchText)
    }
}

//MARK: - UIScrollViewDelegate
extension MoviesViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBarContoller.searchBar.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        scrollToTopButton.isHidden = (offsetY < collectionView.frame.height)
    }
}
