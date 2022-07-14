//
//  haptics.swift
//
//  Created by Peter Hartnett on 6/30/22.
//  Concepts and code parts from Andrew Tetlaw at https://www.raywenderlich.com/10608020-getting-started-with-core-haptics
//  and from Paul Hudson at https://www.hackingwithswift.com/example-code/core-haptics/how-to-play-custom-vibrations-using-core-haptics

//The point of this class is to make the CoreHaptics system a bit easier to implement in a swiftUI project.
// Usage:
// 1- Drop this file into a project.
// 2- The view or controller etc. you want to use haptics create an instance of this class
// 3- use yourClassInstance?.playSlice to play the Slice haptic as defined below
// 4- if you want to use an alternate code when haptics is not available, follow #3 with ?? { what you want to do without haptics }()
// 5- Define new haptic patterns using the format below in the HapticManager extensions

// I am sure there is a better way to write all of the above let me know if it is hard to understand or if there are other issues that arise

//TODO: Extend the code further to allow for encoding and decoding patterns to send to other people, or to save in the case of a system that would give a visual system for creating haptics
//TODO: Create a visual haptics creator program to accompany this format.
//Something with a GUI that covers the possible variables, lets you play test the haptic, and then lets you save out the file for use in a program.
//The HapticManager class would then need a way to load the encoded data for use in a program... perhaps the file could simply be in the extension format below
import Foundation
import CoreHaptics

@available(iOS 13.0, *)
public class HapticManager {
    //This pattern is a combination of those presented by Andrew Tetlaw and Paul Hudson, picking things that make more sense logically and can help to simplify and reduce the number of complications and further optional questions in the code.
    let hapticEngine: CHHapticEngine
    
    //should be able to check if haptics manager is nil to verify the use of haptics with this method. Using init? and returning nil for init allows for a simplified call to haptic functions elsewhere in the program
    public init?() {
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("haptics not supported on device")
            return nil
        }
        
        //here we are testing the creation of an engine and also whether it can actually start.
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine.start()
        } catch {
            print("Haptic engine Creation Error: \(error.localizedDescription)")
            return nil
        }
        
        // The engine stopped; print out why
        // This will happen shortly after every use of the haptic engine, it saves power by not having the haptic engine running constantly and is an interesting note. Whatever is in this closure will run often, I am not sure of a purpose besides an educational one.
        hapticEngine.stoppedHandler = { reason in
            print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt: print("Audio session interrupt")
            case .applicationSuspended: print("Application suspended")
            case .idleTimeout: print("Idle timeout")
            case .systemError: print("System error")
            case .notifyWhenFinished: print("Notify when finiished")
            case .engineDestroyed: print("Engine Destroyed")
            case .gameControllerDisconnect: print("Game Controller Disconnected")
            @unknown default: print("Unknown error")
            }
        }
        
        // If something goes wrong, attempt to restart the engine immediately
        // I am not sure how to force test this code, it is currently untested.
        hapticEngine.resetHandler = { [weak self] in
            print("The engine reset")
            do {
                try self?.hapticEngine.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
        //NOTE: auto shutdown seems to be somewhere in the 2-3 minute range, have not tested with timers enough.
        hapticEngine.isAutoShutdownEnabled = true
    }
    
    //TODO: The two playHaptic functions might be better turned into a bool in the hapticManager init, set it to do one or the other for individual programs
    //Use this for long stretches of haptic interactions, or when you want to pattern to start more quickly and consistently
    public func playHaptic(_ pattern : CHHapticPattern){
    do {
        try hapticEngine.start()
        let player = try hapticEngine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    } catch {
        print("Failed to play Haptic: \(error)")
    }
}
    
    //Use this for intermittent short haptics that do not need to be perfectly snappy
    public func playShortHaptic(_ pattern : CHHapticPattern){
        do {
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
                return .stopEngine
            }
        } catch {
            print("Failed to play Haptic: \(error)")
        }
    }
    
    
}

//Random dice
//WIP: This is currently just the second half of boomSparkle, need to play with things, will make an interface to play with things next
@available(iOS 13.0, *)
extension HapticManager{
    public func playRandomDice(){
        if let pattern = try? randomDicePattern() {
            playHaptic(pattern)
        }
    }
    
