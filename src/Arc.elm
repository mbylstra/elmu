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

fromDegrees : Float -> Float
fromDegrees = degrees

fromRadians : Float -> Float
fromRadians = radians

arc : ArcArgs -> String
arc args =
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

    (startPointX, startPointY) = toAbsoluteCoords args.startAngle
    (endPointX, endPointY) = toAbsoluteCoords args.endAngle

    largeArc = if args.endAngle - args.startAngle >= 180.0 then True else False

  in
    ("M " ++ (toString startPointX) ++ " " ++ (toString startPointY) ++ " " ++
      ( arcSegment
        { absolute=True
        , endPoint=(endPointX, endPointY)
        , radius=(args.radius, args.radius)
        , sweep=False
        , largeArc=largeArc
        , xAxisRotation=0.0
        }
      )
    )
