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

        task.flatMap {

            if let title = $0.title {
                taskTitleTextView.text(title)
            }

            taskStateTextfield.text = $0.stateAsString()

            if let expirationDate = $0.expiration,
                let expirationString = expirationDate.stringFromDate() {

                taskExpirationTextfield.text = expirationString
            }

            if let userName = $0.userName {
                taskUserNameTextfield.text = userName
            }
        }

        if let userName = task?.userName {
            taskUserNameTextfield.text = userName
        }
    }

    // MARK: Actions

    @IBAction func backButtonAction(_: Any) {

        Navigation.sharedInstance.popViewController(true)
    }

    @IBAction func saveButtonAction(_: Any) {

        validateTask().flatMap {

            if self.task != nil {
                updateTask($0)
            } else {
                createNewTask($0)
            }
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

        TaskNetworkHandler.sharedInstance.deleteTask(taskId) { response in

            response.runSync().fold({ _ in

                self.delegate.flatMap {
                    $0.reloadTasksData()
                }

                Navigation.sharedInstance.popViewController(true)

            }, { error in
                debugPrint(error)

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_DeleteTask_alert_message", comment: ""))
            })
        }
    }

    // MARK: Validate Task Data

    func addTaskValidation(taskId: Int?, title: String, state: String, expiration: String, projectId: Int?, user: String?) -> Future<Result<Task, TaskError>> {

        return curry(Task.init)
            <%> Future.pure(Result.pure(taskId))
            <*> TaskValidator.Title(title)
            <*> Future.pure(Task.state(with: state))
            <*> TaskValidator.Expiration(expiration.dateFromString())
            <*> Future.pure(Result.pure(projectId))
            <*> Future.pure(Result.pure(user))
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

        let taskResult = addTaskValidation(taskId: self.task?.taskId, title: taskTitle, state: taskState, expiration: taskExpiration, projectId: self.task?.projectId, user: userName != "" ? userName : nil)
            .runSync()

        switch taskResult {
        case let .Success(task):

            return task

        case let .Failure(reason):

            showErrorAlert(NSLocalizedString("info_alert_title", comment: ""),
                           message: reason.errorDescription())

            return nil
        }
    }

    // MARK: Data from Server

    func createNewTask(_ task: Task) {

        TaskNetworkHandler.sharedInstance.createTask(task) { response in

            response.runSync().fold({ _ in
                self.delegate.flatMap {
                    $0.reloadTasksData()
                }

                Navigation.sharedInstance.popViewController(true)

            }, { error in
                debugPrint(error)

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_AddTask_alert_message", comment: ""))
            })
        }
    }

    func updateTask(_ task: Task) {

        do {
            try TaskNetworkHandler.sharedInstance.updateTask(task) { response in

                response.runSync().fold({ _ in
                    self.delegate.flatMap {
                        $0.reloadTasksData()
                    }

                    Navigation.sharedInstance.popViewController(true)

                }, { error in
                    debugPrint(error)

                    self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateTask_alert_message", comment: ""))
                })
            }
        } catch let WSError.DataRequired(errorDescription) {

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: errorDescription)

        } catch {
            showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateTask_alert_message", comment: ""))
        }
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
