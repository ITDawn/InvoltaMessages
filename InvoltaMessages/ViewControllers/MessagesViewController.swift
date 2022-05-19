//
//  ViewController.swift
//  InvoltaMessages
//
//  Created by Dany on 17.05.2022.
//

import UIKit
import SkeletonView

class MessagesViewController: UIViewController {
    
    private let layout = UICollectionViewFlowLayout()
    private let cellIdentifier = CellForMessages()
    private var model:[String] = []
    private let connectionCheck = Reachability()
    
    private let backGroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        button.isHidden = true
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .systemGray5
        textField.layer.cornerRadius = 20
        return textField
    }()
    
    private let textFieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .systemBlue
        return indicator
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView.isSkeletonable = true
        collectionView.showAnimatedSkeleton(usingColor: .concrete, transition: .crossDissolve(0.25))
    }
    
    private func setUpView() {
        self.navigationController?.navigationBar.backgroundColor = .white
        self.title = "INVOLTA MESSAGES"
        self.view.addSubview(collectionView)
        self.view.addSubview(backGroundView)
        self.view.addSubview(activityIndicator)
        self.textFieldView.addSubview(textField)
        self.view.backgroundColor = .white
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "2")!)
        self.view.addSubview(textFieldView)
        self.view.addSubview(refreshButton)
        
        collectionView.refreshControl?.tintColor = .white
        collectionView.refreshControl?.addTarget(self,
                                                 action: #selector(pullToRefresh),
                                                 for: .valueChanged)
        refreshButton.addTarget(self,
                                action: #selector(refresh),
                                for: .touchUpInside)
        collectionView.backgroundColor = .none
        collectionView.register(CellForMessages.self, forCellWithReuseIdentifier: cellIdentifier.identifier)
        collectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: textFieldView.topAnchor),
            
            backGroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backGroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            backGroundView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            
            textFieldView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            textFieldView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            textFieldView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            textFieldView.heightAnchor.constraint(equalToConstant: 90),
            
            textField.topAnchor.constraint(equalTo: textFieldView.topAnchor, constant: 15),
            textField.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: -30),
            
            refreshButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -10),
            refreshButton.bottomAnchor.constraint(equalTo: textFieldView.topAnchor, constant: -10),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func alert(_ error:Error) {
        let alertVC = UIAlertController(title: error.localizedDescription,
                                        message: "",
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Refresh",
                                        style: .default,
                                        handler: {  [weak self] _ in
            self?.loadData()
        }))
        alertVC.addAction(UIAlertAction(title: "Cancel",
                                        style: .cancel,
                                        handler: {[weak self] _ in
            self?.activityIndicator.stopAnimating()
            self?.refreshButton.isHidden = false
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func loadData() {
        activityIndicator.startAnimating()
        if connectionCheck.isConnectedToNetwork() {
            self.refreshButton.isHidden = true
            NetworkManager.fetchData { model in
                DispatchQueue.main.async {
                    switch model {
                    case .success(let model):
                        self.activityIndicator.stopAnimating()
                        guard let newModel = model?.result else {return}
                        self.model = newModel
                        self.collectionView.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                        self.layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
                    case .failure(let error):
                        self.alert(error)
                    }
                }
            }
        } else {
            let alertVC = UIAlertController(title: "Network error",
                                            message: "please check your internet connection",
                                            preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Try again",
                                            style: .default,
                                            handler: {  [weak self] _ in
                self?.loadData()
            }))
            present(alertVC, animated: true, completion: nil)
            refreshButton.isHidden = false
        }
        
    }
    @objc func pullToRefresh() {
        print("pullme")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func refresh() {
        loadData()
    }
    
}

extension MessagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier.identifier, for: indexPath) as! CellForMessages
        let modelData = model[indexPath.section]
        messageCell.modeLabel.text = modelData
        messageCell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return messageCell
    }
}

extension MessagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: self.view.frame.width / 2, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let firstEdge = UIEdgeInsets(top: 10, left: self.view.frame.width / 2.3, bottom: 10, right: 5)
        let secondEdge = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: self.view.frame.width / 2.3)
        let randomEdges = [firstEdge,secondEdge]
        let randomSection = [section]
        for _ in randomSection {
            return randomEdges.randomElement() ?? secondEdge
        }
        return randomEdges.randomElement() ?? firstEdge
    }
}

extension MessagesViewController: SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return cellIdentifier.identifier
    }
}



