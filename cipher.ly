
\version "2.18.0"

#(define-public (jianpuCipherMap) (list '(1 . "1") '(2 . "2") '(3 . "3")
                       '(4 . "4") '(5 . "5") '(6 . "6") '(7 . "7")
                       '("o-3" . "̤̣") '("o-2" . "̤") '("o-1" . "̣") '("o0" . "")
                       '("o1" . "̇") '("o2" . "̈") '("o3" . "̈̇") '("o4" . "̈̈")
                       '(-1 . "–") '(-2 . "0") '("dot" . ".")))
#(define-public (lisuCipherMap) (list '(10 . "1") '(15 . "A") '(20 . "2") '(25 . "E")
                     '(30 . "3") '(40 . "4") '(45 . "O")
                     '(50 . "5") '(55 . "U") '(60 . "6") '(65 . "Y") '(70 . "7")
                     '("d2" . "–") '("d3" . "") '("d4" . "ʹ")
                     '("o-1". ",") '("o1" . "'")
                     '(-10 . "") '(-20 . "*")))

#(define CipherMap
    (cond ((string=? CipherLanguage "jianpu") jianpuCipherMap)
          ((string=? CipherLanguage "lisu") lisuCipherMap)))

#(define (encodePitch pitch duration)
    (let* ((o (if (null? pitch) -1 (ly:pitch-octave pitch)))
           (a (if (null? pitch) 0 (ly:pitch-alteration pitch)))
           (n (if (null? pitch) -2 (if (< o -4) -1 (1+ (ly:pitch-notename pitch)))))
           (od (+ (* 0.1 (ly:duration-dot-count duration)) o)))
          (cons od (* 10 (+ n a)))))
