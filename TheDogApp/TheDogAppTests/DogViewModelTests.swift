//
//  DogViewModelTests.swift
//  TheDogAppTests
//
//  Created by Joseluis SN on 10/02/25.
//

import XCTest
import Combine
@testable import TheDogApp

final class DogViewModelTests: XCTestCase {
    private var viewModel: DogViewModel?
    private var mockService: MockDogService?
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        mockService = MockDogService()
        viewModel = DogViewModel(service: mockService!)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        cancellables.removeAll()
    }

    func testFetchDogsSuccess() throws {
        guard let viewModel = viewModel else {
            XCTFail("viewModel should not be nil")
            return
        }

        let expectation = XCTestExpectation(description: "Fetch dogs successfully")

        viewModel.$dogs
            .dropFirst()
            .sink { dogs in
                XCTAssertEqual(dogs.count, 2)
                XCTAssertEqual(dogs[0].name, "Golden Retriever")
                XCTAssertEqual(dogs[1].name, "Labrador Retriever")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchDogs()
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchDogsFailure() throws {
        guard let viewModel = viewModel else {
            XCTFail("viewModel should not be nil")
            return
        }

        mockService?.shouldReturnError = true
        let expectation = XCTestExpectation(description: "Handle fetch dogs failure")

        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                XCTAssertTrue(errorMessage!.contains("Failed to fetch dogs"))
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchDogs()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testIsLoadingState() throws {
        guard let viewModel = viewModel else {
            XCTFail("viewModel should not be nil")
            return
        }

        let expectation = XCTestExpectation(description: "isLoading state changes correctly")

        var loadingStates: [Bool] = []

        viewModel.$isLoading
            .dropFirst()  // Skip the initial state
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 2 {
                    XCTAssertEqual(loadingStates, [true, false], "isLoading should be true during fetch and false afterward")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchDogs()
    }

    func testFetchDogsEmptyResponse() throws {
        guard let viewModel = viewModel else {
            XCTFail("viewModel should not be nil")
            return
        }
        
        mockService?.responseDogs = []
        
        let expectation = XCTestExpectation(description: "Handle empty response correctly")
        
        viewModel.$dogs
            .dropFirst()
            .sink { dogs in
                XCTAssertEqual(dogs.count, 0, "Dogs array should be empty when the response has no data")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchDogs()
        wait(for: [expectation], timeout: 1.0)
    }
}
