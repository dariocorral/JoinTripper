//
//  ConfigProvider.swift
//  JoinTripper
//
//  Created by Dario Corral on 02/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import ObjectMapper

protocol ConfigProviderProtocol {
    
}

extension ConfigProviderProtocol {
    
    func obtainConfig() -> Config? {
        return defaultConfig()
    }
    
    func defaultConfig() -> Config {
        
        let resource = "Aviasales_Config"
        
        guard let url = Bundle.main.url(forResource: resource, withExtension: "plist") else {
            fatalError("\(resource) has not found")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("\(resource) has not been loaded")
        }
        
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
            fatalError("\(resource) has not been serialized")
        }
        
        guard let json = plist as? [String : Any] else {
            fatalError("\(resource) has incorrect format")
        }
        
        guard let config = Mapper<Config>().map(JSON: json) else {
            fatalError("\(resource) map error")
        }
        
        return config
    }
}

class ConfigProvider: ConfigProviderProtocol {
    
}

