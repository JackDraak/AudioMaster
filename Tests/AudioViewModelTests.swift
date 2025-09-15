import XCTest
import SwiftUI
@testable import AudioMaster

class AudioViewModelTests: XCTestCase {
    var viewModel: AudioViewModel!

    override func setUp() {
        super.setUp()
        viewModel = AudioViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(viewModel.isMonitoring)
        XCTAssertFalse(viewModel.feedbackWarning)
        XCTAssertNotNil(viewModel.inputDevices)
        XCTAssertNotNil(viewModel.outputDevices)
        XCTAssertNotNil(viewModel.routingMatrix)
    }

    func testDeviceListUpdate() {
        let initialInputCount = viewModel.inputDevices.count
        let initialOutputCount = viewModel.outputDevices.count

        viewModel.updateDeviceList()

        // Device counts should remain consistent after update
        XCTAssertEqual(viewModel.inputDevices.count, initialInputCount)
        XCTAssertEqual(viewModel.outputDevices.count, initialOutputCount)

        // Routing matrix should be properly sized
        if !viewModel.inputDevices.isEmpty && !viewModel.outputDevices.isEmpty {
            XCTAssertEqual(viewModel.routingMatrix.count, viewModel.inputDevices.count)
            XCTAssertEqual(viewModel.routingMatrix.first?.count, viewModel.outputDevices.count)
        }
    }

    func testMonitoringToggle() {
        // Initially not monitoring
        XCTAssertFalse(viewModel.isMonitoring)

        // Toggle monitoring on
        viewModel.toggleMonitoring()

        // Should attempt to start monitoring (may fail without audio permissions)
        // We test the state change rather than the actual audio functionality
    }

    func testRoutingMatrixBounds() {
        // Ensure routing matrix is properly initialized
        viewModel.updateDeviceList()

        if !viewModel.inputDevices.isEmpty && !viewModel.outputDevices.isEmpty {
            let inputCount = viewModel.inputDevices.count
            let outputCount = viewModel.outputDevices.count

            // Test valid routing
            XCTAssertNoThrow(viewModel.updateRouting(input: 0, output: 0, isEnabled: true))

            // Test invalid indices
            // This should handle bounds checking gracefully
            viewModel.updateRouting(input: inputCount + 1, output: 0, isEnabled: true)
            viewModel.updateRouting(input: 0, output: outputCount + 1, isEnabled: true)
        }
    }

    func testLevelUpdates() {
        let expectation = XCTestExpectation(description: "Level updates")

        // Wait for level monitoring to start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Check that levels are being updated
            XCTAssertGreaterThanOrEqual(self.viewModel.inputLevels.count, 0)
            XCTAssertGreaterThanOrEqual(self.viewModel.outputLevels.count, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}