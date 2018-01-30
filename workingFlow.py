print cornercases:
	rowItem0 not:
		a.a.a.a
		empty
		"costcenter" in rowItem0
	
	typical val:
		a.b.c/d


loop everyitem:
	
	isCChead:
		rowItem0 not:
			a.a.a.a.
			empty
		and:
			"costcenter" in rowItem0
		
		then:
			@generate different dealer handlelist
			generate "SUB_**"

			# should add error handling
			get SNAME in dict or list

			if is bridge: add LRvarible

			set element
			set crusor
	
	isLRbridge:
		set element
		set crusor

	isbelowLEVEL2:

		if rowItem0 isempty:
			pass this row

		elif crusor is parent(crusorID in itemID):

			item isSummary():
				isSummary:
					"/" not in itemID
					and itemVal is empty
						or itemID.count(".")<3

				# added:should add error control: if not find
				try:
					find subItem in summaryDict	

			item not isSummary():

				tunnel excavation logic:

					# why i have to get this here
					get this excavation length
					add attribute "LENGTH"

				GENERAL BASIC LOGIC

		else:

			# in here should add hard logic to control error
			# use last children and nextitem to control error
			# print error items

			find this crusor

BASIC TREE GENERATED

TUNNEL LOGIC:
	xpath to get items

	basic function:parseTNmile
		formatstring
		determine port
		splitTNstr:
		# SHOULD ADD ALOT ERROR CONTROL
		# SHOULD ADD ERROR CONTROL IN PARENT FUN TO LOCATE ERROR
			get spliter by LR
			if len(splitedList)<3:
				print(ERROR)
			else:
				formatstring AND GET PILE

		return itemAttribList

	write itemAttrib to tree





