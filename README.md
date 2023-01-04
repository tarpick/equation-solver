# equation-solver
Automated solution of equations of degree 1

Written in Chicken Scheme, so there may be some default bindings
provided by that particular Scheme implementation (e.g., alist-ref)

# equation format
```
(entry1 entry2 ...)
```

... where entry is of format:

```
(sign-identity-multiplier term1 term2 ...)
```

This encodes equations of the form:
```
product1*product2 + product3*product4 + ... = 0
```

# sample usage (thermodynamics law #1)
```
(define my-equation '((1.0 m1 tf) (1.0 m2 tf) (-1.0 m1 t1) (-1.0 m2 t2)))
```
# final temperature after mixing a 25g ice cube into 200g of boiling water
```
(define bindings '((m1 . 25.0) (t1 . 0.0) (m2 . 200.0) (t2 . 100.0)))
```

# solving for final temperature
```
(solve 'tf my-equation)
```

# calculating final temperature (Celsius)
```
(calculate my-equation bindings)
```
