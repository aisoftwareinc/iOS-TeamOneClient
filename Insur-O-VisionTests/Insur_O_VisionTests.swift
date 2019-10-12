//
//  Insur_O_VisionTests.swift
//  Insur-O-VisionTests
//
//  Created by Peter Gosling on 10/5/19.
//  Copyright © 2019 Peter Gosling. All rights reserved.
//

import XCTest
@testable import Insur_O_Vision

class Insur_O_VisionTests: XCTestCase {

  let streamHandler = VideoStreamHandler("rtmp://www.teamone.com", id: "1234567890")
  
  func testNumberAppending() {
    let result = streamHandler.calculateAppendNumber()
    XCTAssert(result == "1234567890")
  }
  
  func testRunning() {
//    streamHandler.zoom(1.0)
//    XCTAssert(streamHandler.rtmpStream.zoomFactor == 1.0)
//    streamHandler.zoom(1.5)
//    XCTAssert(streamHandler.rtmpStream.zoomFactor == 1.5)
//    streamHandler.zoom(2.0)
//    XCTAssert(streamHandler.rtmpStream.zoomFactor == 2.0)
  }
}
