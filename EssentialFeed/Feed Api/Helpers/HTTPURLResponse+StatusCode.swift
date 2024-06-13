//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by macbook abdul on 13/06/2024.
//

import Foundation

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
