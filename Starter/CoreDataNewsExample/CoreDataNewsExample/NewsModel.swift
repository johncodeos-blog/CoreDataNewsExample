import Foundation

typealias NewsModel = [NewsModelItem]

struct NewsModelItem: Decodable {
    let id: Int?
    let title: String?
    let url: String?
    let imageURL: String?
    let date: String?
    let source: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case imageURL = "image_url"
        case date
        case source
    }
}
