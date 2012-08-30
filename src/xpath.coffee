{ EventEmitter } = require 'events'
{ parse } = require 'xpath-parser'
{ evaluate } = require './evaluate'

class exports.XPath extends EventEmitter
    constructor: () ->
        @_expressions = {}

    addListener: (event, ns, listener) ->
        return super(event, listener) if @_expressions[event]?
        [ns, listener] = [null, ns] unless listener?
        exp = parse event
        exp.event = event
        exp.namespace = ns
        @_expressions[event] = exp # TODO sort expressions as tree
        super(event, listener)
    on:@addListener

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