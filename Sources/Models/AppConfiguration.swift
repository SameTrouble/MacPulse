import Foundation

struct Placeholder: Codable, Equatable, Identifiable {
    let id: UUID
    var items: [CarouselItem]
}

struct AppConfiguration: Codable, Equatable {
    var placeholders: [Placeholder]
}
