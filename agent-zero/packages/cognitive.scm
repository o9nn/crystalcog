;;; Agent-Zero Cognitive Package Definitions
;;; This module provides Guix package definitions for cognitive computing packages

(define-module (agent-zero packages cognitive)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system crystal)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages boost)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages opencog))

;; Re-export opencog package as defined in gnu/packages/opencog.scm
(define-public opencog
  (@ (gnu packages opencog) crystalcog))

;; GGML - Machine learning library
;; Note: This is a placeholder package definition for development
;; In production, update the commit hash to a specific version and
;; calculate the correct SHA256 hash using: guix download <url>
(define-public ggml
  (package
    (name "ggml")
    (version "0.1.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ggerganov/ggml")
                    ;; TODO: Pin to specific commit for reproducibility
                    (commit "b2730")))  ; Placeholder commit
              (file-name (git-file-name name version))
              (sha256
               (base32
                ;; TODO: Calculate actual hash using: guix download <url>
                "0000000000000000000000000000000000000000000000000000"))))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f  ; No tests in upstream
       #:make-flags
       (list (string-append "CC=" ,(cc-for-target))
             (string-append "PREFIX=" (assoc-ref %outputs "out")))))
    (native-inputs
     (list gcc-toolchain))
    (synopsis "Tensor library for machine learning")
    (description
     "GGML is a tensor library for machine learning to enable large models and
high performance on commodity hardware.")
    (home-page "https://github.com/ggerganov/ggml")
    (license license:expat)))

;; Guile PLN - Probabilistic Logic Networks
(define-public guile-pln
  (package
    (name "guile-pln")
    (version "0.1.0")
    (source (local-file "../../src/pln" "guile-pln-source"
                        #:recursive? #t))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (guile-site (string-append out "/share/guile/site/3.0")))
               (mkdir-p guile-site)
               (copy-recursively "." guile-site)
               #t))))))
    (native-inputs
     (list guile-3.0))
    (synopsis "Probabilistic Logic Networks for Guile")
    (description
     "Guile-PLN provides Probabilistic Logic Networks reasoning capabilities
for Guile Scheme, part of the CrystalCog project.")
    (home-page "https://github.com/cogpy/crystalcog")
    (license license:agpl3+)))

;; Guile ECAN - Economic Attention Networks
(define-public guile-ecan
  (package
    (name "guile-ecan")
    (version "0.1.0")
    (source (local-file "../../src/attention" "guile-ecan-source"
                        #:recursive? #t))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (guile-site (string-append out "/share/guile/site/3.0")))
               (mkdir-p guile-site)
               (copy-recursively "." guile-site)
               #t))))))
    (native-inputs
     (list guile-3.0))
    (synopsis "Economic Attention Networks for Guile")
    (description
     "Guile-ECAN provides economic attention allocation mechanisms for
cognitive agents, part of the CrystalCog project.")
    (home-page "https://github.com/cogpy/crystalcog")
    (license license:agpl3+)))

;; Guile MOSES - Meta-Optimizing Semantic Evolutionary Search
(define-public guile-moses
  (package
    (name "guile-moses")
    (version "0.1.0")
    (source (local-file "../../src/moses" "guile-moses-source"
                        #:recursive? #t))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (guile-site (string-append out "/share/guile/site/3.0")))
               (mkdir-p guile-site)
               (copy-recursively "." guile-site)
               #t))))))
    (native-inputs
     (list guile-3.0))
    (synopsis "Meta-Optimizing Semantic Evolutionary Search for Guile")
    (description
     "Guile-MOSES provides program learning and evolutionary optimization
algorithms for Guile Scheme, part of the CrystalCog project.")
    (home-page "https://github.com/cogpy/crystalcog")
    (license license:agpl3+)))

;; Guile Pattern Matcher
(define-public guile-pattern-matcher
  (package
    (name "guile-pattern-matcher")
    (version "0.1.0")
    (source (local-file "../../src/pattern_matching" "guile-pattern-matcher-source"
                        #:recursive? #t))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (guile-site (string-append out "/share/guile/site/3.0")))
               (mkdir-p guile-site)
               (copy-recursively "." guile-site)
               #t))))))
    (native-inputs
     (list guile-3.0))
    (synopsis "Pattern matching for cognitive systems")
    (description
     "Guile-Pattern-Matcher provides advanced pattern matching capabilities
for cognitive systems, part of the CrystalCog project.")
    (home-page "https://github.com/cogpy/crystalcog")
    (license license:agpl3+)))

;; Guile Relex - Relationship Extraction
(define-public guile-relex
  (package
    (name "guile-relex")
    (version "0.1.0")
    (source (local-file "../../src/nlp" "guile-relex-source"
                        #:recursive? #t))
    (build-system gnu-build-system)
    (arguments
     `(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'configure)
         (delete 'build)
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (guile-site (string-append out "/share/guile/site/3.0")))
               (mkdir-p guile-site)
               (copy-recursively "." guile-site)
               #t))))))
    (native-inputs
     (list guile-3.0))
    (synopsis "Relationship extraction for natural language processing")
    (description
     "Guile-Relex provides relationship extraction and natural language
processing capabilities for Guile Scheme, part of the CrystalCog project.")
    (home-page "https://github.com/cogpy/crystalcog")
    (license license:agpl3+)))
