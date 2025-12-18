import sys

from pair import *
from scheme_utils import *
from ucb import main, trace

import scheme_forms

##############
# Eval/Apply #
##############

def scheme_eval(expr, env, _=None): # Optional third argument is ignored
    """Evaluate Scheme expression EXPR in Frame ENV.
    env代表就代表帧及其父帧，而built-in函数也在env中，通过lookup函数，返回的就是Procedure类
    >>> expr = read_line('(+ 2 2)')
    >>> expr
    Pair('+', Pair(2, Pair(2, nil)))
    >>> scheme_eval(expr, create_global_frame())
    4
    """
    # Evaluate atoms
    if scheme_symbolp(expr):
        return env.lookup(expr)
    elif self_evaluating(expr):
        return expr

    # All non-atomic expressions are lists (combinations)
    if not scheme_listp(expr):
        raise SchemeError('malformed list: {0}'.format(repl_str(expr)))
    first, rest = expr.first, expr.rest
    if scheme_symbolp(first) and first in scheme_forms.SPECIAL_FORMS:
        return scheme_forms.SPECIAL_FORMS[first](rest, env)
    else:
        # BEGIN PROBLEM 3
        if isinstance(first,Pair):
            first = scheme_eval(first,env)
            
            
        ''' 这里oprands列表查找是通过迭代方式，可以通过递归方式来实现to be continued...  first不用修改因为其最后一定评估为procedure'''    
        sub_list,p = nil,Pair(63,nil)
        while rest is not nil:
            #评估除当前oprator外的其他所有的oprands
            p.rest = Pair(scheme_eval(rest.first,env),nil)
            if sub_list == nil:
                sub_list = p.rest
            rest,p = rest.rest,p.rest
        
        #寻找first symbol对应的过程，可能存在多次绑定
        realprocedure = first
        while not isinstance(realprocedure,Procedure):
            realprocedure = env.lookup(realprocedure)
            
        return scheme_apply(realprocedure,sub_list,env)
        
        # END PROBLEM 3
        #
        # 卡点：
        # Pair逻辑结构不清晰，不能合理访问成员-->视为链表访问即可
        # 对表达式的评估过程还是没有准确认识-->()内就两种情况，关键在于将为评估的部分视为一个整体
        # case1 --> (operators oprands oprands ...) 即单操作符跟多操作数情况，其中操作数可能有嵌套，嵌套情况注意将其递归评估后得到val后再参与参数列表然后操作
        # case2 --> (oprators oprands) 操作符内部有评估，这时只需要优先评估操作符内部后，再按case1处理即可
        # special case --> oprands操作数可能为symbol，这时也需要递归评估得到值或者函数执行
 
def scheme_apply(procedure, args, env):
    """Apply Scheme PROCEDURE to argument values ARGS (a Scheme list) in
    Frame ENV, the current environment."""
    validate_procedure(procedure)
    if not isinstance(env, Frame):
       assert False, "Not a Frame: {}".format(env)
    if isinstance(procedure, BuiltinProcedure):
        # BEGIN PROBLEM 2
        realargs = list()
        while args is not nil:
            realargs.append(args.first)
            args = args.rest
        else:
            realargs.append(env) if procedure.need_env else 0
        # END PROBLEM 2
        try:
            # BEGIN PROBLEM 2
            return procedure.py_func(*realargs)
            # END PROBLEM 2
        except TypeError as err:
            raise SchemeError('incorrect number of arguments: {0}'.format(procedure))
    elif isinstance(procedure, LambdaProcedure):
        # BEGIN PROBLEM 9
        childFrame = procedure.env.make_child_frame(procedure.formals,args)
        return eval_all(procedure.body,childFrame)
        # END PROBLEM 9
    elif isinstance(procedure, MuProcedure):
        # BEGIN PROBLEM 11
        childFrame = env.make_child_frame(procedure.formals,args)
        return eval_all(procedure.body,childFrame)
        # END PROBLEM 11
    else:
        assert False, "Unexpected procedure: {}".format(procedure)

def eval_all(expressions, env):
    """Evaluate each expression in the Scheme list EXPRESSIONS in
    Frame ENV (the current environment) and return the value of the last.

    >>> eval_all(read_line("(1)"), create_global_frame())
    1
    >>> eval_all(read_line("(1 2)"), create_global_frame())
    2
    >>> x = eval_all(read_line("((print 1) 2)"), create_global_frame())
    1
    >>> x
    2
    >>> eval_all(read_line("((define x 2) x)"), create_global_frame())
    2
    """
    # BEGIN PROBLEM 6
    res = None
    while expressions is not nil:
        res = scheme_eval(expressions.first,env)
        expressions = expressions.rest
    return res # replace this with lines of your own code
    # END PROBLEM 6


################################
# Extra Credit: Tail Recursion #
################################

class Unevaluated:
    """An expression and an environment in which it is to be evaluated."""

    def __init__(self, expr, env):
        """Expression EXPR to be evaluated in Frame ENV."""
        self.expr = expr
        self.env = env

def complete_apply(procedure, args, env):
    """Apply procedure to args in env; ensure the result is not an Unevaluated."""
    # if isinstance(procedure,str):
    #     procedure = scheme_eval(procedure,env)
    validate_procedure(procedure)
    val = scheme_apply(procedure, args, env)
    if isinstance(val, Unevaluated):
        return scheme_eval(val.expr, val.env)
    else:
        return val

def optimize_tail_calls(unoptimized_scheme_eval):
    """Return a properly tail recursive version of an eval function."""
    def optimized_eval(expr, env, tail=False):
        """Evaluate Scheme expression EXPR in Frame ENV. If TAIL,
        return an Unevaluated containing an expression for further evaluation.
        """
        if tail and not scheme_symbolp(expr) and not self_evaluating(expr):
            return Unevaluated(expr, env)

        result = Unevaluated(expr, env)
        # BEGIN OPTIONAL PROBLEM 1
        "*** YOUR CODE HERE ***"
        # END OPTIONAL PROBLEM 1
    return optimized_eval














################################################################
# Uncomment the following line to apply tail call optimization #
################################################################

# scheme_eval = optimize_tail_calls(scheme_eval)
