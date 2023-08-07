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
        guard let imageURLString = readerViewModel.getImageURL(at: pageIndex) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if imageURLString.starts(with: "https://cdn") {
                Task {
                    if let image = await self.downloadImage(from: imageURLString) {
                        DispatchQueue.main.async { [weak self] in
                            self?.imageView.image = self?.complexDrawingAndCellShifting(image: image, width: 822, height: 1200)
                        }
                    }
                }
                
            } else {
                self.imageView.kf.setImage(with: URL(string: imageURLString), placeholder: UIImage(systemName: Icons.photoFill))
            }
        }
    }
    private func downloadImage(from urlString: String) async -> UIImage? {
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
