// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskStateLabel: UILabel!
    @IBOutlet weak var taskExpirationLabel: UILabel!
    @IBOutlet weak var taskSelectStateImageView: UIImageView!

    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userLabel: UILabel!

    @IBOutlet weak var taskStateLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var taskTitleLabelTrailingConstraint: NSLayoutConstraint!

    var selectable: Bool?

    override func awakeFromNib() {
        super.awakeFromNib()

        userView.layer.cornerRadius = userView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        guard let selectable = self.selectable,
            selectable == true else {
            return
        }

        taskSelectStateImageView.image = selected ? UIImage(named: "check") : UIImage(named: "uncheck")
    }

    func setupCellWith(task: Task, selectable: Bool) {

        if let title = task.title {
            taskTitleLabel.text = title
        }

        taskStateLabel.text = task.stateAsString()
        if let expiration = task.expiration {
            taskExpirationLabel.attributedText = colorizeDate(date: expiration)
        }

        self.selectable = selectable

        if selectable {
            taskSelectStateImageView.isHidden = false
            taskTitleLabelTrailingConstraint.constant = 45
        } else {
            taskSelectStateImageView.isHidden = true
            taskTitleLabelTrailingConstraint.constant = 0
        }

        if let user = task.userName, user != "" {

            let userArray = user.components(separatedBy: " ")

            var initials = ""
            userArray.forEach { element in
                if initials.count < 2 { initials += element.uppercased().prefix(1) }
            }
            userLabel.text = initials

            userView.isHidden = false
            taskStateLabelLeadingConstraint.constant = 45
        } else {
            userView.isHidden = true
            taskStateLabelLeadingConstraint.constant = 5
        }
    }

    func getExpirationDate(task: Task) -> Date {
        return task.expiration!
    }
}
