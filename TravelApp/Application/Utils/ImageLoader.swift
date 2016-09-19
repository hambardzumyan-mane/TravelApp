//
//  ImageLoader.swift
//  TravelApp
//
//  Created by Mane Hambardzumyan on 9/18/16.
//  Copyright © 2016 Mane. All rights reserved.
//

import UIKit

class ImageLoader: NSObject {
    
    private static let MAX_CURRENT_TASKS_COUNT = 10

    private let LOCK_QUEUE = dispatch_queue_create("com.Mane.TravelApp.ImageLoader", nil)

    private var pendingTasks: [ImageLoadTask] = []
    private var currentTasksCount = 0
    
    static let sharedInstance = ImageLoader()
    
    private override init() {}
    
    func load(name: String, completion: (data: NSData?) -> Void) -> Void {
        let task = ImageLoadTask(name: name, imageDataHandler: completion,
                                 taskCompletionHandler: taskDidComplete)
        if (self.currentTasksCount >= ImageLoader.MAX_CURRENT_TASKS_COUNT) {
            dispatch_sync(LOCK_QUEUE) {
                self.pendingTasks.append(task)
            }
        } else {
            task.run()
            // TODO: - understand how long the task will be retained?
            dispatch_sync(LOCK_QUEUE) {
                self.currentTasksCount += 1
            }
        }
    }
    
    // MARK: - Private Method
    
    private func taskDidComplete() -> Void {
        dispatch_sync(LOCK_QUEUE) {
            if (self.currentTasksCount > 0) {
                self.currentTasksCount -= 1
                if (!self.pendingTasks.isEmpty) {
                    let task = self.pendingTasks.removeFirst()
                    task.run()
                }
            }
        }
    }
}
