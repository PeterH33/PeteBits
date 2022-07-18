# PeteBits

This package is comprised of a bunch of simple little fixes and wrappers for functionality that just hasn't been made nice in swiftUI yet that I like to reuse in projects.

*Note* this is very much a work in progress as I try to figure out how to get packages to play nice. There are many bugs and errors, This would be version 0.0.4, I also need to learn how to properly set version numbers


## File Manager Extension Encode/Decode
The file manager extension allows for quick easy encoding and decoding of JSON files

Encoding ex:
        `FileManager.default.encode(yourData, toFile: "yourFileName")`
        
Decoding ex:
        `if let decodedData: dataType = FileManager.default.decode("yourFileName")`
        
Also provides the `documentsDirectory` as a constant or as a returning function. They are basically the same thing, I just haven't decided which to move forward with or if there is a reason to prefer one over the other.


## Haptics
*Note* In a pretty rough state right now and I do not like how complicated adding new haptics in is. I am working on a system to make the creation of haptics easier, store them in a json or something and make them available to people.

The point of this class is to make the CoreHaptics system a bit easier to implement in a swiftUI project.

 Usage:
 1. Drop this file into a project.
 2. In the view or controller etc. you want to use haptics create an instance of the HapticManager class
 3. use `yourClassInstance?.playSlice` to play the Slice haptic as defined below, use autocomplete to explore other samples
 4. if you want to use an alternate code when haptics is not available, `yourClassInstance?.playSlice ?? { what you want to do without haptics }()`
 5. Define new haptic patterns following the pattern in the end of the Haptics file.


## ViewModifiers
*NOTE* Currently untested, just getting this in here before going to the bookstore.

    Text Field Clear Button -
    This modifier can be used to make a clear field button that appears when a bound field state has some value in it. 
                    .textFieldClearButton(text: $binding)
