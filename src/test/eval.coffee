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

    and_presence: (æ) ->
        expressions = parse "self::presence[@type='chat' or @id='id']"
        console.log {expressions}
        elem1 = new Element('presence', type:'chat', id:'id')
            .c('show').t('chat').up()
            .c('status').t('foo').root()
        elem2 = new Element('presence', type:'subscribed', to:"juliet@domain.lit")
        console.log elem1.toString(), elem2.toString()
        match = evaluate(expressions, [elem1, elem2])
        for el in match
            console.log(el.toString())
            æ.equals "presence", el.name
            æ.equals "chat", el.attrs.type
        æ.equals 1, match.length
        æ.done()

    info: (æ) ->
        ns = "http://jabber.org/protocol/disco#info"
        expressions = parse "self::iq[@type=get]/info:query"
        console.log {expressions}
        elem1 = new Element("iq", to:"juliet@domain.lit", id:"id", type:"get")
            .c("query", xmlns:ns).root()
        elem2 = new Element("iq", to:"juliet@domain.lit", id:"id", type:"get")
            .c("query", xmlns:"other").root()
        console.log elem1.toString(), elem2.toString()
        match = evaluate(expressions, [elem1, elem2], {info:ns})
        for m in match
            el = m.root()
            console.log(el.toString())
            æ.equals "iq", el.name
            æ.equals "get", el.attrs.type
            æ.equals ns, el.children[0].getNS()
        æ.equals 1, match.length
        æ.done()

    'not': (æ) ->
        ns = "http://jabber.org/protocol/disco#info"
        expressions = parse "self::iq[not(@type)]/info:query/self::*"
        console.log {expressions}
        elem1 = new Element("iq", to:"juliet@domain.lit", id:"id")
            .c("query", xmlns:ns).root()
        elem2 = new Element("iq", to:"juliet@domain.lit", id:"id", type:"get")
            .c("query", xmlns:ns).root()
        console.log elem1.toString(), elem2.toString()
        match = evaluate(expressions, [elem1, elem2], {info:ns})
        for el in match
            console.log(el.toString())
            æ.equals "query", el.name
            æ.equals undefined, el.attrs.type
            æ.equals ns, el.getNS()
        æ.equals 1, match.length
        æ.done()



