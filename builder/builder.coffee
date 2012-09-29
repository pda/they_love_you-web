class LevelBuilder

  constructor: (@document) ->
    @palette = new Palette(document, "palette")
    @map = new Map(document, "map", @palette)

    link = document.getElementById("controls").appendChild(document.createElement("a"))
    link.appendChild(document.createTextNode("Export"))
    link.href = ""
    link.addEventListener "click", (event) =>
      event.preventDefault()
      container = document.getElementById("export")
      for node, i in container.childNodes
        container.removeChild(node) if i >= (8 - 1)
      container.insertBefore(@map.toImage(), container.firstChild)


class Map

  MAP_SIZE = 512
  TILE_COUNT = 16
  TILE_SIZE = MAP_SIZE / TILE_COUNT

  constructor: (@document, id, @palette) ->
    @container = @document.getElementById(id)
    @tiles = @buildTiles()
    @attachEvents()

  buildTiles: ->
    tiles = []
    for y in [0...TILE_COUNT]
      for x in [0...TILE_COUNT]
        tiles.push @buildTile(x, y, tiles)
    tiles

  buildTile: (x, y, tiles) ->
    type = if @isEdge(x, y) then "wall" else "floor"
    tile = @container.appendChild(@document.createElement("div"))
    tile.dataset.x = x
    tile.dataset.y = y
    tile.dataset.type = type
    tile.style.backgroundColor = Palette.color(type)
    tile

  isEdge: (x, y) ->
    lastTile = TILE_COUNT - 1
    x == 0 || y == 0 || x == lastTile || y == lastTile

  attachEvents: ->
    @document.body.addEventListener "mousedown", => @drag = true
    @document.body.addEventListener "mouseup", => @drag = false
    @container.addEventListener "click", (event) =>
      @setToCurrentType(event.target)
    @container.addEventListener "mousemove", (event) =>
      @setToCurrentType(event.target) if @drag

  setToCurrentType: (tile) ->
    if @palette.current == "player"
      @setToType(@playerTile, @playerReplaced) if @playerTile
      @playerReplaced = tile.dataset.type
      @playerTile = tile
    @setToType(tile, @palette.current)

  setToType: (tile, type) ->
    tile.style.backgroundColor = Palette.color(type)
    tile.dataset.type = type

  toCanvas: ->
    canvas = @document.createElement("canvas")
    canvas.width = TILE_COUNT
    canvas.height = TILE_COUNT
    context = canvas.getContext("2d")
    for tile in @tiles
      [x, y] = [tile.dataset.x, tile.dataset.y]
      context.fillStyle = Palette.color(tile.dataset.type)
      context.fillRect(x, y, x, y)
    canvas

  toImage: ->
    img = @document.createElement("img")
    img.src = @toCanvas().toDataURL()
    img


class Palette

  PALETTE =
    monster: "rgb(255,   0,   0)"
    player:  "rgb(  0, 255,   0)"
    goal:    "rgb(  0,   0, 255)"
    wall:    "rgb(255, 255, 255)"
    floor:   "rgb(  0,   0,   0)"

  @color = (type) ->
    PALETTE[type]

  constructor: (@document, id) ->
    @container = @document.getElementById(id)
    @current = null
    @color = null
    @default = "floor"
    @build()

  chooseSwatch: (swatch) ->
    swatch = @resolve(swatch)
    swatch.checked = true
    @current = swatch.value
    @color = Palette.color(@current)

  resolve: (swatch) ->
    if typeof(swatch) == "string"
      return @container.querySelector("#swatch_#{swatch}")
    else
      swatch

  build: ->
    @buildElement(type, color) for type, color of PALETTE
    @chooseSwatch("wall")

  buildElement: (type, color) ->
    input = @container.appendChild(@document.createElement("input"))
    label = @container.appendChild(@document.createElement("label"))
    input.type = "radio"
    input.name = "swatch"
    input.value = type
    input.id = "swatch_#{type}"
    label.setAttribute("for", input.id)
    label.appendChild(@document.createTextNode(type))
    label.style.backgroundColor = color
    input.addEventListener "click", (event) => @chooseSwatch(event.target)


@levelBuilder = new LevelBuilder(document)
