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
    
    private var isLoading : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        viewModel.callService {
            self.tableView.reloadData()
            self.endLoading()
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
        if section == 0 {
            return viewModel.numberOfProperties()
        } else {
            return isLoading ? 0 : 0
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath)
        } else {
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > (contentHeight  - (2.0 * scrollView.frame.size.height)),
            !isLoading{
            startLoading()
            viewModel.fetchNextPage {
                self.tableView.reloadData()
                self.endLoading()
            }
        }
    }
    
    func endLoading() {
        self.isLoading = false
    }
    
    func startLoading(){
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
        }
    }
}
