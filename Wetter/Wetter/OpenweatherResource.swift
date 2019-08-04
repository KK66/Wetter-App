//
//  OpenweatherResource.swift
//  Wetter
//
//  Created by Kilian Kellermann on 01.03.17.
//  Copyright © 2017 Kilian Kellermann. All rights reserved.
//

import UIKit

class OpenweatherResource {
    
    // Settings auslesen
    private func getSetting(withName name: String) -> String? {
        
        guard let value = Bundle.main.object(forInfoDictionaryKey: name) as? String else {
            return nil
        }
        
        return value
    }
    
    // URL erzeugen
    private func buildUrlString() -> String? {
        
        // base url
        let host = "api.openweathermap.org"
        let path = "data/2.5/weather"
        let settings = "units=metric&lang=de"
        
        // varaiblen settings
        guard let key = getSetting(withName: "owApiKey"), let zip = getSetting(withName: "owZipcode") else {
            
            print("settings nicht gefunden.")
            return nil
        }
        
        return "http://\(host)/\(path)?zip=\(zip),de&appid=\(key)&\(settings)"
    }
    
    // öffentliche Schnittestelle:
    // - Wetterbericht herunterladen
    func fetchReport(completion: @escaping (_ response: OpenweatherResponse) -> () ) {
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // async herunterladen
        queue.async {
            // URL (ehemals NSURL)
            guard let url = self.buildUrlString(),
                let urlObj = URL(string: url) else {
                print("Problem beim erstellen der URL")
                return
            }
            
            let task = session.dataTask(with: urlObj, completionHandler: {
                (data, response, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let data = data, let apiResponse = self.createResponse(fromData: data) else {
                    print("Keine Daten?")
                    return
                }
                
                DispatchQueue.main.async {
                    completion(apiResponse)
                }
                
            })
            
            task.resume()
        }
    }
    
    func fetchImage(forIcon: String, completion: @escaping (_ img: UIImage) -> ()) {
        
        let iconUrl = "http://openweathermap.org/img/w/\(forIcon).png"
        
        DispatchQueue.global(qos: .userInteractive).async {
            guard let urlObj = URL(string: iconUrl) else {
                print("fehlerhafte Bildurl?")
                return
            }
            
            do {
                let imgData = try Data.init(contentsOf: urlObj)
                
                guard let image = UIImage(data: imgData) else {
                    print("image nicht erstellt?")
                    return
                }
                
                DispatchQueue.main.async {
                    completion(image)
                }
                
            } catch {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    //
    private func createResponse(fromData: Data) -> OpenweatherResponse? {
        
        guard let jsonDict = parseJson(data: fromData) else {
            print("Problem beim verarbeiten von json.")
            return nil
        }
        
        guard let weatherColl = jsonDict["weather"] as? NSArray,
              let mainDict = jsonDict["main"] as? [String: AnyObject] else {
            
            print("konnte dictionaries nicht lesen.")
            return nil
        }
        
        guard let weatherDict = weatherColl[0] as? [String: AnyObject] else {
            print("Probleme beim lesen des weather arrays")
            return nil
        }
        
        guard let icon = weatherDict["icon"] as? String,
            let description = weatherDict["description"] as? String,
            let temperatur = mainDict["temp"] as? Double else {
                
                print("Konnte werte nicht lesen")
                return nil
        }
        
        let response = OpenweatherResponse(icon: icon, description: description, temperatur: temperatur)
        
        return response
    }
    
    private func parseJson(data: Data) -> NSDictionary? {
        
        do {
            let jsonDict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
            
            return jsonDict
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
