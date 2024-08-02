//
//  Cache.swift
//  IconSearch
//
//  Created by Evgeniy Goncharov on 01.08.2024.
//

import UIKit

class Cache {
    static let imageCache = NSCache<NSString, UIImage>()
    static let iconsCache = NSCache<NSString, IconsModel>()
}
