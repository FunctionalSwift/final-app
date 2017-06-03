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

class TaskNetworkHandler: NetworkHandler {

    static var sharedInstance = TaskNetworkHandler()

    typealias tasksResponse = (_ response: [Task]?) -> Void
    typealias taskResponse = (_ response: Task?) -> Void
    typealias errorResponse = (_ error: Error) -> Void

    func getTasks(_ onSuccess: @escaping tasksResponse, onError: @escaping errorResponse) {

        performBasicGetWithPath(TaskWS.list.getWS(), onSuccess: { jsonArray in

            onSuccess(self.getTasks(jsonObject: jsonArray))

        }) { error in
            onError(error)
        }
    }

    func getTask(_ id: String, _ onSuccess: @escaping taskResponse, onError: @escaping errorResponse) throws {

        guard id != "" else {
            throw WSError.dataRequired(Message: "field id is required")
        }

        performBasicGetWithPath(TaskWS.get.getWS() + id, onSuccess: { jsonDictionary in

            onSuccess(self.getTask(jsonObject: jsonDictionary))

        }) { error in
            onError(error)
        }
    }

    func createTask(_ task: Task, _ onSuccess: @escaping taskResponse, onError: @escaping errorResponse) {

        performBasicPostWithPath(TaskWS.create.getWS(), parameters: Task.encode(task), onSuccess: { jsonArray in

            onSuccess(self.getTask(jsonObject: jsonArray!))

        }) { error in
            onError(error)
        }
    }

    func updateTask(_ task: Task, _ onSuccess: @escaping taskResponse, onError: @escaping errorResponse) throws {

        guard let taskID = task.taskId else {
            throw WSError.dataRequired(Message: "field id is required")
        }

        performBasicPutWithPath(TaskWS.update.getWS() + String(describing: taskID), parameters: Task.encode(task), onSuccess: { jsonArray in

            onSuccess(self.getTask(jsonObject: jsonArray!))

        }) { error in
            onError(error)
        }
    }

    func deleteTask(_ id: Int, _ onSuccess: @escaping taskResponse, onError: @escaping errorResponse) {

        performBasicDeleteWithPath(TaskWS.delete.getWS() + String(id), onSuccess: { jsonArray in

            onSuccess(self.getTask(jsonObject: jsonArray!))

        }) { error in
            onError(error)
        }
    }

    func getTask(jsonObject: Any?) -> Task? {

        if let jsonArray = jsonObject as? [Any] {

            return getTask(jsonObject: jsonArray.first)

        } else if let dictionaryArray = jsonObject as? [String: AnyObject] {

            return Task.decode(dictionaryArray)
        }

        return nil
    }

    func getTasks(jsonObject: Any?) -> [Task]? {

        guard let tasks = jsonObject as? [AnyObject] else {
            return nil
        }

        var taskArray = [Task]()

        tasks.forEach { task in
            if let taskData = self.getTask(jsonObject: task) {
                taskArray.append(taskData)
            }
        }

        return taskArray
    }
}
