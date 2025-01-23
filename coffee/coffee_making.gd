extends Node2D


enum CoffeeTemperature {HOT, COLD}
enum MilkPitcher {NONE, SMALL, MEDIUM, LARGE}

var coffee_type: CoffeeTemperature



#region - Variáveis que afetam a nota do café
# FIRST STAGE
## HOT SERVE - How many sugar spoons
var sugar_spoons: int = 0

## COLD BREW - How many ice cubes
var ice_cubes: int = 0


# SECOND STAGE
## HOT SERVE - How much milk
var milk_pitcher: MilkPitcher = MilkPitcher.NONE

## COLD BREW - How much coffee
var coffee_oz: float = 0


# THIRD STAGE
## HOT SERVE - How much of your milk is actually just foam
var foam_percentage: float = 0 

## COLD BREW - How many pumps of syrup
var syrup_pumps: int = 0
#endregion
