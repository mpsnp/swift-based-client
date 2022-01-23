//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 26/11/2021.
//

import Foundation

extension Task where Success == Never, Failure == Never {
  static func sleep(seconds: TimeInterval) async throws {
    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
  }
}
