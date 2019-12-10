//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by ken.zhang on 2019/11/29.
//  Copyright © 2019 ken.zhang. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast_Swift

class WeatherViewController: BaseViewController {

    private lazy var tipLabel: UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = "Please input city or zipcode:"
        return lbl
    }()

    private lazy var gpsButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Search by location", for: .normal)

        return btn
    }()

    private lazy var recentButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Recent Search", for: .normal)

        return btn
    }()

    private lazy var searchBar: UITextField = {
        let bar = UITextField(frame: CGRect.zero)
        bar.placeholder = "city name or zip code"
        bar.backgroundColor = UIColor.gray
        bar.textColor = UIColor.black
        return bar
    }()

    private lazy var searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Search", for: .normal)

        return btn
    }()

    private lazy var tableview: UITableView = {
        let tb = UITableView(frame: CGRect.zero, style: .plain)
        tb.delegate = self
        tb.dataSource = self
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

        return tb
    }()
    
    private lazy var weatherView: WeatherView = WeatherView(frame: CGRect.zero)

    private let padding = 20

    private var viewModel: WeatherViewModel!

    private var disposedBag = DisposeBag()
    private var gpsTriggerSignal = PublishSubject<Void>()
    private var currentGPS: Coordinate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Weather"
        // Do any additional setup after loading the view.
        viewModel = WeatherViewModel()
        setupUI()
        setupLocation()
        loadMostRecent()
    }

    func setupUI() {
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.height.equalTo(25)
        }

        view.addSubview(recentButton)
        recentButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalToSuperview().offset(-padding)
            make.height.equalTo(25)
        }

        view.addSubview(searchButton)
        searchButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-padding)
            make.top.equalTo(tipLabel.snp.bottom).offset(padding)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }

        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.leading.equalTo(tipLabel)
            make.top.equalTo(tipLabel.snp.bottom).offset(padding)
            make.trailing.equalTo(searchButton.snp.leading).offset(-padding)
            make.height.equalTo(30)
        }

        view.addSubview(gpsButton)
        gpsButton.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom).offset(padding)
            make.centerX.equalToSuperview()
        }

        view.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(gpsButton.snp.bottom).offset(5)
            make.bottom.equalTo(recentButton.snp.top).offset(-padding)
        }
        
        view.addSubview(weatherView)
        weatherView.snp.makeConstraints { (make) in
            make.edges.equalTo(tableview)
        }
        weatherView.isHidden = true
        

        gpsButton.rx.tap.bind { [unowned self] in
            self.searchBar.resignFirstResponder()
            self.gpsTriggerSignal.onNext(())
        }.disposed(by: disposedBag)

        recentButton.rx.tap.bind { [unowned self] in
            let vc = RecentViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            vc.weatherBlock = { [unowned self] (model) in
                self.searchRecent(input: model.result ?? "")
            }
        }.disposed(by: disposedBag)

        searchButton.rx.tap.flatMap { [unowned self] (_) -> Observable<InputType> in
            self.view.makeToastActivity(.center)
            if let gps = self.currentGPS {
                self.currentGPS = nil
                return self.viewModel.judgeInputType(input: "\(gps.latitude ?? 0),\(gps.lontitude ?? 0)")
            } else {
                return self.viewModel.judgeInputType(input: self.searchBar.text)
            }
        }.flatMap { [unowned self] (input) -> Observable<Result<Data, ErrorInfo>> in
            return self.viewModel.reqeustWeatherBy(input: input)
        }.flatMap { [unowned self] (result) -> Observable<Result<WeatherModel, ErrorInfo>> in
            return self.viewModel.parseWeatherByData(result: result)
        }.subscribeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] (result) in
            self.view.hideToastActivity()
            switch result {
            case .success(let model):
                self.viewModel.upsertResult(input: self.searchBar.text ?? "")
                self.weatherView.setModel(model: model)
                self.weatherView.isHidden = false
                self.searchBar.resignFirstResponder()
            case .failure(let err):
                self.weatherView.isHidden = true
                switch err {
                case .inputError(let type):
                    switch type {
                    case .empty:
                        print("input can not be empty")
                        self.view.makeToast("Input can not be empty")
                    case .unkown:
                        self.view.makeToast("Input can not be recognized")
                    default:
                        break
                    }
                case .parseError(let err):
                    print("error: \(err.localizedDescription)")
                    self.view.makeToast("City can not be found")
                default:
                    self.view.makeToast("Unknown error occurs")
                }
            }
        }).disposed(by: disposedBag)

        searchBar.rx.text.orEmpty.asObservable().flatMapLatest { [unowned self] (text) -> Observable<Int> in
            if let text = self.searchBar.text, text.isEmpty {
                return Observable<Int>.just(0)
            } else {
                return self.viewModel.findResults(input: text)
            }
        }.subscribeOn(MainScheduler.instance).subscribe(onNext: {  [unowned self] (count) in
            if count == 0 {
                self.tableview.isHidden = true
            } else {
                self.tableview.isHidden = false
                self.tableview.reloadData()
            }
        }).disposed(by: disposedBag)
    }

    func loadMostRecent() {
        viewModel.findMostResult().subscribeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] (model) in
            if model == nil {
                self.view.makeToast("No recent search")
            } else {
                self.searchRecent(input: model?.result ?? "", canEmpty: false)
            }
        }).disposed(by: disposedBag)
    }
    
    func searchRecent(input: String, canEmpty: Bool = true) {
        self.searchBar.text = input
        if canEmpty {
            self.searchButton.sendActions(for: .touchUpInside)
        } else {
            if !input.isEmpty {
                self.searchButton.sendActions(for: .touchUpInside)
            }
        }
    }

    func setupLocation() {
        LocationManager.shared.startPositioning()

        Observable.combineLatest(LocationManager.shared.locationSignal, gpsTriggerSignal).subscribeOn(MainScheduler.instance).subscribe(onNext: { (signal) in
            self.currentGPS = signal.0.1
            self.searchBar.text = signal.0.0
            self.searchRecent(input: signal.0.0)
        }).disposed(by: disposedBag)
    }
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filterArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = viewModel.filterArr[indexPath.row].result
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchRecent(input: viewModel.filterArr[indexPath.row].result ?? "")
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent match results"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }


}
