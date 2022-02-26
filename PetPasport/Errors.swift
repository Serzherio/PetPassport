//
//  Errors.swift
//  PetPasport
//
//  Created by Сергей on 26.02.2022.
//  Copyright © 2022 Сергей. All rights reserved.
//

import Foundation

enum CalendarError {
    case eventsDontExist
    case eventsCannotBeDeleted
    case eventsCannotBeCreated
}

extension CalendarError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .eventsDontExist:
            return NSLocalizedString("Ошибка События не найдены", comment: "События не найдены")
        case .eventsCannotBeDeleted:
            return NSLocalizedString("Ошибка События не были удалены", comment: "События не были удалены")
        case .eventsCannotBeCreated:
            return NSLocalizedString("Ошибка События не могут быть созданы", comment: "События не могут быть созданы")
        }
    }
}
