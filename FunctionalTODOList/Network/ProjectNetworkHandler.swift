// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

enum ProjectWS: Int {
    case list = 0
    case get
    case update
    case delete
    case create

    func getWS() -> String {
        switch self {
        case .list: return "projects?_embed=tasks"
        case .get, .update, .delete: return "projects/"
        case .create: return "projects"
        }
    }
}

class ProjectNetworkHandler: NetworkHandler {

    static var sharedInstance = ProjectNetworkHandler()

    typealias projectsResponse = (_ response: [Project]?) -> Void
    typealias projectResponse = (_ response: Project?) -> Void
    typealias errorResponse = (_ error: Error) -> Void

    func getProjects(_ onSuccess: @escaping projectsResponse, onError: @escaping errorResponse) {

        performBasicGetWithPath(ProjectWS.list.getWS(), onSuccess: { json in
            onSuccess(self.getProjects(jsonObject: json))
        }) { error in
            onError(error)
        }
    }

    func getProject(_ id: String, _ onSuccess: @escaping projectResponse, onError: @escaping errorResponse) throws {

        guard id != "" else {
            throw WSError.dataRequired(Message: "field id is required")
        }

        performBasicGetWithPath(ProjectWS.get.getWS() + id, onSuccess: { json in

            onSuccess(self.getProject(jsonObject: json))

        }) { error in
            onError(error)
        }
    }

    func createProject(_ project: Project, _ onSuccess: @escaping projectResponse, onError: @escaping errorResponse) {

        performBasicPostWithPath(ProjectWS.create.getWS(), parameters: Project.encode(project), onSuccess: { json in

            onSuccess(self.getProject(jsonObject: json))

        }) { error in
            onError(error)
        }
    }

    func updateProject(_ project: Project, _ onSuccess: @escaping projectResponse, onError: @escaping errorResponse) throws {

        guard let projectID = project.projectId else {
            throw WSError.dataRequired(Message: "field id is required")
        }

        performBasicPutWithPath(ProjectWS.update.getWS() + String(describing: projectID), parameters: Project.encode(project), onSuccess: { json in

            onSuccess(self.getProject(jsonObject: json))

        }) { error in
            onError(error)
        }
    }

    func deleteProject(_ id: Int, _ onSuccess: @escaping projectResponse, onError: @escaping errorResponse) {

        performBasicDeleteWithPath(ProjectWS.delete.getWS() + String(id), onSuccess: { json in

            onSuccess(self.getProject(jsonObject: json))

        }) { error in
            onError(error)
        }
    }

    func updateProjectTask(_ project: Project, _ onSuccess: @escaping projectResponse, onError: @escaping errorResponse) throws {

        let group = DispatchGroup()

        guard let projectID = project.projectId else {
            throw WSError.dataRequired(Message: "field id is required")
        }

        if let tasks = project.elements {
            tasks.forEach { taskData in

                group.enter()

                try? TaskNetworkHandler.sharedInstance.updateTask(Task(taskId: taskData.taskId, title: taskData.title, state: taskData.state, expiration: taskData.expiration, projectId: projectID, userName: taskData.userName), { _ in

                    group.leave()
                }, onError: { error in

                    debugPrint(error)
                    group.suspend()
                    onError(error)
                })
            }

            group.notify(queue: .main) {
                onSuccess(project)
            }
        }
    }

    func getProject(jsonObject: Any?) -> Project? {

        if let jsonArray = jsonObject as? [Any] {

            return getProject(jsonObject: jsonArray.first)

        } else if let dictionaryArray = jsonObject as? [String: AnyObject] {

            return Project.decode(dictionaryArray)
        }

        return nil
    }

    func getProjects(jsonObject: Any?) -> [Project]? {

        guard let projects = jsonObject as? [AnyObject] else {
            return nil
        }

        var projectArray = [Project]()

        projects.forEach { project in
            if let projectData = self.getProject(jsonObject: project) {
                projectArray.append(projectData)
            }
        }

        return projectArray
    }
}
