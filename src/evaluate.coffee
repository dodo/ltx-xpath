{ isArray } = Array
flatten_map = (arr, fn) ->
    # like Array::map but flattens the result
    arr.reduce(((a,e) -> a.concat(fn(e))), [])

exports.axes = axes =
    'document-root': (n) -> n.root()
    'self':   (n) -> [n]
    'parent': (n) -> n.parent? and [n.parent] or []
    'child':  (n) -> n.children
    'ancestor': (n) ->
        r = []
        r.unshift(n) while (n = n.parent)
        return r
    'ancestor-or-self': (n) ->
        r = axes.ancestor(n)
        r.push(n)
        return r
    'descendant': (n) ->
        flatten_map(n.children, axes['descendant-or-self'])
    'descendant-or-self': (n) ->
        r = axes.descendant(n)
        r.unshift(n)
        return r


exports.evaluate = evaluate = (expressions, nodes, namespaces = {}) ->
    for exp in expressions
        xmlns = namespaces[exp.prefix]
        if exp.axis
            if axes[exp.axis]?
                nodes = flatten_map(nodes, axes[exp.axis])
            else
                console.error "unknown axis '#{exp.axis}'"

        # TODO predicate
        nodes = evaluate(exp.expression, nodes, namespaces) if exp.expression?
        if exp.args
            # TODO args
        else
            nodes = nodes.filter((n) -> n.is(exp.nc, xmlns))
    return nodes

