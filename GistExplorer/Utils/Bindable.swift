import Foundation
import UIKit

protocol Bindable: AnyObject {
    associatedtype ViewModelIO

    var viewModel: ViewModelIO? { get set }

    func bindViewModel()
}

extension Bindable where Self: UIViewController {
    func bind(to model: Self.ViewModelIO) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}

extension Bindable where Self: UITableViewCell {
    func bind(to model: Self.ViewModelIO) {
        viewModel = model
        bindViewModel()
    }
}

extension Bindable where Self: UICollectionViewCell {
    func bind(to model: Self.ViewModelIO) {
        viewModel = model
        bindViewModel()
    }
}
