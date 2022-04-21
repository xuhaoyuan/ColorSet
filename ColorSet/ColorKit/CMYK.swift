//
//  CMYK.swift
//  ColorKit
//
//  Created by Boris Emorine on 6/20/20.
//  Copyright © 2020 BorisEmorine. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// The cyan (C) channel of the CMYK color space.
    public var _cyan: CGFloat {
        return (1 - _red - key) / (1 - key)
    }
    
    /// The magenta (M) channel of the CMYK color space.
    public var _magenta: CGFloat {
        return (1 - _green - key) / (1 - key)
    }
    
    /// The yellow (Y) channel of the CMYK color space.
    public var _yellow: CGFloat {
        return (1 - _blue - key) / (1 - key)
    }
    
    /// The key (black) (K) channel of the CMYK color space.
    public var key: CGFloat {
        return 1 - max(_red, _green, _blue)
    }
    
}
