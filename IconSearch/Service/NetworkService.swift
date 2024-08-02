//
//  NetworkService.swift
//  IconSearch
//
//  Created by Evgeniy Goncharov on 01.08.2024.
//

import UIKit

class NetworkService {
    
    private let baseURL = "https://api.iconfinder.com/v4/icons/search"
    private let apiKey = "bc7KAyFU5rfj3FpGeAFxVTkNvv0dDk6N7UhbK5LNopADRL3BNHeUybADuM1H6jZY"
    private let count = "1000"
    private let premium = "false"
    private let vector = "false"
    private let formar = "png"
    
    private let iconsCache = NSCache<NSString, IconsModel>()
    private let imageCache = NSCache<NSString, UIImage>()
    
    func searchIcons(query: String) async throws -> IconsModel {
        let cacheKey = query as NSString
        if let cachedIcons = iconsCache.object(forKey: cacheKey) {
            return cachedIcons
        }
        
        var components = URLComponents(string: baseURL)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "count", value: count),
            URLQueryItem(name: "premium", value: premium),
            URLQueryItem(name: "vector", value: vector),
            URLQueryItem(name: "formar", value: formar)
        ]
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 1000
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let iconsModel = try JSONDecoder().decode(IconsModel.self, from: data)
        iconsCache.setObject(iconsModel, forKey: cacheKey)
        
        return iconsModel
    }
    
    func searchIconsSync(query: String, completion: @escaping (Result<IconsModel, Error>) -> Void) {
        Task {
            do {
                let data = try await searchIcons(query: query)
                DispatchQueue.main.async {
                    completion(.success(data))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(from url: URL) async throws -> UIImage {
        let cacheKey = url.absoluteString as NSString
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotParseResponse)
        }
        
        imageCache.setObject(image, forKey: cacheKey)
        
        return image
    }
}

