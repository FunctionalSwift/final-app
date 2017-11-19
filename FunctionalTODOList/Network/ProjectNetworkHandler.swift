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

typealias projectResult = Result<Project<Task>, WSError>
typealias projectsResult = Result<[Project<Task>], WSError>
typealias projectsResponse = (_ response: Future<projectsResult>) -> Void
typealias projectResponse = (_ response: Future<projectResult>) -> Void

class ProjectNetworkHandler: NetworkHandler {

    static var sharedInstance = ProjectNetworkHandler()

    func getProjects(_ completion: @escaping projectsResponse) {

        performBasicGetWithPath(ProjectWS.list.getWS(), onSuccess: { json in

            completion(Future.async(projectsResult.Success(self.getProjects(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(projectsResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func getProject(_ id: String, _ completion: @escaping projectResponse) throws {

        guard id != "" else {
            throw WSError.DataRequired(Message: "field id is required")
        }

        performBasicGetWithPath(ProjectWS.get.getWS() + id, onSuccess: { json in

            completion(Future.async(projectResult.Success(self.getProject(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(projectResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func createProject(_ project: Project<Task>, _ completion: @escaping projectResponse) {

        performBasicPostWithPath(ProjectWS.create.getWS(), parameters: ProjectTasks.encode(project), onSuccess: { json in

            completion(Future.async(projectResult.Success(self.getProject(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(projectResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func updateProject(_ project: Project<Task>, _ completion: @escaping projectResponse) throws {

        guard let projectID = project.projectId else {
            throw WSError.DataRequired(Message: "field id is required")
        }

        performBasicPutWithPath(ProjectWS.update.getWS() + String(describing: projectID), parameters: ProjectTasks.encode(project), onSuccess: { json in

            completion(Future.async(projectResult.Success(self.getProject(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(projectResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func deleteProject(_ id: Int, _ completion: @escaping projectResponse) {

        performBasicDeleteWithPath(ProjectWS.delete.getWS() + String(id), onSuccess: { json in

            completion(Future.async(projectResult.Success(self.getProject(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(projectResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func updateProjectTask(_ project: Project<Task>, _ completion: @escaping projectResponse) throws {

        let group = DispatchGroup()

        guard let projectID = project.projectId else {
            throw WSError.DataRequired(Message: "field id is required")
        }

        if let tasks = project.elements {
            tasks.forEach { taskData in

                group.enter()

                try? TaskNetworkHandler.sharedInstance.updateTask(Task(taskId: taskData.taskId, title: taskData.title, state: taskData.state, expiration: taskData.expiration, projectId: projectID, userName: taskData.userName), { response in

                    response.runSync().ifFailure({ error in

                        debugPrint(error)
                    })

                    group.leave()
                })
            }

            group.notify(queue: .main) {
                completion(Future.pure(Result.pure(project)))
            }
        } else {
            completion(Future.pure(Result.pure(project)))
        }
    }

    func getProject(jsonObject: Any?) -> Project<Task>? {

        if let jsonArray = jsonObject as? [Any] {

            return getProject(jsonObject: jsonArray.first)

        } else if let dictionaryArray = jsonObject as? [String: AnyObject] {

            return ProjectTasks.decode(dictionaryArray)
        }

        return nil
    }

    func getProjects(jsonObject: Any?) -> [Project<Task>]? {

        guard let tasks = jsonObject as? [AnyObject] else {
            return nil
        }

        return tasks.flatMap(getProject)
    }
}
