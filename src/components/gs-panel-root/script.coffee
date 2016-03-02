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
      value: GS.Rezisable.HORIZONTAL
    rootHeight:
      type: Number
    childHeight:
      type: Number
      observer: 'child_height_change'
  
  behaviors: [GS.Rezisable]
  
  created:->
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
    
  _debug_change: ->
    unless @container then return
    if @debug
      @container.classList.add 'debug'
    else
      @container.classList.remove 'debug'
        
  molt:(elem)->
    window.getComputedStyle(elem)
        
  begin_resize:(context, evnt)->
    context.minHeightPX = @molt(@fixer).minHeight
    context.reziserHeight = @reziser.clientHeight
        
  resize:(context, evnt)->
    y_delta = evnt.clientY - context.initial_mouse_y
    nextHeight = context.initial_frame_heigth + y_delta 
    if nextHeight > @minHeightSupported
      @childHeight = (nextHeight - context.reziserHeight)
      @fixer.style.minHeight = @childHeight + 'px'
      @style.maxHeight = nextHeight + 'px'
    false
    
  finish_resize:(context)->
    @fixer.style.minHeight = context.minHeightPX
    @style.transition = '0.5s';
    false
  
  add: (element, path)->
    path = path or '0'
    @main.add element, path
    
