//
//  NameRemappingWithNamespace.swift
//  rosswiftTests
//
//  Created by Thomas Gustafsson on 2018-10-31.
//

import XCTest
@testable import RosSwift

class NameRemappingWithNamespace: XCTestCase {

    static var allTests = [
        ("testParameterRemapping",testParameterRemapping)
    ]


    override func setUp() {
        var args = CommandLine.arguments + ["/a/test_full:=/b/test_full",
                                            "/a/test_local:=test_local2",
                                            "test_relative:=/b/test_relative"]
        Ros.ThisNode.instance.namespace = "a"
        _ = Ros.initialize(argv: &args, name: "name_remapped_with_ns")
        Ros.Param.set(key: "/b/test_full", value: "asdf")
        Ros.Param.set(key: "/a/test_local2", value: "asdf")
        Ros.Param.set(key: "/b/test_relative", value: "asdf")
    }

    override func tearDown() {
        Ros.ThisNode.instance.namespace = ""

        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParameterRemapping() {



        var param = ""

        XCTAssertEqual(Ros.Names.resolve(name: "test_full"), "/b/test_full")
        XCTAssert(Ros.Param.get("test_full", &param))
        XCTAssertEqual(Ros.Names.resolve(name: "/a/test_full"), "/b/test_full")
        XCTAssert(Ros.Param.get("/a/test_full", &param))

        XCTAssertEqual(Ros.Names.resolve(name: "test_local"), "/a/test_local2")
        XCTAssert(Ros.Param.get("test_local", &param))
        XCTAssertEqual(Ros.Names.resolve(name: "/a/test_local"), "/a/test_local2")
        XCTAssert(Ros.Param.get("/a/test_local", &param))

        XCTAssertEqual(Ros.Names.resolve(name: "test_relative"), "/b/test_relative")
        XCTAssert(Ros.Param.get("test_relative", &param))
        XCTAssertEqual(Ros.Names.resolve(name: "/a/test_relative"), "/b/test_relative")
        XCTAssert(Ros.Param.get("/a/test_relative", &param))

        XCTAssertNil(Ros.Names.resolve(name: "1244"))
        XCTAssertEqual(Ros.Names.resolve(name: "åäö"), "/a/åäö")
    }

    func testNodeNameRemapping() {
        let node_name = Ros.ThisNode.getName()
        XCTAssertEqual(node_name, "/a/name_remapped_with_ns")
    }

}
