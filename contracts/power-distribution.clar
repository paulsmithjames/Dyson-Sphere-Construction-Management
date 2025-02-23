;; Power Distribution Contract

(define-map power-allocation
  { consumer-id: uint }
  { allocated-power: uint }
)

(define-data-var total-power uint u0)

(define-public (allocate-power (consumer-id uint) (amount uint))
  (let
    ((current-allocation (default-to u0 (get allocated-power (map-get? power-allocation { consumer-id: consumer-id })))))
    (if (<= (+ amount (var-get total-power)) u1000000)
      (begin
        (var-set total-power (+ (var-get total-power) amount))
        (ok (map-set power-allocation
          { consumer-id: consumer-id }
          { allocated-power: (+ current-allocation amount) }
        ))
      )
      (err u400)
    )
  )
)

(define-public (deallocate-power (consumer-id uint) (amount uint))
  (let
    ((current-allocation (default-to u0 (get allocated-power (map-get? power-allocation { consumer-id: consumer-id })))))
    (if (>= current-allocation amount)
      (begin
        (var-set total-power (- (var-get total-power) amount))
        (ok (map-set power-allocation
          { consumer-id: consumer-id }
          { allocated-power: (- current-allocation amount) }
        ))
      )
      (err u400)
    )
  )
)

(define-read-only (get-power-allocation (consumer-id uint))
  (map-get? power-allocation { consumer-id: consumer-id })
)

(define-read-only (get-total-power)
  (var-get total-power)
)

