module Arc
  ( arc
  , arcSegment
  )
  where

import String

boolToIntString : Bool -> String
boolToIntString b =
  case b of
    True -> "1"
    False -> "0"

type alias ArcSegmentArcs =
  { absolute : Bool
  , radius : (Float, Float)
  , xAxisRotation : Float
  , largeArc : Bool
  , sweep : Bool
  , endPoint : (Float, Float)
  }

arcSegment : ArcSegmentArcs -> String
arcSegment args =
  let
    (radiusX, radiusY) = args.radius
    (endX, endY) = args.endPoint
  in
    [ if args.absolute then "A" else "a" -- 'A' for arc. Capital for absolute, lower for relative - isn't it obvious?!
    , toString radiusX  -- radius X
    , toString radiusY -- radius Y
    , toString args.xAxisRotation  -- x axis rotation
    , boolToIntString args.largeArc -- large arc flag
    , boolToIntString args.sweep  -- sweep flag
    , toString endX
    , toString endY
    ]
    |> String.join " "

type alias ArcArgs =
  { radius : Float
  , centerPoint : (Float, Float)
  , startAngle : Float
  , endAngle : Float
  }

type alias ArcInfo =
  { radius : Float
  , centerPoint : (Float, Float)
  , startPoint : (Float, Float)
  , endPoint : (Float, Float)
  }


fromDegrees : Float -> Float
fromDegrees = degrees

fromRadians : Float -> Float
fromRadians = radians


-- we want a function, that, given the same args, will return the center position
-- the position of the start of the arc, and the position of the end of the arc.
-- by giving a radius
-- for example, you could use this function to draw a spiral.
-- maybe its just the same, but you modify the radius?
-- this function itself can be used by arc

-- arcInfo : ArcArgs -> ?
getArcInfo : ArcArgs -> ArcInfo
getArcInfo args =
  let
    startAngleRadians = 0.0
    radius = args.radius
    (centerX, centerY) = args.centerPoint

    toAbsoluteCoords angleDegrees =
      let
        (normPointX, normPointY) = fromPolar (1.0, fromDegrees angleDegrees)
        pointX = centerX + (normPointX * radius)
        pointY = centerY - (normPointY * radius)
      in
        (pointX, pointY)

    startPoint = toAbsoluteCoords args.startAngle
    endPoint = toAbsoluteCoords args.endAngle
  in
    { centerPoint = args.centerPoint
    , radius = args.radius
    , startPoint = startPoint
    , endPoint = endPoint
    }


arc : ArcArgs -> String
arc args =
  let
    arcInfo = getArcInfo args

    startAngleRadians = 0.0
    radius = args.radius
    (centerX, centerY) = args.centerPoint
    (startPointX, startPointY) = arcInfo.startPoint
    (endPointX, endPointY) = arcInfo.endPoint
    largeArc = if args.endAngle - args.startAngle >= 180.0 then True else False
  in
    ("M " ++ (toString startPointX) ++ " " ++ (toString startPointY) ++ " " ++
      ( arcSegment
        { absolute=True
        , endPoint=arcInfo.endPoint
        , radius=(args.radius, args.radius)
        , sweep=False
        , largeArc=largeArc
        , xAxisRotation=0.0
        }
      )
    )
