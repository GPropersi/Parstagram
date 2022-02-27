//
//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit
import AlamofireImage

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postedAt: UILabel!
    
    var post: Post! {
        didSet {
            captionLabel.attributedText = post.getAttributedCaption()
            photoView.af.setImage(withURL: post.postImageURL!)
            postedAt.text = post.getTimeSincePosted()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
