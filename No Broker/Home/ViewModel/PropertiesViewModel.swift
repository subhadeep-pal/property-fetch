//
//  PropertiesViewModel.swift
//  No Broker
//
//  Created by Subhadeep Pal on 18/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class PropertiesViewModel: NSObject {

    @IBOutlet weak var webService: PropertiesWebService!
    
    private var properties: [Property] = []
    
    var buildingTypeFilters: [Property.BuildingType] = []
    var typeFilters: [Property.PropertyType] = []
    var furnishingTypeFilters: [Property.FurnishingType] = []
    
    
    var totalProperties : Int = 0
    
    func filteredProperties() -> [Property] {
        return properties.filter { (property) -> Bool in
            var returnValue = true
            
            if buildingTypeFilters.count > 0 {
                returnValue = returnValue && buildingTypeFilters.contains(property.propertyBuildingType)
            }
            if typeFilters.count > 0 {
                returnValue = returnValue && typeFilters.contains(property.propertyType)
            }
            if furnishingTypeFilters.count > 0 {
                returnValue = returnValue && furnishingTypeFilters.contains(property.furnishingType)
            }
            return returnValue
        }
    }
    
    func numberOfProperties() -> Int {
        return filteredProperties().count
    }
    
    func propertyTitle(index: Int) -> String {
        return filteredProperties()[index].propertyTitle
    }
    
    func secondaryTitle(index: Int) -> String {
        return filteredProperties()[index].secondaryTitle
    }
    
    func furnishing(index: Int) -> String {
        return "\(filteredProperties()[index].furnishingDesc) Furnished"
    }
    
    func bathroom(index: Int) -> String {
        return "\(filteredProperties()[index].bathroom) Bathrooms"
    }
    
    func type(index: Int) -> Property.PropertyType {
        return filteredProperties()[index].propertyType
    }

    func furnishingType(index: Int) -> Property.FurnishingType {
        return filteredProperties()[index].furnishingType
    }

    func buildingType(index: Int) -> Property.BuildingType {
        return filteredProperties()[index].propertyBuildingType
    }
    
    func rent(index: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let number = NSNumber(integerLiteral:  filteredProperties()[index].rent)
        guard let formattedString = numberFormatter.string(from: number) else {
            return "₹ \(filteredProperties()[index].rent)"
        }
        return "₹ \(formattedString)"
    }
    
    func propertySize(index: Int) -> String {
        return "\(filteredProperties()[index].propertySize) Sq. ft"
    }
    
    func imagUrl(index: Int) -> String? {
        guard let imageString = filteredProperties()[index].displayImageUrlString() else {
            return nil
        }
        return imageString
    }
    
    func callService(onSuccess: @escaping ()->()) {
        webService.fetch(onSuccess: { (properties, total) in
            self.properties = properties
            self.totalProperties = total
            onSuccess()
        }) {
            print("failed")
        }
    }
    
    func fetchNextPage(onSuccess: @escaping ()->()) {
        guard totalProperties > self.properties.count else {
            return
        }
        webService.fetch(nextPage: true, onSuccess: { (properties, total) in
            self.properties.append(contentsOf: properties)
            self.totalProperties = total
            onSuccess()
        }) {
            print("failed")
        }
    }
}
