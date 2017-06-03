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

        let userArray = user.components(separatedBy: " ")

        var initials = ""
        userArray.forEach { element in
            if initials.count < 2 { initials += element.uppercased().prefix(1) }
        }
        userInitialsLabel.text = initials
    }
}
