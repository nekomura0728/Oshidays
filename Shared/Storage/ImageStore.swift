import Foundation
import UIKit

enum ImageStore {
    private static func imagesDir() -> URL {
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupId) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return container.appendingPathComponent(AppConstants.imagesDirectory, isDirectory: true)
    }

    static func save(image: UIImage, id: String) {
        let dir = imagesDir()
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let url = dir.appendingPathComponent("\(id).jpg")
            // Keep widget-friendly file sizes: Widget archival rejects images with too large pixel area.
            // Use max longer edge 1536 to stay under the archive threshold.
            let resized = image.resized(maxDimension: 1536)
            if let data = resized.jpegData(compressionQuality: 0.9) {
                try data.write(to: url, options: .atomic)
            }
        } catch {
            print("[ImageStore] save error: \(error)")
        }
    }

    static func load(id: String) -> UIImage? {
        let url = imagesDir().appendingPathComponent("\(id).jpg")
        return UIImage(contentsOfFile: url.path)
    }

    static func delete(id: String) {
        let url = imagesDir().appendingPathComponent("\(id).jpg")
        try? FileManager.default.removeItem(at: url)
    }
}

private extension UIImage {
    func resized(maxDimension: CGFloat) -> UIImage {
        let longer = Swift.max(size.width, size.height)
        guard longer > maxDimension else { return self }
        let ratio = maxDimension / longer
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
