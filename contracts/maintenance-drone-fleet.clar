;; Maintenance Drone Fleet Contract

(define-data-var next-drone-id uint u0)

(define-map drones
  { drone-id: uint }
  {
    status: (string-ascii 20),
    current-task: (optional uint)
  }
)

(define-public (register-drone)
  (let
    ((drone-id (+ (var-get next-drone-id) u1)))
    (var-set next-drone-id drone-id)
    (ok (map-set drones
      { drone-id: drone-id }
      {
        status: "idle",
        current-task: none
      }
    ))
  )
)

(define-public (assign-task (drone-id uint) (task-id uint))
  (let
    ((drone (unwrap! (map-get? drones { drone-id: drone-id }) (err u404))))
    (ok (map-set drones
      { drone-id: drone-id }
      (merge drone {
        status: "busy",
        current-task: (some task-id)
      })
    ))
  )
)

(define-public (complete-task (drone-id uint))
  (let
    ((drone (unwrap! (map-get? drones { drone-id: drone-id }) (err u404))))
    (ok (map-set drones
      { drone-id: drone-id }
      (merge drone {
        status: "idle",
        current-task: none
      })
    ))
  )
)

(define-read-only (get-drone-status (drone-id uint))
  (map-get? drones { drone-id: drone-id })
)

