
if typeof window.GS is 'undefined'
  window.GS = {}
  
GS.Rezisable =

  properties: 
    parentOrientation:
      type: String
      
    notLast:
      type: Boolean
      observer: '_not_last_change'
  
  listeners: do ->
    listeners = {}
    listeners[GS.EVENTS.RESIZE_BEGIN] = '__on_begin_resize'
    listeners
    
  HORIZONTAL: 'horizontal'
  VERTICAL: 'vertical'
  NOT_LAST_CLASS: 'not-last'
  
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
    
  _not_last_change:->
    if @notLast
      @classList.add @NOT_LAST_CLASS
    else
      @classList.remove @NOT_LAST_CLASS
    
  ready: ->
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
    



