// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

typealias TaskTypesCount = (completed: Int, doing: Int)

struct Task: Equatable {

    let taskId: Int?
    let title: String?
    let state: Bool?
    let expiration: Date?
    let projectId: Int?
    let userName: String?

    static func modelsFromDictionaryArray(_ array: [[String: AnyObject]]?) -> [Task] {

        guard let array = array else {
            return []
        }

        var models: [Task] = []
        for item in array {
            models.append(Task.decode(item))
        }
        return models
    }

    static func decode(_ json: [String: AnyObject]) -> Task {

        let idTask = JSONInt(json[TaskKeys.id])
        let title = JSONString(json[TaskKeys.title])
        let state = JSONBool(json[TaskKeys.state])
        var expiration: Date?
        if let date = JSONString(json[TaskKeys.expiration]) {
            expiration = date.dateFromString()
        }

        let idProject = JSONInt(json[TaskKeys.projectId])
        let userName = JSONString(json[TaskKeys.userName])

        return Task(taskId: idTask, title: title, state: state, expiration: expiration, projectId: idProject, userName: userName)
    }

    static func encode(_ task: Task) -> [String: AnyObject] {

        var taskDictionary = [String: AnyObject]()

        if let id = task.taskId {
            taskDictionary[TaskKeys.id] = id as AnyObject
        }

        if let title = task.title {
            taskDictionary[TaskKeys.title] = title as AnyObject
        }

        if let state = task.state {
            taskDictionary[TaskKeys.state] = state as AnyObject
        }

        if let expiration = task.expiration,
            let expirationDate = expiration.stringFromDate() {
            taskDictionary[TaskKeys.expiration] = expirationDate as AnyObject
        }

        if let project = task.projectId {
            taskDictionary[TaskKeys.projectId] = project as AnyObject
        }

        if let user = task.userName {
            taskDictionary[TaskKeys.userName] = user as AnyObject
        }

        return taskDictionary
    }

    func stateAsString() -> String {

        guard let state = self.state else {
            return TaskState.doing
        }

        return state ? TaskState.completed : TaskState.doing
    }

    static func stateAsBool(state: String) -> Bool {
        return state == TaskState.completed
    }

    static func countTaskTypes(tasks: [Task]?) -> TaskTypesCount {

        guard let tasks = tasks else {
            return TaskTypesCount(completed: 0, doing: 0)
        }

        var completed = 0, doing = 0

        tasks.forEach { task in
            if task.stateAsString() == TaskState.completed {
                completed += 1
            } else {
                doing += 1
            }
        }

        return TaskTypesCount(completed: completed, doing: doing)
    }

    static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.taskId == rhs.taskId
    }
}

public class TaskValidator {

    public static func validateTitle(title: String?) -> Bool {

        guard let title = title else {
            return false
        }

        return title.count >= 40
    }

    public static func validateState(state: Bool?) -> Bool {

        return state != nil
    }

    public static func validateDate(date: Date?) -> Bool {

        guard let date = date else {
            return false
        }

        return date > Date()
    }
}
