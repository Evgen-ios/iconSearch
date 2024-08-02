import Foundation

// MARK: - IconsModel
struct IconsModel: Codable {
    let totalCount: Int
    var icons: [IconModel]
    
    init() {
        self.totalCount = .zero
        self.icons = .init()
    }
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case icons
    }
}

// MARK: - IconModel
struct IconModel: Codable {
    let iconID: Int
    let tags: [String]
    let publishedAt: String
    let isPremium: Bool
    let type: TypeEnum
    let containers: [Container]
    let rasterSizes: [RasterSize]
    let vectorSizes: [VectorSize]?
    let styles, categories: [Category]
    let isIconGlyph: Bool
    let prices: [Price]?
    let isPurchased: Bool?
    var isImageSaved: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case iconID = "icon_id"
        case tags
        case publishedAt = "published_at"
        case isPremium = "is_premium"
        case type, containers
        case rasterSizes = "raster_sizes"
        case vectorSizes = "vector_sizes"
        case styles, categories
        case isIconGlyph = "is_icon_glyph"
        case prices
        case isPurchased = "is_purchased"
    }
}

// MARK: - Category
struct Category: Codable {
    let identifier, name: String
}

// MARK: - Container
struct Container: Codable {
    let format: ContainerFormat
    let downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case format
        case downloadURL = "download_url"
    }
}

enum ContainerFormat: String, Codable {
    case ai = "ai"
    case icns = "icns"
    case ico = "ico"
    case svg = "svg"
}

// MARK: - Price
struct Price: Codable {
    let license: License
    let currency: String
    let price: Int
}

// MARK: - License
struct License: Codable {
    let licenseID: Int
    let name: String
    let url: String
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case licenseID = "license_id"
        case name, url, scope
    }
}

// MARK: - RasterSize
struct RasterSize: Codable {
    let formats: [FormatElement]
    let size, sizeWidth, sizeHeight: Int
    
    enum CodingKeys: String, CodingKey {
        case formats, size
        case sizeWidth = "size_width"
        case sizeHeight = "size_height"
    }
}

// MARK: - FormatElement
struct FormatElement: Codable {
    let format: PurpleFormat
    let previewURL: String
    let downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case format
        case previewURL = "preview_url"
        case downloadURL = "download_url"
    }
}

enum PurpleFormat: String, Codable {
    case png = "png"
}

// MARK: - TypeEnum
enum TypeEnum: String, Codable {
    case vector = "vector"
    case raster = "raster"
}

// MARK: - VectorSize
struct VectorSize: Codable {
    let formats: [Container]
    let targetSizes: [[Int]]
    let size, sizeWidth, sizeHeight: Int
    
    enum CodingKeys: String, CodingKey {
        case formats
        case targetSizes = "target_sizes"
        case size
        case sizeWidth = "size_width"
        case sizeHeight = "size_height"
    }
}
