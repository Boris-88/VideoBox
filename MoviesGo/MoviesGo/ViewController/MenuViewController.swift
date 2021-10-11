// MenuViewController.swift
// Copyright © Boris Zverik. All rights reserved.

import UIKit

final class MenuViewController: UIViewController {
    // MARK: - public properties

    lazy var avatarButton = makeAvatarButton()

    // MARK: - Private properties

    private lazy var avatarImageView = makeAvatarImageView()
    private lazy var collectionView = makeCollectionView()
    private var onSelectedID: ((Int) -> Void)?
    private var menuViewModel: MenuViewModel!
    private var menuView: MenuView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - PRIVATE METHODE

    private func setupView() {
        createAvatarButton()
        createTitleNC()
    }

    private func createAvatarButton() {
        let barButton = UIBarButtonItem()
        barButton.customView = avatarButton
        navigationItem.rightBarButtonItem = barButton
        avatarButton.addTarget(self, action: #selector(tapShowAvatarButton), for: .touchUpInside)
        guard let data = UserDefaults.standard.value(forKey: "avatar") as? Data else { fatalError() }
        let image = UIImage(data: data)?.resizeImage(to: CGSize(width: 35, height: 35))
        avatarButton.setImage(image, for: .normal)
    }

    private func createTitleNC() {
        navigationController?.overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Смотреть"
        tabBarController?.tabBar.barTintColor = .white
    }

    @objc public func tapShowAvatarButton() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        present(vc, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension MenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let id = pageDataMovie?.movies[indexPath.row].id else { return }
        onSelectedID = { [weak self] id in
            guard let self = self else { return }
            let descriptionVC = DescriptionViewController()
            descriptionVC.id = id
            self.navigationController?.pushViewController(descriptionVC, animated: true)
        }
        onSelectedID?(id)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        cell.alpha = 0.2
        UIView.animate(withDuration: 0.8) {
            cell.alpha = 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                cell.transform = .init(scaleX: 0.85, y: 0.85)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                cell.transform = .identity
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MenuViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageDataMovie?.movies.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.reuseID,
            for: indexPath
        ) as? CollectionViewCell else { return UICollectionViewCell() }
        if let pageDataMovie = pageDataMovie {
            let movie = pageDataMovie.movies[indexPath.row]
            cell.update(mainHost: AppSetting.imageHost, posterPath: movie.posterPath)
            cell.configurCell(movie: movie)
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 400, height: 200)
    }
}
