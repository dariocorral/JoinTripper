//
//  DataAPI.swift
//  JoinTripper
//
//  Created by Dario Corral on 13/10/18.
//  Copyright © 2018 Dario Corral. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class DataAPI: NSObject, CLLocationManagerDelegate {
    
    // Used to start getting the users location
    let locationManager = CLLocationManager()
    
    //MARK: - Propierty Container Core Data definition
    //Creamos el container que da acceso a la entidad "Currencies"
    
    let persistentContainer: NSPersistentContainer =  {
        let container = NSPersistentContainer(name:"JoinTripper")
        container.loadPersistentStores{ (description,error) in
            if let error = error {
                print("Error setting up Core Data \(error).")
            }
        }
        return container
    }()
    
    
    //MARK: - Load JSON Currencies Data into Core Data
    func loadJSONCurrenciesData() -> Void {
        
        do {
            //Usamos JSONSerialization para acceder a la info
            guard
                let file = Bundle.main.url(forResource: "Currencies", withExtension: "json")else {
                    print ("Error reading JSON file")
                    return
            }
            let data = try Data(contentsOf: file)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonDictionary = jsonObject as? [AnyHashable:Any]
            
            guard let symbolsListJson = jsonDictionary?["results"] as? [String:Any]
                else {
                    print ("Error looking up results JSON file key Currencies")
                    return
            }
            
            //Creamos variable de los códigos/símbolos de las divisas
            var symbolsArray = [String]()
            
            for item in symbolsListJson {
                symbolsArray.append(item.key)
            }
            //Creamos variable de los nombres de las divisas
            var nameArray = [String]()
            
            for item in symbolsArray {
                var aux = symbolsListJson[item] as? [String:Any]
                nameArray.append((aux?["currencyName"] as? String)!)
            }
            //Creamos una variable dict con las anteriores variables
            var currenciesDict = [String: String]()
            
            for i in 0..<min(nameArray.count, symbolsArray.count) {
                currenciesDict[symbolsArray[i]] = nameArray[i]
            }
            //Introducimos la info generada dentro de la entidad Currencies
            for (keys,values) in currenciesDict{
                persistentContainer.viewContext.performAndWait {
                    
                    var currencies:Currencies!
                    
                    currencies = Currencies(context: persistentContainer.viewContext)
                    currencies.symbol = keys as String
                    currencies.name = values as String
                    //Imprimimos las instancias creadas y salvadas en consola
                    //print(currencies)
                }
            }
            //Salvamos la información introducida
            try persistentContainer.viewContext.save()
            
        } catch let error {
            print("Error during process of loading Currencies data: \(error)")
        }
    }
    
    //MARK: - Load JSON Countries Data into Core Data
    func loadJSONCountriesData() -> Void {
        
        do {
            //Usamos JSONSerialization para acceder a la info
            guard
                let file = Bundle.main.url(forResource: "Countries", withExtension: "json")else {
                    print ("Error reading JSON file")
                    return
            }
            let data = try Data(contentsOf: file)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonDictionary = jsonObject as? [AnyHashable:Any]
            
            guard let symbolsListJson = jsonDictionary?["results"] as? [String:Any]
                else {
                    print ("Error looking up results JSON file key Countries")
                    return
            }
            
            //Creamos variable de los códigos/símbolos de las divisas
            var symbolsArray = [String]()
            
            for item in symbolsListJson {
                symbolsArray.append(item.key)
            }
            //Creamos variable array de los nombres de los países
            var nameArray = [String]()
            
            for item in symbolsArray {
                var aux = symbolsListJson[item] as? [String:Any]
                nameArray.append((aux?["name"] as? String)!)
            }
            
            //Creamos una variable array de los símbolos de las monedas
            var currencyCode = [String]()
            
            for item in symbolsArray {
                var aux = symbolsListJson[item] as? [String:Any]
                currencyCode.append((aux?["currencyId"] as? String)!)
            }
            
            //Creamos una variable dict con las anteriores variables
            var currenciesDict = [String: [String]]()
            
            for i in 0..<min(nameArray.count, currencyCode.count, symbolsArray.count) {
                currenciesDict[symbolsArray[i]] = [nameArray[i], currencyCode[i]]
            }
            //Introducimos la info generada dentro de la entidad Currencies
            for (keys,values) in currenciesDict{
                persistentContainer.viewContext.performAndWait {
                    
                    var countries:Countries!
                    
                    countries = Countries(context: persistentContainer.viewContext)
                    countries.code = keys as String
                    countries.name = values[0] as String
                    countries.symbol = values[1] as String
                    //Imprimimos las instancias creadas y salvadas en consola
                    //print(countries)
                }
            }
            //Salvamos la información introducida
            try persistentContainer.viewContext.save()
            
        } catch let error {
            print("Error during process of loading Countries data: \(error)")
        }
    }
    
    //MARK: - Load JSON Currencies Data into Core Data
    func loadJSONAirportsData() -> Void {
        
        do {
            //Usamos JSONSerialization para acceder a la info
            guard
                let file = Bundle.main.url(forResource: "Airports", withExtension: "json")else {
                    print ("Error reading JSON file")
                    return
            }
            let data = try Data(contentsOf: file)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonDictionary = jsonObject as? [[AnyHashable:Any]]
            
            guard let fullListJson = jsonDictionary as? [[String:Any]]
                else {
                    print ("Error looking up results JSON file key Airports")
                    return
            }
            
            //Creamos variable de los códigos/símbolos de los aeropuertos
            var codesArray = [String]()
            
            for i in 0..<fullListJson.count {
                guard let dictCodesArray = fullListJson[i]["code"] as? String else {return}
                codesArray.append(dictCodesArray)
            }
            //Creamos variable de los nombres de los aeropuertos
            var namesArray = [String]()
            
            for i in 0..<fullListJson.count {
                guard let dictNamesArray = fullListJson[i]["name"] as? String else {return}
                namesArray.append(dictNamesArray)
            }
            
            //Creamos variable de la latitud
            var latArray = [String]()
            
            for i in 0..<fullListJson.count {
                guard let dictLatArray = fullListJson[i]["lat"] as? String else {return}
                latArray.append(dictLatArray)
            }
            
            //Creamos variable de la latitud
            var longArray = [String]()
            
            for i in 0..<fullListJson.count {
                guard let dictLongArray = fullListJson[i]["lon"] as? String else {return}
                longArray.append(dictLongArray)
            }
            
            //Creamos una variable dict con las anteriores variables
            var airportsDict = [String: [String]]()
            
            for i in 0..<min(namesArray.count, codesArray.count) {
                airportsDict[codesArray[i]] = [namesArray[i], latArray[i], longArray[i]]
            }
            // For use when the app is open & in the background
            self.locationManager.requestAlwaysAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuracy here.
                self.locationManager.startUpdatingLocation()
                
            } else {print("no enable location")}
            
            //User location
            if let userLocation = self.locationManager.location  {
                
                //print("User location: \(userLocation.coordinate.latitude) ,\(userLocation.coordinate.longitude)")
                
                //Introducimos la info generada dentro de la entidad Airports
                //print("Airports count: \(airportsDict.count)")
                
                for (keys,values) in airportsDict{
                    persistentContainer.viewContext.performAndWait {
                        
                        var airports:Airports!
                        
                        airports = Airports(context: persistentContainer.viewContext)
                        airports.code = keys as String
                        airports.name = values[0] as String
                        
                        //Distance calculation
                        let lat = values[1] as String
                        let long = values[2] as String
                        
                        var distance = Double()
                        
                        if let latFloat = Double(lat),
                            let longFloat = Double(long){
                            //Coordinates
                            let coordinates = CLLocation(latitude: latFloat, longitude: longFloat)
                            //Distance meters
                            distance = coordinates.distance(from: userLocation)
                        }
                        else {
                            print ("Error calculating coordinates airport \(keys): \(values[0])")
                            distance = Double(0.0)
                        }
                        
                        //Put integer into core data about distance
                        airports.distance = distance
                        
                        //Imprimimos las instancias creadas y salvadas en consola
                        //print("Airports - Code:\(airports.code ?? "No code")")
                        //print("Airports - name:\(airports.name ?? "No name")")
                        //print("Airports - distance:\(airports.distance)")
                    }
                }
                
            } else {
                
                //Save distance as 0 km
                for (keys,values) in airportsDict{
                    persistentContainer.viewContext.performAndWait {
                        
                        var airports:Airports!
                        
                        airports = Airports(context: persistentContainer.viewContext)
                        airports.code = keys as String
                        airports.name = values[0] as String
                        
                        let distance = Double(0.0)
                        
                        //Put integer into core data about distance
                        airports.distance = distance
                        
                        //Imprimimos las instancias creadas y salvadas en consola
                        //print("Airports - Code:\(airports.code ?? "No code")")
                        //print("Airports - name:\(airports.name ?? "No name")")
                        //print("Airports - distance:\(airports.distance)")
                    }
                }
            }
            //Salvamos la información introducida
            try persistentContainer.viewContext.save()
            
        } catch let error {
            print("Error during process of loading Currencies data: \(error)")
        }
    }
    
    //MARK: - Load JSON Language Data into Core Data
    func loadJSONLanguagesData() -> Void {
        
        do {
            //Usamos JSONSerialization para acceder a la info
            guard
                let file = Bundle.main.url(forResource: "Languages", withExtension: "json")else {
                    print ("Error reading JSON file")
                    return
            }
            let data = try Data(contentsOf: file)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonDictionary = jsonObject as? [[AnyHashable:Any]]
            
            guard let fullListJson = jsonDictionary as? [[String:Any]]
                else {
                    print ("Error looking up results JSON file key Languages")
                    return
            }
            
            //Creamos variable de los códigos/símbolos de los idiomas
            var codesArray = [String]()
            
            for i in 0..<fullListJson.count {
                guard let dictCodesArray = fullListJson[i]["alpha2"] as? String else {return}
                codesArray.append(dictCodesArray)
            }
            //Creamos variable de los nombres de los aeropuertos
            var namesArray = [String]()
            
            for i in 0..<fullListJson.count {
                guard let dictNamesArray = fullListJson[i]["English"] as? String else {return}
                namesArray.append(dictNamesArray)
            }
            //Creamos una variable dict con las anteriores variables
            var languagesDict = [String: String]()
            
            for i in 0..<min(namesArray.count, codesArray.count) {
                languagesDict[codesArray[i]] = namesArray[i]
            }
            //Introducimos la info generada dentro de la entidad Languages
            for (keys,values) in languagesDict{
                persistentContainer.viewContext.performAndWait {
                    
                    var languages:Languages!
                    
                    //Extract language names
                    guard let namesRawOne = values.split(separator:";").first,
                        let namesRawTwo = namesRawOne.split(separator:",").first,
                        let names = namesRawTwo.split(separator:"(").first
                        
                        else {print ("Impossible to extract Languages data")
                            return}
                    
                    languages = Languages(context: persistentContainer.viewContext)
                    languages.code = keys.uppercased() as String
                    languages.name = String(names) as String
                    
                    //Imprimimos las instancias creadas y salvadas en consola
                    //print(languages)
                    
                }
            }
            //Salvamos la información introducida
            try persistentContainer.viewContext.save()
            
        } catch let error {
            print("Error during process of loading Languages data: \(error)")
        }
    }
    
}
