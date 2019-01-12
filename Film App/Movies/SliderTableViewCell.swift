import UIKit

class SliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sliderContentView: UIView!
    @IBOutlet weak var sliderScrollView: UIScrollView!
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    
    private var posterSlides = [UIButton]()
    private var posterImages = ["harrypotter", "starwars", "lordrings"]
    private var timer: Timer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sliderCollectionView.contentInsetAdjustmentBehavior = .never
        sliderCollectionView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        collectionViewLayout.estimatedItemSize = CGSize(width: self.frame.width, height: sliderCollectionView.frame.height)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        sliderCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SliderCollectionViewCell")
    }

//    @objc private func slideButtonPressed() {
//        print("Pressed")
//
//    }
    
   @objc private func showNextSlide() {
        print("Tik-tak")
   
    }
    
    func swipeSlidesOnTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showNextSlide), userInfo: nil, repeats: true)
        
        // TODO: Timer.invalidate()
    }
    
}

extension SliderTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posterImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCollectionViewCell", for: indexPath)
        let image = UIImage(named: posterImages[indexPath.item])
        let imageView = UIImageView(image: image)
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cell.addSubview(imageView)
        return cell
        
    }
    
    
}
