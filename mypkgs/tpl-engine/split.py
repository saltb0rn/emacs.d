import re
import sys
regex = "(?s)({{.*?}}|{%.*?%}|{#.*?#})"

text = """
<p>Welcome, {{user_name}}!</p>
<p>Products:</p>
<ul>
{% for product in product_list %}
    <li>{{ user_name }}:
        {{(or price format_price)}}</li>
{% endfor %}
</ul>
"""


def get_tokens(text, regex=regex):
    return re.split(regex, text)


tokens = get_tokens(text)


# code_builder : (list-of string) -> string
def code_builder(tokens, data_context=None):
    """compile tokens into elisp code string"""
    data_context = data_context if data_context else dict()
    bindings = []
    binding_append = bindings.append
    body = []
    code_result = ["(let ("]
    body_append = body.append
    ops_stack = []              # check the "endif" tag if matchs "if" tag
    match = re.match

    for var, val in data_context.items():
        if isinstance(val, list):
            res = "(list"
            for item in val:
                res += ' "%s"' % item
            val = res + ")"
            binding_append("%s(%s %s)" % ("" if bindings else " ", var, val))
        elif isinstance(val, str):
            binding_append('%s(%s "%s")' % ("" if bindings else " ", var, val))
        else:
            binding_append("%s(%s %s)" % ("" if bindings else " ", var, val))
    code_result.extend(bindings)
    code_result.extend([")", " (concat"])
    for token in tokens:
        if token.startswith("{#"):
            pass
        elif token.startswith("{{"):
            # value/variable tag: an expression to be evaluated
            expr = token[2:-2].strip()
            body_append(' (format %s %s)' % ('"%s"', expr))
        elif token.startswith("{%"):
            # action tag: split into words and parse futher
            words = token[2:-2].strip().split()
            stmt = words[0]
            assert stmt
            if stmt == "if":
                # An if statement: evaluate the expression
                ops_stack.append("if")
                assert stmt > 1
                if len(words) == 2:
                    body_append("(if %s" % words[1])
                else:
                    if words[2].startswith("(") and words[-1].endswith(")"):
                        for word in words[1:]:
                            body_append(word)
            elif stmt == "for":
                # A loop: iterate over expression results
                ops_stack.append("for")
                if len(words[1:]) == 3 and words[2] == "in":
                    body_append((" (let (value) (dolist (%s %s value)"
                                 " (setq value (concat value")
                                % (words[1], words[3]))
                else:
                    raise Exception
            elif match("end(if|for)", stmt):
                if len(words) != 1:
                    raise Exception
                else:
                    assert words
                    last_in = ops_stack.pop()
                    if stmt.endswith("if"):
                        assert last_in == "if"
                        body_append(")")
                    elif stmt.endswith("for"):
                        assert last_in == "for"
                        body_append("))))")
            else:
                raise Exception
        else:
            if token:
                body_append(' "%s"' % token.strip())
    code_result.extend(body)
    code_result.extend([")", ")"])
    return "".join(code_result)


res = code_builder(get_tokens(text),
                   dict(
                       product_list=["PC", "Switch", "XBOX", "PS4"],
                       price="300rmb",
                       format_price=200,
                       user_name=1
                   ))

sys.stdout.write(res)
