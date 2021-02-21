import Foundation
import UIKit
import SnapKit
import WebKit

final class GistDetailView: UIView {

    lazy var ownerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .appDarkGray
        return imageView
    }()

    lazy var ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .title1
        label.textColor = .appDarkGray
        return label
    }()

    lazy var filesLabel: UILabel = {
        let label = UILabel()
        label.font = .headline
        label.textColor = .appMediumGray
        return label
    }()

    lazy var filesPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = .headline
        label.textColor = .appMediumGray
        return label
    }()

    lazy var filesTableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.allowsSelection = true
        tableView.sectionIndexBackgroundColor = .appBlue
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.backgroundColor = .appLightGray
        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        addSubviews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubviews() {
        addSubview(ownerImageView)
        addSubview(ownerNameLabel)
        addSubview(filesTableView)
        addSubview(filesLabel)
        addSubview(filesPreviewLabel)
        addSubview(webView)
    }

    private func makeConstraints() {
        ownerNameLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().offset(16)
            make.top.equalTo(ownerImageView.snp.bottom).offset(16)
        }

        ownerImageView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.height.equalTo(200)
        }

        filesTableView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(filesLabel.snp.bottom).offset(8)
            make.height.equalTo(150)
        }

        filesLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().offset(16)
            make.top.equalTo(ownerNameLabel.snp.bottom).offset(16)
        }

        filesPreviewLabel.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().offset(16)
            make.top.equalTo(filesTableView.snp.bottom).offset(16)
        }

        webView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().offset(16)
            make.top.equalTo(filesPreviewLabel.snp.bottom).offset(16)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottomMargin)
        }
    }
}
