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


    descendant: (æ) ->
        expressions = parse "//o"
        elem = new Element('ü').c('b').c('o').c('r')
            .c('c').up().c('o').up().c('o').up().c('l').up()
            .up().up().up()
        console.log expressions
        console.log elem.toString()
        match = evaluate(expressions, [elem])
        æ.equals 1, match[0].children.length
        for el in match
            console.log(el.toString())
            æ.equals "o", el.name
        æ.equals 3, match.length
        æ.done()

