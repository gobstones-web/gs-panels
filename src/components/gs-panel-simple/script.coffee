Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties:
    concretElement:
      type: Object
    index:
      type: Number
      
  behaviors: [GS.Rezisable] 
  
  ready: ->
    @container = @$.container
    
  attached: ->
    @__propagate_height_change()
    
  __propagate_height_change: ->
    #skiping height propagation before attach
    if @concretElement 
      @concretElement.style.height = @fixedHeight + 'px'
      @concretElement.panelHeight = @fixedHeight
      
  get_children_tree: ->
    id: @identifier
    
  _panel_width_change: ->
    @__set_width_percent @panelWidth
  
  remove_me: ->
    @parentNode.fire GS.EVENTS.CHILD_REMOVE, item: @
