# U — Language Specification

This document specifies the U programming language. It is a complete, concise, and authoritative specification covering lexical structure, grammar, keywords, type system, execution model, and examples.

**Notation.** The grammar is given in extended Backus–Naur Form (EBNF). Terminal tokens are shown in quotes. Nonterminals are in angle brackets. Optional elements are in `[...]`. Repetition is indicated with `{...}`.

**File:** [U_LANGUAGE.md](U_LANGUAGE.md)

---

## 1. Overview

U is a small, script-oriented language combining declarative `model` data blocks and imperative `func` procedures. U files may include a shebang for direct execution. Statements terminate with semicolons (`;`). U emphasizes concise configuration and control-flow primitives including deterministic error-handling constructs.

## 2. Lexical Structure

- Line comments: `#` until end-of-line. A shebang is a comment-like token beginning a file, e.g. `#u/sh!`.
- Identifiers: start with an ASCII letter or underscore, followed by letters, digits, underscores, or punctuation characters allowed in property names (see section 4).
- String literal: double-quoted sequences, supporting typical escape sequences `\\n`, `\\"`, `\\\\`.
- Numeric literal: sequence of digits (optional fractional and exponent forms may be implemented by toolchains).
- Special literal: `undefined`, `true`, `false`.
- Statement terminator: `;` (required between statements).

## 3. Tokens and Operators

- Assignment and separators: `=`, `:`, `;`, `,`, `{`, `}`.
- Access and mapping: `.` (property access), `?.` (optional-safe access), `=>` (forwarding / mapping operator).
- Logical and boolean: `||` (logical or). Equality/comparison includes extended operators like `===?` for strict/nullable checks.
- Negation/flags: a leading `!` may be applied to identifiers to mark negation or flagged entries in configuration contexts.

## 4. Grammar (EBNF)

Top-level program:

<program> ::= { <directive> | <declaration> | <statement> }

Directives and comments:

<directive> ::= <shebang> | <comment>
<shebang> ::= '#u/sh!'
<comment> ::= '#' <any-chars> '\\n'

Declarations:

<declaration> ::= <model-decl> | <func-decl> | <var-decl>

<model-decl> ::= 'model' <identifier> '=' '{' { <model-entry> } '}' ';'
<model-entry> ::= <property> ':' <expression> ';' | <model-decl>

<func-decl> ::= 'func' <identifier> '(' [ <param-list> ] ')' '{' { <statement> } '}'
<param-list> ::= <param> { <param> }
<param> ::= <identifier> ':' <type>

<var-decl> ::= 'var' ':' <type> <identifier> '=' <expression> ';'

Statements and expressions:

<statement> ::= <expression> ';' | <control-block>
<expression> ::= <literal> | <identifier> | <call> | <access> | <mapping>
<call> ::= <expression> '(' [ <arg-list> ] ')'
<arg-list> ::= <expression> { ',' <expression> }
<access> ::= <expression> '.' <identifier> | <expression> '?.' <identifier>
<mapping> ::= <expression> '=>' <expression>

Control constructs and special blocks:

<control-block> ::= <if-block> | <listen-block> | <try-block> | <return-stmt>
<if-block> ::= 'if' '(' <expression> ')' <statement>
<listen-block> ::= 'listen' '{' { <statement> } '}'
<try-block> ::= 'try' { <try-modifier> } '{' { <statement> } '}' [ <try-tail> ]
<try-modifier> ::= 'too' | 'also' | 'or'
<try-tail> ::= 'return' <expression> ';' | <statement>
<return-stmt> ::= 'return' <expression> ';'

Types:

<type> ::= 'Str' | 'Boo' | 'Num' | 'Any' | <identifier>

Literals:

<literal> ::= <string> | <number> | 'undefined' | 'true' | 'false'

Notes:
- The grammar treats `model` entries as first-class nested declarations. A `model` may contain properties whose keys may include punctuation and leading `!` flags.
- The sequence `try too`, `try also`, and `try or` form a chained error-handling construct; their precise semantic behavior is defined in the execution model below.

## 5. Keywords

The reserved keywords in U include at least:

- `model`, `func`, `var`, `try`, `too`, `also`, `or`, `listen`, `if`, `return`, `undefined`, `true`, `false`.

Additional reserved identifiers used idiomatically: `shebang` (`#u/sh!` comment) and property-prefix `!` for flagged model entries.

Identifiers may nonetheless include punctuation characters when used as model keys; when in expression context they follow standard identifier rules.

## 6. Type System

