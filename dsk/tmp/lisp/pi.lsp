(load "/lib/lisp/core.lsp")

(define (pi-digits digits)
  (do
    (define i 0)
    (define q 1)
    (define r 0)
    (define t 1)
    (define k 1)
    (define n 3)
    (define l 3)
    (while (<= i digits)
      (if (< (- (+ (* q 4) r) t) (* n t))
        (do
          (print (string n (if (= i 0) "." "")))
          (set i (+ i 1))
          (define nr (* 10 (- r (* n t))))
          (set n (- (/ (* 10 (+ (* 3 q) r)) t) (* 10 n)))
          (set q (* q 10))
          (set r nr))
        (do
          (define nr (* (+ (* 2 q) r) l))
          (define nn (/ (+ 2 (* q k 7) (* r l)) (* t l)))
          (set q (* q k))
          (set t (* t l))
          (set l (+ l 2))
          (set k (+ k 1))
          (set n nn)
          (set r nr))))
    ""))

(println
  (if (nil? args) "Usage: pi <precision>"
    (pi-digits (string->number (head args)))))
