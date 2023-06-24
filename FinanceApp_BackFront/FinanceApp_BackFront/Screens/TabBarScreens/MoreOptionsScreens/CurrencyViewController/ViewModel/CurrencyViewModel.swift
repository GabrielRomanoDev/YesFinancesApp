//
//  CurrencyViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/05/23.
//

import Foundation

protocol CurrencyViewModelProtocol: AnyObject {
    func success()
    func error(error: ErrorRequest)
}

class CurrencyViewModel {
    
    private var service: ExchangeRateService = ExchangeRateService()
    public var exchangeRate: ExchangeRate?
    weak var delegate: CurrencyViewModelProtocol?
    private var lastRequestDate: String?
    private var currencyExchangeRate: Double = 1
    
    public func updateExchangeRate() {
        let today: String = Date().toString(format: globalStrings.dateFormat)
        if lastRequestDate != today {
            service.getExchangeRateFromJson { result in
                switch result {
                case .success(let success):
                    self.exchangeRate = success
                    lastRequestDate = Date().toString(format: globalStrings.dateFormat)
                    self.delegate?.success()
                case .failure(let failure):
                    self.delegate?.error(error: failure)
                }
            }
        }
    }

    public func getConvertedValue(sourceCoin: CurrencyInfos, targetCoin: CurrencyInfos, value: Double) -> String {
        let baseValue = exchangeRate?.conversionRates[exchangeRate?.baseCode ?? "USD"] ?? 0
        let sourceRate = exchangeRate?.conversionRates[sourceCoin.code] ?? 0
        let targetRate = exchangeRate?.conversionRates[targetCoin.code] ?? 0
        self.currencyExchangeRate = ((baseValue / sourceRate) * targetRate)
        let result = value * self.currencyExchangeRate
        
        return targetCoin.symbol + " " + formatNumberCurrency(value: result)
    }
    
    public func getCoinInfo(index: Int) -> CurrencyInfos {
        return coinsList[index]
    }
    
    public func getLastExchangeQuote(sourceSymbol: String, targetSymbol: String) -> String {
        return sourceSymbol + " 1,00 = " + targetSymbol + " " + formatNumberCurrency(value: currencyExchangeRate)
    }
    
    public func getActualDate() -> String {
        let date = Date()
        
        return date.toString(format: moreOptionsStrings.momentDateFormat)
    }
    
    public func formatNumberCurrency(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "pt_BR")

        return formatter.string(from: NSNumber(value: value)) ?? "0,00"
    }
    
}
