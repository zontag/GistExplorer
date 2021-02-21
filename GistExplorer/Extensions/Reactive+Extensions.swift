import Foundation
import RxSwift
import RxCocoa
import Kingfisher
import UIKit
import WebKit

extension Reactive where Base: UIImageView {
    var kfBuilder: Binder<KF.Builder> {
        Binder(base) { base, builder in
            builder.set(to: base)
        }
    }
}

extension Reactive where Base: WKWebView {
    var url: Binder<URL?> {
        Binder(base) { base, url in
            if let url = url {
                base.load(URLRequest(url: url))
            }
        }
    }
}
