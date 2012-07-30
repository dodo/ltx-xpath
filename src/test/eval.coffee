{ Element } = require 'ltx'
{ parse } = require 'xpath-parser'
{ evaluate } = require '../lib/evaluate'


module.exports =

    simple: (æ) ->
        expressions = parse "/o"
        elem = new Element('über').c('c').up().c('o').up().c('o').up().c('l').up()
        console.log expressions
        console.log elem.toString()
        match = evaluate(expressions, [elem])
        for el in match
            console.log(el.toString())
            æ.equals "o", el.name
        æ.equals 2, match.length
        æ.done()

