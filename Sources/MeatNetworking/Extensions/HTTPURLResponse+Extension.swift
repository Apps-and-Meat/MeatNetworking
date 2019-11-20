//
//  HTTPURLResponse+Extension.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    func getWarning(searchKey: String = "Warning") -> String? {
        for (key, value) in allHeaderFields {
            if let key = key as? String {
                if key == searchKey {
                    if let value = value as? String {
                        return value
                    }
                }
            }
        }
        return nil
    }
}
