{ isArray } = Array
flatten_map = (arr, fn) ->
    # like Array::map but flattens the result
    arr.reduce(((a,e) -> a.concat(fn(e))), [])

exports.evaluate = evaluate = (expressions, nodes, namespaces = {}) ->
    for exp in expressions
        xmlns = namespaces[exp.prefix]
        # TODO axis
        # TODO predicate
        # TODO args
        nodes = evaluate(exp.expression, nodes, namespaces) if exp.expression?
        nodes = flatten_map(nodes, (n) -> n.getChildren(exp.nc, xmlns))
    return nodes

