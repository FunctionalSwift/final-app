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

    func setupWith(project: Project<Task>) {

        descriptionLabel.text = project.description

        expirationDateTitleLabel.text = NSLocalizedString("project_date", comment: "")
        stateTitleLabel.text = NSLocalizedString("project_state", comment: "")

        if let dates = project.map(ProjectTasks.getDate).elements, !dates.isEmpty {

            expirationDateLabel.attributedText = colorizeDate(date: dates.reduce(dates[0]) { $1 > $0 ? $0 : $1 })
        } else {
            expirationDateLabel.text = "-"
        }

        if let states = project.map(ProjectTasks.getState).elements, !states.isEmpty {

            stateLabel.text = Task.stateAsString(state: states.filter { $0 == false }.isEmpty)
        } else {
            stateLabel.text = "-"
        }

        let taskTypesCount = Task.countTaskTypes(tasks: project.elements)

        completedTasksLabel.text = "\(taskTypesCount.completed)/\(taskTypesCount.doing + taskTypesCount.completed)"

        if let users = project.flatMap(ProjectTasks.getUserName).elements,
            !users.isEmpty {
            usersCollectionView.setupCollectionViewWith(users: users)
        } else {
            usersCollectionView.isHidden = true
            stateTitleLabelBottomConstraint.constant = 5
            stateLabelBottomConstraint.constant = 5
            completedTasksLabelBottomConstraint.constant = 5
        }
    }
}
