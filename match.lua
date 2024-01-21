require "vector2i"

Match = {}

function Match:new(coord, length, horizontal)
  local private = {}
  private.coord = coord
  private.length = length
  private.horizontal = horizontal

  local public = {}
  function public:getCoord()
    return private.coord
  end

  function public:getLength()
    return private.length
  end

  function public:isHorizontal()
    return private.horizontal
  end

  setmetatable(public, self)
  self.__index = self

  return public
end