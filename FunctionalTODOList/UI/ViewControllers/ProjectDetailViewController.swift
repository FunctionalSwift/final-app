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

    var taskProject: Project<Task>?
    var delegate: ProjectDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setViewStrings()

        getTasks()
        prepareScreen()

        if taskProject != nil {
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

        taskProject.flatMap { projectDescriptionTextView.text = $0.description }
    }

    func getTasks() {

        activityIndicator.startAnimating()

        TaskNetworkHandler.sharedInstance.getTasks { response in

            response.runSync().fold({ tasks in
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

            }, { error in

                debugPrint(error)

                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true

                self.taskListTableView.isHidden = true
                self.noDataView.isHidden = false

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: error.description())
            })
        }
    }

    // MARK: Actions

    @IBAction func backButtonAction(_: Any) {

        Navigation.sharedInstance.popViewController(true)
    }

    @IBAction func saveButtonAction(_: Any) {

        validateProject().flatMap {

            if self.taskProject != nil {
                updateProject($0)
            } else {
                createNewProject($0)
            }
        }
    }

    @IBAction func deleteTaskAction(_: Any) {

        guard let project = self.taskProject,
            let projectId = project.projectId else {

            debugPrint("Error - deleteTaskAction(:)")

            showInfoAlert(NSLocalizedString("info_alert_title", comment: ""),
                          message: NSLocalizedString("info_DeleteProject_alert_message", comment: ""))

            return
        }

        ProjectNetworkHandler.sharedInstance.deleteProject(projectId) { response in

            response.runSync().fold({ _ in

                self.delegate.flatMap { $0.reloadProjectsData() }

                Navigation.sharedInstance.popViewController(true)

            }, { error in
                debugPrint(error)

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_DeleteProject_alert_message", comment: ""))

            })
        }
    }

    // MARK: Validate Project Data

    func addProjectValidation(projectId: Int?, description: String, tasks: [Task]?) -> Future<Result<Project<Task>, ProjectError>> {

        return curry(Project<Task>.init)
            <%> Future.pure(Result.pure(projectId))
            <*> ProjectValidator.Description(description)
            <*> Future.pure(Result.pure(tasks))
    }

    func validateProject() -> Project<Task>? {

        guard let projectDescription = self.projectDescriptionTextView.text else {
            debugPrint("Error - createNewTask")

            showInfoAlert(NSLocalizedString("info_alert_title", comment: ""),
                          message: NSLocalizedString("info_AddProject_alert_message", comment: ""))

            return nil
        }

        let tasks = taskListTableView.indexPathsForSelectedRows.flatMap {
            $0.map { ind in
                self.taskListTableView.getTasks().flatMap {
                    $0[ind.row]
                }
            }
        }

        let projectResult = addProjectValidation(projectId: taskProject?.projectId, description: projectDescription, tasks: tasks as? [Task]).runSync()

        switch projectResult {

        case let .Success(project):
            return project

        case let .Failure(reason):

            showErrorAlert(NSLocalizedString("info_alert_title", comment: ""),
                           message: reason.errorDescription())

            return nil
        }
    }

    // MARK: Data from Server

    func createNewProject(_ project: Project<Task>) {

        ProjectNetworkHandler.sharedInstance.createProject(project) { response in

            response.runSync().fold({ proj in

                self.updateProjectTasks(project: Project<Task>(projectId: proj.projectId, description: proj.description, elements: project.elements))

            }, { error in
                debugPrint(error)

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_AddProject_alert_message", comment: ""))

            })
        }
    }

    func updateProject(_ project: Project<Task>) {

        do {
            try ProjectNetworkHandler.sharedInstance.updateProject(project) { response in

                response.runSync().fold({ _ in

                    self.updateProjectTasks(project: project)

                }, { error in
                    debugPrint(error)

                    self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateProject_alert_message", comment: ""))
                })
            }
        } catch let WSError.DataRequired(errorDescription) {

            self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: errorDescription)

        } catch {
            showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateTask_alert_message", comment: ""))
        }
    }

    func updateProjectTasks(project: Project<Task>) {

        try? ProjectNetworkHandler.sharedInstance.updateProjectTask(project, { response in

            response.runSync().fold({ _ in
                self.removeProjectTask(project)

                self.delegate.flatMap {
                    $0.reloadProjectsData()
                }

                Navigation.sharedInstance.popViewController(true)

            }, { error in
                debugPrint(error)

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: error.description())
            })
        })
    }

    func selectedProjectTask(allTasks: [Task]) {

        guard let project = taskProject,
            let tasks = project.elements else {
            return
        }

        tasks.forEach { task in

            if let index = allTasks.index(where: { task.taskId == $0.taskId }) {
                taskListTableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }

    func removeProjectTask(_ validatedProject: Project<Task>) {

        guard let oldProject = taskProject,
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
        try? TaskNetworkHandler.sharedInstance.updateTask(task, { response in

            response.runSync().ifFailure({ error in

                debugPrint(error)

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: NSLocalizedString("error_UpdateProject_alert_message", comment: ""))
            })
        })
    }
}
