fs = require 'fs'
util = require 'util'
corpusDir = './corpus'

isLetter = (s, i) ->
	if i < 0 || i > s.length
		return false
	code = s.charCodeAt i
	(code >= 65 && code <= 90) || (code >= 97 && code <= 122)

sameLetter = (s, i, j) ->
	d = s.charCodeAt(i) - s.charCodeAt(j)
	d == 0 || d == 32 || d == -32

findPalindromesAt = (s, i, j, callback) ->
	length = 1
	while i > 0 && j < s.length
		if !sameLetter s, i, j
			break
		if length > 5 && !isLetter(s, i - 1) && !isLetter(s, j + 1)
			callback s[i..j].replace(/[^a-zA-Z]/g, ' ').replace(/\s+/g, ' ').toLowerCase()
		i--
		while !isLetter(s, i) && i > 0
			i--
		j++
		while !isLetter(s, j) && j < s.length
			j++
		length += 2

findPalindromes = (s, callback) ->
	i = 0
	while i < s.length
		while !isLetter(s, i) && i < s.length
			i++
		findPalindromesAt(s, i, i, callback)
		j = i + 1
		while !isLetter(s, j) && j < s.length
			j++
		findPalindromesAt(s, i, j, callback)
		i++

trie = {}

setInTrie = (s) ->
	i = 0
	pointer = trie
	while i < s.length
		while !isLetter(s, i) && i < s.length
			i++
		if i < s.length
			c = s.charAt(i).toLowerCase()
			next = pointer[c]
			if !next
				pointer[c] = {}
			pointer = pointer[c]
			i++
	isNew = !pointer.value
	pointer.value = s
	isNew

getFromTrie = (s) ->
	i = 0
	pointer = trie
	while i < s.length
		while !isLetter(s, i) && i < s.length
			i++
		if i < s.length
			c = s.charAt(i).toLowerCase()
			next = pointer[c]
			if !next
				return null
			pointer = pointer[c]
			i++
	return pointer.value

findReversals = (s, callback) ->
	i = 0
	while i < s.length
		while !isLetter(s, i) && i < s.length
			i++
		j = i
		word = ''
		for x in [0..3]
			while isLetter(s, j) && j < s.length
				word += s.charAt(j)
				j++
			word = word.toLowerCase()
			if setInTrie(word)
				reverseWord = word.split('').reverse().join('')
				match = getFromTrie(reverseWord)
				if match
					callback(word + ' ' + match)
			while !isLetter(s, j) && j < s.length
				j++
			word += ' '
		while isLetter(s, i) && i < s.length
			i++

store = {}

readFile = (err, data) ->
	s = data.toString()
	storeAndLog = (words) ->
		if !store[words]
			store[words] = 1
			console.log words
			fs.appendFile './output.txt', words + '\n'
	#findPalindromes s, storeAndLog
	findReversals s, storeAndLog

fs.readdir corpusDir, (err, files) ->
	fs.writeFile './output.txt', '', () ->
		for file in files
			if file == '.' || file == '..'
				continue
			fs.readFile corpusDir + '/' + file, readFile
