//
//  UIImage+SD.swift
//  Mems
//
//  Created by Evgeny Ivanov on 16.12.2019.
//  Copyright © 2019 Eugene Ivanov. All rights reserved.
//

import UIKit
import SDWebImage

extension UIImageView {
    func setImageWithSD(
        from string: String,
        placeholder: UIImage? = .from(color: Style.Color.lightGray)
    ) {
		image = .from(color: Style.Color.lightGray)
        guard let url = URL(string: NetworkService.baseUrl + string) else { return }
        
        sd_setImage(
			with: url,
            placeholderImage: placeholder,
            options: [.scaleDownLargeImages]
        ) { [weak self] image, error, cacheType, _ in
            guard let self = self else { return }

            self.image = image
        }
	}

    func setAvatarWithSD(
        from string: String,
        placeholder: UIImage? = .from(color: Style.Color.lightGray)
    ) {
        image = .from(color: Style.Color.lightGray)
        guard let url = URL(string: string) else { return }

        sd_setImage(
            with: url,
            placeholderImage: placeholder,
            options: [.scaleDownLargeImages]
        ) { [weak self] image, error, cacheType, _ in
            guard let self = self else { return }

            self.image = image
        }
    }
}
