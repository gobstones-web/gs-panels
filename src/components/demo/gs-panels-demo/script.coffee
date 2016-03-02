Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties:
    mainWidth:
      type: Number
      observer: '_main_width_change'
    mainHeight:
      type: Number
      observer: '_main_height_change'
    nextClass:
      type: String
    nextClassIndex:
      type: Number
      value: 0
      observer: '_next_class_index_change'
    changeClassAuto:
      type: Boolean
      value: true
    classOptions:
      type: Array
      value: ['red', 'green', 'blue']
    nextName:
      type: String
      value: 'Panel Name'
      
  listeners:
    'panelSimple.tap': '_add_panel_simple'
    'panelComplex.tap': '_add_panel_complex'
      
  ready:->
    @nextClass = @classOptions[@nextClassIndex]
    @panels = panels = @$.gsPanels
    
  _next_class_index_change:->
    @classOptions and @nextClass = @classOptions[@nextClassIndex]
      
  _change_class_index:->
    if @changeClassAuto
      nextClassIndex = @nextClassIndex + 1
      if nextClassIndex >= @classOptions.length
        nextClassIndex = 0
      @nextClassIndex = nextClassIndex
    
  _add_panel_simple: ->
    item = document.createElement 'gs-panels-demo-item'
    item.elementClasses = @nextClass
    item.elementName = @nextName
    @panels.add item
    @_change_class_index()
    
  _add_panel_complex: ->
    item = document.createElement 'gs-panels-demo-item-flex'
    item.elementClasses = @nextClass
    item.elementName = @nextName
    @panels.add item
    @_change_class_index()
    
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
