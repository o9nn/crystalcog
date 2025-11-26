;;; GNU Guix --- Functional package management for GNU
;;; CrystalCog OpenCog Package Definitions
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.

(define-module (gnu packages opencog)
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
  #:use-module (gnu packages pkg-config))

(define-public crystalcog
  (package
    (name "crystalcog")
    (version "0.1.0")
    (source (local-file "../.." "crystalcog-checkout"
                        #:recursive? #t
                        #:select? (git-predicate (dirname (current-filename)))))
    (build-system crystal-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'configure
           (lambda* (#:key inputs outputs #:allow-other-keys)
             #t))
         (replace 'build
           (lambda _
             (invoke "shards" "install")
             (invoke "shards" "build" "--release")))
         (replace 'check
           (lambda _
             (invoke "crystal" "spec")))
         (replace 'install
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (bin (string-append out "/bin"))
                    (lib (string-append out "/lib"))
                    (share (string-append out "/share/crystalcog")))
               (mkdir-p bin)
               (mkdir-p lib)
               (mkdir-p share)
               (copy-recursively "bin" bin)
               (copy-recursively "src" (string-append lib "/src"))
               (copy-recursively "docs" (string-append share "/docs"))
               #t))))))
    (native-inputs
     (list pkg-config))
    (inputs
     (list boost
           guile-3.0
           postgresql
           sqlite))
    (synopsis "Crystal language implementation of the OpenCog framework")
    (description
     "CrystalCog is a complete rewrite of the OpenCog artificial intelligence
system in Crystal language.  It provides better performance, memory safety, and
maintainability compared to the original C++/Python implementation.

OpenCog is a framework for building artificial general intelligence (AGI)
systems.  It includes:
- AtomSpace: Knowledge representation and storage
- PLN: Probabilistic Logic Networks for reasoning
- URE: Unified Rule Engine for inference
- Pattern Matcher: Complex pattern recognition
- NLP: Natural language processing components
- Distributed networking for multi-agent systems")
    (home-page "https://github.com/cogpy/crystalcog")
    (license license:agpl3+)))

(define-public opencog
  ;; Alias for compatibility with existing manifests
  crystalcog)
