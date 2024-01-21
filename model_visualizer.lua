ModelVisualizer = { hasColoredOutput=false }

function ModelVisualizer.printWelcome(self) 
  print("       Welcome to the match-3 game!      ")
  print("-----------------------------------------")
  print("                Input:                   ")
  print("      Type 'm x y d' to make a move      ")
  print("'(x, y)' represents the crystal to choose")
  print("   'd' represents the direction to move  ")
  print("          Type 'q' to leave              ")
  print("-----------------------------------------")
end

function ModelVisualizer.printModel(self, model)
  crystals = model.getCrystals()
  io.write("  ")
  for i = 0, #crystals - 1 do
    io.write(i)
    io.write(" ")
  end
  io.write("\n")

  print(" --------------------")
  for i = 1, #crystals do
    if self.hasColoredOutput then
      io.write("\27[30m")
    end

    io.write(i - 1)
    io.write("|")
    for j = 1, #crystals[i] do
      if self.hasColoredOutput then
        if crystals[i][j] == "A" then io.write("\27[31m")
        elseif crystals[i][j] == "B" then io.write("\27[32m")
        elseif crystals[i][j] == "C" then io.write("\27[33m")
        elseif crystals[i][j] == "D" then io.write("\27[34m")
        elseif crystals[i][j] == "E" then io.write("\27[35m")
        elseif crystals[i][j] == "F" then io.write("\27[36m")
        end
      end

      io.write(crystals[i][j])
      io.write(" ")
    end
    io.write("\n")

    if self.hasColoredOutput then
      io.write("\27[30m")
    end
  end
end

function ModelVisualizer.printEnd()
  print("Bye!")
end

function ModelVisualizer.setColoredOutput(self, v)
  self.hasColoredOutput = v
end