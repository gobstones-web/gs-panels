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

  listeners: do ->
    listeners = {}
    listeners[GS.EVENTS.UNREGISTER]  = '_unregister'
    listeners

  behaviors: [GS.Rezisable]

  RESIZE_DELAY: 100
  RESIZE_DELTA: 40
  
  created:->
    #avoid agregate 'main' identifier
    @register = main: 1
    @parentOrientation = GS.Rezisable.VERTICAL

  ready: ->
    #main is the first composite-panel 
    @main = @$.main
    #resizer is the bottom bar wich begin 
    @resizer = @$.panelResizer
    #heightFixer is a div that force a minheight in root-panel component
    #fix resizer position
    @heightFixer = @$.heightFixer
    #onReziseFixer is a div that force browser to hold root-panel position
    #this expand and contract and fix page total height
    @onReziseFixer = @$.onReziseFixer

  attached:->
    #if root-panel css height is grater than MAX_HEIGHT
    #it shrink till MAX_HEIGHT px
    MAX_HEIGHT = 600
    resizer_h = @resizer.clientHeight
    #minHeightSupported: css min-height
    @minHeightSupported = @parse_px @molt(@heightFixer).minHeight
    #check if client provides height
    if @rootHeight
      #subtract resizer_height and set children height
      @childHeight = @rootHeight - resizer_h
      maxHeight = @rootHeight + 'px'
    else
      #process height by min_height_fixer
      if @minHeightSupported > MAX_HEIGHT
        next_height = @minHeightSupported
      else
        next_height = MAX_HEIGHT
      maxHeight = (next_height + resizer_h) + 'px'
      @childHeight = next_height
    @style.maxHeight = maxHeight

  get_children_tree:->
    #API method
    @main.get_children_tree()

  child_height_change:->
    #set height in heightFixer in order to fix 'resizer' position
    @heightFixer.style.maxHeight = @childHeight + 'px';
    #propagate height change over children
    @main.panelHeight = @childHeight

  _debug_change: ->
    unless @container then return
    if @debug
      @container.classList.add 'debug'
    else
      @container.classList.remove 'debug'

  begin_resize:(context, evnt)->
    #outside_resize: represent the height in pixel that was resized in outside mode
    context.outside_resize = 0 
    #minHeightPX: the initial root-panel min-height
    context.minHeightPX = @molt(@heightFixer).minHeight
    #resizerHeight: initial resizer height 
    context.resizerHeight = @resizer.clientHeight
    #minHeightPX: the initial root-panel height
    context.initial_frame_heigth = @clientHeight
    #initial_window_scroll_y: initial scroll vertical position
    context.initial_window_scroll_y = window.scrollY
    #initial_mouse_y: the initial clientY value
    context.initial_mouse_y = evnt.detail.clientY
    #bottom offset
    #TODO on_resize_fixer_height should not integrate resizer part
    context.on_resize_fixer_height = document.documentElement.clientHeight - evnt.detail.clientY
    @style.transition = 'none'
  
  safe_set_height:(context, y_delta)->
    nextHeight = context.initial_frame_heigth + context.outside_resize + y_delta
    if nextHeight > @minHeightSupported
      @childHeight = (nextHeight - context.resizerHeight)
      @heightFixer.style.minHeight = @childHeight + 'px'
      @style.maxHeight = nextHeight + 'px'
      next_resizer_height = context.on_resize_fixer_height
      next_resizer_height -= y_delta
      #next_resizer_height -= context.outside_resize
      if next_resizer_height < 0
        next_resizer_height = 0
      @onReziseFixer.style.height = next_resizer_height + 'px'
      
  auto_resize:(permission, context, y_delta)->
    unless permission.cancel
      context.outside_resize += @RESIZE_DELTA
      next_scroll_y = context.initial_window_scroll_y + context.outside_resize
      window.scrollTo(window.scrollX, next_scroll_y)
      @safe_set_height(context, y_delta)
      @resizing = permission = {}
      next_time = => @auto_resize(permission, context, y_delta)
      window.setTimeout next_time, @RESIZE_DELAY
    
  begin_auto_resize:(context, evnt, y_delta)->
    @resizing = {}
    y_delta = evnt.clientY - context.initial_mouse_y
    @auto_resize @resizing, context, y_delta
      
  finish_auto_resize:(context, evnt)->   
    @resizing.cancel = true
    @resizing = undefined
    
  resize:(context, evnt)->
    #y_delta: the height in pixel that was resized in normal mode
    y_delta = evnt.clientY - context.initial_mouse_y
    if evnt.clientY >= document.documentElement.clientHeight
      not @resizing and @begin_auto_resize context, evnt, y_delta
    else
      if @resizing 
        @finish_auto_resize context, evnt
      else
        @safe_set_height context, y_delta
    
  finish_resize:(context, evnt)->
    @resizing and @finish_auto_resize(context)
    @heightFixer.style.minHeight = context.minHeightPX
    @onReziseFixer.style.height = '0px'
    
  DuplicatedIdentifierError: do ->
    error = (id) ->
      this.name = 'DuplicatedIdentifierError'
      this.message = "Duplicated Identifier supplied: [#{id}]"
    error.prototype = Error.prototype
    error
  
  _unregister: (polymer_event)->
    identifier = polymer_event.detail.item.identifier
    if identifier
      delete @register[identifier]
    @fire GS.EVENTS.PANELS_CHANGE
  
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
