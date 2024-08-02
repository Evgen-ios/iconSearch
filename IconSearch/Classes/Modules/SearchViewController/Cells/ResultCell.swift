//
//  ResultCell.swift
//  IconSearch
//
//  Created by Evgeniy Goncharov on 01.08.2024.
//

import UIKit
import Foundation

final class ResultCell: UITableViewCell {
    
    // MARK: - Properties
    private var isImageSaved = false
    
    private lazy var iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.clipsToBounds = true
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    private lazy var sizeLabel: UILabel = {
        let sizeLabel = UILabel()
        sizeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        sizeLabel.text = "512x512"
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        return sizeLabel
    }()
    
    private lazy var tagsLabel: UILabel = {
        let tagsLabel = UILabel()
        tagsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tagsLabel.text = "512x512"
        tagsLabel.numberOfLines = .zero
        tagsLabel.lineBreakMode = .byWordWrapping
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        return tagsLabel
    }()
    
    // MARK: - Inherited Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        iconImageView.image = nil
        iconImageView.cancelImageLoad()
    }
    
    private func setup() {
        setupViews()
    }
    
    // MARK: SetupViews
    private func setupViews() {
        [iconImageView, sizeLabel, tagsLabel].forEach {
            addSubview($0)
        }
        
        setupConstraints()
    }
    
    // MARK: layoutConstraints
    func setupConstraints() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            sizeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            sizeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            sizeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            tagsLabel.leadingAnchor.constraint(equalTo: sizeLabel.leadingAnchor),
            tagsLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 4),
            tagsLabel.trailingAnchor.constraint(equalTo: sizeLabel.trailingAnchor),
            tagsLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

extension ResultCell {
    func configure(model: IconModel) {
        let rasterSize = model.rasterSizes
            .max(by: { $0.size < $1.size })
        
        let previewURLInRasterSizes = rasterSize
            .flatMap { findLargestPreviewURL(from: [ $0 ]) }
        
        self.isImageSaved = model.isImageSaved
        
        guard let previewURLInRasterSizes, let url = URL(string: previewURLInRasterSizes) else { return }
        
        iconImageView.loadImage(from: url)
        
        let text = "\(rasterSize?.sizeHeight ?? .zero)x\(rasterSize?.sizeHeight ?? .zero)"
        setLabelText(for: sizeLabel, withInitialText: "Размер: ", andFollowingText: text, initialTextLength: 7)
        
        concatenateTags(from: model.tags)
    }
    
    private func findLargestPreviewURL(from sizes: [RasterSize]) -> String? {
        return sizes
            .flatMap { $0.formats }
            .compactMap { $0.downloadURL }
            .first { !$0.isEmpty }
    }
    
    private func concatenateTags(from array: [String]) {
        let limitedArray = array.prefix(10)
        let text = limitedArray.joined(separator: ", ")
        setLabelText(for: tagsLabel, withInitialText: "Теги: ", andFollowingText: text, initialTextLength: 5)
    }
    
    private func setLabelText(for label: UILabel, withInitialText initialText: String, andFollowingText followingText: String, initialTextLength: Int) {
        let completeText = "\(initialText)\(followingText)"
        let firstFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let secondFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        let attributedString = NSMutableAttributedString(string: completeText)
        
        let rangeForBoldText = NSRange(location: 0, length: initialTextLength)
        attributedString.addAttribute(.font, value: firstFont, range: rangeForBoldText)
        
        let rangeForRegularText = NSRange(location: initialTextLength, length: completeText.count - initialTextLength)
        attributedString.addAttribute(.font, value: secondFont, range: rangeForRegularText)
        
        label.attributedText = attributedString
    }
}
