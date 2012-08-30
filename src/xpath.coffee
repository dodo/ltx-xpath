{ EventEmitter } = require 'events'
{ parse } = require 'xpath-parser'
{ evaluate } = require './evaluate'

class exports.XPath extends EventEmitter
    constructor: () ->
        @_expressions = {}

    addExpression: (xpath, namespaces) ->
        exp = parse xpath
        exp.xpath = xpath
        exp.namespace = ns
        @_expressions[xpath] = exp # TODO sort expressions as tree

    addListener: (event, ns, listener) ->
        return super(event, listener) if @_expressions[event]?
        [ns, listener] = [null, ns] unless listener?
        @addExpression(event, ns)
        super(event, listener)
    on:@addListener

    once: (event, ns, listener) ->
        return super(event, listener) if @_expressions[event]?
        [ns, listener] = [null, ns] unless listener?
        @addExpression(event, ns)
        super(event, listener)

    removeListener: (event) ->
        @_expressions[event] = null
        super

    match: (elem) =>
        matched = no
        for event, expression of @_expressions
            if evaluate(expression, [elem], expression.namespace)
                matched = yes
                @emit(event, elem)
        return matched