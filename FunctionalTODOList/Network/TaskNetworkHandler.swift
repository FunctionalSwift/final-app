// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

enum TaskWS: Int {
    case list = 0
    case get
    case update
    case delete
    case create

    func getWS() -> String {
        switch self {
        case .list: return "tasks/"
        case .get, .update, .delete: return "tasks/"
        case .create: return "tasks"
        }
    }
}

typealias taskResult = Result<Task, WSError>
typealias tasksResult = Result<[Task], WSError>
typealias tasksResponse = (_ response: Future<tasksResult>) -> Void
typealias taskResponse = (_ response: Future<taskResult>) -> Void

class TaskNetworkHandler: NetworkHandler {

    static var sharedInstance = TaskNetworkHandler()

    func getTasks(_ completion: @escaping tasksResponse) {

        performBasicGetWithPath(TaskWS.list.getWS(), onSuccess: { json in

            completion(Future.async(tasksResult.Success(self.getTasks(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(tasksResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func getTask(_ id: String, _ completion: @escaping taskResponse) throws {

        guard id != "" else {
            throw WSError.DataRequired(Message: "field id is required")
        }

        performBasicGetWithPath(TaskWS.get.getWS() + id, onSuccess: { json in

            completion(Future.async(taskResult.Success(self.getTask(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(taskResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func createTask(_ task: Task, _ completion: @escaping taskResponse) {

        performBasicPostWithPath(TaskWS.create.getWS(), parameters: Task.encode(task), onSuccess: { json in

            completion(Future.async(taskResult.Success(self.getTask(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(taskResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func updateTask(_ task: Task, _ completion: @escaping taskResponse) throws {

        guard let taskID = task.taskId else {
            throw WSError.DataRequired(Message: "field id is required")
        }

        performBasicPutWithPath(TaskWS.update.getWS() + String(describing: taskID), parameters: Task.encode(task), onSuccess: { json in

            completion(Future.async(taskResult.Success(self.getTask(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(taskResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func deleteTask(_ id: Int, _ completion: @escaping taskResponse) {

        performBasicDeleteWithPath(TaskWS.delete.getWS() + String(id), onSuccess: { json in

            completion(Future.async(taskResult.Success(self.getTask(jsonObject: json)!)))

        }) { error in

            completion(Future.pure(taskResult.Failure(.GenericError(Message: error.localizedDescription))))
        }
    }

    func getTask(jsonObject: Any?) -> Task? {

        if let jsonArray = jsonObject as? [Any] {

            return getTask(jsonObject: jsonArray.first)
        }

        return (jsonObject as? [String: AnyObject]).flatMap(Task.decode)
    }

    func getTasks(jsonObject: Any?) -> [Task]? {

        guard let tasks = jsonObject as? [Any] else {
            return nil
        }

        return tasks.flatMap(getTask)
    }
}
