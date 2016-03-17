import Html exposing (div, button, text, node, h2, p)
import StartApp.Simple as StartApp
import Gui.GridInput.Grid as Grid

main =
  StartApp.start { model = Grid.init 20 20, view = view, update = Grid.update }


styleNode cssString =
  node "style" [] [ text cssString ]


view action model =
  div []
    [ styleNode """
        body {
          padding: 40px;
          font-family: 'Montserrat', Arial, serif; font-weight: 400;
        }
        h2 {
          font-family: 'Montserrat', Arial, serif; font-weight: 700;
        }
        .grid {
          cursor: default;
          display: flex;
          width: 500px;
          height: 500px;
          border: 2px solid black;
        }
        .cell {
          width: 10px;
          height: 10px;
          /* border: 1px solid white; */
        }
        .cell.active {
          background-color: rgba(255, 0, 0, 0.4);
        }
      """
    , Grid.view action model
    ]
