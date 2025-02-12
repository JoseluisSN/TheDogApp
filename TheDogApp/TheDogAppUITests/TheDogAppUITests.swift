//
//  TheDogAppUITests.swift
//  TheDogAppUITests
//
//  Created by Joseluis SN on 7/02/25.
//

import XCTest

final class TheDogAppUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
        app = nil
    }
    
    func testTitleIsVisible() {
        let title = app.staticTexts["dogBreedsTitle"]
        XCTAssertTrue(title.exists, "The title '🐶 Dog Breeds' should be visible on the screen.")
    }
    
    func testSearchDog() {
        let searchField = app.textFields["dogSearchField"]
        XCTAssertTrue(searchField.exists, "The search field should be visible.")
        
        searchField.tap()
        searchField.typeText("Retriever")
        
        let goldenRetriever = app.staticTexts["dogName_Golden Retriever"]
        XCTAssertTrue(goldenRetriever.waitForExistence(timeout: 5), "Golden Retriever should appear in the search results.")
    }
    
    func testLazyVStackLoadsMoreDogs() {
        let firstDog = app.staticTexts["dogName_Golden Retriever"]
        XCTAssertTrue(firstDog.exists, "The first dog (Golden Retriever) should be visible.")
        
        app.swipeUp()
        
        let lastDog = app.staticTexts["dogName_Labrador Retriever"]
        XCTAssertTrue(lastDog.waitForExistence(timeout: 5), "The last dog (Labrador Retriever) should appear after scrolling.")
    }
}
