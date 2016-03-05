Polymer
  is: '#GRUNT_COMPONENT_NAME'
  
  listeners:
    'mousedown': '_mousedown'

  _mousedown:(evnt)->
    unless evnt.which is 1 then return 
    @fire GS.EVENTS.RESIZE_BEGIN,
      clientX: evnt.clientX
      clientY: evnt.clientY
    