;; Construction Coordination Contract

(define-data-var next-task-id uint u0)

(define-map construction-tasks
  { task-id: uint }
  {
    module-id: uint,
    task-type: (string-ascii 50),
    priority: uint,
    status: (string-ascii 20)
  }
)

(define-public (create-task (module-id uint) (task-type (string-ascii 50)) (priority uint))
  (let
    ((task-id (+ (var-get next-task-id) u1)))
    (var-set next-task-id task-id)
    (ok (map-set construction-tasks
      { task-id: task-id }
      {
        module-id: module-id,
        task-type: task-type,
        priority: priority,
        status: "pending"
      }
    ))
  )
)

(define-public (update-task-status (task-id uint) (new-status (string-ascii 20)))
  (let
    ((task (unwrap! (map-get? construction-tasks { task-id: task-id }) (err u404))))
    (ok (map-set construction-tasks
      { task-id: task-id }
      (merge task { status: new-status })
    ))
  )
)

(define-read-only (get-task (task-id uint))
  (map-get? construction-tasks { task-id: task-id })
)

