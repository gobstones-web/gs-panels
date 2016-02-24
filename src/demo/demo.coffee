document.addEventListener("DOMContentLoaded", (event)-> 

	document.getElementById("addHeader").addEventListener('click', (event)->
		addHeader()
	)

	document.getElementById("addFooter").addEventListener('click', (event)->
		addFooter()
	)

	document.getElementById("addButtonMultiple").addEventListener('click', (event)->
		addMultipleElement()
	)

	addSingleElement200px = ->
		panelManager = document.getElementById("panel-manager")
		div = document.createElement("div")
		div.style.width = "200px"
		div.style.border = "solid 2px black"
		panelManager.addSingleElement(div)

	addHeader = ->
		panelManager = document.getElementById("panel-manager")
		div = document.getElementById("header")
		panelManager.addSingleElement(div)

	addFooter = ->
		panelManager = document.getElementById("panel-manager")
		div = document.createElement("div")
		div.style.border = "solid 2px black"
		div.style.height = "100px"
		div.style.width = "100%"
		panelManager.addSingleElement(div)
	

	createDiv = ->
		div = document.createElement("div")
		div.style.border = "solid 2px black"
		div

	addMultipleElement = ->
		panelManager = document.getElementById("panel-manager")
		elementList = []
		for each in [1,2,3]
			div = createDiv()
			div.innerHTML = div.innerHTML + 'Sarasa'
			elementList.push div

		panelManager.addMultipleElment(elementList, "vertical")

)

