//
//  UIImageView + Ext.swift
//  IconSearch
//
//  Created by Evgeniy Goncharov on 01.08.2024.
//

import UIKit

extension UIImageView {
    
    private struct AssociatedKeys {
        static var imageLoadTask = "imageLoadTask"
    }
    
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        if let placeholder = placeholder {
            self.image = placeholder
        }
        
        let urlString = url.absoluteString as NSString
        if let cachedImage = ImageCache.shared.object(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        currentTask?.cancel()
        
        let task = Task {
            do {
                let image = try await NetworkService().downloadImage(from: url)
                ImageCache.shared.setObject(image, forKey: urlString)
                
                DispatchQueue.main.async {
                    if !(self.currentTask?.isCancelled ?? true) {
                        self.image = image
                    }
                }
            } catch {
                switch error.localizedDescription {
                case "cancelled":
                    break
                default:
                    print(error)
                }
                
            }
        }
        
        currentTask = task
    }
    
    func cancelImageLoad() {
        currentTask?.cancel()
    }
    
    private var currentTask: Task<Void, Never>? {
        get {
            objc_getAssociatedObject(self, &AssociatedKeys.imageLoadTask) as? Task<Void, Never>
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.imageLoadTask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
