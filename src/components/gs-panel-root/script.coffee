Polymer
  is: '#GRUNT_COMPONENT_NAME'
  
  properties: 
    debug:
      type: Object
      value: false
      observer: '_debug_change'
    orientation:
      type: String
      value: GS.Rezisable.HORIZONTAL
  
  behaviors: [GS.Rezisable]
  
  created:->
    @parentOrientation = GS.Rezisable.VERTICAL
      
  ready: ->
    @main = @$.main
    
  _debug_change: ->
    unless @container then return
    if @debug
      @container.classList.add 'debug'
    else
      @container.classList.remove 'debug'
        
  begin_resize:(context, evnt)->
    context.initialMinHeight = window.getComputedStyle(@).getPropertyValue("min-height")
        
  resize:(context, evnt)->
    y_delta = evnt.clientY - context.initial_mouse_y
    nextHeight = context.initial_frame_heigth + y_delta
    @style.minHeight = nextHeight + 'px'
    @style.maxHeight = nextHeight + 'px'
    @style.height = nextHeight + 'px'
    false
    
  finish_resize:(context)->
    @style.minHeight = context.initialMinHeight
    @style.transition = '0.5s';
    false
  
  add: (element, path)->
    path = path or '0'
    @main.add element, path
    
