//
//  RNBridgeInstanceHolder.swift
//  TusNativeExample
//
//  Created by Daniel Jones on 4/1/22.
//

import Foundation
import React

@objcMembers
final class RNBridgeInstanceHolder : NSObject {

  static let sharedInstance = RNBridgeInstanceHolder()

  var bridge: RCTBridge?

  var rctRootView: RCTRootView?
}
