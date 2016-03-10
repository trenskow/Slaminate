//
//  NullAnimation.swift
//  Slaminate
//
//  Created by Kristian Trenskow on 06/03/16.
//  Copyright © 2016 Trenskow.io. All rights reserved.
//

public class NullAnimation: Animation {
    
    public init() {
        super.init(duration: 0.0)
    }
    
    override func commit() {
        complete(true)
    }
    
}