    private func randomDicePattern() throws -> CHHapticPattern{
        var events = [CHHapticEvent]()
        let curves = [CHHapticParameterCurve]()

        for _ in 1...16 {
            // make some sparkles
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: TimeInterval.random(in: 0.1...1))
            events.append(event)
        }
        
        return try CHHapticPattern(events: events, parameterCurves: curves)
    }
}

//Boom sparkle
@available(iOS 13.0, *)
extension HapticManager{
    public func playBoomSparkle(){
        if let pattern = try? boomSparklePattern() {
            playHaptic(pattern)
        }
    }
    
    private func boomSparklePattern() throws -> CHHapticPattern{
        
        var events = [CHHapticEvent]()
        var curves = [CHHapticParameterCurve]()

        do {
            // create one continuous buzz that fades out
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)

            let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
            let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1.5, value: 0)

            let parameter = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, end], relativeTime: 0)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 1.5)
            events.append(event)
            curves.append(parameter)
        }

        for _ in 1...16 {
            // make some sparkles
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: TimeInterval.random(in: 0.1...1))
            events.append(event)
        }
        
        return try CHHapticPattern(events: events, parameterCurves: curves)

    }
}

//Snip
@available(iOS 13.0, *)
extension HapticManager {

    //This code should either give us the pattern and run it, or it will fail to get the pattern and do nothing. The program will keep going without the haptic feedback. If there is some strange behavior you can probably handle it in here.
    public func playSlice(){
        if let pattern = try? slicePattern() {
            playHaptic(pattern)
        }
    }
    
    private func slicePattern() throws -> CHHapticPattern {
        let slice = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.35),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.25)
            ],
            relativeTime: 0,
            duration: 0.25)
        
        let snip = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.08)
        
        return try CHHapticPattern(events: [slice, snip], parameters: [])
    }
}

//Long boom
@available(iOS 13.0, *)
extension HapticManager {
    public func playHudsonOne(){
        if let pattern = try? hudsonOnePattern() {
            playHaptic(pattern)
        }
    }
    
    private func hudsonOnePattern() throws -> CHHapticPattern{
        
        // create a dull, strong haptic
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        
        // create a curve that fades from 1 to 0 over one second
        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
        
        // use that curve to control the haptic strength
        let parameter = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [start, end], relativeTime: 0)
        
        // create a continuous haptic event starting immediately and lasting one second
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 1)
        
        return try CHHapticPattern(events: [event], parameterCurves: [parameter])
    }
}

//playTest is for accepting parameters and testing how the resulting haptic feels. I suppose this oculd be used to run a much simpler in line interface too....
@available(iOS 13.0, *)
extension HapticManager{
    public func playHaptic(sharpness: Double, intensity: Double){
        if let pattern = try? testPattern(sharpnessIn: sharpness, intensityIn: intensity) {
            playHaptic(pattern)
        }
    }
    
    private func testPattern(sharpnessIn: Double, intensityIn: Double) throws -> CHHapticPattern{
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpnessIn))
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensityIn))
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [sharpness, intensity], relativeTime: 0, duration: 1)
        
        return try CHHapticPattern(events: [event], parameterCurves: [])
    }
    
}

//SOS
@available(iOS 13.0, *)
extension HapticManager{
    public func playSOS(){
        if let pattern = try? SOSPattern() {
            playHaptic(pattern)
        }
    }
    
    private func SOSPattern() throws -> CHHapticPattern {
        let short1 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0)
        let short2 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.2)
        let short3 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 0.4)
        let long1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 0.6, duration: 0.5)
        let long2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.2, duration: 0.5)
        let long3 = CHHapticEvent(eventType: .hapticContinuous, parameters: [], relativeTime: 1.8, duration: 0.5)
        let short4 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.4)
        let short5 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.6)
        let short6 = CHHapticEvent(eventType: .hapticTransient, parameters: [], relativeTime: 2.8)
        
        return try CHHapticPattern(events: [short1, short2, short3, long1, long2, long3, short4, short5, short6], parameters: [])
    }
    
}

