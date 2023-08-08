//
//  ReaderPageViewController.swift
//  tachiyomi
//
//  Created by Grace, Mu-Hui Yu on 8/4/23.
//

import UIKit
import RxRelay
import RxSwift
import Kingfisher

class ReaderPageViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    
    private let readerViewModel: ReaderViewModel
    let pageIndex: Int
    
    init(readerViewModel: ReaderViewModel, pageIndex: Int) {
        self.readerViewModel = readerViewModel
        self.pageIndex = pageIndex
    }

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        
        readerViewModel
            .pages
            .asObservable()
            .subscribe { [weak self] _ in
                self?.reconfigureImage()
            }
            .disposed(by: disposeBag)
    }
}


// MARK: - View Config
extension ReaderPageViewController {
    private func configureViews() {
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3

        view.addSubview(scrollView)
        view.backgroundColor = .clear
        
        reconfigureImage()
    }
    private func configureConstraints() {
        imageView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(scrollView)
        }
        scrollView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func reconfigureImage() {
        guard let page = readerViewModel.getPage(at: pageIndex), let imageURLString = page.imageURL else { return }
        guard let urlScheme = imageURLString.getURLScheme() else { return }
        
        switch urlScheme {
        case .local:
            self.storeImage(from: imageURLString)
        case .remote:
            if imageURLString.starts(with: "https://cdn") {
                // TODO: - Change to proper prefix
                fetchEncodedImage(for: page, from: imageURLString)
            } else {
                if let modifier = page.modifier {
                    fetchImageWithAuth(for: page, from: imageURLString, modifier)
                } else {
                    fetchImage(from: imageURLString)
                }
            }
        case .unknown:
            return
        }
    }
    private func storeImage(from url: String) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(contentsOfFile: url) {
                self?.imageView.image = image
            }
        }
    }
    private func fetchEncodedImage(for page: ChapterPage, from url: String) {
        let placeholder = UIImage(systemName: Icons.photoFill)
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = placeholder
            guard let width = page.width, let height = page.height else { return }
            Task {
                if let image = await self?.downloadEncodedImage(from: url) {
                    DispatchQueue.main.async { [weak self] in
                        self?.imageView.image = self?.complexDrawingAndCellShifting(image: image, width: width, height: height)
                    }
                }
            }
        }
    }
    private func fetchImageWithAuth(for page: ChapterPage, from url: String, _ modifier: AnyModifier) {
        // TODO: - 403...
        let placeholder = UIImage(systemName: Icons.photoFill)
        DispatchQueue.main.async { [weak self] in
            self?.imageView.kf.setImage(with: URL(string: url), placeholder: placeholder, options: [.requestModifier(modifier)])
        }
    }
    private func fetchImage(from url: String) {
        let placeholder = UIImage(systemName: Icons.photoFill)
        DispatchQueue.main.async { [weak self] in
            self?.imageView.kf.setImage(with: URL(string: url), placeholder: placeholder)
        }
    }
    private func downloadEncodedImage(from urlString: String) async -> UIImage? {
        do {
            guard let url = URL(string: urlString) else { return nil }
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error downloading image: \(error)")
            return nil
        }
    }
}

extension ReaderPageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension ReaderPageViewController {
    private func complexDrawingAndCellShifting(image: UIImage, width: CGFloat, height: CGFloat, divideNum: CGFloat = 4, multiple: CGFloat = 8) -> UIImage? {
        
        guard let data = image.pngData() else { return nil }
        
        let cWidth = (floor(width / (divideNum * multiple)) * multiple)
        let cHeight = (floor(height / (divideNum * multiple)) * multiple)
        
        // Create a new image context
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        for e in 0..<Int(divideNum * divideNum) {
            let x = CGFloat((e % Int(divideNum))) * cWidth
            let y = floor(CGFloat(e) / divideNum) * cHeight
            
            // The source cell in the original image
            let cellSrc = CGRect(x: x, y: y, width: cWidth, height: cHeight)
            
            // Calcualte the destination cell's position
            let row = floor(CGFloat(e) / divideNum)
            let dstE = CGFloat(e % Int(divideNum)) * divideNum + row
            let dstX = dstE.truncatingRemainder(dividingBy: divideNum) * cWidth
            let dstY = floor(dstE / divideNum) * cHeight
            let cellDst = CGRect(x: dstX, y: dstY, width: cWidth, height: cHeight)
            
            if let subImageRef = image.cgImage?.cropping(to: cellSrc) {
                let subImage = UIImage(cgImage: subImageRef)
                context.clear(cellDst)
                subImage.draw(in: cellDst)
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        print(image, newImage)
        UIGraphicsEndImageContext()

        return newImage
    }
}
