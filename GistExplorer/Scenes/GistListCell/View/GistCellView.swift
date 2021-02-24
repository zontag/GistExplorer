import Foundation
import UIKit

final class GistCellView: UIView {

    // MARK: - Views
    private lazy var cropContentView: UIView = {
        let view = UIView(frame: .zero)
        view.clipsToBounds = true
        view.layer.cornerRadius = 6
        return view
    }()

    lazy var ownerImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .appDarkGray
        return imageView
    }()

    lazy var ownerNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appDarkGray
        label.font = .headline
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    lazy var gistTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appMediumGray
        label.font = .footnote
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    lazy var favoriteSwitch: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .headline
        return button
    }()

    init() {
        super.init(frame: .zero)
        setupShadow()
        addSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupFavoriteButton(save: Bool) {
        favoriteSwitch.setTitleColor(save ? .red : .green, for: .normal)
        favoriteSwitch.setTitle(save ? "Delete" : "Save", for: .normal)
    }

    private func addSubviews() {
        self.addSubview(cropContentView)

        let vStack = UIStackView(arrangedSubviews: [ownerNameLabel, gistTypeLabel])
        vStack.axis = .vertical
        vStack.spacing = 8

        let hStack = UIStackView(arrangedSubviews: [vStack, favoriteSwitch])
        hStack.axis = .horizontal
        hStack.alignment = .center

        cropContentView.addSubview(ownerImageView)
        cropContentView.addSubview(hStack)

        ownerImageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        ownerImageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(hStack.snp.top).inset(-8)
        }

        cropContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        hStack.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview().inset(10).priority(.required)
        }
    }

    private func setupShadow() {
        self.layer.cornerRadius = 6
        self.clipsToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = .init(width: 0, height: 1)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.2
        self.backgroundColor = .appLightGray
    }
}
