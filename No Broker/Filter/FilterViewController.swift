//
//  FilterViewController.swift
//  No Broker
//
//  Created by Subhadeep Pal on 18/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

protocol FilterProtocol {
    func filterApplied(propertyTypeFilters: [Property.PropertyType], buildingTypeFilters: [Property.BuildingType], furnishingTypeFilters: [Property.FurnishingType])
}

class FilterViewController: UIViewController {
    
    var buildingTypeFilters: [Property.BuildingType] = []
    var typeFilters: [Property.PropertyType] = []
    var furnishingTypeFilters: [Property.FurnishingType] = []
    
    var delegate: FilterProtocol?
    
    private let furnishingTypes = [Property.FurnishingType.semiFurnished,Property.FurnishingType.fullyFurnished]
    private let buildingTypes = [Property.BuildingType.AP, Property.BuildingType.IH, Property.BuildingType.IF]
    private let propertyTypes = [Property.PropertyType.BHK2, Property.PropertyType.BHK3, Property.PropertyType.BHK4]
    
    
    @IBOutlet var typeFilterButtons: [UIButtonX]!
    @IBOutlet var buildingTypeFilterButtons: [UIButtonX]!
    @IBOutlet var furnisingTypeFilterButtons: [UIButtonX]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        for item in buildingTypeFilters {
            guard let index = buildingTypes.index(of: item) else {continue}
            buildingTypeFilterButtons[index].isSelected = true
        }
        
        for item in typeFilters {
            guard let index = propertyTypes.index(of: item) else {continue}
            typeFilterButtons[index].isSelected = true
        }
        
        for item in furnishingTypeFilters {
            guard let index = furnishingTypes.index(of: item) else {continue}
            furnisingTypeFilterButtons[index].isSelected = true
        }
    }
    
    @IBAction func apartmentTypeButtonTapped(_ sender: UIButtonX) {
        sender.isSelected = !sender.isSelected
        guard let index = typeFilterButtons.index(of: sender) else {return}
        if let filterIndex = typeFilters.index(of: propertyTypes[index]) {
            typeFilters.remove(at: filterIndex)
        } else {
            typeFilters.append(propertyTypes[index])
        }
    }
    
    @IBAction func buildingTypeButtonTapped(_ sender: UIButtonX) {
        sender.isSelected = !sender.isSelected
        guard let index = buildingTypeFilterButtons.index(of: sender) else {return}
        if let filterIndex = buildingTypeFilters.index(of: buildingTypes[index]) {
            buildingTypeFilters.remove(at: filterIndex)
        } else {
            buildingTypeFilters.append(buildingTypes[index])
        }
    }
    
    @IBAction func furnishingTypeButtonTapped(_ sender: UIButtonX) {
        sender.isSelected = !sender.isSelected
        guard let index = furnisingTypeFilterButtons.index(of: sender) else {return}
        if let filterIndex = furnishingTypeFilters.index(of: furnishingTypes[index]) {
            furnishingTypeFilters.remove(at: filterIndex)
        } else {
            furnishingTypeFilters.append(furnishingTypes[index])
        }
    }
    

    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyTapped(_ sender: UIButton) {
        self.delegate?.filterApplied(propertyTypeFilters: typeFilters, buildingTypeFilters: buildingTypeFilters, furnishingTypeFilters: furnishingTypeFilters)
    }
    
    @IBAction func refreshFiltersTapped(_ sender: UIBarButtonItem) {
        buildingTypeFilters = []
        for item in buildingTypeFilterButtons {
            item.isSelected = false
        }
        
        typeFilters = []
        for item in typeFilterButtons{
            item.isSelected = false
        }
        
        furnishingTypeFilters = []
        for item in furnisingTypeFilterButtons{
            item.isSelected = false
        }
    }
}
