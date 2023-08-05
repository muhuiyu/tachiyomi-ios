//
//  Base.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/3/23.
//

import UIKit
import RxSwift

// MARK: - Base
struct Base {
    
}

extension Base {
    // MARK: - Base.MVVMViewController
    class MVVMViewController<T: ViewModelType>: BaseViewController {
        let viewModel: T
        let disposeBag = DisposeBag()
        
        init(appCoordinator: AppCoordinator? = nil, viewModel: T) {
            self.viewModel = viewModel
            super.init(appCoordinator: appCoordinator)
        }
    }
    
    // MARK: - Base.ViewModel
    class ViewModel: ViewModelType {
        internal let disposeBag = DisposeBag()
        
        weak var appCoordinator: AppCoordinator?
        
        init(appCoordinator: AppCoordinator? = nil) {
            self.appCoordinator = appCoordinator
        }
    }
}

// MARK: - ViewModelType
public protocol ViewModelType {
    
}

// MARK: - BaseViewController
class BaseViewController: ViewController {
    private let disposeBag = DisposeBag()
    
    weak var appCoordinator: AppCoordinator?
    
    init(appCoordinator: AppCoordinator? = nil) {
        super.init()
        self.appCoordinator = appCoordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
