Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties:
    mainWidth:
      type: Number
      observer: '_main_width_change'
    mainHeight:
      type: Number
      observer: '_main_height_change'
      
  listeners:
    'panelA.tap': '_add_panel_a'
    'panelB.tap': '_add_panel_b'
    'panelC.tap': '_add_panel_c'
      
  ready:->
    @panels = panels = @$.gsPanels
    
  _add_panel_a: ->
    item = document.createElement 'gs-panels-demo-item'
    item.elementClasses = 'red'
    item.elementName = 'panel A'
    @panels.add item
    
  _add_panel_b: ->
    item = document.createElement 'gs-panels-demo-item'
    item.elementClasses = 'green'
    item.elementName = 'panel B'
    @panels.add item
    
  _add_panel_c: ->
    item = document.createElement 'gs-panels-demo-item'
    item.elementClasses = 'blue'
    item.elementName = 'panel C'
    @panels.add item
    
  _is_numeric: (value)->
    not isNaN(value) and value isnt ''
    
  _main_width_change: ->
    if @_is_numeric(@mainWidth)
      @panels and @panels.style.width = @mainWidth + 'px'
    else
      @panels and @panels.style.width = '100%'
      
  _main_height_change: ->
    if @_is_numeric(@mainHeight)
      @panels and @panels.style.height = @mainHeight + 'px'
    else
      @panels and @panels.style.height = 'auto'
