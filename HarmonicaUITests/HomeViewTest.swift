import XCTest

final class HomeViewUITest: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        sleep(3)
    }
    
    func test_HomeView_DisplaysMainElements() {
        XCTAssertTrue(app.staticTexts["welcomeText"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["cartButton"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.textFields.element.waitForExistence(timeout: 10))
    }
    
    func test_HomeView_SearchWorks() {
        let searchField = app.textFields.firstMatch
        
        guard searchField.waitForExistence(timeout: 10) else {
            XCTFail("Campo de busca não encontrado")
            return
        }
        
        searchField.tap()
        searchField.typeText("Guitarra")
        
        XCTAssertTrue(searchField.exists)
    }
    
    func test_HomeView_ProductsLoad() {
        let productGrid = app.otherElements["productGrid"]
        XCTAssertTrue(productGrid.waitForExistence(timeout: 15))
    }
}
