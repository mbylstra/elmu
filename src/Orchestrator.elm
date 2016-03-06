module Orchestrator where
import Audio.StatePool as StatePool exposing (StatePool)
import Audio.MainTypes exposing (DictGraph)
import Native.Orchestrator


updateGraph : ui -> StatePool -> DictGraph ui  -> Float
updateGraph uiModel statePool graph =
  Native.Orchestrator.updateGraph uiModel statePool graph
