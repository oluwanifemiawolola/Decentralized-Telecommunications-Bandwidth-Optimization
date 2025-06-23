;; Network Engineer Verification Contract
;; Manages verification and credentials of network engineers

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_VERIFIED (err u101))
(define-constant ERR_NOT_VERIFIED (err u102))
(define-constant ERR_INVALID_CREDENTIALS (err u103))

;; Data structures
(define-map verified-engineers principal {
    verified: bool,
    certification-level: uint,
    verification-date: uint,
    specialization: (string-ascii 50)
})

(define-map engineer-credentials principal {
    years-experience: uint,
    certifications: (list 10 (string-ascii 30)),
    reputation-score: uint
})

;; Read-only functions
(define-read-only (is-engineer-verified (engineer principal))
    (default-to false (get verified (map-get? verified-engineers engineer)))
)

(define-read-only (get-engineer-info (engineer principal))
    (map-get? verified-engineers engineer)
)

(define-read-only (get-engineer-credentials (engineer principal))
    (map-get? engineer-credentials engineer)
)

;; Public functions
(define-public (verify-engineer (engineer principal) (cert-level uint) (specialization (string-ascii 50)))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (is-engineer-verified engineer)) ERR_ALREADY_VERIFIED)
        (asserts! (> cert-level u0) ERR_INVALID_CREDENTIALS)

        (map-set verified-engineers engineer {
            verified: true,
            certification-level: cert-level,
            verification-date: block-height,
            specialization: specialization
        })

        (ok true)
    )
)

(define-public (update-credentials (years uint) (certs (list 10 (string-ascii 30))))
    (begin
        (asserts! (is-engineer-verified tx-sender) ERR_NOT_VERIFIED)

        (map-set engineer-credentials tx-sender {
            years-experience: years,
            certifications: certs,
            reputation-score: (+ years (* (len certs) u10))
        })

        (ok true)
    )
)

(define-public (revoke-verification (engineer principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-engineer-verified engineer) ERR_NOT_VERIFIED)

        (map-delete verified-engineers engineer)
        (ok true)
    )
)
