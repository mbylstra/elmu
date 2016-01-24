module KeyboardNoteInput where

import Keyboard
import Maybe exposing (withDefault)
import Char exposing (KeyCode, fromCode)
import AudioUtil exposing (pitchToFrequency)

type alias Pitch = Float

charToPitch : Char -> Maybe Pitch
charToPitch c =
  case c of
    's' -> Just 60.0
    'd' -> Just 62.0
    'f' -> Just 64.0

    'g' -> Just 65.0
    'h' -> Just 67.0
    'j' -> Just 69.0
    'k' -> Just 71.0

    'l' -> Just 72.0

    _ -> Nothing


keyboardGuiPitch : Signal Float
keyboardGuiPitch =
  Signal.map (\keyCode -> keyCode |> fromCode |> charToPitch |> withDefault 0.0) Keyboard.presses

keyboardGuiFrequency : Signal Float
keyboardGuiFrequency =
  Signal.map pitchToFrequency keyboardGuiPitch
