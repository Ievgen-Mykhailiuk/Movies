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
    private let edgeInset: CGFloat = 15
    private let spacing: CGFloat = 25
    private let titleFontSize: CGFloat = 26
    private let listTitle: String = "Popular Movies"
    private let noSearchResultsViewHeight: CGFloat = 200
    private let searchInProgressLabelHeight: CGFloat = 50

    private lazy var layout: UICollectionViewCompositionalLayout = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .absolute(estimatedCellHeight))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size,
                                                       subitem: item,
                                                       count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: .zero,
                                                      leading: edgeInset,
                                                      bottom: .zero,
                                                      trailing: edgeInset)
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
    
    private lazy var noSearchResultsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: noSearchResultsViewHeight / 2).isActive = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var noSearchResultsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "noResults")
        imageView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: noSearchResultsViewHeight / 2).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var noSearchResultsView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: .zero,
                                                  y: view.frame.height / 4,
                                                  width: view.frame.width,
                                                  height: noSearchResultsViewHeight))
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(noSearchResultsLabel)
        stackView.addArrangedSubview(noSearchResultsImageView)
        stackView.isHidden = true
        return stackView
    }()
    
    private lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.frame = view.bounds
        backgroundView.addGradient(with: [.white, .darkGray], startPoint: .bottomLeft, endPoint: .topRight)
        return backgroundView
    }()
    
    private lazy var searchInProgressLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: .zero,
                                          y: view.frame.height / 4,
                                          width: view.frame.width,
                                          height: searchInProgressLabelHeight))
        label.attributedText = NSAttributedString(
            string: "Searching...",
            attributes: [.font: UIFont(name: Constants.appFont, size: titleFontSize) as Any,
                         .foregroundColor: Constants.appColor as Any]
        )
        label.textAlignment = .center
        label.isHidden = true
        return label
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
            guard self.currentSortType != .popular else { return }
            self.currentSortType = .popular
        })
        let nowPlaying = UIAlertAction(title: "now playing",
                                       style: .default,
                                       handler: { SortBlock in
            guard self.currentSortType != .nowPlaying else { return }
            self.currentSortType = .nowPlaying
        })
        let topRated = UIAlertAction(title: "top rated",
                                     style: .default,
                                     handler: { SortBlock in
            guard self.currentSortType != .topRated else { return }
            self.currentSortType = .topRated
        })
        let upcoming = UIAlertAction(title: "upcoming",
                                     style: .default,
                                     handler: { SortBlock in
            guard self.currentSortType != .upcoming else { return }
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
        searchBarContoller.view.addSubview(searchInProgressLabel)
        searchBarContoller.view.addSubview(noSearchResultsView)
        searchBarContoller.searchBar.delegate = self
    }
}

//MARK: - MoviesViewProtocol
extension MoviesViewController: MoviesView {

    func showError(with message: String) {
        showAlert(title: .defaultError, message: message)
    }
    
    func update() {
        collectionView.reloadSections(IndexSet(integer: .zero))
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
        noSearchResultsLabel.attributedText = NSAttributedString(
            string: "No results for '\(searchText)'",
            attributes: [.font: UIFont(name: Constants.appFont, size: titleFontSize) as Any,
                         .foregroundColor: Constants.appColor as Any]
        )
        noSearchResultsView.isHidden = false
        searchInProgressLabel.isHidden = true
    }
    
}

//MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getItemsCount(hasLoader: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == presenter.getItemsCount(hasLoader: false) {
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
        guard indexPath.item == presenter.getItemsCount(hasLoader: false) - itemsLeftToNextPage else { return }
        presenter.getNextPage(sort: currentSortType)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath.item)
    }
}

//MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.stopSearch()
        noSearchResultsView.isHidden = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchInProgressLabel.isHidden = searchText.isEmpty
        presenter.search(text: searchText) {
            self.searchInProgressLabel.isHidden = true
        }
        noSearchResultsView.isHidden = true
    }
}

//MARK: - UIScrollViewDelegate
extension MoviesViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBarContoller.searchBar.endEditing(true)
    }
}
