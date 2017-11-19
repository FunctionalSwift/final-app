// Copyright © FunctionalSwift.com 2017. All rights reserved.

import Foundation

public enum ProjectError {
    case DescriptionTooShort

    func errorDescription() -> String {
        switch self {
        case .DescriptionTooShort:
            return NSLocalizedString("error_project_description_too_short", comment: "")
        }
    }
}

public struct Project<T> {

    var projectId: Int?
    var description: String?
    var elements: [T]?

    func map<U>(_ transform: @escaping (T) -> U) -> Project<U> {
        return Project<U>(projectId: projectId, description: description, elements: elements?.map(transform))
    }

    func flatMap<U>(_ transform: (T) -> Project<U>) -> Project<U> {

        let elements = self.elements?
            .map(transform)
            .flatMap { $0.elements }
            .joined()
            .map { $0 }

        return Project<U>(projectId: projectId, description: description, elements: elements)
    }
}

public class ProjectTasks {

    static func modelsFromDictionaryArray(_ array: [[String: AnyObject]]) -> [Project<Task>] {
        return array.map(ProjectTasks.decode)
    }

    static func decode(_ json: [String: AnyObject]) -> Project<Task> {

        let idProject = JSONInt(json[ProjectKeys.id])
        let description = JSONString(json[ProjectKeys.description])
        let tasks = JSONArray(json[ProjectKeys.tasks]).map(Task.modelsFromDictionaryArray)

        return Project<Task>(projectId: idProject, description: description, elements: tasks)
    }

    static func encode(_ project: Project<Task>) -> [String: AnyObject] {

        var projectDictionary = [String: AnyObject]()

        if let id = project.projectId {
            projectDictionary[ProjectKeys.id] = id as AnyObject
        }

        if let description = project.description {
            projectDictionary[ProjectKeys.description] = description as AnyObject
        }

        return projectDictionary
    }

    static func getDate(task: Task) -> Date {
        return task.expiration!
    }

    static func getState(task: Task) -> Bool {
        return task.state!
    }

    static func getUserName(task: Task) -> Project<String> {

        return task.userName.map {
            Project<String>.init(projectId: nil, description: nil, elements: [$0])
        } ?? Project<String>.init()
    }
}

public class ProjectValidator {

    public class var Description: Validator<String, ProjectError> {
        return validate(.DescriptionTooShort) {
            $0.count >= 30
        }
    }
}
