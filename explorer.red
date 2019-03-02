Red [
	Author: "Toomas Vooglaid"
	Date: 16-Feb-2019
	File: %explorer.red
]
#include %../utils/info.red
;use https://raw.githubusercontent.com/toomasv/syntax-highlighter/master/info.red
plan-ctx: context [
	obj: none
	tx: make face! [type: 'text]
	words: copy []
	selected: copy []
	step: len: half: 0
	boxes: type: none
	color: 'white
	path: to-path []
	with-types: none
	pos: d1: d2: d3: none
	history: clear []
	;box-size: 120x25
	
	options: [
		none!			white
		any-object! 	pink
		function!		crimson
		any-function! 	papaya
		map!			teal
		scalar!			green
		any-word!		sky
		any-list!		red
		any-string! 	orange
		immediate! 		tanned
		default!		khaki
		;any-type!		white
	]
	vopts: compose/only ["Default" (options)]
	opts: ["Default"]
	load-options: func [which][
		either exists? %viewer-options.red [
			vopts: load %viewer-options.red
			if find vopts which [
				options: copy/deep select vopts which
			]
			opts: extract at vopts 3 2
		][
			save/header %viewer-options.red vopts [
				Title: {Red-viewer color-themes}
			]
			vopts: load %viewer-options.red
		]
	]
	load-options "Default"
	append opts ["Save theme..." "Remove theme"]
	
	reload-options: func [which][
		system/view/auto-sync?: off
		options: copy/deep select vopts option: which
		box: copy/deep legend/pane/2
		box/state: none
		box/parent: none
		clear at legend/pane 2
		ofy: box/offset/y
		foreach [opt clr] options [
			box1: copy/deep box
			box1/text: to-string opt
			box1/color: get clr
			box1/offset/y: ofy 
			;print-props box1
			ofy: ofy + box/size/y
			append legend/pane  box1
		]
		legend/size/y: ofy + 1
		theme-save/offset/y: legend/offset/y + legend/size/y + 10
		show [legend theme-save]
		make-plan/keep-path []
	]
	
	opt-lay: [below]
	typesets: [
		number! scalar! any-word! all-word! immediate! any-function! any-object! any-string! 
		any-list! any-path! any-block! series! external! default! internal! any-type!
	]
	datatypes: sort collect [
		foreach word load help-string datatype! [
			if datatype? attempt [get word] [keep word]
		]
	]
	colors: sort extract load help-string tuple! 2

	print-props: func [wh][
		print ["Properties of" form type? wh ":"]
		foreach prop exclude switch type?/word wh [
			event! [system/catalog/accessors/event!]
			object! [words-of wh]
		][window face parent on-change* on-deep-change*][
			print [prop ":" mold wh/:prop]
		]
	]

	edit-options: func [which idx /local opt i where what found new box][
		clear at opt-lay 2
		either which [
			opt: find options which
		][
			insert opt: skip options (index? idx) - 1 * 2 reduce [none 'white]
			new-line opt true
			foreach-face/with legend [
				face/offset/y: face/offset/y + idx/1/size/y
			][
				face/offset/y > idx/1/offset/y
			]
			box: copy/deep first idx
			box/text: "New" 
			box/color: white
			box/offset/y: idx/1/offset/y + idx/1/size/y
			box/parent: none
			box/state: none
			;print-props box
			insert idx: next idx box
			legend/size/y: legend/size/y + box/size/y
			theme-save/offset/y: legend/offset/y + legend/size/y + 10
		]
		typesets: head typesets
		foreach [where what] [datatypes which typesets which colors opt/2][
			append opt-lay compose/only/deep [
				drop-list data (split form get where space) 
				with [
					flags: 'scrollable 
					selected: either found: find (where) (what) [index? found][none]
				] on-change [
					either 3 > i: index? find face/parent/pane face [
						i: pick [2 1] i = 1
						face/parent/pane/:i/selected: none
						show face/parent
						change opt to-word new: pick face/data face/selected
						idx/1/text: new
					][
						change next opt new: to-word pick face/data face/selected
						idx/1/color: get new
					]
					show face
					make-plan/keep-path []
				]
			]
		]
		view/flags opt-lay [modal popup]
	]
	theme-save-VID: [
		panel hidden [
			origin 0x0 below
			typ: field ""
			button "Save" [
				either find vopts typ/text [
					put vopts typ/text options
				][
					repend vopts [typ/text options]
					insert skip tail themes/data -2 typ/text
				]
				themes/selected: index? find themes/data typ/text
				show themes
				save %viewer-options.red vopts
				theme-save/visible?: no
				show theme-save
			]
		]
	]
	
	legend-VID: [
		panel black [
			origin 1x1 space 0x0 below
			themes: drop-list 120 data (opts) select 1
			on-select [
				switch/default option: pick face/data event/picked [
					"Save theme..." [
						typ/text: copy pick face/data face/selected
						theme-save/visible?: yes
						show theme-save
					]
					"Remove theme" [
						remove?: no
						view/flags [
							button "Remove" [remove?: yes unview] 
							button "Cancel" [unview]
						][modal popup]
						if remove? [
							remove/part find vopts pick face/data idx: face/selected 2
							remove at face/data idx
							face/selected: 1
							show face
							save %viewer-options.red vopts
							reload-options first face/data 
						]
					]
				][
					reload-options pick face/data event/picked
				]
			]
			style bx: box 120x25 with [
				menu: [
					"Change..." change 
					"Remove" remove 
					"Add after..." add 
					"Up" up 
					"Down" down
				]
			]
			on-menu [switch event/picked [
				change [
					edit-options 
						to-word select first idx: find legend/pane face 'text 
						idx
				]
				remove [
					remove/part find options to-word face/text 2
					pos: find face/parent/pane face
					szy: pos/1/size/y
					ofy: pos/1/offset/y
					remove pos
					foreach-face/with legend [face/offset/y: face/offset/y - szy][face/offset/y > ofy]
					legend/size/y: legend/size/y - szy
					theme-save/offset/y: legend/offset/y + legend/size/y + 10
					make-plan/keep-path []
				]
				add [
					edit-options 
						none 
						idx: find legend/pane face
				]
				up [
					if 2 < idx: index? found: find legend/pane face [
						opt: find options to-word face/text
						move/part opt skip opt -2 2
						ofy: legend/pane/(idx - 1)/offset/y
						legend/pane/(idx - 1)/offset/y: face/offset/y
						face/offset/y: ofy
						move found back found
						show legend
						make-plan/keep-path []
					]
				]
				down [
					if (length? legend/pane) > idx: index? found: find legend/pane face [
						opt: find options to-word face/text
						move/part skip opt 2 skip opt -2 2
						ofy: legend/pane/(idx + 1)/offset/y
						legend/pane/(idx + 1)/offset/y: face/offset/y
						face/offset/y: ofy
						move found next found
						show legend
						make-plan/keep-path []
					]
				]
			]]
		]
	]
	legend-pos: tail legend-VID/3
	fill-legend: does [
		clear legend-pos
		foreach [type color] options [
			repend legend-VID/3 ['bx to-string type color]
		]
	]
	fill-legend
	up-level: does [
		either block? :path [
			path: to-path path/2
			make-plan/keep-path []
		][
			if 1 < length? path [
				remove back tail path
				make-plan/keep-path []
			]
		]
	]
	win: layout/options/flags compose [
		on-menu [switch event/picked [
			back [
				unless head? history [
					history: back history 
					path: copy first history
					make-plan/keep-path/no-history []
				]
			]
			forward [
				unless 1 >= length? history [
					history: next history
					path: copy first history 
					make-plan/keep-path/no-history []
				]
			]
			up [up-level]
			quit [unview]
		]]
		on-down [pos: event/offset]
		on-over [
			if event/down? [
				diff: event/offset - pos
				half: boxes/draw/2: boxes/draw/2 + diff
				pos: event/offset
				show boxes
			]
		]
		on-wheel [
			if event/face = face [
				len: len + (event/picked * 10)
				parse at boxes/draw 3 [any [
					'line 0x0 s: pair! (
						d1: s/1 - s/3 d2: s/1 - s/4 d3: s/1 - s/6
						ang: atan2 s/1/x s/1/y
						change s as-pair round/to len * sin ang 1 round/to len * cos ang 1
						s/3: s/1 - d1 s/4: s/1 - d2 s/6: s/1 - d3
					)
				|	skip
				]]
				show boxes
			]
		]
		boxes: box with [
			size: to-pair system/view/screens/1/size/y - 150
			draw: compose [translate (half: size / 2)]
		] on-down [
			either event/ctrl? [
				parse head boxes/draw [some [
					'box s: if (within? event/offset - half s/1 s/2 - s/1) 
					(
						move/part skip s -6 tail s 11
						move/part skip tail s -19 tail s 8
						show win
					) thru end
				| 	skip
				]]
			][
				parse tail boxes/draw [some [r:
					'box if (within? event/offset - half r/2 r/3 - r/2) (
						either 6 = length? r [
							up-level
						][
							wrd: to-word first skip r 5
							make-plan/keep-path :wrd
						]
					) thru end
				|	if (head? r) reject
				| 	(r: back r) :r
				]]
			]
		]
		below
		legend: (legend-VID)
		theme-save: (theme-save-VID)
	][
		offset: 20x20
		menu: [
			popup 
			"Back" back 
			"Forward" forward 
			"Up" up 
			"Quit" quit
		]
	][all-over]
	make-box: func [
		word [any-type!];[word! any-list!] 
		idx [integer!] 
		/with 
			types [block!] 
		/local ang c0 sz val
	][
		ang: idx - 1 * step
		c0: as-pair len * sin ang -1 * len * cos ang
		either any [any-list? word any-function? word any-object? word] [
			tx/text: replace/all copy/part mold word 30 [lf | tab | "  "] ""
		][
			tx/text: mold word
		]
		if all [
			not block? :path
			not any-list? get path
			any [
				all [
					immediate? val: attempt/safer [get append copy path word] 
					;not any-word? val
					not none? val
				]
				any-string? :val
			]
		][
			val2: rejoin [": " copy/part val: mold :val 30] 
			append tx/text val2 
			if 30 < length? val [append tx/text "..."]
		]
		sz: (size-text tx) / 2
		repend boxes/draw [
			'fill-pen color
			'line 0x0 c0
			'box c0 - sz - 2 c0 + sz + 2
			'text c0 - sz tx/text
		]
	]
	in-types?: func [type [datatype!]][
		with-types: head with-types
		forall with-types [
			if any [
				type = get with-types/1 
				all [
					typeset? get with-types/1 
					find get with-types/1 type
				]
			] [return with-types/1]
		]
		no
	]
	get-color: func [type [datatype!] type2 [word!]][
		unless any [
			color: select options to-word type 
			color: select options type2
		] [
			typesets: head typesets
			forall typesets [
				if either typeset? get type2 [
					find intersect get typesets/1 get type2 type
				][
					find get typesets/1 get type2
				][
					color: select options typesets/1
					if color [break]
				]
			]
		]
		any [color 'white]
	]
	make-boxes: func [/local word type type2][
		clear at boxes/draw 3
		len: boxes/size/y / 2 - 100
		either with-types [
			clear selected
			forall words [
				either block? :path [
					type: type? words/1
				][
					type: type? case [
						any-list? get path [
							pick get path index? words
						]
						any-function? get path [get words/1]
						true [
							select get path words/1
						]
					]
				]
				if type2: in-types? type [
					repend/only selected [words/1 type type2]
				]
			]
			step: 2 * pi / length? selected
			;probe selected
			forall selected [
				set [word type type2] selected/1
				color: get-color type type2
				make-box/with word index? selected reduce [type type2]
			]
		][
			step: 2 * pi / length? words
			color: 'white
			forall words [
				make-box words/1 index? words
			]
		]
		tx/text: form path
		sz: (size-text tx) / 2
		color: get-color type? either block? :path [path][get path] 'any-type!
		repend boxes/draw [
			'fill-pen color
			'box 0 - sz - 2 sz + 2
			'text 0 - sz tx/text
		]
	]
	comment {
	make-obj: func [block [block!]][; TBD!
		parse block [
			'view s: [
				opt ['reduce | 'compose] block!
			|	[	path! if (first s/1 = 'layout) 
				|	'layout
				]
			]
		]
	]
	func-words: func [fn][ ;TBD!
		parse body-of :fn [
			collect any [s:
				if (any-function? get :s/1)(
					
				)
			|	if (path? :s/1)
				keep (s/1)
				skip
			]
		]
	]
	}
	make-plan: func [
		'struct [word! path! block!];[object! file! block! word! path! map!] 
		/with 
			types [block!]
		/keep-path
		/no-history
	][
		system/view/auto-sync?: off
		with-types: either with [types][[any-type!]]
		;if file? :struct [struct: load struct]
		;case [
		;	block? :struct [struct: make-obj struct]
			;map? :struct [struct: object body-of struct]
		;]
		
		unless keep-path [clear path]
		case [
			all [
				find [spec-of body-of] :struct
				any-function? get path
			][
				path: reduce [struct to-get-path path]
			]
			;block? :path 
			:struct [append path :struct]
		]
		unless any [
			no-history 
			path = first history
		][
			history: next history
			clear history
			insert/only history copy :path
		]
		either block? :path [
			insert clear words do path
		][
			insert clear words switch type?/word get :path [
				object! [words-of obj: get :path]
				map! [keys-of obj: get :path]
				function! [[spec-of body-of]];func-words obj: get :path]
				native! action! op! [[spec-of]]
				block! hash! paren! vector! [get :path]
			]
		]
		make-boxes
		show win
	]
	set 'explore func ['struct [word! path! block!]][
		make-plan :struct
		view win
	]
]
