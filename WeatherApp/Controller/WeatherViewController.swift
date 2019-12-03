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

class WeatherViewController: UIViewController {

    private lazy var tipLabel: UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = "Please input city name or zip code or GPS"
        return lbl
    }()

    private lazy var searchBar: UITextField = {
        let bar = UITextField(frame: CGRect.zero)
        bar.placeholder = "city name or zip code or GPS"
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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        viewModel = WeatherViewModel()
        setupUI()
    }

    func setupUI() {
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
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

        view.addSubview(tableview)
        tableview.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(5)
        }

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
                self.viewModel.insertResult()
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
            return self.viewModel.findResult(input: text)
        }.subscribeOn(MainScheduler.instance).subscribe(onNext: {  [unowned self] (_) in
            self.tableview.reloadData()
            }).disposed(by: disposedBag)
    }
}


extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.resultArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = viewModel.resultArr[indexPath.row].result
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model = viewModel.resultArr[indexPath.row]
            viewModel.resultArr.remove(at: indexPath.row)
            viewModel.deleteResult(model: model)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.setEditing(false, animated: true)
        }
    }
}
