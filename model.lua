require "match"
require "model_visualizer"

Model = { crystals = {} }

function Model.init(self)
  for y = 1, 10 do
    self.crystals[y] = {}
    for x = 1, 10 do
      self.crystals[y][x] = " "
    end
  end

  self:mix()
end

function Model.tick(self)
  -- horizontal check for matches
  local matches = {}

  for y = 1, #self.crystals do
    local prev = self.crystals[y][1]
    local count = 1

    for x = 2, #self.crystals[y] do
      local current = self.crystals[y][x]
      if current == prev then
        count = count + 1
      else
        if count >= 3 then
          local match = Match:new(Vector2I:new(y, x), count, true)
          table.insert(matches, match)
        end
        prev = current
        count = 1
      end
    end

    if count >= 3 then
      local match = Match:new(Vector2I:new(y, #self.crystals[y] + 1), count, true)
      table.insert(matches, match)
    end
  end

  -- vertical check for matches
  for x = 1, #self.crystals[1] do
    local prev = self.crystals[1][x]
    local count = 1

    for y = 2, #self.crystals do
      local current = self.crystals[y][x]
      if current == prev then
        count = count + 1
      else
        if count >= 3 then
          local match = Match:new(Vector2I:new(y, x), count, false)
          table.insert(matches, match)
        end
        prev = current
        count = 1
      end
    end

    if count >= 3 then
      local match = Match:new(Vector2I:new(#self.crystals + 1, x), count, false)
      table.insert(matches, match)
    end
  end

  if #matches <= 0 then
    return false
  end

  -- remove the matches
  for i = 1, #matches do
    local match = matches[i]
    local dir = Vector2I:new(0, 0)

    if match:isHorizontal() then
      dir.y = 1
    else
      dir.x = 1
    end

    for j = 1, match:getLength() do
      local coord = match:getCoord()
      coord = coord:sub(dir:mulI(j))

      if self.crystals[coord.x][coord.y] ~= " " then
        self.crystals[coord.x][coord.y] = " "
      end
    end
  end

  -- drop crystals
  for x = 1, #self.crystals[1] do
    for y = #self.crystals, 1, -1 do
      if self.crystals[y][x] == " " then
        toSwap = 0
        for k = y - 1, 1, -1 do
          if self.crystals[k][x] ~= " " then
            toSwap = k
            break
          end
        end

        if toSwap ~= 0 then
          self.crystals[y][x] = self.crystals[toSwap][x]
          self.crystals[toSwap][x] = " "
        end
      end
    end
  end

  -- fill the empty coords
  for y = 1, #self.crystals do
    for x = 1, #self.crystals[y] do
      if self.crystals[y][x] == " " then
        local possibilities = {"A", "B", "C", "D", "E", "F"}
        self.crystals[y][x] = possibilities[math.random(1, #possibilities)]
      end
    end
  end

  return true
end

function Model.move(self, from, to)
  -- bounds check
  if to.x < 1 or to.x > #self.crystals or to.y < 1 or to.y > #self.crystals[1] then
    print("Out of bounds!")
    return false
  end

  if not self:canMove() then
    print("Mixing the board - no allowed moves!")
    self:mix()
    self:dump()
    return true
  end

  local temp = self.crystals[from.y][from.x]

  self.crystals[from.y][from.x] = self.crystals[to.y][to.x]
  self.crystals[to.y][to.x] = temp

  local anyMatches = false
  -- it is possible that after the filling there will be more matches
  while self:tick() do
    anyMatches = true
    self:dump()
  end

  if not anyMatches then
    self.crystals[to.y][to.x] = self.crystals[from.y][from.x]
    self.crystals[from.y][from.x] = temp

    print("No such match in that move!")
    return false
  end

  return true
end

function Model.mix(self)
  for y = 1, #self.crystals do
    for x = 1, #self.crystals[y] do
      local possibilities = {"A", "B", "C", "D", "E", "F"}

      local a = " "
      local b = " "
      local matchCount = 0

      if y > 2 then
        a = self.crystals[y - 1][x]
        if a == self.crystals[y - 2][x] then
          matchCount = 1
        end
      end
      if x > 2 then
        b = self.crystals[y][x - 1]
        if b == self.crystals[y][x - 2] then
          matchCount = matchCount + 1
          if matchCount == 1 then
            a = b
          elseif b < a then
            local temp = a
            a = b
            b = temp
          end
        end
      end

      local t = math.random(1, #possibilities - matchCount)
      if matchCount > 0 and possibilities[t] >= a then
        t = t + 1
      end
      if matchCount == 2 and possibilities[t] >= b then
        t = t + 1
      end

      self.crystals[y][x] = possibilities[t]
    end
  end
end

function Model.canMove(self)
  for y = 1, #self.crystals do
    for x = 1, #self.crystals[y] do
      local current = self.crystals[y][x]

      -- a a b a
      if x > 3 and self.crystals[y][x - 2] == current and self.crystals[y][x - 3] == current then
        return true
      end
      -- a b a a
      if x + 3 <= #self.crystals[y] and self.crystals[y][x + 2] == current and self.crystals[y][x + 3] == current then
        return true
      end

      -- a
      -- a
      -- b
      -- a
      if y > 3 and self.crystals[y - 2][x] == current and self.crystals[y - 3][x] == current then
        return true
      end
      -- a
      -- b
      -- a
      -- a
      if y + 3 <= #self.crystals and self.crystals[y + 2][x] == current and self.crystals[y + 3][x] == current then
        return true
      end

      if y > 2 then
        if x > 2 and self.crystals[y - 1][x - 1] == current then
          -- a a b
          -- c d a
          -- or
          -- a b a
          -- c a d
          if (x >= 3 and self.crystals[y - 1][x - 2] == current) or 
            (x + 1 <= #self.crystals[y] and self.crystals[y - 1][x + 1] == current) then
            return true
          end
          -- a b
          -- a c
          -- d a
          -- or
          -- a b
          -- d a
          -- a d
          if (y >= 3 and self.crystals[y - 2][x - 1] == current) or 
            (y + 1 <= #self.crystals and self.crystals[y + 1][x - 1] == current) then
            return true
          end
        end

        if x + 1 <= #self.crystals[y] and self.crystals[y - 1][x + 1] == current then
          -- b a a
          -- a c d
          if (x + 2 <= #self.crystals[y] and self.crystals[y - 1][x + 2] == current) then
            return true
          end
          -- b a
          -- c a
          -- a d
          -- or
          -- b a
          -- a c
          -- d a
          if (y >= 3 and self.crystals[y - 2][x + 1] == current) or 
            (y + 1 <= #self.crystals and self.crystals[y + 1][x + 1] == current) then
            return true
          end
        end
      end

      if y + 1 <= #self.crystals then
        if x > 2 and self.crystals[y + 1][x - 1] == current then
          -- b c a 
          -- a a d
          -- or
          -- b a c
          -- a d a
          if (x >= 3 and self.crystals[y + 1][x - 2] == current) or 
            (x + 1 <= #self.crystals[y] and self.crystals[y + 1][x + 1] == current) then
            return true
          end
          -- b a
          -- a c
          -- a d
          if y + 2 <= #self.crystals and self.crystals[y + 2][x - 1] == current then
            return true
          end
        end

        if x + 1 <= #self.crystals[y] and self.crystals[y + 1][x + 1] == current then
          -- a b c
          -- d a a
          if (x + 2 <= #self.crystals[y] and self.crystals[y + 1][x + 2] == current) then
            return true
          end
          -- a b
          -- c a
          -- d a
          if y + 2 <= #self.crystals and self.crystals[y + 2][x + 1] == current then
            return true
          end
        end
      end
    end
  end

  return false
end

function Model.dump(self)
  ModelVisualizer:printModel(self)
end