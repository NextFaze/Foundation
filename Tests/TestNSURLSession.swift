import PMKFoundation
import OHHTTPStubs
import PromiseKit
import XCTest

class NSURLSessionTests: XCTestCase {
    func test1() {
        let json: NSDictionary = ["key1": "value1", "key2": ["value2A", "value2B"]]

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: nil)
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)
        URLSession.shared.dataTask(with: rq).asDictionary().then { rsp -> Void in
            XCTAssertEqual(json, rsp)
            ex.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func test2() {

        // test that URLDataPromise chains thens
        // this test because I don’t trust the Swift compiler

        let dummy = ("fred" as NSString).data(using: String.Encoding.utf8.rawValue)!

        OHHTTPStubs.stubRequests(passingTest: { $0.url!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(data: dummy, statusCode: 200, headers: [:])
        }

        let ex = expectation(description: "")
        let rq = URLRequest(url: URL(string: "http://example.com")!)

        after(interval: 0.1).then {
            URLSession.shared.dataTask(with: rq)
        }.then { x -> Void in
            XCTAssertEqual(x, dummy)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }
}
