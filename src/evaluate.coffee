{ isArray } = Array
foldl = (arr, fn) ->
    # like Array::map but flattens the result
    arr.reduce(((a,e) -> a.concat(fn(e))), [])

exports.axes = axes =
    'document-root': (n) -> n.root()
    'self':   (n) -> [n]
    'parent': (n) -> n.parent? and [n.parent] or []
    'child':  (n) -> n.children ? []
    'attribute': (n, {nc}) -> n.attrs[nc]? and [n.attrs[nc]] or []
    'ancestor': (n) ->
        r = []
        r.unshift(n) while (n = n.parent)
        return r
    'ancestor-or-self': (n) ->
        r = axes.ancestor(n)
        r.push(n)
        return r
    'descendant': (n) ->
        foldl(n.children ? [], axes['descendant-or-self'])
    'descendant-or-self': (n) ->
        r = axes.descendant(n)
        r.unshift(n)
        return r


exports.operations = operations =
    'union': (args) -> foldl(args, (n) -> n())
    'or': (args) -> (a = args[0]()).length and a or args[1]()
    'and': (args) -> [operations.union(args).every((e) -> e is true)]
    '=': (args) -> args[0]()[0] is args[1]()[0]

exports.functions = functions =
    'node': (args, nodes) ->
        if args.length > 1 or Object.keys(args[0]).length > 0
            console.warn "ignoring arguments"
        nodes.filter((n) -> n?.is?)
    'text': (args, nodes) ->
        # FIXME args
        nodes.filter((n) -> typeof n is 'string')


exports.evaluate = evaluate = (expressions, nodes, namespaces = {}) ->
    for exp in expressions
        nodes = evaluate(exp.expression, nodes, namespaces) if exp.expression?
        xmlns = namespaces[exp.prefix]
        if exp.axis
            if (axis = axes[exp.axis])?
                nodes = foldl nodes, (n) ->
                    predicate = [true]
                    if exp.predicate?
                        # only add acis nodes when predicate evaluates to true
                        predicate = foldl exp.predicate.slice(), (pred) ->
                            evaluate(pred, [n], namespaces)
                    return if predicate[0] then axis(n, exp) else []
            else
                console.error "unknown axis '#{exp.axis}'"

        if exp.args
            args = exp.args.slice().map (arg) ->
                # only evaluate if needed
                (() -> evaluate(arg, nodes.slice(), namespaces))
            if exp.operator?
                if operations[exp.operator]?
                    nodes = operations[exp.operator](args)
                else
                    console.error "unknown operator '#{exp.operator}'"
            else if exp.nc?
                if functions[exp.nc]?
                    nodes = functions[exp.nc](args, nodes)
                else
                    console.error "unknown function '#{exp.nc}'"
        else if exp.nc?
            nodes = nodes.filter((n) -> n.is?(exp.nc, xmlns) ? true)
        if exp.value
            nodes = nodes.filter((n) -> not n.is?)
            nodes.push exp.value
    return nodes

