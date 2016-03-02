
if typeof window.GS is 'undefined'
  window.GS = {}
  
GS.Rezisable =

  properties: 
    parentOrientation:
      type: String
      
  listeners:
    'begin-resize': '__on_begin_resize'
    
  HORIZONTAL: 'horizontal'
  VERTICAL:   'vertical'
  
  parse_px: (in_px)->
    if /px$/.test in_px
      value = parseFloat in_px.slice(0, -2)
    else
      console.log 'Error in px parsing. Receives: ' +  in_px
    value
    
  ready: ->
    @__make_resizable()
    
  __make_resizable: ->
    ori = @parentOrientation = @parentOrientation or @HORIZONTAL
    @extend @, @strategies[ori]
    @[ori] = true
    
  __on_begin_resize: (evnt)->
    evnt.cancelBubble = true
    evnt.preventDefault()
    context = {}
    mousemove = (evnt) => 
      @__rezise context, evnt
    mouseup = (evnt) =>
      unless evnt.which is 1 then return 
      evnt.cancelBubble = true
      evnt.preventDefault()
      @__finish_resize context
      document.removeEventListener("mousemove", mousemove)
      document.removeEventListener("mouseup", mouseup)
    document.addEventListener("mouseup", mouseup)
    document.addEventListener("mousemove", mousemove)
    @__begin_resize context, evnt
   
  strategies:
    vertical:
      __after_push: (element, position)->
        
      __begin_resize: (context, evnt)->
        if @begin_resize and not @begin_resize(context, evnt) then return
        context.initial_frame_heigth = @clientHeight
        context.initial_mouse_y = evnt.detail.clientY
        @style.transition = 'none'
        
      __rezise:(context, evnt)->
        evnt.cancelBubble = true
        evnt.preventDefault()
        if @resize and not @resize(context, evnt) then return
        y_delta = evnt.clientY - context.initial_mouse_y
        nextHeight = context.initial_frame_heigth + y_delta
        @style.minHeight = nextHeight + 'px'
        
      __finish_resize:(context)->
        if @finish_resize and not @finish_resize(context) then return
        @style.minHeight = "40px"
        @style.transition = '0.5s';
      
    horizontal: 
      __after_push: (element)->
        amount = @children.length + 1
        count = 0
        width = 100 / amount
        for children in @children
          children.style.width = width + '%'
          css_width = children.style.width
          if /%$/.test css_width
            real_width = parseFloat children.style.width.slice(0, -1)
          else
            real_width = width
          count += real_width
        last_width = 100 - count
        element.style.width  = last_width + '%'
      __begin_resize: ->
      __finish_resize: ->
      __rezise: ->
