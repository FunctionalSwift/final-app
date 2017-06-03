// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

protocol ProjectDelegate {
    func reloadProjectsData()
}

class ProjectDetailViewController: UIViewController {

    @IBOutlet weak var projectDescriptionLabel: UILabel!
    @IBOutlet weak var projectDescriptionTextView: TextView!
    @IBOutlet weak var taskListLabel: UILabel!
    @IBOutlet weak var taskListTableView: TaskTableView!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var project: Project?
    var delegate: ProjectDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewStrings()

        getTasks()
        prepareScreen()

        if project != nil {
            setProjectTasksData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setViewStrings() {

        projectDescriptionLabel.text = NSLocalizedString("project_description_text", comment: "")
        projectDescriptionTextView.placeHolder = NSLocalizedString("project_description_placeholder", comment: "")
        taskListLabel.text = NSLocalizedString("project_task_list_text", comment: "")
    }

    func prepareScreen() {
        taskListTableView.isHidden = true
        taskListTableView.tableFooterView = UIView()
        noDataView.isHidden = true
    }

    func setProjectTasksData() {

        if let project = project {
            projectDescriptionTextView.text = project.description
        }
    }

    func getTasks() {

        activityIndicator.startAnimating()

        TaskNetworkHandler.sharedInstance.getTasks({ tasks in

            guard let tasks = tasks else {
                self.taskListTableView.isHidden = true
                self.noDataView.isHidden = false
                return
            }

            if tasks.isEmpty {
                self.taskListTableView.isHidden = true
                self.noDataView.isHidden = false

            } else {

                self.taskListTableView.setupTableViewWith(tasks: tasks, taskDelegate: nil, selectable: true)
                self.selectedProjectTask(allTasks: tasks)
                self.taskListTableView.isHidden = false
                self.noDataView.isHidden = true
            }

            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true

        }) { error in

            debugPrint(error)

            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true

            self.taskListTableView.isHidden = true
            self.noDataView.isHidden = false

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: error.localizedDescription)
        }
    }

    // MARK: Actions

    @IBAction func backButtonAction(_: Any) {

        Navigation.sharedInstance.popViewController(true)
    }

    @IBAction func saveButtonAction(_: Any) {
        if project != nil {
            updateProject()
        } else {
            createNewProject()
        }
    }

    @IBAction func deleteTaskAction(_: Any) {

        guard let project = self.project,
            let projectId = project.projectId else {

            debugPrint("Error - deleteTaskAction(:)")

            showInfoAlert(NSLocalizedString("info_alert_title", comment: ""),
                          message: NSLocalizedString("info_DeleteProject_alert_message", comment: ""))

            return
        }

        ProjectNetworkHandler.sharedInstance.deleteProject(projectId, { _ in

            if let delegate = self.delegate {
                delegate.reloadProjectsData()
            }
            Navigation.sharedInstance.popViewController(true)

        }) { error in
            debugPrint(error)

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_DeleteProject_alert_message", comment: ""))
        }
    }

    // MARK: Validate Project Data

    func validateProject() -> Project? {

        guard let projectDescription = self.projectDescriptionTextView.text else {
            debugPrint("Error - createNewTask")

            showInfoAlert(NSLocalizedString("info_alert_title", comment: ""),
                          message: NSLocalizedString("info_AddProject_alert_message", comment: ""))

            return nil
        }

        var tasksArray: [Task] = []

        if let indexes = taskListTableView.indexPathsForSelectedRows {
            indexes.forEach { index in
                if let tasks = self.taskListTableView.getTasks() {
                    tasksArray.append(tasks[index.row])
                }
            }
        }

        if ProjectValidator.validateDescription(description: projectDescription) {
            return Project(projectId: project?.projectId, description: projectDescription, elements: tasksArray)
        }

        showErrorAlert(NSLocalizedString("info_alert_title", comment: ""),
                       message: NSLocalizedString("error_project_invalid_data", comment: ""))

        return nil
    }

    // MARK: Data from Server

    func createNewProject() {

        guard let project = validateProject() else {
            return
        }

        ProjectNetworkHandler.sharedInstance.createProject(project, { proj in

            if var proj = proj {
                proj.elements = project.elements
                self.updateProjectTasks(project: proj)
            }

        }) { error in
            debugPrint(error)

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_AddProject_alert_message", comment: ""))
        }
    }

    func updateProject() {

        guard let project = validateProject() else {
            return
        }

        do {
            try ProjectNetworkHandler.sharedInstance.updateProject(project, { _ in

                self.updateProjectTasks(project: project)

            }, onError: { error in
                debugPrint(error)

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateProject_alert_message", comment: ""))

            })
        } catch let WSError.dataRequired(errorDescription) {

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: errorDescription)

        } catch {
            showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateTask_alert_message", comment: ""))
        }
    }

    func updateProjectTasks(project: Project) {
        try? ProjectNetworkHandler.sharedInstance.updateProjectTask(project, { _ in
            self.removeProjectTask(project)

            if let delegate = self.delegate {
                delegate.reloadProjectsData()
            }

            Navigation.sharedInstance.popViewController(true)

        }, onError: { error in
            debugPrint(error)

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: error.localizedDescription)

        })
    }

    func selectedProjectTask(allTasks: [Task]) {

        guard let project = project,
            let tasks = project.elements else {
            return
        }

        tasks.forEach { task in

            if let index = allTasks.index(where: { task.taskId == $0.taskId }) {
                taskListTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }

    func removeProjectTask(_ validatedProject: Project) {

        guard let oldProject = project,
            let oldProjectElements = oldProject.elements else {
            return
        }

        oldProjectElements.filter { oldElement in

            guard let validatedElements = validatedProject.elements else {
                return true
            }

            return validatedElements.filter { oldElement.taskId == $0.taskId }.isEmpty

        }.forEach { self.updateTask(task: Task(taskId: $0.taskId, title: $0.title, state: $0.state, expiration: $0.expiration, projectId: nil, userName: $0.userName)) }
    }

    func updateTask(task: Task) {
        try? TaskNetworkHandler.sharedInstance.updateTask(Task(taskId: task.taskId, title: task.title, state: task.state, expiration: task.expiration, projectId: nil, userName: task.userName), { _ in
        }, onError: { error in
            debugPrint(error)

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateProject_alert_message", comment: ""))
        })
    }
}
