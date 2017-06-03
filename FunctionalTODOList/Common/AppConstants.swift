// Copyright © FunctionalSwift.com 2017. All rights reserved.

import UIKit

struct TaskKeys {
    static let id = "id"
    static let title = "title"
    static let state = "taskState"
    static let expiration = "expiration"
    static let projectId = "projectId"
    static let userName = "user"
}

struct TaskState {
    static let completed = "Completed"
    static let doing = "Doing"
}

struct ProjectKeys {
    static let id = "id"
    static let description = "description"
    static let tasks = "tasks"
}
