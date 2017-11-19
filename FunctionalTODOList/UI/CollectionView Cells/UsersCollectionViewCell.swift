// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

class UsersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var userInitialsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        bgView.layer.cornerRadius = bgView.frame.width / 2
    }

    func setupWith(user: String) {

        userInitialsLabel.text = user.components(separatedBy: " ")
            .map { String($0.uppercased().prefix(1)) }
            .prefix(2)
            .joined()
    }
}
