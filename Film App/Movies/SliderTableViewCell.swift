import UIKit

class SliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sliderContentView: UIView!
    @IBOutlet weak var sliderScrollView: UIScrollView!
    
    private var posterSlides = [UIButton]()
    private var posterImages = ["harrypotter", "starwars", "lordrings"]

    
    override func layoutSubviews() {
        super.layoutSubviews()
        createSlides()
        setupScrollView(with: posterSlides)
    }

    private func setupScrollView(with slides: [UIButton]) {

        sliderScrollView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        sliderScrollView.contentSize = CGSize(width: self.frame.width * CGFloat(slides.count), height: self.frame.height)
        sliderScrollView.isPagingEnabled = true

        for i in 0..<slides.count {
            slides[i].frame = CGRect(x: self.frame.width * CGFloat(i), y: 0, width: self.frame.width, height: self.frame.height)
            sliderScrollView.addSubview(slides[i])
        }
        
    }
    
    private func createSlides() {
        
        for posterName in posterImages {
            let poster = createPosterButton(with: posterName)
            posterSlides.append(poster)
        }
        
    }
    
    private func createPosterButton(with imageName: String) -> UIButton {
        
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let button = UIButton(frame: frame)
        let image = UIImage(named: imageName)
        button.setBackgroundImage(image, for: .normal)
        button.addTarget(self, action: #selector(slideButtonPressed), for: .touchUpInside)
        return button
    }
    
    @objc private func slideButtonPressed() {
        print("Pressed")
    }
    
}
