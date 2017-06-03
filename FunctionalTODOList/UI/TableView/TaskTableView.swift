// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

class TaskTableView: UITableView, UITableViewDelegate, UITableViewDataSource {

    var taskDelegate: TaskDelegate?

    fileprivate var projectTaskArray: [Project]?
    fileprivate var taskArray: [Task]?
    fileprivate var selectable: Bool = false
    fileprivate let taskCellIdentifier = "TaskTableViewCell"

    // MARK: TableView Configure

    func tableViewInitialSetup() {
        delegate = self
        dataSource = self

        registerTableViewCells()

        sectionHeaderHeight = UITableViewAutomaticDimension
        estimatedRowHeight = UITableViewAutomaticDimension

        alwaysBounceVertical = false
    }

    func setupTableViewWith(tasks: [Task], taskDelegate: TaskDelegate?, selectable: Bool) {

        tableViewInitialSetup()

        taskArray = tasks

        estimatedSectionHeaderHeight = 57

        self.selectable = selectable
        self.taskDelegate = taskDelegate

        reloadData()
    }

    func setupTableViewWith(projects: [Project], taskDelegate: TaskDelegate, selectable: Bool) {

        tableViewInitialSetup()

        projectTaskArray = projects

        estimatedSectionHeaderHeight = 83

        self.selectable = selectable
        self.taskDelegate = taskDelegate

        reloadData()
    }

    func registerTableViewCells() {

        register(UINib(nibName: taskCellIdentifier, bundle: nil), forCellReuseIdentifier: taskCellIdentifier)
    }

    // MARK: TableView ReloadData

    func reloadDataWith(_ tasks: [Task]) {
        taskArray = tasks
        reloadData()
    }

    func reloadDataWith(_ projects: [Project]) {
        projectTaskArray = projects
        reloadData()
    }

    func getTasks() -> [Task]? {
        return taskArray
    }

    func getProjects() -> [Project]? {
        return projectTaskArray
    }

    // MARK: TableViewDatasource

    func numberOfSections(in _: UITableView) -> Int {

        guard let projects = projectTaskArray else {
            return 1
        }

        return projects.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {

        guard let projects = projectTaskArray,
            let tasks = projects[section].elements else {

            guard let taskArr = taskArray else { return 0 }

            return taskArr.count
        }

        return tasks.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {

        return UITableViewAutomaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {

        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: taskCellIdentifier, for: indexPath) as! TaskTableViewCell

        if let projects = projectTaskArray,
            let projectTaskArr = projects[indexPath.section].elements {

            cell.setupCellWith(task: projectTaskArr[indexPath.row], selectable: selectable)
        } else if let taskArr = taskArray {

            cell.setupCellWith(task: taskArr[indexPath.row], selectable: selectable)
        } else {
            return UITableViewCell()
        }

        return cell
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let projects = projectTaskArray,
            let projectDetailView = UINib(nibName: "ProjectDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? ProjectDetailView else {

            if allowsSelection,
                let taskTypeCountView = UINib(nibName: "TaskTypeCountView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? TaskTypeCountView,
                let taskArr = self.taskArray {

                taskTypeCountView.setupWith(typesCount: Task.countTaskTypes(tasks: taskArr))

                return taskTypeCountView
            }

            return nil
        }

        projectDetailView.setupWith(project: projects[section])

        let tapGesture = UITapGestureRecognizer(target: taskDelegate, action: #selector(ProjectListViewController.projectViewSelected(gestureRecognizer:)))

        projectDetailView.addGestureRecognizer(tapGesture)
        projectDetailView.tag = section

        return projectDetailView
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    // MARK: TableViewDelegate

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let taskDetailVC = Navigation.getViewController(taskDetailViewController, from: Storyboards.Tasks.rawValue) as? TaskDetailViewController,
            !selectable else {
            return
        }

        if let projects = projectTaskArray,
            let tasks = projects[indexPath.section].elements {
            taskDetailVC.task = tasks[indexPath.row]
        } else if let tasks = taskArray {
            taskDetailVC.task = tasks[indexPath.row]
        }

        taskDetailVC.delegate = taskDelegate

        Navigation.sharedInstance.pushViewController(taskDetailVC, animated: true)
    }
}
