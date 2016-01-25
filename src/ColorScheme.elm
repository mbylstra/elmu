module ColorScheme where

import Color exposing (Color)
import ColourLovers exposing (Palette)
import Array exposing (Array)
import Maybe exposing (withDefault)

type alias ColorScheme =
  { windowBackground: Color
  , pianoWhites: Color
  , pianoBlacks: Color
  , knobBackground: Color
  , knobForeground: Color
  , controlPanelBackground: Color
  , controlPanelBorders: Color
  }

defaultColorScheme : ColorScheme
defaultColorScheme =
  { windowBackground= Color.white
  -- { windowBackground= Color.red
  , pianoWhites= Color.white
  -- , pianoWhites= Color.green
  , pianoBlacks= Color.black
  -- , pianoBlacks= Color.blue
  , knobBackground= Color.black
  , knobForeground= Color.lightRed
  , controlPanelBackground= Color.white
  , controlPanelBorders= Color.black
  }

fromColourLovers : Palette -> ColorScheme
fromColourLovers palette =
  let
    colors = palette.colors
  in
    { defaultColorScheme |
        windowBackground = withDefault defaultColorScheme.windowBackground (Array.get 0 colors)
      -- , pianoWhites = withDefault defaultColorScheme.pianoWhites (Array.get 1 colors)
      -- , pianoBlacks = withDefault defaultColorScheme.pianoBlacks (Array.get 2 colors)
      , knobBackground = withDefault defaultColorScheme.knobBackground (Array.get 3 colors)
      , knobForeground = withDefault defaultColorScheme.knobForeground (Array.get 4 colors)
      , controlPanelBackground = withDefault defaultColorScheme.controlPanelBackground (Array.get 5 colors)
      , controlPanelBorders = withDefault defaultColorScheme.controlPanelBorders (Array.get 6 colors)
    }

fromColourLoversArray : Array Palette -> Array ColorScheme
fromColourLoversArray palettes =
  Array.map fromColourLovers palettes
