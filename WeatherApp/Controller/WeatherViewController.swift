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
        lbl.text = "Please select input type"
        return lbl
    }()

    private lazy var typeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("City", for: .normal)

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

    private let padding = 20

    private var viewModel: WeatherViewModel!

    private var disposedBag = DisposeBag()
    private var gpsTriggerSignal = PublishSubject<Void>()

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
        view.addSubview(typeButton)
        typeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.trailing.equalToSuperview().offset(-padding)
            make.width.equalTo(100)
            make.height.equalTo(25)
        }

        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalTo(typeButton).offset(-padding)
            make.height.equalTo(25)
        }

        view.addSubview(recentButton)
        recentButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-padding)
            make.leading.equalToSuperview().offset(padding)
            make.trailing.equalTo(typeButton).offset(-padding)
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

        view.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(5)
            make.bottom.equalTo(recentButton.snp.top).offset(-padding)
        }

        typeButton.rx.tap.bind { [unowned self] in
            self.searchBar.resignFirstResponder()
            self.showActionAlert()
        }.disposed(by: disposedBag)

        recentButton.rx.tap.bind { [unowned self] in
            self.navigationController?.pushViewController(RecentViewController(), animated: true)
        }.disposed(by: disposedBag)

        searchButton.rx.tap.flatMap { [unowned self] (_) -> Observable<InputType> in
            self.view.makeToastActivity(.center)
            return self.viewModel.judgeInputType(input: self.searchBar.text)
        }.flatMap { [unowned self] (input) -> Observable<Result<Data, ErrorInfo>> in
            return self.viewModel.reqeustWeatherBy(input: input)
        }.flatMap { [unowned self] (result) -> Observable<Result<WeatherModel, ErrorInfo>> in
            return self.viewModel.parseWeatherByData(result: result)
        }.subscribeOn(MainScheduler.instance).subscribe(onNext: { [unowned self] (result) in
            self.view.hideToastActivity()
            switch result {
            case .success(let model):
                print(model)
                self.viewModel.upsertResult(input: self.searchBar.text ?? "")
            case .failure(let err):
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
                    self.view.makeToast("Input can not be recognized")
                default:
                    self.view.makeToast("Unknown error occurs")
                }
            }
        }).disposed(by: disposedBag)

        searchBar.rx.text.orEmpty.asObservable().flatMapLatest { [unowned self] (text) -> Observable<Void> in
            return self.viewModel.findResults(input: text)
        }.subscribeOn(MainScheduler.instance).subscribe(onNext: {  [unowned self] (_) in
            self.tableview.reloadData()
        }).disposed(by: disposedBag)
    }

    func loadMostRecent() {
        viewModel.findMostResult().subscribe(onNext: { [unowned self] (model) in
            let input = model?.result ?? ""
            self.searchBar.text = input
            if !input.isEmpty {
                self.searchButton.sendActions(for: .touchUpInside)

            }
        }).disposed(by: disposedBag)
    }

    func setupLocation() {
        Observable.zip(LocationManager.shared.locationSignal, gpsTriggerSignal).subscribeOn(MainScheduler.instance).subscribe(onNext: { (signal) in
            if !self.searchBar.isHidden {
                self.searchBar.text = signal.0
            }
        }).disposed(by: disposedBag)
    }

    func showActionAlert() {
        let alert = UIAlertController(title: "Selection", message: "", preferredStyle: .actionSheet)
        let city = UIAlertAction(title: "City", style: .default) { [unowned self] (_) in
            self.typeButton.setTitle("City", for: .normal)
            self.searchBar.text = ""
            self.searchBar.keyboardType = .default
        }
        let zipcode = UIAlertAction(title: "Zipcode", style: .default) { [unowned self] (_) in
            self.typeButton.setTitle("Zipcode", for: .normal)
            self.searchBar.text = ""
            self.searchBar.keyboardType = .numberPad
        }
        let GPS = UIAlertAction(title: "GPS", style: .default) { (_) in
            self.typeButton.setTitle("GPS", for: .normal)
            LocationManager.shared.startPositioning()
            self.gpsTriggerSignal.onNext(())
        }
        alert.addAction(city)
        alert.addAction(zipcode)
        alert.addAction(GPS)
        self.present(alert, animated: true, completion: nil)
    }
}


extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filterArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = viewModel.filterArr[indexPath.row].result
        return cell
    }
}