#(define (decodePitch encoded grob) 
    (let* ((n (inexact->exact (round (/ (cdr encoded) 10))))
           (a (- (* 10 n) (cdr encoded)))
           (o (1+ (inexact->exact (round (car encoded)))))
           (dc (inexact->exact (round (* 10 (- (+ 1.0 (car encoded)) o)))))
           (d (ly:grob-property grob 'duration-log))
           (cmap CipherMap)
           (name (or (assoc-ref (cmap) (cdr encoded))
                     (string-append (or (assoc-ref (cmap) (string-append "a" (number->string a))) "")
                                    (or (assoc-ref (cmap) n) ""))))
           (octave (or (assoc-ref (cmap) (string-append "o" (number->string o))) ""))
           (duration (or (assoc-ref (cmap) (string-append "d" (number->string d))) ""))
           (dot (string-join (map (lambda (x) (or (assoc-ref (cmap) "dot") ".")) (iota dc)))))
          (string-append name octave duration dot)))

#(define (beamdirp arts dir)
    (cond ((null? arts) #f)
          ((and (eq? (ly:music-property (car arts) 'name) 'BeamEvent)
                (= (ly:music-property (car arts) 'span-direction) dir)) #t)
          (else (beamdirp (cdr arts) dir))))

#(define (addBeams lastnote m state changed dml)
    (if (> dml 2) (begin
        (if (and state (or (beamdirp (ly:music-property m 'articulations) -1)
                              changed))
            (let* ((e (make-music 'BeamEvent 'span-direction 1))
                   (a (ly:music-property lastnote 'articulations)))
                  (ly:music-set-property! lastnote 'articulations (append a (list e)))))
        (if (or (and (not state) (not (beamdirp (ly:music-property m 'articulations) -1)))
                changed)
            (let* ((s (make-music 'BeamEvent 'span-direction -1))
                   (a (ly:music-property m 'articulations)))
                  (ly:music-set-property! m 'articulations (append a (list s)))))
        (set! state (not (beamdirp (ly:music-property m 'articulations) 1)))))
    (if (and (< dml 3) state) (begin
        (set! state #f)
        (let* ((e (make-music 'BeamEvent 'span-direction 1))
               (a (ly:music-property lastnote 'articulations)))
              (ly:music-set-property! lastnote 'articulations (append a (list e))))))
    (list state))

#(define (singleBeams lastnote m state changed dml)
    (let* ((arts (ly:music-property m 'articulations))
           (haso (beamdirp arts -1))
           (hasc (beamdirp arts 1))
           (open (make-music 'BeamEvent 'span-direction -1))
           (close (make-music 'BeamEvent 'span-direction 1)))
          (if (and (> dml 2) (not (or state haso hasc)))
              (ly:music-set-property! m 'articulations (append arts (list open close))))
          (list state)))

#(define (slurBeams lastnote m state changed dml)
    (let* ((arts (ly:music-property m 'articulations)))
          (for-each (lambda (a)
                        (if (eq? (ly:music-property a 'name) 'BeamEvent) (begin
                            (ly:music-set-property! a 'name 'SlurEvent)
                            (ly:music-set-property! a 'types '(post-event span-even event slur-event))))) arts)
          (list #f)))

prepCipher = #(define-music-function (parser location notes) (ly:music?)
    "Split long notes into invisibly slured shorter special ones. Force beaming everywhere"
    (let* ((lastnote '())
           (state #f)
           (abeam (make-music 'ContextSpeccedMusic 'context-type 'Bottom
                        'element (make-music 'PropertySet 'value #f 'symbol 'autoBeaming)))
           (results (list abeam)))
        (for-each (lambda (mnote)
            (set! results (append results
              (if (or (eq? (ly:music-property mnote 'name) 'NoteEvent)
                      (eq? (ly:music-property mnote 'name) 'RestEvent))
                (let* ((m (ly:music-deep-copy mnote))
                       (type (ly:music-property mnote 'name))
                       (lasttype (if (null? lastnote) '() (ly:music-property lastnote 'name)))
                       (dml (ly:duration-log (ly:music-property mnote 'duration)))
                       (lastl (if (null? lastnote) 0
                                  (ly:duration-log (ly:music-property lastnote 'duration))))
                       (difftype (not (eq? type lasttype))))
                      ; force beaming on all quavers
                      (set! state (car (if (string=? CipherLanguage "lisu")
                                           (slurBeams lastnote m state difftype dml)
                                           (singleBeams lastnote m state difftype dml))))
                      (set! lastnote m)
                      ; test for minims and longer and split
                      (if (< dml 2)
                        (let* ((d2 (ly:make-duration 2))
                               (newm (ly:music-deep-copy m))
                               (newl (ly:music-deep-copy m))
                               (res (list))
                               (p (ly:music-property m 'pitch))
                               (pn (if (null? p) 0 (ly:pitch-notename p)))
                               (pa (if (null? p) 0 (ly:pitch-alteration p)))
                               (dots (ly:duration-dot-count (ly:music-property m 'duration)))
                               (dashcount (- (* (if (< dml 1) 4 2) (if (> dots 0) 1.5 1)) 1))
                               (hideonetie (make-music 'ContextSpeccedMusic 'context-type 'Bottom 'element
                                  (make-music 'OverrideProperty 'once #t 'symbol 'Slur
                                              'grob-property-path (list 'transparent)
                                              'pop-first #t 'grob-value #t))))
                              (ly:music-set-property! newm 'duration d2)
                              (ly:music-set-property! newm 'articulations 
                                        (list (make-music 'SlurEvent 'span-direction -1)))
                              (set! res (append res (list hideonetie newm)))
                              (ly:music-set-property! newl 'duration d2)
                              (ly:music-set-property! newl 'pitch (ly:make-pitch -6 pn pa))
                              (for-each (lambda (x) (set! res (append res (list newl))))
                                        (iota (- dashcount 1)))
                              (ly:music-set-property! m 'duration d2)
                              (ly:music-set-property! m 'pitch (ly:make-pitch -6 pn pa))
                              (ly:music-set-property! m 'articulations (append (ly:music-property m 'articulations)
                                        (list (make-music 'SlurEvent 'span-direction 1))))
                              (append res (list m)))
                        (list m)))
                (list mnote)))))
            (if (eq? (ly:music-property notes 'name) 'RelativeOctaveMusic)
                (ly:music-property (ly:music-property notes 'element) 'elements)
                (ly:music-property notes 'elements)))
        (make-music 'SequentialMusic 'elements results)))

#(define (makeNoteHead context engraver event pitch)
    (let* ((g (ly:engraver-make-grob engraver 'NoteHead event))
           (steps (if (null? pitch) 0 (ly:pitch-steps pitch)))
           (mc (+ steps (ly:context-property context 'middleCPosition 0)))
           (d (ly:event-property event 'duration)))
          (ly:grob-set-property! g 'duration-log (ly:duration-log d))
          (ly:grob-set-property! g 'staff-position mc)
          (ly:grob-set-property! g 'stem-attachment '(0 . 0))
          (ly:grob-set-property! g 'extra-offset (encodePitch pitch d))))

CipherVoiceAdjust = #(define-music-function (parser location lang) (string?)
    (if (string=? lang "lisu")
        (ly:parser-include-string "\\remove \"Accidental_engraver\" \\override Beam #'transparent = ##t % \\override Stem #'direction = #UP"))
    (make-music 'SequentialMusic 'void #t))
    
\layout {
    cipher-beam-overhang = #0.5
    cipher-font = #"Charis SIL bold"
    cipher-font-size = #0
    \context {
        \Voice
        \name CipherVoice
        \alias Voice
        \remove "Note_head_line_engraver"
        \remove "Note_heads_engraver"
        \remove "Rest_engraver"
        \remove "Dots_engraver"
        \override Stem #'direction = #DOWN
        \CipherVoiceAdjust \CipherLanguage
        \override NoteHead #'transparent = ##f
        \override NoteHead #'Y-offset = #1
        \override Stem #'transparent = ##t
        \override StaffSymbol.line-count = #0
        \consists #(lambda (context)
          (let ((events (list)))
            (make-engraver
              (listeners
                ((rhythmic-event engraver event)
                 (set! events (cons event events))))
              ((process-music translator)
               (if (not (null? events))
                   (for-each (lambda (e)
                        (let* ((d (ly:event-property e 'duration))
                               (dl (ly:duration-log d))
                               (p (ly:event-property e 'pitch))
                               (d2 (ly:make-duration 2)))
                              (makeNoteHead context translator e p))) events)))
              ((stop-translation-timestep translator)
                  (set! events (list))))))
        \override Accidental #'font-size = #-4
        \override Accidental #'Y-offset = #1
        \override Stem #'length-fraction = #0.1
        \override Beam #'beam-thickness = #0.1
        \override Beam #'length-fraction = #0.5
        \override Tie #'staff-position = #3
        \override Slur #'staff-position = #3.0
        \override TupletBracket #'bracket-visibility = ##t
        \override NoteHead #'font-size = #2
        \override NoteHead #'stencil = #(lambda (grob) (let*
            ((e (ly:grob-property grob 'extra-offset '(0 . 0)))
             (t (decodePitch e grob))
             (layout (ly:grob-layout grob))
             (font (ly:output-def-lookup layout 'cipher-font "Times New Roman"))
             (fontsize (ly:output-def-lookup layout 'cipher-font-size 0)))
            (ly:grob-set-property! grob 'extra-offset '(0 . 0))
            (grob-interpret-markup grob
                (markup #:override (cons 'font-name font) #:override (cons 'font-size fontsize)
                        #:text (if (null? t) " " t)))))
        \override Beam #'stencil = #(lambda (grob) (let*
            ((p (ly:grob-property grob 'beam-segments))
             (overhang (ly:output-def-lookup (ly:grob-layout grob) 'cipher-beam-overhang 0.5))
             (q (map (lambda (x) (let*
                    ((left (cadadr x))
                     (right (cddadr x))
                     (o (if (< (- right left) 2.5) (* -0.5 overhang) overhang))) 
                    (cons (car x) (list (cons 'horizontal (cons (- left o) (+ right o))))))) p)))
            (ly:grob-set-property! grob 'beam-segments q)
            (ly:beam::print grob)))
        \shiftOff
    }

    \context {
        \CipherVoice
        \name CipherTwo
        \alias CipherVoice
        \override NoteHead #'Y-offset = #-3
    }

CipherStaffAdjust = #(define-music-function (parser location lang) (string?)
    (if (string=? lang "lisu")
        (ly:parser-include-string "\\remove \"Accidental_engraver\""))
    (make-music 'SequentialMusic 'void #t))

    \context {
        \Staff
        \name CipherStaff
        \alias Staff
        \accepts "CipherVoice"
        \accepts "CipherTwo"
        \remove "Clef_engraver"
        \CipherStaffAdjust \CipherLanguage
        \override StaffSymbol #'line-count = #0
        \override BarLine #'bar-extent = #'(-5 . 4)
        \override StaffSymbol #'Y-extent = #'(-2.5 . 2.5)
        \override VerticalAxisGroup #'minimum-Y-extent = #'(-2.5 . 2.5)
    }
}

#(define (setLanguageLisu)
    (define-public CipherLanguage lisuCipherMap))
