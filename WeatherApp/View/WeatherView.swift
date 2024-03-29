//
//  WeatherView.swift
//  WeatherApp
//
//  Created by 张坚 on 2019/12/3.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit

class WeatherView: UIView {

    private lazy var cityNameLabel: WeatherLabel = WeatherLabel(frame: CGRect.zero)
    private lazy var temperatureLabel: WeatherLabel = WeatherLabel(frame: CGRect.zero)
    private lazy var humidityLabel: WeatherLabel = WeatherLabel(frame: CGRect.zero)
    private lazy var pressureLabel: WeatherLabel = WeatherLabel(frame: CGRect.zero)
    private lazy var latLabel: WeatherLabel = WeatherLabel(frame: CGRect.zero)
    private lazy var lonLabel: WeatherLabel = WeatherLabel(frame: CGRect.zero)

    private let padding = 10
    private let height = 40
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        self.addSubview(cityNameLabel)
        cityNameLabel.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.height.equalTo(height)
        }
        
        self.addSubview(temperatureLabel)
        temperatureLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(cityNameLabel)
            make.top.equalTo(cityNameLabel.snp.bottom).offset(padding)
            make.height.equalTo(height * 2)
        }
        temperatureLabel.numberOfLines = 3
        
        self.addSubview(latLabel)
        latLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(cityNameLabel)
            make.top.equalTo(temperatureLabel.snp.bottom).offset(padding)
            make.height.equalTo(height)
        }
        
        self.addSubview(lonLabel)
        lonLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(cityNameLabel)
            make.top.equalTo(latLabel.snp.bottom).offset(padding)
            make.height.equalTo(height)
        }
        
        self.addSubview(humidityLabel)
        humidityLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(cityNameLabel)
            make.top.equalTo(lonLabel.snp.bottom).offset(padding)
            make.height.equalTo(height)
        }
        
        self.addSubview(pressureLabel)
        pressureLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(cityNameLabel)
            make.top.equalTo(humidityLabel.snp.bottom).offset(padding)
            make.height.equalTo(height)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(model: WeatherModel) {
        cityNameLabel.text = "City: \(model.name ?? "")"
        if let value = model.mainData?.temperature, let minValue = model.mainData?.tempMin, let maxValue = model.mainData?.tempMax {
            temperatureLabel.text = "Temperature: \(value.celsiusStr) / \(value.fahrenheitStr) \n Ranges: \n \(minValue.celsiusStr) ~ \(maxValue.celsiusStr) / \(minValue.fahrenheitStr) ~ \(maxValue.fahrenheitStr)"
        } else {
            temperatureLabel.text = "Temperature: unknown"
        }
        latLabel.text = "Latitude: \(model.coordinate?.latitude ?? 0)"
        lonLabel.text = "Lontitude: \(model.coordinate?.lontitude ?? 0)"
        pressureLabel.text = "Pressure: \(model.mainData?.pressure ?? 0) hPa"
        humidityLabel.text = "Humidity: \(model.mainData?.humidity ?? 0) %"
    }
}

class WeatherLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.textColor = UIColor.black
        self.backgroundColor = UIColor.gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
