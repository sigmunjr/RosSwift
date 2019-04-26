//
//  serviceTests.swift
//  rosswiftTests
//
//  Created by Thomas Gustafsson on 2018-10-24.
//

import XCTest
@testable import RosSwift
@testable import StdMsgs
@testable import BinaryCoder


class serviceTests: XCTestCase {

    static var allTests = [
        ("testCallService",testCallService),
        ("testCallEcho",testCallEcho),
        ("testCallInternalService",testCallInternalService),
        ("testServiceAdvCopy", testServiceAdvCopy),
        ("testServiceAdvMultiple",testServiceAdvMultiple),
        ("testCallSrvMultipleTimes",testCallSrvMultipleTimes)
    ]

    override func setUp() {
    }

    override func tearDown() {
    }

    func srvCallback(req: TestStringString.Request) -> TestStringString.Response? {
        return TestStringString.Response("A")
    }

    func testCallService() {
        let ros = Ros(name: "testCallService")
        let node = ros.createNode()
        guard let serv = node.advertise(service: "/service_adv", srvFunc: srvCallback) else {
            XCTFail()
            return
        }

        var req = TestStringString.Request()
        var res = TestStringString.Response()
        req.data = "case_FLIP"

        XCTAssert(Service.waitForService(ros: ros, serviceName: "/service_adv"))
        if Service.call(node: node, serviceName: "/service_adv", req: req, response: &res) {
            print(res)
        }
        XCTAssert(Service.call(node: node, serviceName: "/service_adv", req: req, response: &res))
        XCTAssertEqual(res.data, "A")

        serv.shutdown()  // Just in case the ARC throws us away
    }

    func testCallEcho() {
        let ros = Ros(name: "testCallEcho")
        let node = ros.createNode()

        var req = TestStringString.Request()
        var res = TestStringString.Response()
        req.data = "case_FLIP"

        if Service.waitForService(ros: ros, serviceName: "/echo", timeout: 10 )  {
            let message = Service.call(node: node, serviceName: "/echo", req: req, response: &res)
            XCTAssert(message)
            if message {
                XCTAssertEqual(res.data,req.data)
            }
        }
    }

    func serviceCallback(req : TestStringString.Request) -> TestStringString.Response? {
        return TestStringString.Response("test")
    }

    func testCallInternalService() {
        let ros = Ros(name: "testCallInternalService")
        let n = ros.createNode()
        var t = TestStringString()

        let srv1 = n.advertise(service: "/test_srv", srvFunc: serviceCallback)
        XCTAssertNotNil(srv1)
        XCTAssert(Service.call(node: n, name: "/test_srv", service: &t))
        XCTAssertEqual(t.response.data, "test")


    }

    func testServiceAdvCopy()  {
        let ros = Ros(name: "testServiceAdvCopy")
        let node = ros.createNode()
        var t = TestStringString()

        do {
            let srv1 = node.advertise(service: "/test_srv_23", srvFunc: serviceCallback)
            sleep(4)
            XCTAssert(Service.call(node: node, name: "/test_srv_23", service: &t))
            do {
                let srv2 = srv1
                do {
                    let srv3 = srv2
                    XCTAssert(srv3 === srv2)
                    t.response.data = ""
                    XCTAssert(Service.call(node: node, name: "/test_srv_23", service: &t))
                    XCTAssertEqual(t.response.data, "test")
                }
                XCTAssert(srv2 === srv1);
                t.response.data = ""
                XCTAssert(Service.call(node: node, name: "/test_srv_23", service: &t))
                XCTAssertEqual(t.response.data, "test")
            }
            t.response.data = ""
            XCTAssert(Service.call(node: node, name: "/test_srv_23", service: &t))
            XCTAssertEqual(t.response.data, "test")
        }
        sleep(1)
        XCTAssertFalse(Service.call(node: node, name: "/test_srv_23", service: &t))

        print("\(node.isOK)")

    }






    func testServiceAdvMultiple()  {
        let ros = Ros(name: "testServiceAdvMultiple")
        let n = ros.createNode()

        let srv = n.advertise(service: "/test_srv_19", srvFunc: serviceCallback)
        let srv2 = n.advertise(service: "/test_srv_19", srvFunc: serviceCallback)
        XCTAssert(srv != nil)
        XCTAssertNil(srv2)

    }



    func testCallSrvMultipleTimes() {
        let ros = Ros(name: "testCallSrvMultipleTimes")
        let node = ros.createNode()
        let serv = node.advertise(service: "/service_adv2", srvFunc: srvCallback)
        XCTAssertNotNil(serv)
        var req = TestStringString.Request()
        var res = TestStringString.Response()
        req.data = "case_FLIP"

//        self.measure {
            for _ in 0..<10 {
                XCTAssert(Service.call(node: node, serviceName: "service_adv2", req: req, response: &res))
            }
//        }
    }



}
