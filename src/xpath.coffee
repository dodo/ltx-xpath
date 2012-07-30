{ EventEmitter } = require 'events'
{ parse } = require 'xpath-parser'
{ evaluate } = require './evaluate'

class exports.XPath extends EventEmitter
    constructor: () ->
        @_expressions = {}
        @on('newListener', @onlistener)

    onlistener: (event, listener) ->
        return if @_expressions[event]?
        exp = parse event
        exp.event = event
        @_expressions[event] = exp # TODO sort expressions as tree

    removeListener: (event) ->
        @_expressions[event] = null
        super

    match: (elem) =>
        matched = no
        for event, expression of @_expressions
            if evaluate(expression, [elem])
                matched = yes
                @emit(event, elem)
        return matched