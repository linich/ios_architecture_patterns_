//
//  IconImageServiceTests.swift
//  ActivityListUITests
//
//  Created by Maksim Linich on 9.04.24.
//

import XCTest
import ActivityListUI
import ActivityListDomain

final class IconImageServiceTests: XCTestCase {

    func test_getImage_returnsValidImageInAllCases() {
        let sut = createSUT()
        XCTAssertEqual(sut.getImage(byKind: .airplane).pngData(), imageFromUIBundle(named: "airplane").pngData())
        XCTAssertEqual(sut.getImage(byKind: .american_football).pngData(), imageFromUIBundle(named: "american-football").pngData())
        XCTAssertEqual(sut.getImage(byKind: .baseball).pngData(), imageFromUIBundle(named: "baseball").pngData())
        XCTAssertEqual(sut.getImage(byKind: .fight).pngData(), imageFromUIBundle(named: "fight").pngData())
        XCTAssertEqual(sut.getImage(byKind: .game).pngData(), imageFromUIBundle(named: "game").pngData())
        XCTAssertEqual(sut.getImage(byKind: .gym).pngData(), imageFromUIBundle(named: "gym").pngData())
        XCTAssertEqual(sut.getImage(byKind: .shop).pngData(), imageFromUIBundle(named: "shop").pngData())
        XCTAssertEqual(sut.getImage(byKind: .skiing).pngData(), imageFromUIBundle(named: "skiing").pngData())
        XCTAssertEqual(sut.getImage(byKind: .swimming).pngData(), imageFromUIBundle(named: "swimming").pngData())
        XCTAssertEqual(sut.getImage(byKind: .undefined).pngData(), imageFromUIBundle(named: "undefined").pngData())
        
        for kind in ActivityType.allCases {
            XCTAssertNoThrow({let _ = sut.getImage(byKind: kind)}, "Should return image for \(kind)")
        }
        
    }
    
    // Mark: - hepers
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> (ImageService) {
        let sut = ImageService()
        trackMemoryLeak(sut)
        return (sut)
    }

    fileprivate func imageFromUIBundle(named name: String) -> UIImage {
        let bundle = Bundle(for: ImageService.self)
        return UIImage(named: name, in: bundle, with: nil)!
    }
}
