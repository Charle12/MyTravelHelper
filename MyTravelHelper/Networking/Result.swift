//
//  Result.swift
//  MyTravelHelper
//
//  Created by Prabhat Pandey on 19/11/2020.
//  Copyright © 2020 Prabhat Pandey. All rights reserved.

import Foundation

enum Result<T, U> where U: Error  {
    case success(T)
    case failure(U)
}
