
import UIKit
import Accelerate
import SDWebImage

extension UIImage {
    static func from(
        color: UIColor, size: CGSize = CGSize(width: 1, height: 1), opaque: Bool = false, scale: CGFloat = 0
    ) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Cannot create image from color \(color)")
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    static func imageDataFrom(url: URL, completion: @escaping (Result<Data>) -> Void) {
        SDWebImageManager.shared.loadImage(
            with: url,
            options: [.scaleDownLargeImages, .queryMemoryData],
            context: [:],
            progress: nil
        ) { _, data, error, _, _, _ in
                DispatchQueue.main.async {
                    if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(error ?? BackendError.unknown))
                    }
                }
            }
    }
    
    static func imageDataFrom(link: String, completion: @escaping (Result<Data>) -> Void) {
        guard let url = URL(string: link) else { return }
        
        imageDataFrom(url: url, completion: completion)
    }
    
    static func downloadedFrom(url: URL, completion: @escaping (Result<UIImage>) -> Void) {
        imageDataFrom(url: url) { result in
            switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    } else {
                        completion(.failure(BackendError.unknown))
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    static func downloadedFrom(link: String, completion: @escaping (Result<UIImage>) -> Void) {
        guard let url = URL(string: link) else { return }
        
        downloadedFrom(url: url, completion: completion)
    }
    
    func transform(withNewColor color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        guard let mask = cgImage else { return nil }
        context.clip(to: rect, mask: mask)
        
        color.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func base64() -> String {
        pngData()!.base64EncodedString(options: .lineLength64Characters)
    }
}

extension UIImage {
    func resizeWith() -> UIImage? {
        let width = CGFloat(300)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }

    func resizeImageUsingVImage(_ newSize: CGSize) -> UIImage? {
        var newSizeAspect: CGSize
        let ratio   = max(newSize.width / size.width, newSize.height / size.height)
        let width   = size.width * ratio
        let height  = size.height * ratio
        newSizeAspect = CGSize(width: width,  height: height)
        
        let cgImage = self.cgImage!
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue), version: 0, decode: nil, renderingIntent: CGColorRenderingIntent.defaultIntent)
        var sourceBuffer = vImage_Buffer()
        defer {
            free(sourceBuffer.data)
        }
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        // create a destination buffer
        //let scale = self.scale
        let destWidth = Int(newSizeAspect.width)
        let destHeight = Int(newSizeAspect.height)
        let bytesPerPixel = self.cgImage!.bitsPerPixel/8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            //destData.deallocate(capacity: destHeight * destBytesPerRow)
            destData.deallocate()
        }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        // create a CGImage from vImage_Buffer
        var destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        guard error == kvImageNoError else { return nil }
        // create a UIImage
        let resizedImage = destCGImage.flatMap { UIImage(cgImage: $0, scale: 0.0, orientation: self.imageOrientation) }
        destCGImage = nil
        return resizedImage
    }
    
    func asyncResizeImageUsingVImage(size: CGSize, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let im = self.resizeImageUsingVImage(size)
            DispatchQueue.main.async {
                completion(im)
            }
        }
    }

    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func fixOrientation() -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        let width  = self.size.width
        let height = self.size.height
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: width, y: height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.rotated(by: 0.5*CGFloat.pi)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: height)
            transform = transform.rotated(by: -0.5*CGFloat.pi)
            
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        default:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        guard let colorSpace = cgImage.colorSpace else {
            return nil
        }
        
        guard let context = CGContext(
            data: nil,
            width: Int(width),
            height: Int(height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
            ) else {
                return nil
        }
        
        context.concatenate(transform);
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        // And now we just create a new UIImage from the drawing context
        guard let newCGImg = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: newCGImg)
    }
}
