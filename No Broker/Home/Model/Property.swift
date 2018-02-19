//
//  Property.swift
//  No Broker
//
//  Created by Subhadeep Pal on 18/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

struct PropertiesServiceResponse: Decodable {
    let status: Int
    let otherParams : OtherParams
    let data: [Property]
}

struct OtherParams: Decodable {
    let city: String
    let topPropertyId: String?
    let total_count: Int
    let count: Int
    let region_id: String
    let searchToken: String?
}

struct Property: Decodable {
    
    enum PropertyType: String {
        case BHK2 = "BHK2"
        case BHK3 = "BHK3"
        case BHK4 = "BHK4"
        case none = "NONE"
    }
    
    enum BuildingType: String {
        case AP = "AP"
        case IH = "IH"
        case IF = "IF"
        case none = "NONE"
    }
    
    enum FurnishingType: String {
        case fullyFurnished = "FULLY_FURNISHED"
        case semiFurnished = "SEMI_FURNISHED"
        case none = "NONE"
        
        static let values = [
            fullyFurnished: "Fully Furnished",
            semiFurnished: "Semi Furnished",
            none: "Not Furnished"
        ]
        
        func displayValue() -> String {
            guard let value = FurnishingType.values[self] else {
                return FurnishingType.values[.none]!
            }
            return value
        }
    }
    
    
    let propertyTitle: String
    let rent: Int
    let secondaryTitle: String
    let propertySize: Int
    let photos : [Photo]
    let type: String
    let buildingType: String
    let furnishing: String
    let bathroom: Int
    let furnishingDesc: String
    
    func displayImageUrlString() -> String? {
        guard let displayPic = photos.filter({ (photo) -> Bool in
            photo.displayPic
        }).first else {return nil}
        
        let mediumKey = displayPic.imagesMap.medium
        let key = mediumKey.split(separator: "_").first!
        return "http://d3snwcirvb4r88.cloudfront.net/images/\(key)/\(mediumKey)"
    }
    
    var propertyType : PropertyType {
        guard let propertyType = PropertyType.init(rawValue: type) else {
            return .none
        }
        return propertyType
    }
    
    var propertyBuildingType : BuildingType {
        guard let type = BuildingType.init(rawValue: buildingType) else {
            return .none
        }
        return type
    }
    
    var furnishingType: FurnishingType {
        guard let type = FurnishingType.init(rawValue: furnishing) else {
            return .none
        }
        return type
    }
}

struct Photo: Decodable {
    let title: String
    let name: String
    let displayPic : Bool
    let imagesMap: ImagesMap
}

struct ImagesMap: Decodable {
    let thumbnail: String
    let original: String
    let large: String
    let medium: String
}
