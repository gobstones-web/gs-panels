Polymer
  is: '#GRUNT_COMPONENT_NAME'

  properties: 
    debug:
      type: Object
      value: false
      observer: '_debug_change'
      
  ready: ->
    @main = @$.main
    
  _debug_change: ->
    unless @container then return
    if @debug
      @container.classList.add 'debug'
    else
      @container.classList.remove 'debug'
    
  add: (element, path)->
    path = path or '0'
    @main.add element, path
    
