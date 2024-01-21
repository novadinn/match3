require "model"
require "model_visualizer"
require "vector2i"

if #arg >= 1 then
  if arg[1] == "-wcol" then
    ModelVisualizer:setColoredOutput(true)
  end
end

ModelVisualizer:printWelcome()

model = Model
model:init()
model:dump()
promt = io.read()

while promt ~= "q" do
  if string.match(promt, "^m %d %d [lrud]$") then
    local x, y, dir = promt:match("^m (%d) (%d) ([lrud])$")
    x = x + 1
    y = y + 1

    local from = Vector2I:new(x, y)
    local to = Vector2I:new(x, y)

    if dir == "l" then
      to.x = to.x - 1
    elseif dir == "r" then
      to.x = to.x + 1
    elseif dir == "u" then
      to.y = to.y - 1
    elseif dir == "d" then
      to.y = to.y + 1
    end

    if not model:move(from, to) then
      print("Incorrent move!")
    end
    
  else
    print("The input has incorrect format!")
  end

  promt = io.read()
end

ModelVisualizer:printEnd()