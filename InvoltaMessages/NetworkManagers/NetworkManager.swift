//
//  NetworkManager.swift
//  InvoltaMessages
//
//  Created by Dany on 17.05.2022.
//

import UIKit
final class NetworkManager {
    
    static  func fetchData(comletion:@escaping (Result<Model?,Error>) -> Void){
        DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
            let urlString = "https://numero-logy-app.org.in/getMessages?offset=0"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask (with: url) { data, responce, error in
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let object = try JSONDecoder().decode (Model.self, from: data)
                    comletion(.success(object))
                } catch  {
                    comletion(.failure(error))
                }
            }.resume()})
    }
}
