import Foundation

struct RoutePlan: Codable{
    let visits: [Visit]!
}

struct Visit: Codable{
    let startTime: Date!
    let firstName: String!
    let lastName: String!
    let avatar: String?
    let address: String?
    let coordinates: [Double]!
}