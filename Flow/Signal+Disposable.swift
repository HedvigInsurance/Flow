//
//  Signal+Disposable.swift
//  
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Foundation

public extension CoreSignal {
    /// Returns a new signal that holds disposable until itself is disposed
    func hold(_ disposable: Disposable) -> CoreSignal<Kind, Value> {
        let signal = providedSignal
        let refState = StateAndCallback(state: 0)

        return CoreSignal(setValue: signal.setter, onEventType: { callback in
            let state = StateAndCallback(state: (), callback: callback)

            refState.protect {
                refState.val += 1
            }
            
            state += Disposer {
                refState.protect {
                    refState.val -= 1
                    if refState.val == 0 {
                        disposable.dispose()
                    }
                }
            }
            
            state += signal.onEventType { eventType in
                switch eventType {
                case .initial(nil):
                    state.call(.initial(nil))
                case .initial(let value?):
                    state.call(.initial(value))
                case .event(.value(let value)):
                    state.call(.event(.value(value)))
                case .event(.end(let error)):
                    state.call(.event(.end(error)))
                }
            }

            return state
        })
    }
}
