Polymer
  is: '#GRUNT_COMPONENT_NAME'
  
  properties:
    debug:
      type: Object
      value: false
      observer: '_debug_change'
    orientation:
      type: String
      value: GS.Rezisable.VERTICAL
    mainOrientation:
      type: String
      value: GS.Rezisable.VERTICAL
      #value: GS.Rezisable.HORIZONTAL
    rootHeight:
      type: Number
    childHeight:
      type: Number
      observer: 'child_height_change'
  
  behaviors: [GS.Rezisable]
  
  created:->
    @register = {}
    @parentOrientation = GS.Rezisable.VERTICAL
      
  ready: ->
    @main = @$.main
    @reziser = @$.panelReziser
    @fixer = @$.heightFixer
  
  attached:->
    MAX_HEIGHT = 200
    resizer_h = @reziser.clientHeight
    @minHeightSupported = @parse_px @molt(@fixer).minHeight
    #check if client provides height
    if @rootHeight
      #subtract resizer_height and set children height
      @childHeight = @rootHeight - resizer_h
      maxHeight = @rootHeight + 'px'
    else
      #process height by min_height_fixer
      if @minHeightSupported > MAX_HEIGHT
        maxHeight = (@minHeightSupported + resizer_h) + 'px'
        @childHeight = @minHeightSupported
      else
        maxHeight = (MAX_HEIGHT + resizer_h) + 'px'
        @childHeight = MAX_HEIGHT
    @style.maxHeight = maxHeight
    
  child_height_change:->
    @fixer.style.maxHeight = @childHeight + 'px';
    @main.panelHeight = @childHeight
    
  _debug_change: ->
    unless @container then return
    if @debug
      @container.classList.add 'debug'
    else
      @container.classList.remove 'debug'
    
  begin_resize:(context, evnt)->
    context.minHeightPX = @molt(@fixer).minHeight
    context.reziserHeight = @reziser.clientHeight
    context.initial_frame_heigth = @clientHeight
    context.initial_mouse_y = evnt.detail.clientY
    @style.transition = 'none'
        
  resize:(context, evnt)->
    y_delta = evnt.clientY - context.initial_mouse_y
    nextHeight = context.initial_frame_heigth + y_delta 
    if nextHeight > @minHeightSupported
      @childHeight = (nextHeight - context.reziserHeight)
      @fixer.style.minHeight = @childHeight + 'px'
      @style.maxHeight = nextHeight + 'px'
    
  finish_resize:(context, evnt)->
    @fixer.style.minHeight = context.minHeightPX
    @style.transition = '0.5s'
    
  DuplicatedIdentifierError: do ->
    error = (id) ->
      this.name = 'DuplicatedIdentifierError'
      this.message = "Duplicated Identifier supplied: [#{id}]"
    error.prototype = Error.prototype
    error
  
  add: (element, item_id, parent_id)->
    parent = @register[parent_id] or @main
    if item_id and @register[item_id] then throw new @DuplicatedIdentifierError(item_id)
    created = parent.add_simple element, item_id
    item_id and @register[item_id] = created
    
  _add_composite: (ori, item_id, parent_id)->
    parent = @register[parent_id] or @main
    if item_id and @register[item_id] then throw new @DuplicatedIdentifierError(item_id)
    created = parent.add_composite ori, item_id
    item_id and @register[item_id] = created
    
  add_vertical: (item_id, parent_id)->
    @_add_composite GS.Rezisable.VERTICAL, item_id, parent_id
    
  add_horizontal: (item_id, parent_id)->
    @_add_composite GS.Rezisable.HORIZONTAL, item_id, parent_id
