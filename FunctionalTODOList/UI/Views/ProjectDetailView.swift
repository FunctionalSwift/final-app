// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

class ProjectDetailView: UIView {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var expirationDateTitleLabel: UILabel!
    @IBOutlet weak var stateTitleLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var completedTasksLabel: UILabel!
    @IBOutlet weak var usersCollectionView: UsersCollectionView!

    @IBOutlet weak var stateTitleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stateLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var completedTasksLabelBottomConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupWith(project: Project) {

        descriptionLabel.text = project.description

        expirationDateTitleLabel.text = NSLocalizedString("project_date", comment: "")
        stateTitleLabel.text = NSLocalizedString("project_state", comment: "")

        var users = [String]()
        var date: Date?
        var state = true

        if let tasks = project.elements, !tasks.isEmpty {

            tasks.forEach { task in

                if let user = task.userName, user != "" {
                    users.append(user)
                }

                if let expiration = task.expiration {
                    if date == nil || date! > expiration {
                        date = expiration
                    }
                }

                if let taskState = task.state, !taskState {
                    state = taskState
                }
            }

            if let date = date {
                expirationDateLabel.attributedText = colorizeDate(date: date)
            } else {
                expirationDateLabel.text = "_"
            }

            stateLabel.text = state ? TaskState.completed : TaskState.doing

        } else {
            expirationDateLabel.text = "-"
            stateLabel.text = "-"
        }

        let taskTypesCount = Task.countTaskTypes(tasks: project.elements)

        completedTasksLabel.text = "\(taskTypesCount.completed)/\(taskTypesCount.doing + taskTypesCount.completed)"

        if users.isEmpty {
            usersCollectionView.isHidden = true
            stateTitleLabelBottomConstraint.constant = 5
            stateLabelBottomConstraint.constant = 5
            completedTasksLabelBottomConstraint.constant = 5
        } else {
            usersCollectionView.setupCollectionViewWith(users: users)
        }
    }
}
