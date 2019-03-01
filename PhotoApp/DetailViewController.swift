//
//  DetailViewController.swift
//  PhotoApp
//
//  Created by Kirill Pahnev on 01/03/2019.
//  Copyright © 2019 Kirill Pahnev. All rights reserved.
//

import UIKit
import Photos

class DetailViewController: UIViewController {
    @IBOutlet weak var albumDetailsLabel: UILabel!
    @IBOutlet weak var randomImageButton: UIButton! {
        didSet {
            randomImageButton.tintColor = #colorLiteral(red: 0.7333333333, green: 0, blue: 0.8666666667, alpha: 1)
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    private let imageManager = PHCachingImageManager()
    
    var album: PHAssetCollection? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.8549019608, blue: 0.7333333333, alpha: 1) // For some reason ipad doesn't respect the color set in AppDelegate
    }
}

// MARK: - MasterViewControllerDelegate

extension DetailViewController: MasterViewControllerDelegate {
    func didSelectAlbum(_ album: PHAssetCollection) {
        if self.album == album { return }
        self.album = album
    }
}

// MARK: - Private

private extension DetailViewController {
    @IBAction func randomImageButtonTapped(_ sender: UIButton) {
        showRandomImage()
    }
    
    func configureView() {
        guard isViewLoaded else { return }
        
        let imageCount = album?.estimatedAssetCount ?? 0
        let imageNoun = imageCount == 1 ? "image" : "images"
        albumDetailsLabel.text = "This album has \(imageCount) \(imageNoun)."
        title = album?.localizedTitle
        
        showRandomImage()
    }
    
    func showRandomImage() {
        guard let asset = randomAssetFrom(album) else { return }
        imageManager.requestImage(for: asset, targetSize: imageView.frame.size, contentMode: .aspectFill, options: nil) { [weak self ] (image, _) in
            guard let self = self,
                let image = image else { return print("Seems that this asset has no image")}
            self.imageView.image = image
        }
    }
    
    func randomAssetFrom(_ album: PHAssetCollection?) -> PHAsset? {
        guard let album = album else { return nil }
        let assets = PHAsset.fetchAssets(in: album, options: nil)
        guard assets.count > 0 else { return nil }
        
        let randomPosition = Int.random(in: 0 ..< assets.count)
        return assets.object(at: randomPosition)
    }
}
