
if typeof window.GS is 'undefined'
  window.GS = {}
  
GS.Rezisable =

  properties: 
    identifier:
      type: String
    parentOrientation:
      type: String
    panelWidth:
      type: Number 
      value: 100
      observer: '__panel_width_change'
    fixedHeight:
      type: Number 
      observer: '__fixed_height_change'
    panelHeight:
      type: Number
      observer: '__panel_height_change'
    notLast:
      type: Boolean
      observer: '__not_last_change'
  
  listeners: do ->
    listeners = {}
    listeners[GS.EVENTS.RESIZE_BEGIN] = '__on_begin_resize'
    listeners
    
  HORIZONTAL: 'horizontal'
  VERTICAL: 'vertical'
  NOT_LAST_CLASS: 'not-last'
  
  created: ->
    @resize_data = {}
  
  molt:(elem)-> window.getComputedStyle(elem)
  
  parse_px: (in_px)->
    if /px$/.test in_px
      value = parseFloat in_px.slice(0, -2)
    else
      console.log 'Error in px parsing. Receives: ' +  in_px
      value = in_px
    value
    
  parse_percent: (in_percent)->
    if /\%$/.test in_percent
      value = parseFloat in_percent.slice(0, -1)
    else
      console.log 'Error in % parsing. Receives: ' +  in_percent
      value = in_percent
    value
    
  __not_last_change:->
    if @notLast
      @classList.add @NOT_LAST_CLASS
    else
      @classList.remove @NOT_LAST_CLASS
    @__update_fixed_height()
  
  __update_fixed_height: ->
    if @parentOrientation is GS.Rezisable.VERTICAL and @notLast
      @fixedHeight = @panelHeight - 7
    else
      @fixedHeight = @panelHeight
  
  __fixed_height_change: ->
    @__propagate_height_change()
    
  __propagate_height_change: ->
    
  __panel_height_change: ->
    @__set_height_px @panelHeight
    @__update_fixed_height()
    
  __propagate_width_change: ->
    
  __panel_width_change: ->
    @__set_width_percent @panelWidth
    @__propagate_width_change()
  
  __set_width_percent: (percent)->
    @style.width = percent + '%'
    @resize_data.width = @parse_percent @style.width
    
  __set_height_px: (in_px)->
    @style.height = in_px + 'px'
    @resize_data.height = @parse_px @style.height
    
  attached: ->
    @parentOrientation = @parentOrientation or @HORIZONTAL
    @classList.add 'child-of-' + @parentOrientation
    
  __on_begin_resize: (evnt)->
    evnt.cancelBubble = true
    evnt.preventDefault()
    context = item:@
    mousemove = (evnt) => 
      evnt.cancelBubble = true
      evnt.preventDefault()
      @resize context, evnt
    mouseup = (evnt) =>
      unless evnt.which is 1 then return 
      evnt.cancelBubble = true
      evnt.preventDefault()
      @finish_resize context, evnt
      document.removeEventListener("mousemove", mousemove)
      document.removeEventListener("mouseup", mouseup)
    document.addEventListener("mouseup", mouseup)
    document.addEventListener("mousemove", mousemove)
    @begin_resize context, evnt
   
  begin_resize:(context, native_event)->
    @fire GS.EVENTS.CHILD_RESIZE_BEGIN, 
      context: context
      position:
        clientX: native_event.detail.clientX
        clientY: native_event.detail.clientY
        
  resize:(context, polymer_event)->
    @fire GS.EVENTS.CHILD_RESIZE, 
      context: context
      position:
        clientX: polymer_event.clientX
        clientY: polymer_event.clientY
    
  finish_resize:(context, polymer_event)->
    @fire GS.EVENTS.CHILD_RESIZE_FINISH,
      context: context
      position:
        clientX: polymer_event.clientX
        clientY: polymer_event.clientY
