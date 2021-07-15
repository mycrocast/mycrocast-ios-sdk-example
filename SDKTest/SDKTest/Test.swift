//
// Created by Sven on 14.06.21.
//

import Foundation

class AdvertisementPlayedResponse {
    var canBePlayedAgain: Bool

    private enum CodingKeys: String, CodingKey {
        case canBePlayedAgain
    
    }

    init(from decoder: Decoder) throws {
    
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.canBePlayedAgain = try container.decodeIfPresent(Bool.self, forKey: .canBePlayedAgain) ?? true

    }
}

class Test2: AdvertisementPlayedResponse {
    
    var test: Bool
    
    init(_ blub: Bool) {
        
    }
    
}

