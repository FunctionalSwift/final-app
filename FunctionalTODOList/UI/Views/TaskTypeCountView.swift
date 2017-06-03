// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

class TaskTypeCountView: UIView {

    @IBOutlet weak var completedTypeCountLabel: UILabel!
    @IBOutlet weak var doingTypeCountLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupWith(typesCount: TaskTypesCount) {

        completedTypeCountLabel.text = String(format: NSLocalizedString("tasks_completed_message", comment: ""), NSNumber(value: typesCount.completed))
        doingTypeCountLabel.text = String(format: NSLocalizedString("tasks_in_progress_message", comment: ""), NSNumber(value: typesCount.doing))
    }
}
