Vector2I = { x=0, y=0 }

function Vector2I:new(x, y)
  local public = {}
  public.x = x
  public.y = y

  function public:sub(other)
    local result = Vector2I:new(public.x - other.x, public.y - other.y)
    return result
  end

  function public:mulI(value)
    local result = Vector2I:new(public.x * value, public.y * value)
    return result
  end

  setmetatable(public, self)
  self.__index = self
  
  return public
end