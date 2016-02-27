setColor : a -> { r | color : a } -> { r | color : a }
setColor newValue record =
   { record | color = newValue }


getColor : { r | color : a } -> a
getColor record =
   record.color


-- x = .color "blue" { color = "blue"}
x = !color "blue"
