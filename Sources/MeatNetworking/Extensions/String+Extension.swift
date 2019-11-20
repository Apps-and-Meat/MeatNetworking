//
//  String+Extension.swift
//  MeetNetworking
//
//  Created by Karl Söderberg on 2019-05-12.
//  Copyright © 2019 AppMeat AB. All rights reserved.
//

import Foundation

public extension String {
    init(anyValue value: Any) {
        self.init()
        guard let strValue = value as? CustomStringConvertible else { return }
        self = strValue.description
    }

    func lowerCaseFirstLetter() -> String {
        let stringWithoutFirstLetter = dropFirst()
        let firstLetterLowerCased = prefix(1).lowercased()
        return firstLetterLowerCased + stringWithoutFirstLetter
    }

    func upperCaseFirstLetter() -> String {
        let stringWithoutFirstLetter = dropFirst()
        let firstLetterUpperCased = prefix(1).uppercased()
        return firstLetterUpperCased + stringWithoutFirstLetter
    }
}
