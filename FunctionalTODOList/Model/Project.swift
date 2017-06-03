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

struct Project {

    var projectId: Int?
    var description: String?
    var elements: [Task]?

    static func decode(_ json: [String: AnyObject]) -> Project {

        let idProject = JSONInt(json[ProjectKeys.id])
        let description = JSONString(json[ProjectKeys.description])
        let tasks = Task.modelsFromDictionaryArray(JSONArray(json[ProjectKeys.tasks]))

        return Project(projectId: idProject, description: description, elements: tasks)
    }

    static func encode(_ project: Project) -> [String: AnyObject] {

        var projectDictionary = Dictionary<String, AnyObject>()

        if let id = project.projectId {
            projectDictionary[ProjectKeys.id] = id as AnyObject
        }

        if let description = project.description {
            projectDictionary[ProjectKeys.description] = description as AnyObject
        }

        return projectDictionary
    }
}

public class ProjectValidator {

    public class func validateDescription(description: String) -> Bool {
        return description.count >= 30
    }
}
