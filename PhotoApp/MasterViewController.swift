//
//  MasterViewController.swift
//  PhotoApp
//
//  Created by Kirill Pahnev on 01/03/2019.
//  Copyright © 2019 Kirill Pahnev. All rights reserved.
//

import UIKit
import Photos

protocol MasterViewControllerDelegate: class {
    func didSelectAlbum(_ album: PHAssetCollection)
}

class MasterViewController: UITableViewController {

    var delegate: MasterViewControllerDelegate?

    private var albums: PHFetchResult<PHAssetCollection>? {
        didSet {
            tableView.reloadData()

            // select first item on ipads if possible, since it will be showing the details
            guard UITraitCollection().horizontalSizeClass == .regular else { return }
            guard let firstAlbum = albums?.firstObject else { return }
            delegate?.didSelectAlbum(firstAlbum)
            tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.checkPhotosPermissions()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        guard albums == nil else { return }
        checkPhotosPermissions()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let destination = segue.destination as? UINavigationController,
                let detailVC = destination.topViewController as? DetailViewController,
                let album = sender as? PHAssetCollection else { fatalError() }

            detailVC.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            detailVC.navigationItem.leftItemsSupplementBackButton = true

            detailVC.album = album
        }
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let album = albums?[indexPath.row]
        cell.textLabel?.text = album?.localizedTitle
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let album = albums?[indexPath.row] else { fatalError() }
        delegate?.didSelectAlbum(album)
        performSegue(withIdentifier: "showDetail", sender: album)
    }
}

private extension MasterViewController {
    func checkPhotosPermissions() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            requestPhotoLibraryAccess()
        case .authorized:
            fetchAlbums()
        case .denied:
            showPermissionAlert()
        case .restricted:
            print("Nothing we can do here")
        }

    }
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                self.fetchAlbums()
            case .denied:
                self.showPermissionAlert()
            case .notDetermined, .restricted:
                print("Nothing we can do here")
            }
        }
    }

    func showPermissionAlert() {
        let alert = UIAlertController(title: "No permissions to photos",
                                      message: "This app needs permissions to your photos in order to work correctly",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Change permission", style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { fatalError() }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Not now", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func fetchAlbums() {
        albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
    }
}
