{ isArray } = Array
foldl = (arr, fn) ->
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
        foldl(n.children, axes['descendant-or-self'])
    'descendant-or-self': (n) ->
        r = axes.descendant(n)
        r.unshift(n)
        return r

exports.operations = operations =
    'union': (args) -> foldl(args, (n) -> n())
    'or': (args) -> (a = args[0]()).length and a or args[1]()
    'and': (args) -> operations.union(args)

exports.evaluate = evaluate = (expressions, nodes, namespaces = {}) ->
    for exp in expressions
        nodes = evaluate(exp.expression, nodes, namespaces) if exp.expression?
        xmlns = namespaces[exp.prefix]
        if exp.axis
            if axes[exp.axis]?
                nodes = foldl(nodes, axes[exp.axis])
            else
                console.error "unknown axis '#{exp.axis}'"

        # TODO predicate
        if exp.args
            # TODO args
            if exp.operator?
                if operations[exp.operator]?
                    args = exp.args.slice().map (arg) ->
                        # only evaluate if needed
                        (() -> evaluate(arg, nodes.slice(), namespaces))
                    nodes = operations[exp.operator](args)
                else
                    console.error "unknown operator '#{exp.operator}'"
        else
            nodes = nodes.filter((n) -> n.is(exp.nc, xmlns)) if exp.nc?
    return nodes

