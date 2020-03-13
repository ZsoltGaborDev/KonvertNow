//
//  CoinManager.swift
//  KovertNow
//
//  Created by zsolt on 13/03/2020.
//  Copyright © 2020 zsolt. All rights reserved.
//

import Foundation


protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String, symbol: String)
    func didFailWithError(error: Error)
}

class CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbol = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    var selectedSymbol = ""
    let apiKey = "FEC3A249-9404-45A8-8266-A7ED3DD67D0F"
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    
    //MARK: - Networking
    func getCoinPrice(for currency: String, with symbol: String) {
        
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        print(urlString)
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency, symbol: symbol)
                    }
                }
            }
            task.resume()
        }
    }
    
    //MARK: - JSON Parsing
    func parseJSON(_ data: Data) -> Double? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            print(lastPrice)
            return lastPrice
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