U uses a lightweight, nominal type annotation syntax. Types are optional at runtime but recommended for clarity in function signatures and variable declarations. The core types are `Str`, `Boo`, `Num`, and `Any`. Type annotations are primarily syntactic and may be used by tooling for static checks; the runtime performs dynamic typing with the following semantics:

- `Str`: string values.
- `Boo`: boolean values `true` or `false`.
- `Num`: numeric values.
- `Any`: no constraint.

Unannotated variables are dynamically typed. `undefined` represents absence of value.

## 7. Execution Model

Program start:

- A U program executes top-to-bottom. Declarations (`model`/`func`/`var`) create bindings in the current module scope.
- If a shebang `#u/sh!` is present and the file is executed by an appropriate runner, its directive is honored by the host environment.

Scoping:

- U uses lexical scoping. `model` blocks create nested scopes for their entries. Functions declared with `func` capture outer lexical bindings.

Function calls and mapping:

- A call is written as `f(x, y)`. The mapping operator `=>` forwards an expression into another expression or handler: `expr => handler` applies `handler` to the value of `expr` (commonly used for concise transformations and continuation-style wiring).

Error handling and `try` chains:

- U provides a deterministic chainable error-control construct using `try` with modifiers `too`, `also`, `or`. The semantics are:
  - `try { ... }` executes the block normally; if it completes without runtime errors, execution continues past the `try` block.
  - `try too { ... }` attaches an immediate recovery or post-action that runs if the `try` block succeeds or fails depending on context (tooling and host may interpret `too` as "also execute on success" or as a shorthand for an associated handler; authors should select consistent semantics in a toolchain).
  - `also` and `or` are used to chain multiple handlers or fallback alternatives; `or` typically denotes fallback behavior when previous branches fail.

Example pattern:

```
try too {
    doSomething();
} or return { error: "failure" };
```

This pattern expresses a primary attempt, followed by alternative handling or explicit returns on error.

`listen` block:

- `listen { ... }` defines an event/trigger block that evaluates its contained statements when executed. It is commonly used for dynamic initialization and conditional wiring.

Property access and optional-safe access:

- `a.b` accesses property `b` on `a`. If `a` may be absent, `a?.b` performs safe access returning `undefined` when `a` is absent.

Special flagged entries:

- A model property may include a `!` prefix, e.g. `!important: /path/*;`. Such flagged entries are first-class keys in the model but are conventionally treated specially by consuming tooling (e.g., higher priority, exclusion/inclusion rules).

## 8. Standard Library and Host Interop

U is designed to be embedded in host runtimes. Host-specific bindings (like `os`, `g`, `body`) are provided by the runtime environment. The language defines no mandatory standard library in the core spec; each runtime provides its own integration points.

## 9. Examples

Model definition:

```
model gh = {
    res: os/bin/*;
    acc: /;
    g: /*;
    ignore: /dist*;
    ignore: /gh*;
    !important: /os/!*;
    model i = {
        module: true;
    };
};
```

Function and control flow example:

```
func initInstall(scope:Str isSilent:Boo shell:Str) {
    try too {
        g.slot(token, !gh.?!important);
        return;
    };

    listen {
        if (initInstall.hasPassed("randomos run*")) try too {
            g.slice();
        };
        {
            var:Str shell = undefined || listen {
                if (initInstall.hasPassed(shell)) => (body.getBody( /* ... */ ));
            };
            if (var ===? "powershell") return {
                errorCompose(() => ({ status: 418, error: "go away windows" }));
            }
            try also or try too or try or return {
                log(errorCompose.output, ());
            };
            return {};
        }
    }
}
```

Notes:
- The examples above illustrate typical U idioms: `model` for structured configuration, `func` for procedures, `listen` for event/trigger blocks, and `try` chains for robust control flow.

## 10. Tooling and Implementation Guidance

- Parsers: implement a two-phase parser (lexical then syntactic) with explicit semicolon termination; treat `model` keys with flexible identifier rules.
- Type checking: provide optional static checks for annotated `var` and `func` parameters; accept `undefined` as a possible runtime value unless statically narrowed.
- Runtime: implement lexical scoping, first-class model objects (map/dict like), and first-class functions with closures.

## 11. Open Questions and Extension Points

This specification defines a stable core suitable for implementations. Implementers may extend U with additional standard types, pattern matching, or macro systems. For exact semantics of `try too` / `try also` / `or` and the `=>` forwarding operator, implementers should pick and document one consistent behavior (the examples above show recommended behavior for portable tooling).


