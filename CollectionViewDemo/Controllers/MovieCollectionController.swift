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
        self.refreshControl = view
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
        self.page = 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                self.refreshControl?.endRefreshing()
                self.loadMovies(page: self.page)
        })
        self.collectionView_movieCollection.reloadData()
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

