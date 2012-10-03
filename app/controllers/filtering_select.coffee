{Controller} = require 'spine'
template = require 'views/filtering_select'
Filterer = require './filterer'
CharacteristicMenuItem = require './characteristic_menu_item'
getPhysicallyAdjacentSibling = require 'lib/get_physically_adjacent_sibling'

class FilteringSelect extends Controller
  set: null
  characteristics: null
  itemController: null

  selection: null

  events:
    'keydown input': 'onKeyDownSearchInput'
    'click button[name="clear-filters"]': 'onClickClearFilters'
    'keydown .items': 'onKeyDownItems'
    'click [data-item]': 'onClickItem'

  elements:
    '.selection-label': 'label'
    '.filtering-select-menu': 'menu'
    'input[name="search"]': 'searchInput'
    '.filtering-select-menu .match .filterers': 'filterersContainer'
    '.filtering-select-menu .items': 'itemsContainer'

  constructor: ->
    super
    throw new Error 'FilteringSelect needs a set' unless @set
    throw new Error 'FilteringSelect needs some characteristics' unless @characteristics

    @html template @
    @appendItems()
    @appendFilterers()

    setTimeout @onSetFilter
    @set.bind 'filter', @onSetFilter

  appendItems: ->
    for item in @set.items
      controller = new @itemController model: item
      itemNode = controller.el
      itemNode.attr 'data-item': item.id
      @itemsContainer.append itemNode

  appendFilterers: ->
    for characteristic in @characteristics
      filterer = new Filterer
        set: @set
        characteristic: characteristic
        valueController: CharacteristicMenuItem

      @filterersContainer.append filterer.el

  onSetFilter: =>
    @el.toggleClass 'no-matches', @set.matches.length is 0

    matchIds = (match.id for match in @set.matches)
    for itemNode in @itemsContainer.children '[data-item]'
      itemNode = $(itemNode)
      itemId = itemNode.attr 'data-item'
      itemNode.toggleClass 'hidden',  itemId not in matchIds

  onKeyDownSearchInput: (e) ->
    inputValue = @searchInput.val()
    @set.filter label: new RegExp(inputValue, 'i'), false

  onClickClearFilters: ->
    @set.filter {}, true

  directions = [LEFT, UP, RIGHT, DOWN] = [37, 38, 39, 40]
  onKeyDownItems: (e) ->
    if e.which in directions
      e.preventDefault()

      selectedItem = @itemsContainer.children '.selected'
      if selectedItem.length > 0
        direction = switch e.which
          when LEFT then 'left'
          when UP then 'up'
          when RIGHT then 'right'
          when DOWN then 'down'

        keyed = getPhysicallyAdjacentSibling selectedItem, direction
        keyed?.click()

  onClickItem: ({currentTarget}) ->
    itemId = $(currentTarget).attr 'data-item'
    item = @set.find(id: itemId)[0]
    @select item

  select: (item) ->
    @label.html ''
    @itemsContainer.children('.selected').removeClass 'selected'

    if item
      @label.html item.label
      @itemsContainer.children("[data-item='#{item.id}']").addClass 'selected'

    @trigger 'select', item

module.exports = FilteringSelect
