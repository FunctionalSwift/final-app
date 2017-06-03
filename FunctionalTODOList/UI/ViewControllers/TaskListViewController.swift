// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

enum filteredScopes: Int {
    case title = 0
    case state
    case user

    func string() -> String {
        switch self {
        case .title:
            return NSLocalizedString("task_scoped_title", comment: "")
        case .state:
            return NSLocalizedString("task_scoped_state", comment: "")
        case .user:
            return NSLocalizedString("task_scoped_user", comment: "")
        }
    }
}

extension UIViewController {

    func showInfoAlert(_ title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func showErrorAlert(_ title: String, message: String) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

class TaskListViewController: UIViewController, UISearchBarDelegate, TaskDelegate {

    @IBOutlet weak var taskListTableView: TaskTableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    fileprivate let taskCellIdentifier = "TaskTableViewCell"

    var tasks: [Task]?

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareScreen()
        setupSearchBar()
        registerTableViewCells()

        getTasks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func registerTableViewCells() {

        taskListTableView.register(UINib(nibName: taskCellIdentifier, bundle: nil), forCellReuseIdentifier: taskCellIdentifier)
    }

    func prepareScreen() {
        taskListTableView.isHidden = true
        taskListTableView.alwaysBounceVertical = false
        searchBar.isHidden = true
        noDataView.isHidden = true
    }

    func setupSearchBar() {
        searchBar.showsScopeBar = true
        searchBar.scopeButtonTitles = [filteredScopes.title.string(), filteredScopes.state.string(), filteredScopes.user.string()]
        searchBar.tintColor = UIColor.darkGray
        searchBar.selectedScopeButtonIndex = 0
        searchBar.delegate = self
    }

    // MARK: SearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty, let tasks = tasks {
            taskListTableView.reloadDataWith(tasks)
        } else {
            filterTableViewElements(scopeSelected: searchBar.selectedScopeButtonIndex, text: searchText)
        }
    }

    func filterTableViewElements(scopeSelected: Int, text: String) {

        guard let initialTasks = tasks else {
            return
        }

        switch scopeSelected {
        case filteredScopes.title.rawValue:

            taskListTableView.reloadDataWith(initialTasks.filter { ($0.title?.lowercased().contains(text.lowercased()))! })
            break

        case filteredScopes.state.rawValue:

            taskListTableView.reloadDataWith(initialTasks.filter { ($0.stateAsString().contains(text)) })
            break

        case filteredScopes.user.rawValue:

            taskListTableView.reloadDataWith(initialTasks.filter { ($0.userName?.lowercased().contains(text.lowercased()))! })
            break

        default:
            break
        }
    }

    // MARK: Data from Server

    func getTasks() {

        activityIndicator.startAnimating()

        TaskNetworkHandler.sharedInstance.getTasks({ tasks in

            guard let tasksArray = tasks else {
                return
            }

            if tasksArray.count > 0 {

                self.tasks = tasksArray
                self.taskListTableView.setupTableViewWith(tasks: tasksArray, taskDelegate: self, selectable: false)
                self.taskListTableView.isHidden = false
                self.searchBar.isHidden = false
                self.noDataView.isHidden = true

            } else {
                self.taskListTableView.isHidden = true
                self.searchBar.isHidden = true
                self.noDataView.isHidden = false
            }

            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true

        }) { error in

            debugPrint(error)

            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }

    // MARK: TaskDelegate

    func reloadTasksData() {
        getTasks()
    }

    // MARK: Actions
    @IBAction func addNewTaskAction(_: Any) {

        guard let taskDetailVC = Navigation.getViewController(taskDetailViewController, from: Storyboards.Tasks.rawValue) as? TaskDetailViewController else {
            return
        }

        taskDetailVC.delegate = self

        Navigation.sharedInstance.pushViewController(taskDetailVC, animated: true)
    }

    @IBAction func sortTasksAction(_: Any) {

        if let tasks = taskListTableView.getTasks() {
            switch searchBar.selectedScopeButtonIndex {

            case filteredScopes.title.rawValue:
                taskListTableView.reloadDataWith(tasks.sorted { $0.title?.compare($1.title!) == .orderedAscending })
                break

            case filteredScopes.state.rawValue:
                taskListTableView.reloadDataWith(tasks.sorted { $0.stateAsString().compare($1.stateAsString()) == .orderedAscending })
                break

            case filteredScopes.user.rawValue:
                taskListTableView.reloadDataWith(tasks.sorted { $0.userName?.compare($1.userName!) == .orderedAscending })
                break

            default:
                break
            }
        }
    }

    @IBAction func backButtonAction(_: Any) {

        Navigation.sharedInstance.popViewController(true)
    }
}
