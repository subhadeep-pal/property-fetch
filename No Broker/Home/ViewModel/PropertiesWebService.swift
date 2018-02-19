//
//  PropertiesWebService.swift
//  No Broker
//
//  Created by Subhadeep Pal on 18/02/18.
//  Copyright © 2018 Personal. All rights reserved.
//

import UIKit

class PropertiesWebService: NSObject {
    
    private var lastFetchedPageNumber: Int!
    
    
    private func url(forPageNumber pageNo: Int) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "www.nobroker.in"
        urlComponents.path = "/api/v1/property/filter/region/ChIJLfyY2E4UrjsRVq4AjI7zgRY/"
        let latLang = URLQueryItem(name: "lat_lng", value: "12.9279232,77.6271078")
        let rent = URLQueryItem(name: "rent", value: "0,500000")
        let travelTime = URLQueryItem(name: "travelTime", value: "30")
        let pageNo = URLQueryItem(name: "pageNo", value: "\(pageNo)")
        urlComponents.queryItems = [latLang, rent, travelTime, pageNo]
        
        guard let url = urlComponents.url else {
            return nil
        }
        return url
    }
    
    
    func fetch(nextPage: Bool = false, onSuccess success: @escaping ([Property], Int)->(), onFailure failure: @escaping()->()) {
        var pageNumber = 0
        
        if nextPage {
            pageNumber = (lastFetchedPageNumber ?? 0) + 1
        }
        
        guard let url = url(forPageNumber: pageNumber) else {return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let _ = error {
                failure()
            } else if let jsonData = data {
                
                let decoder = JSONDecoder()
                
                do {
                    let propertiesServiceResponse = try decoder.decode(PropertiesServiceResponse.self, from: jsonData)
                    DispatchQueue.main.async { [unowned self] in
                        self.lastFetchedPageNumber = pageNumber
                        success(propertiesServiceResponse.data, propertiesServiceResponse.otherParams.total_count)
                    }
                } catch{
                    failure()
                }
            } else {
                let _ = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                failure()
            }
        }
        
        task.resume()
        print(url.absoluteString)
    }
    
}
