//
//  Macros.h
//  Project
//
//  Created by Mike on 2019/1/13.
//  Copyright © 2019 CDJay. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height-812)?YES:NO)
#define Height (IS_IPHONEX ? ([[UIScreen mainScreen] bounds].size.height-34):([[UIScreen mainScreen] bounds].size.height))

#endif /* Macros_h */
