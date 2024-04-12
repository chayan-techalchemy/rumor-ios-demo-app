//
//  AppConstants.swift
//  RumorDemo
//
//  Created by Tech Alchemy
//

import Foundation
import UIKit

struct AppConstants {
    static let dummyPostImages = [
        "https://images.dog.ceo//breeds//akita//Akita_inu_blanc.jpg",
        "https://images.dog.ceo/breeds/leonberg/n02111129_279.jpg",
        "https://images.dog.ceo/breeds/terrier-welsh/lucy.jpg",
        "https://images.dog.ceo/breeds/rottweiler/n02106550_6978.jpg",
        "https://images.dog.ceo/breeds/airedale/n02096051_4868.jpg",
        "https://images.dog.ceo/breeds/labradoodle/lola.jpg",
        "https://images.dog.ceo/breeds/spitz-japanese/tofu.jpg"
    ]

    static let baseURL = "https://dummyapi.io/data"
    static let dummyAPIAppID = "66156dd3240888512f9908a8"

    static let serverDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let postDateFormat = "MMM d, yyyy"

    static let dummyUserID = "60d0fe4f5311236168a109e7"

    static let buttonTintColor = UIColor(named: "button-tint")
}
