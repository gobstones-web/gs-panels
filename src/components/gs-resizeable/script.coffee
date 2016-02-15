Polymer
    is: '#GRUNT_COMPONENT_NAME'

    attached: ()->
    	$('#div1').resizable
    	  handles:'e, w'
    	$('#div1').resize ->
    	  $('#div2').width $('#parent').width() - $('#div1').width()
    	  return
    	