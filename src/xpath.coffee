{ EventEmitter } = require 'events'
{ parse } = require 'xpath-parser'
{ evaluate } = require './evaluate'

class exports.XPath extends EventEmitter
    constructor: () ->
        @_expressions = {}

    addExpression: (xpath, namespaces) ->
        exp = parse xpath
        exp.xpath = xpath
        exp.namespace = namespaces
        @_expressions[xpath] = exp # TODO sort expressions as tree

    addListener: (event, ns, listener) ->
        [ns, listener] = [null, ns] unless listener?
        return super(event, listener) if @_expressions[event]?
        @addExpression(event, ns)
        super(event, listener)
    on:@::addListener

    once: (event, ns, listener) ->
        [ns, listener] = [null, ns] unless listener?
        return super(event, listener) if @_expressions[event]?
        @addExpression(event, ns)
        super(event, listener)

    removeListener: (event) ->
        res = super
        @_expressions[event] = null unless @listeners(event).length
        return res

    match: (elem) =>
        matched = no
        for event, expression of @_expressions
            match = evaluate(expression, [elem], expression.namespace)
            if match.length
                matched = yes
                @emit(event, elem, match)
        return matched