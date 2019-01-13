import UIKit

class SliderTableViewCell: UITableViewCell {

    var sliderCollectionView: UICollectionView!
    var collectionViewLayout: UICollectionViewFlowLayout!
    
    private var posterSlides: [(image: String, path: String)] = [
        (image: "harrypotter", path: ""),
        (image: "starwars", path: ""),
        (image: "lordrings", path: "")
    ]
    
    private var timer: Timer?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setSliderCollectionView()
        
        addSwipeRecognizers()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionViewLayout.estimatedItemSize = CGSize(width: sliderCollectionView.frame.width, height: sliderCollectionView.frame.height)
        swipeSlidesOnTimer()
    }
    
    // Private
    
    private func setSliderCollectionView() {
        sliderCollectionView = createCollectionView()
        collectionViewLayout = sliderCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        self.addSubview(sliderCollectionView)
        setCollectionViewConstraints()
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        sliderCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SliderCollectionViewCell")
    }
    
    private func createCollectionView() -> UICollectionView {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }

    func swipeSlidesOnTimer() {
        
        DispatchQueue.global(qos: .background).async {
            self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.showNextSlide), userInfo: nil, repeats: true)
            let runLoop = RunLoop.current
            runLoop.add(self.timer!, forMode: .default)
            runLoop.run()
        }
        
        
    }
    @objc private func showNextSlide() {
        
        DispatchQueue.main.async {
            let cellSize = CGSize(width: self.sliderCollectionView.frame.width, height: self.sliderCollectionView.frame.height)
            let contentOffset = self.sliderCollectionView.contentOffset
            let scrollRect = CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height)
            self.sliderCollectionView.scrollRectToVisible(scrollRect, animated: true)
        }

    }
    
    private func setCollectionViewConstraints() {
        sliderCollectionView.translatesAutoresizingMaskIntoConstraints = false
        sliderCollectionView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        sliderCollectionView.heightAnchor.constraint(equalTo: sliderCollectionView.widthAnchor, multiplier: 10/25).isActive = true
        sliderCollectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sliderCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sliderCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        sliderCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private func addSwipeRecognizers() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(userSwipedSlider))
        swipeRight.numberOfTouchesRequired = 1
        swipeRight.direction = .right
        swipeRight.delegate = self
        self.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(userSwipedSlider))
        swipeLeft.numberOfTouchesRequired = 1
        swipeLeft.direction = .left
        swipeLeft.delegate = self
        self.addGestureRecognizer(swipeLeft)
        
    }
    
    @objc private func userSwipedSlider() {
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }
    }
    
}

extension SliderTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 500
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCollectionViewCell", for: indexPath)
        let index = indexPath.item % posterSlides.count
        let image = UIImage(named: posterSlides[index].image)
        let imageView = UIImageView(image: image)
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cell.addSubview(imageView)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select")
        if let timer = timer, timer.isValid {
            timer.invalidate()
        }

    }
   
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
