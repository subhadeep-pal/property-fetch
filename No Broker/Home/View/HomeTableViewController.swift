//
//  HomeTableViewController.swift
//  No Broker
//
//  Created by Subhadeep Pal on 17/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    @IBOutlet var viewModel: PropertiesViewModel!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    private var isLoading : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let oldCount = viewModel.numberOfProperties()
        viewModel.callService {
            newCount in
            self.updateTableView(previousCount: oldCount, updatedCount: newCount)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return viewModel.numberOfProperties()
        } else {
            return 1
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "propertyCell", for: indexPath) as? HomeTableViewCell else {
            return UITableViewCell()
        }
        // Configure the cell...
        cell.propertyNameLabel.text = viewModel.propertyTitle(index: indexPath.row)
        cell.rentAmountLabel.text = viewModel.rent(index: indexPath.row)
        cell.areaLabel.text = viewModel.propertySize(index: indexPath.row)
        cell.propertyLocationLabel.text = viewModel.secondaryTitle(index: indexPath.row)
        cell.featuredLabel.text = "\(viewModel.furnishing(index: indexPath.row))\n\(viewModel.bathroom(index: indexPath.row))"
        
        if let imageUrlString = viewModel.imagUrl(index: indexPath.row){
            if let image = ImageLoader.cache.object(forKey: imageUrlString as AnyObject) as? Data{
                let cachedImage = UIImage(data: image)
                cell.propertyImageView.image = cachedImage
            } else {
                let imageLoader = ImageLoader(delegate: self, indexPath: indexPath)
                imageLoader.imageFromUrl(urlString: imageUrlString)
                cell.propertyImageView.image = #imageLiteral(resourceName: "placeholder")
            }
        } else {
            cell.propertyImageView.image = #imageLiteral(resourceName: "placeholder")
        }
        
        if indexPath.row + 5 >= viewModel.numberOfProperties() {
            loadNextPage()
        }
        return cell
        } else {
            loadNextPage()
            
            guard let cell =  tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as? LoadingTableViewCell else { return UITableViewCell() }
            
            if viewModel.reachedLastPage {
                cell.activityIndicator.isHidden = true
                cell.activityIndicator.stopAnimating()
                cell.statusLabel.isHidden = false
                if viewModel.numberOfProperties() == 0 {
                    cell.statusLabel.text = "No properties matching criteria"
                } else {
                    cell.statusLabel.text = "That's all folks"
                }
            } else {
                cell.activityIndicator.startAnimating()
                cell.activityIndicator.isHidden = false
                cell.statusLabel.isHidden = true
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 380
        } else {
            return 60
        }
        
    }
    
    private func updateTableView(previousCount oldValue:Int, updatedCount newValue: Int) {
        var array = [IndexPath]()
        for i in oldValue..<newValue {
            array.append(IndexPath(row: i, section: 0))
        }
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: array, with: .automatic)
        self.tableView.endUpdates()
        self.endLoading()
    }
    
    private func loadNextPage() {
        if !isLoading {
            startLoading()
            let oldCount = viewModel.numberOfProperties()
            viewModel.fetchNextPage {
                newCount in
                self.updateTableView(previousCount: oldCount, updatedCount: newCount)
            }
        }
    }
    
    private func endLoading() {
        self.isLoading = false
        self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
    }
    
    private func startLoading(){
        self.isLoading = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "filterSegue" {
            guard let filterVC = (segue.destination as? UINavigationController)?.visibleViewController as? FilterViewController else {return}
            filterVC.buildingTypeFilters = viewModel.buildingTypeFilters
            filterVC.furnishingTypeFilters = viewModel.furnishingTypeFilters
            filterVC.typeFilters = viewModel.typeFilters
            filterVC.delegate = self
        }
    }
    
    func updateFilter() {
        if viewModel.isFilterApplied {
            filterButton.image = #imageLiteral(resourceName: "icon_filter_filled")
        } else {
            filterButton.image = #imageLiteral(resourceName: "icon_filter")
        }
    }
}

extension HomeTableViewController: ImageLoaderProtocol {
    func imageLoaded(image: UIImage, forIndexPath indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? HomeTableViewCell {
            cell.propertyImageView.image = image
        }
    }
}

extension HomeTableViewController: FilterProtocol {
    func filterApplied(propertyTypeFilters: [Property.PropertyType], buildingTypeFilters: [Property.BuildingType], furnishingTypeFilters: [Property.FurnishingType]) {
        self.dismiss(animated: true) {
            self.viewModel.typeFilters = propertyTypeFilters
            self.viewModel.buildingTypeFilters = buildingTypeFilters
            self.viewModel.furnishingTypeFilters = furnishingTypeFilters
            self.tableView.reloadData()
            self.updateFilter()
        }
    }
}
