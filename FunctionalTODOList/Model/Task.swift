// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

typealias TaskTypesCount = (completed: Int, doing: Int)
typealias TaskResult = Result<Bool, TaskError>

public enum TaskError {
    case TitleTooShort
    case UnknownState
    case InvalidDate

    func errorDescription() -> String {
        switch self {
        case .TitleTooShort:
            return NSLocalizedString("error_task_title_too_short", comment: "")
        case .UnknownState:
            return NSLocalizedString("error_task_unknown_state", comment: "")
        case .InvalidDate:
            return NSLocalizedString("error_task_invalid_date", comment: "")
        }
    }
}

public struct Task: Equatable {

    let taskId: Int?
    let title: String?
    let state: Bool?
    let expiration: Date?
    let projectId: Int?
    let userName: String?

    static func modelsFromDictionaryArray(_ array: [[String: AnyObject]]) -> [Task] {
        return array.map(Task.decode)
    }

    static func decode(_ json: [String: AnyObject]) -> Task {

        let idTask = JSONInt(json[TaskKeys.id])
        let title = JSONString(json[TaskKeys.title])
        let state = JSONBool(json[TaskKeys.state])
        let expiration = json[TaskKeys.expiration].flatMap(JSONString |> dateFromString)
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

        if let expiration = task.expiration {
            taskDictionary[TaskKeys.expiration] = expiration.stringFromDate() as AnyObject
        }

        if let projectId = task.projectId {
            taskDictionary[TaskKeys.projectId] = projectId as AnyObject
        }

        if let user = task.userName {
            taskDictionary[TaskKeys.userName] = user as AnyObject
        }

        return taskDictionary
    }

    static func state(with string: String) -> TaskResult {

        if string == TaskState.completed || string == TaskState.doing {
            return TaskResult.Success(string == TaskState.completed ? true : false)
        }

        return TaskResult.Failure(.UnknownState)
    }

    static func stateAsString(state: Bool) -> String {
        return state ? TaskState.completed : TaskState.doing
    }

    static func dateFromString(data: Any) -> Date? {

        return (data as? String).flatMap { $0.dateFromString() }
    }

    static func countTaskTypes(tasks: [Task]?) -> TaskTypesCount {

        return tasks.flatMap { task in
            task.reduce(TaskTypesCount(completed: 0, doing: 0)) { accumulator, task in

                task.state.flatMap { state in
                    state ? TaskTypesCount(accumulator.completed + 1, accumulator.doing) :
                        TaskTypesCount(accumulator.completed, accumulator.doing + 1)

                } ?? accumulator
            }
        } ?? TaskTypesCount(completed: 0, doing: 0)
    }

    public static func == (lhs: Task, rhs: Task) -> Bool {
        return lhs.taskId == rhs.taskId
    }

    func stateAsString() -> String {
        return state.map { $0 ? TaskState.completed : TaskState.doing } ?? TaskState.doing
    }
}

public class TaskValidator {

    public class var Title: Validator<String, TaskError> {
        return validate(.TitleTooShort) { $0.count >= 40 }
    }

    public class var State: Validator<Optional<Bool>, TaskError> {
        return validate(.UnknownState) { $0 != nil }
    }

    public class var Expiration: Validator<Date, TaskError> {
        return validate(.InvalidDate) { $0 > Date() }
    }
}
