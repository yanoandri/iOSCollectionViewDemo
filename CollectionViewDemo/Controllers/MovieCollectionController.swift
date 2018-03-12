//
//  ViewController.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 07/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit
import Kingfisher
import UIScrollView_InfiniteScroll

class MovieCollectionController: UIViewController {
    @IBOutlet weak var label_DropFavouritesMovie: UILabel!
    @IBOutlet weak var view_ViewDropImage: UIView!
    @IBOutlet weak var constraint_viewConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView_movieCollection: UICollectionView!
    var movieList : [Movie] = []
    var page : Int = 1
    weak var refreshControl : UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionView_movieCollection.register(UINib.init(nibName: "MovieViewCell", bundle: nil), forCellWithReuseIdentifier: "cell_MovieCell")
        
        collectionView_movieCollection.register(UINib.init(nibName: "MovieHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "reusableView_MovieHeaderId")
        
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(MovieCollectionController.refresh(_:)), for: UIControlEvents.valueChanged)
        collectionView_movieCollection.addSubview(view)
        
        self.label_DropFavouritesMovie.isHidden = true;
        self.refreshControl = view
        
        if #available(iOS 11.0, *){
            collectionView_movieCollection.dragInteractionEnabled = true
            collectionView_movieCollection.dragDelegate = self
            
            let config = UIPasteConfiguration(forAccepting: NSString.self)
            //let config = UIPasteConfiguration(forAccepting: UIImage.self)
            view_ViewDropImage.pasteConfiguration = config
            
            let drop = UIDropInteraction(delegate: self)
            view_ViewDropImage.addInteraction(drop)
            
        }else{
            //fall back on earlier version
        }
        
        
        collectionView_movieCollection.addInfiniteScroll(handler: {
            (collectionView_movieCollection) in
            self.loadMovies(page: self.page + 1)
        })
        
        loadMovies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMovies(page: Int = 1){
        MoviePosterHelper.shared.loadMovie(page: page){
            (response, error) in
            self.collectionView_movieCollection.finishInfiniteScroll()
            self.refreshControl?.endRefreshing()
            if let response = response {
                self.page = response.page
                if page == 1 {
                        self.movieList = response.results
                }else{
                    self.movieList = self.movieList + response.results
                }
                self.collectionView_movieCollection.reloadData()
            }
        }
//        if let url = Bundle.main.url(forResource: "Movies", withExtension: "json"){
//            do{
//                let data = try Data.init(contentsOf: url)
//                //let response = try JSONDecoder().decode(MoviesResponse.self, from: data)
//                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
//                let response = MoviesResponse(data: json)
//
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                appDelegate.saveContext()
//
//                movieList = response.results
//                collectionView_movieCollection.reloadData()
//            }catch{
//                print(error.localizedDescription)
//            }
//      }
        
    }
    
    @objc func refresh(_ sender: Any){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                self.refreshControl?.endRefreshing()
                self.loadMovies(page: self.page)
        })
        self.collectionView_movieCollection.reloadData()
    }
}
//MARK: - UIDropInteractionDelegate
@available(iOS 11.0, *)
extension MovieCollectionController : UIDropInteractionDelegate{
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: UIDropOperation.copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        for item in session.items{
            item.itemProvider.loadObject(ofClass: NSString.self, completionHandler: {
                (object, error) in
                if let object = object as? NSString{
                    let movieId = object.integerValue
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        let context = appDelegate.persistentContainer.viewContext
                        
                        if let movie = Movie.movie(with: movieId, in: context){
                            movie.favorited = true
                            appDelegate.saveContext()
                            
                            NotificationCenter.default.post(name: favouritesMovie, object: nil)
                            
                        }
                    }
                }
//                if let image = object as? UIImage{
//                    DispatchQueue.main.async {
//                        self.imageView_DropMovieFav.image = image
//                    }
//                }
            })
        }
    }
}
//MARK: - UICollectionViewDragDelegate
@available(iOS 11.0, *)
extension MovieCollectionController : UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        
        constraint_viewConstraint.constant = 128
        self.label_DropFavouritesMovie.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        constraint_viewConstraint.constant = 0
        self.label_DropFavouritesMovie.isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let movie = movieList[indexPath.item]
        let provider = NSItemProvider(object: NSString(string: "\(movie.movieId)"))
        let item = UIDragItem(itemProvider: provider)
        
        return [item]
//        if let cell = collectionView_movieCollection.cellForItem(at: indexPath) as? MovieViewCell{
//            if let image = cell.imageview_MovieImage.image{
//                let provider = NSItemProvider(object: image)
//                let item = UIDragItem(itemProvider: provider)
//
//                return [item]
//            }
//        }
//        return []
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {

        let movie = movieList[indexPath.item]
        let provider = NSItemProvider(object: NSString(string: "\(movie.movieId)"))
        let item = UIDragItem(itemProvider: provider)
        
        return [item]
        
//        if let cell = collectionView_movieCollection.cellForItem(at: indexPath) as? MovieViewCell{
//            if let image = cell.imageview_MovieImage.image{
//                let provider = NSItemProvider(object: image)
//                let item = UIDragItem(itemProvider: provider)
//
//                return [item]
//            }
//        }
    }
}

extension MovieCollectionController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView_movieCollection.dequeueReusableCell(withReuseIdentifier: "cell_MovieCell", for: indexPath) as! MovieViewCell
        let tag = cell.tag + 1
        cell.tag = tag
        
        let movie = movieList[indexPath.item]
        cell.label_titleLabel.text = movie.title
        cell.label_subtitleLabel.text = movie.releaseDate?.string(format: "dd MMM yyyy")
        
        cell.imageview_MovieImage.image = nil
        if let posterPath = movie.posterPath{
            cell.imageview_MovieImage.kf.setImage(with: URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
        }
//        if let posterPath = movie.posterPath{
//            MoviePosterHelper.shared.downloadImage(with: "https://image.tmdb.org/t/p/original\(posterPath)",
//                completion: { (image, error) in
//                    if cell.tag == tag{
//                        cell.imageview_MovieImage.image = image
//                    }
//            })
//        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView_movieCollection.frame.width - 60)/2
        //print(width)
        let height = width * 5 / 4
        //print(height)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 64, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView_movieCollection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "reusableView_MovieHeaderId", for: indexPath) as! MovieHeaderView
        
        view.label_titleLabel.text = "Movie Of"
        view.label_subTitleLabel.text = "2018"
        
        return view
    }
}

