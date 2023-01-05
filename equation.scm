; m1*tf + m2*tf - m1*t1 - m2*t2 = 0

; ((coeff degree) ...)

; ((sign product1 product2 ...) ...)

(define *equation* '((1.0 m1 tf) (1.0 m2 tf) (-1.0 m1 t1) (-1.0 m2 t2)))

(define (remove element lst)
  (cond ((null? lst)
         '())
        ((equal? element (car lst))
         (remove element (cdr lst)))
        (else
         (cons (car lst) (remove element (cdr lst))))))

(define (invert-sign equation)
  (if (null? equation)
      equation
      (let* ((entry (car equation))
             (multiplier (car entry))
             (inverse-multiplier (* -1.0 multiplier)))
        (cons (cons inverse-multiplier (cdr entry))
              (invert-sign (cdr equation))))))

(define (partition-by-variable variable equation)
  (define (add-to-bucket expression bucket)
    (let ((lhs (car bucket))
          (rhs (cdr bucket)))
      (if (member variable (cdr expression))
          (cons (cons (remove variable expression) lhs) rhs)
          (cons lhs (cons expression rhs)))))
  (define (recur equation result)
    (if (null? equation)
        result
        (recur (cdr equation)
               (add-to-bucket (car equation) result))))
  (recur equation '(())))

(define (solve variable equation)
  (define (prepend-mult lst)
    (map (lambda (l) (cons '* l)) lst))
  (define (process coefficient . constants)
    (cond ((null? coefficient)
           constants)
          ((and (= 1 (length coefficient))
                (> 0 (caar coefficient)))
           (list constants (invert-sign coefficient)))
          (else
           (list (invert-sign constants) coefficient))))
  (cons '/
        (map (lambda (e) (cons '+ e))
             (map prepend-mult
                  (apply process
                         (partition-by-variable variable equation))))))

(define (find-unknown-var bindings equation)
  (define (unique lst)
    (cond ((null? lst)
           lst)
          ((member (car lst) (cdr lst))
           (unique (cdr lst)))
          (else
           (cons (car lst) (unique (cdr lst))))))
  (define (remove-entries ents lst)
    (if (null? ents)
        (unique lst)
        (remove-entries (cdr ents) (remove (car ents) lst))))
  (let ((known-vars (map car bindings))
        (eqn-vars (flatten (map cdr equation))))
    (remove-entries known-vars eqn-vars)))

(define (substitute bindings expression)
  (cond ((null? expression)
         '())
        ((pair? (car expression))
         (cons (substitute bindings (car expression))
               (substitute bindings (cdr expression))))
        (else
         (cons (alist-ref (car expression) bindings eqv? (car expression))
               (substitute bindings (cdr expression))))))

(define (calculate equation bindings)
  (let ((var (find-unknown-var bindings equation)))
    (if (not (= 1 (length var)))
        (error "too many unknown variables")
        (let* ((solution (solve (car var) equation))
               (expr (substitute bindings solution)))
          (print solution)
          (print expr)
          (eval expr)))))
