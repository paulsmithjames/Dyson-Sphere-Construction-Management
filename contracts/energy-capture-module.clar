;; Energy Capture Module Contract

(define-data-var next-module-id uint u0)

(define-map modules
  { module-id: uint }
  {
    position: (tuple (x int) (y int) (z int)),
    efficiency: uint,
    status: (string-ascii 20)
  }
)

(define-public (register-module (x int) (y int) (z int) (efficiency uint))
  (let
    ((module-id (+ (var-get next-module-id) u1)))
    (var-set next-module-id module-id)
    (ok (map-set modules
      { module-id: module-id }
      {
        position: { x: x, y: y, z: z },
        efficiency: efficiency,
        status: "active"
      }
    ))
  )
)

(define-public (update-module-status (module-id uint) (new-status (string-ascii 20)))
  (let
    ((module (unwrap! (map-get? modules { module-id: module-id }) (err u404))))
    (ok (map-set modules
      { module-id: module-id }
      (merge module { status: new-status })
    ))
  )
)

(define-read-only (get-module (module-id uint))
  (map-get? modules { module-id: module-id })
)

