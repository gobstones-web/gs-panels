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
    parentId:
      type: String
      value: ''
    nextId:
      type: String
      value: 'top-horizontal'
      
  listeners:
    'panelSimple.tap': '_add_panel_simple'
    'panelComplex.tap': '_add_panel_complex'
    'panelVertical.tap': '_add_panel_vertical'
    'panelHorizontal.tap': '_add_panel_horizontal'
      
  ready:->
    @nextClass = @classOptions[@nextClassIndex]
    @panels = panels = @$.gsPanels
    
  generate_horizontal:(hlevel)->  
    @panels.add_horizontal hlevel
    for vlevel in ['LEFT','CENTER','RIGHT']
      @_add_panel
        component_name: 'gs-panels-demo-item'
        self_id: hlevel + '_' + vlevel
        parent_id: hlevel
        klass: @nextClass
      @_change_class_index()
        
  attached:->
    for hlevel in ['BOTTOM','MIDDLE','TOP']
      @generate_horizontal hlevel
  
  _next_class_index_change:->
    @classOptions and @nextClass = @classOptions[@nextClassIndex]
      
  _change_class_index:->
    if @changeClassAuto
      nextClassIndex = @nextClassIndex + 1
      if nextClassIndex >= @classOptions.length
        nextClassIndex = 0
      @nextClassIndex = nextClassIndex
  
  _add_panel: (cfg)->
    item = document.createElement cfg.component_name
    item.elementClasses = cfg.klass
    item.elementName = cfg.self_id
    @panels.add item, cfg.self_id, cfg.parent_id
    
  _add_form_panel: (component_name)->
    @_add_panel 
      component_name: component_name
      self_id: @nextId
      parent_id: @parentId
      klass: @nextClass
    @_change_class_index()
    
  _add_panel_simple: -> @_add_form_panel 'gs-panels-demo-item'
    
  _add_panel_complex: -> @_add_form_panel 'gs-panels-demo-item-flex'
      
  _add_panel_vertical: ->
    @panels.add_vertical @nextId, @parentId
    
  _add_panel_horizontal: ->
    @panels.add_horizontal @nextId, @parentId
    
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
