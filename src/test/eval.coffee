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

    op: (æ) ->
        expressions = parse "c | o | l"
        elem = new Element('über').c('c').up().c('o').up().c('o').up().c('l').up()
        console.log expressions
        console.log elem.toString()
        match = evaluate(expressions, [elem])
        for el in match
            console.log(el.toString())
            æ.equals "o", el.name.replace(/c|l/,"o")
        æ.equals 4, match.length
        æ.done()

    presence: (æ) ->
        expressions = parse "self::presence[@type='chat']"
        elem1 = new Element('presence', type:'chat')
            .c('show').t('chat').up()
            .c('status').t('foo').root()
        elem2 = new Element('presence', type:'subscribed', to:"juliet@domain.lit")
        console.log expressions
        console.log elem1.toString(), elem2.toString()
        match = evaluate(expressions, [elem1, elem2])
        for el in match
            console.log(el.toString())
            æ.equals "presence", el.name
            æ.equals "chat", el.attrs.type
        æ.equals 1, match.length
        æ.done()

