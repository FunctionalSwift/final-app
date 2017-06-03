// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

class UsersCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    fileprivate var usersArray: [String]?
    fileprivate let usersCellIdentifier = "UsersCollectionViewCell"

    func setupCollectionViewWith(users: [String]) {
        delegate = self
        dataSource = self

        registerCollectionViewCells()

        usersArray = users

        reloadData()
    }

    func registerCollectionViewCells() {

        register(UINib(nibName: usersCellIdentifier, bundle: nil), forCellWithReuseIdentifier: usersCellIdentifier)
    }

    // MARK: UICollectionViewDataSource
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {

        guard let users = usersArray else {
            return 0
        }
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UsersCollectionViewCell", for: indexPath) as! UsersCollectionViewCell

        if let users = usersArray {
            cell.setupWith(user: users[indexPath.row])
        }

        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAtIndexPath _: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
}
