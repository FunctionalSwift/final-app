// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

class ProjectListViewController: UIViewController, UISearchBarDelegate, TaskDelegate, ProjectDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var projectListTableView: TaskTableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var projects: [Project<Task>]?

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareScreen()
        setupSearchBar()

        getProjects()

        automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func prepareScreen() {
        searchBar.isHidden = true
        noDataView.isHidden = true
    }

    func setupSearchBar() {
        searchBar.showsScopeBar = false
        searchBar.tintColor = UIColor.darkGray
        searchBar.selectedScopeButtonIndex = 0
        searchBar.delegate = self
    }

    // MARK: SearchBarDelegate

    func searchBar(_: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {

            projects.flatMap {
                projectListTableView.reloadDataWith($0)
            }
        } else {
            filterTableViewElements(text: searchText)
        }
    }

    func filterTableViewElements(text: String) {

        projects.flatMap {
            projectListTableView.reloadDataWith(
                $0.filter {
                    ($0.description?.lowercased().contains(text.lowercased()))!
            })
        }
    }

    // MARK: Data from Server

    func map<Date>(_ proj: Project<Task>, transform: @escaping (Task) -> Date) -> Project<Date> {

        return Project(projectId: nil, description: nil, elements: proj.elements.map { $0.map(transform) })
    }

    func getProjects() {

        activityIndicator.startAnimating()

        ProjectNetworkHandler.sharedInstance.getProjects { response in

            response.runSync().fold({ projects in

                if projects.isEmpty {
                    self.projectListTableView.isHidden = true
                    self.searchBar.isHidden = true
                    self.noDataView.isHidden = false
                } else {

                    self.projects = projects
                    self.projectListTableView.setupTableViewWith(projects: projects, taskDelegate: self, selectable: false)
                    self.projectListTableView.isHidden = false
                    self.searchBar.isHidden = false
                    self.noDataView.isHidden = true
                }

                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true

            }, { error in
                debugPrint(error)

                self.projectListTableView.isHidden = true
                self.searchBar.isHidden = true
                self.noDataView.isHidden = false

                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true

                self.showErrorAlert(NSLocalizedString("error_alert_title", comment: ""), message: error.description())

            })
        }
    }

    // MARK: Actions

    @IBAction func addNewProjectAction(_: Any) {

        guard let projectDetailVC = Navigation.getViewController(projectDetailViewController, from: Storyboards.Projects.rawValue) as? ProjectDetailViewController else {
            return
        }

        projectDetailVC.delegate = self

        Navigation.sharedInstance.pushViewController(projectDetailVC, animated: true)
    }

    @IBAction func sortProjectsAction(_: Any) {

        projectListTableView.getProjects().flatMap {
            projectListTableView.reloadDataWith($0.sorted { $0.description?.compare($1.description!) == .orderedAscending })
        }
    }

    @IBAction func showTaskListAction(_: Any) {

        guard let taskListVC = Navigation.getViewController(taskListViewController, from: Storyboards.Tasks.rawValue) as? TaskListViewController else {
            return
        }

        Navigation.sharedInstance.pushViewController(taskListVC, animated: true)
    }

    // MARK: TaskDelegate

    func reloadTasksData() {
        getProjects()
    }

    // MARK: ProjectDelegate

    func reloadProjectsData() {
        getProjects()
    }

    // MARK: UIGestureRecognizer Delegate
    @objc func projectViewSelected(gestureRecognizer: UIGestureRecognizer) {
        guard let projectDetailVC = Navigation.getViewController(projectDetailViewController, from: Storyboards.Projects.rawValue) as? ProjectDetailViewController,
            let projects = projectListTableView.getProjects(),
            let view = gestureRecognizer.view else {
            return
        }

        projectDetailVC.taskProject = projects[view.tag]
        projectDetailVC.delegate = self

        Navigation.sharedInstance.pushViewController(projectDetailVC, animated: true)
    }
}
