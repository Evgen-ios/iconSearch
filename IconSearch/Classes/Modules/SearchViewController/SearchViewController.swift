//
//  SearchViewController.swift
//  IconSearch
//
//  Created by Evgeniy Goncharov on 01.08.2024.
//

import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - Private Lazy Properties
    private let networkService = NetworkService()
    private var items: IconsModel = .init()
    private var tableViewBottomConstraint: NSLayoutConstraint?
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Введите запрос"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Найти", for: .normal)
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    private let searchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 90
        tableView.register(ResultCell.self, forCellReuseIdentifier: "resultCell")
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    // MARK: - Inherited Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupKeyboardObservers()
    }
    
    deinit {
        removeKeyboardObservers()
    }
}

// MARK: - Methods
extension SearchViewController {
    
    private func FectIcons(query: String) {
        showActivityIndicator()
        networkService.searchIconsSync(query: query) { result in
            switch result {
            case .success(let model):
                self.items = model
                
                self.tableView.reloadData()
                self.hideActivityIndicator()
                
                if model.icons.count == .zero {
                    self.showAlert(title: "Нет изображений", message: "Попробуйте другой запрос")
                }
                
            case .failure(let error):
                print("\(error)")
            }
        }
    }
    
    @objc private func searchButtonTapped() {
        guard let query = searchBar.text, !query.isEmpty else { return }
        print("Запрос: \(query)")
        FectIcons(query: query)
        searchBar.resignFirstResponder()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .white
        [searchBar, searchButton].forEach {
            searchStackView.addArrangedSubview($0)
        }
        
        [searchStackView, tableView].forEach {
            view.addSubview($0)
        }
        
        view.addSubview(activityIndicator)
    }
    
    private func showActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    private func setupConstraints() {
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            searchStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            searchBar.widthAnchor.constraint(equalTo: searchStackView.widthAnchor, multiplier: 0.8),
            
            tableView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewBottomConstraint!
        ])
    }
    
    private func showAlert(title: String, message: String, actionTitle: String = "OK") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func saveImage(for model: IconModel, at indexPath: IndexPath) {
        guard !model.isImageSaved else { return }
        
        if let url = model.rasterSizes
            .flatMap({ $0.formats })
            .compactMap({ $0.previewURL })
            .first(where: { !$0.isEmpty }),
           let imageURL = URL(string: url) {
            
            Task {
                do {
                    let image = try await networkService.downloadImage(from: imageURL)
                    
                    DispatchQueue.main.async {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                        
                        var updatedModel = model
                        updatedModel.isImageSaved = true
                        self.items.icons[indexPath.row] = updatedModel
                        
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                } catch {
                    print(error.localizedDescription)
                    showAlert(title: "Ошибка", message: "Не удалось сохранить изображение в галерею телефона")
                }
            }
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            showAlert(title: "Успех", message: "Изображение успешно сохранено в галерею телефона")
            
            if let indexPath = self.tableView.indexPathsForVisibleRows?.first(where: { indexPath in
                let model = self.items.icons[indexPath.row]
                return model.isImageSaved
            }) {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        tableViewBottomConstraint?.constant = -keyboardFrame.height
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        tableViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButtonTapped()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchButton.isEnabled = !searchText.isEmpty
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveImage(for: items.icons[indexPath.row], at: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.icons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as? ResultCell else {
            return UITableViewCell()
        }
        cell.configure(model: items.icons[indexPath.row])
        return cell
    }
}
