// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

enum TaskType: Int {
    case task = 0
    case subtask
}

protocol TaskDelegate {
    func reloadTasksData()
}

class TaskDetailViewController: UITableViewController, PickerViewDelegate {

    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskTitleTextView: TextView!
    @IBOutlet weak var taskStateLabel: UILabel!
    @IBOutlet weak var taskStateTextfield: UITextField!
    @IBOutlet weak var taskExpirationLabel: UILabel!
    @IBOutlet weak var taskExpirationTextfield: UITextField!
    @IBOutlet weak var taskUserNameLabel: UILabel!
    @IBOutlet weak var taskUserNameTextfield: UITextField!

    fileprivate let subTaskCollectionViewCell = "SubTaskCollectionViewCell"

    var task: Task?

    var delegate: TaskDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewStrings()

        setPickerData()

        setTextfieldsToolbar()

        if task != nil {
            setTaskData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setViewStrings() {

        taskTitleLabel.text = NSLocalizedString("task_title", comment: "")
        taskStateLabel.text = NSLocalizedString("task_state", comment: "")
        taskExpirationLabel.text = NSLocalizedString("task_expiration_date", comment: "")
        taskUserNameLabel.text = NSLocalizedString("task_user_name", comment: "")
        taskTitleTextView.placeholder(text: NSLocalizedString("task_description_placeholder", comment: ""))
        taskStateTextfield.placeholder = NSLocalizedString("task_state_placeholder", comment: "")
        taskExpirationTextfield.placeholder = NSLocalizedString("task_expiration_date_placeholder", comment: "")
        taskUserNameTextfield.placeholder = NSLocalizedString("task_user_name_placeholder", comment: "")
    }

    func setTextfieldsToolbar() {

        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: NSLocalizedString("done_button_text", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(TaskDetailViewController.donePicker))

        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        taskStateTextfield.inputAccessoryView = toolBar
        taskExpirationTextfield.inputAccessoryView = toolBar
    }

    func setPickerData() {

        let statePicker = PickerView()
        statePicker.pickerDelegate = self
        statePicker.set(dataSource: [TaskState.completed, TaskState.doing])
        taskStateTextfield.inputView = statePicker

        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .dateAndTime
        taskExpirationTextfield.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }

    func setTaskData() {

        guard let task = task else {
            return
        }

        if let title = task.title {
            taskTitleTextView.text(title)
        }

        taskStateTextfield.text = task.stateAsString()

        if let expirationDate = task.expiration,
            let expirationString = expirationDate.stringFromDate() {

            taskExpirationTextfield.text = expirationString
        }

        if let userName = task.userName {
            taskUserNameTextfield.text = userName
        }
    }

    // MARK: Actions

    @IBAction func backButtonAction(_: Any) {

        Navigation.sharedInstance.popViewController(true)
    }

    @IBAction func saveButtonAction(_: Any) {

        if task != nil {
            updateTask()
        } else {
            createNewTask()
        }
    }

    @IBAction func deleteTaskAction(_: Any) {

        guard let task = self.task,
            let taskId = task.taskId else {

            debugPrint("Error - deleteTaskAction(:)")

            showInfoAlert(NSLocalizedString("info_alert_title", comment: ""),
                          message: NSLocalizedString("info_DeleteTask_alert_message", comment: ""))

            return
        }

        TaskNetworkHandler.sharedInstance.deleteTask(taskId, { _ in

            if self.delegate != nil {
                self.delegate?.reloadTasksData()
            }

            Navigation.sharedInstance.popViewController(true)

        }) { error in

            debugPrint(error)
        }
    }

    func validateTask() -> Task? {
        guard let taskTitle = self.taskTitleTextView.text,
            let taskState = self.taskStateTextfield.text,
            let taskExpiration = self.taskExpirationTextfield.text,
            let userName = self.taskUserNameTextfield.text else {

            debugPrint("Error - createNewTask")

            showInfoAlert(NSLocalizedString("info_alert_title", comment: ""),
                          message: NSLocalizedString("info_AddTask_alert_message", comment: ""))

            return nil
        }

        if TaskValidator.validateTitle(title: taskTitle),
            TaskValidator.validateState(state: Task.stateAsBool(state: taskState)),
            TaskValidator.validateDate(date: taskExpiration.dateFromString()) {

            return Task(taskId: task?.taskId, title: taskTitle, state: Task.stateAsBool(state: taskState), expiration: taskExpiration.dateFromString(), projectId: task?.projectId, userName: userName)
        }

        showErrorAlert(NSLocalizedString("info_alert_title", comment: ""),
                       message: NSLocalizedString("error_invalid_data", comment: ""))
        return nil
    }

    // MARK: Data from Server

    func createNewTask() {

        guard let task = validateTask() else {
            return
        }

        TaskNetworkHandler.sharedInstance.createTask(task, { _ in

            if self.delegate != nil {
                self.delegate?.reloadTasksData()
            }

            Navigation.sharedInstance.popViewController(true)

        }) { error in

            debugPrint(error)

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_AddTask_alert_message", comment: ""))
        }
    }

    func updateTask() {

        guard let task = validateTask() else {
            return
        }

        try? TaskNetworkHandler.sharedInstance.updateTask(task, { _ in

            if self.delegate != nil {
                self.delegate?.reloadTasksData()
            }

            Navigation.sharedInstance.popViewController(true)

        }, onError: { error in

            debugPrint(error)

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateTask_alert_message", comment: ""))

        })
    }

    // MARK: PickerViewDelegate

    func updateElementSelected(element: String) {

        taskStateTextfield.text = element
    }

    @objc func donePicker() {

        tableView.endEditing(true)
    }

    @objc func handleDatePicker(sender: UIDatePicker) {

        taskExpirationTextfield.text = sender.date.stringFromDate()
    }
}
