//
//  Dictionary+Extension.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public extension Dictionary {
    func union(_ dictionaries: Dictionary...) -> Dictionary {
        var result = self
        dictionaries.forEach { dictionary in
            dictionary.forEach { key, value in
                _ = result.updateValue(value, forKey: key)
            }
        }
        return result
    }
}
