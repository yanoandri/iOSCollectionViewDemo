//
//  MovieFavoritesViewController.swift
//  CollectionViewDemo
//
//  Created by Developer 1 on 09/03/18.
//  Copyright © 2018 DyCode. All rights reserved.
//

import UIKit
let favouritesMovie = NSNotification.Name.init("MyFavouritesMovieNotification")
class MovieFavoritesViewController: UIViewController {
    @IBOutlet weak var collectionView_FavoritesMovie: UICollectionView!
    var favMovieList : [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView_FavoritesMovie.register(UINib.init(nibName: "MovieViewCell", bundle: nil), forCellWithReuseIdentifier: "cell_MovieCell")
        
        collectionView_FavoritesMovie.register(UINib.init(nibName: "MovieHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "reusableView_MovieHeaderId")
        
        NotificationCenter.default.addObserver(self, selector: #selector(MovieFavoritesViewController.refresh(_:)), name:favouritesMovie , object: nil)
        // Do any additional setup after loading the view.
        loadFavouritesMovie()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh(_ sender: Notification){
        loadFavouritesMovie()
        self.collectionView_FavoritesMovie.reloadData()
    }
    
    
    func loadMovies(page: Int = 1){
        MoviePosterHelper.shared.loadMovie(page: page){
            (response, error) in
            //self.collectionView_FavoritesMovie.finishInfiniteScroll()
            //self.refreshControl?.endRefreshing()
            if let response = response {
                //self.page = response.page
                if page == 1 {
                    self.favMovieList = response.results
                }else{
                    self.favMovieList = self.favMovieList + response.results
                }
                self.collectionView_FavoritesMovie.reloadData()
            }
        }
    }
    
    func loadFavouritesMovie(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        if let movie = Movie.favouritedMovies(in: context){
            self.favMovieList = movie
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

//MARK - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MovieFavoritesViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favMovieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView_FavoritesMovie.dequeueReusableCell(withReuseIdentifier: "cell_MovieCell", for: indexPath) as! MovieViewCell
        let tag = cell.tag + 1
        cell.tag = tag
        
        let movie = favMovieList[indexPath.item]
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
        
        let width = (collectionView_FavoritesMovie.frame.width - 60)/2
        //print(width)
        let height = width * 5 / 4
        //print(height)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 64, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView_FavoritesMovie.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "reusableView_MovieHeaderId", for: indexPath) as! MovieHeaderView
        
        view.label_titleLabel.text = "Favorites Movie Of"
        view.label_subTitleLabel.text = "2018"
        
        return view
    }
}
