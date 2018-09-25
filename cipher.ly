
\version "2.18.0"

% This is immensely complicated for what is basically a defined?
condmus = #(define-music-function (parser location sym music) (string? string?)
    (define (my1 x y) x)
    (if (> (length (filter (lambda (x) (string=? (symbol->string x) sym)) 
                           (hash-map->list my1 (struct-ref (current-module) 0)))) 0)
        (ly:parser-include-string music))
    (make-music 'SequentialMusic 'void #t))

ncondmus = #(define-music-function (parser location sym music) (string? string?)
    (define (my1 x y) x)
    (if (not (> (length (filter (lambda (x) (string=? (symbol->string x) sym))
                           (hash-map->list my1 (struct-ref (current-module) 0)))) 0))
        (ly:parser-include-string music))
    (make-music 'SequentialMusic 'void #t))

#(define-public (jianpuCipherMap) (list '(1 . "1") '(2 . "2") '(3 . "3")
                       '(4 . "4") '(5 . "5") '(6 . "6") '(7 . "7")
                       '("o-3" . "̤̣") '("o-2" . "̤") '("o-1" . "̣")
                       '("o1" . "̇") '("o2" . "̈") '("o3" . "̈̇") '("o4" . "̈̈")
                       '(-1 . "–") '(-2 . "0") '("dot" . ".")))
#(define-public (kepatihanCipherMap) (list '(10 . "1") '(11 . "1̸") '(19 . "1̸") '(20 . "2")
                    '(21 . "2̸") '(29 . "2̸") '(30 . "3") '(40 . "4") '(41 . "4̸") '(49 . "4̸")
                    '(50 . "5") '(51 . "5̸") '(59 . "5̸") '(60 . "6") '(61 . "6̸") '(69 . "6̸") '(70 . "7")
                    '("o-3" . "̤̣") '("o-2" . "̤") '("o-1" . "̣")
                    '("o1" . "̇") '("o2" . "̈") '("o3" . "̈̇") '("o4" . "̈̈")
                    '(-1 . ".") '(-2 . "0") '("dot" . ".")))
#(define-public (lisuCipherMap) (list '(10 . "1") '(11 . "A") '(19 . "A") '(20 . "2") '(21 . "E")
                     '(29 . "E") '(30 . "3") '(40 . "4") '(41 . "O") '(49. "O")
                     '(50 . "5") '(55 . "U") '(60 . "6") '(61 . "Y") '(69 . "Y") '(70 . "7")
                     '("d2" . "–") '("d3" . "") '("d4" . "ʹ")
                     '("dot3" . "·") '("dot4" . "ʹ")
                     '("o-1". ",") '("o1" . "'")
                     '(-10 . "") '(-20 . "*")))

\ncondmus "CipherLanguage" "CipherLanguage = \"jianpu\""

#(define CipherMap
    (cond ((string=? CipherLanguage "jianpu") jianpuCipherMap)
          ((string=? CipherLanguage "lisu") lisuCipherMap)
          ((string=? CipherLanguage "kepatihan") kepatihanCipherMap)))

#(define (encodePitch pitch duration)
    (let* ((o (if (null? pitch) -1 (ly:pitch-octave pitch)))
           (a (if (null? pitch) 0 (ly:pitch-alteration pitch)))
           (n (if (null? pitch) -2 (if (< o -4) -1 (1+ (ly:pitch-notename pitch)))))
           (od (+ (* 0.1 (ly:duration-dot-count duration)) o)))
          (cons od (* 10 (+ n (/ a 5))))))
#(define (decodePitch encoded grob) 
    (let* ((n (inexact->exact (round (/ (cdr encoded) 10))))
           (a (* 5 (- (* 10 n) (cdr encoded))))
           (o (1+ (inexact->exact (round (car encoded)))))
           (dc (inexact->exact (round (* 10 (- (+ 1.0 (car encoded)) o)))))
           (d (ly:grob-property grob 'duration-log))
           (cmap CipherMap)
           (name (or (assoc-ref (cmap) (cdr encoded))
                     (string-append (or (assoc-ref (cmap) (string-append "a" (number->string a))) "")
                                    (or (assoc-ref (cmap) n) ""))))
           (octave (or (assoc-ref (cmap) (string-append "o" (number->string o))) ""))
           (duration (or (assoc-ref (cmap) (string-append "d" (number->string d))) ""))
           (dot (if (> dc 0) (string-join (if (string=? CipherLanguage "lisu")
                                 (map (lambda (x) (or (assoc-ref (cmap) (string-append "dot" (number->string (+ (1+ d) x)))) "")) (iota dc))
                                 (map (lambda (x) (or (assoc-ref (cmap) "dot") ".")) (iota dc))))
                    "")))
          (string-append name octave duration dot)))

#(define (beamdirp arts dir)
    (cond ((null? arts) #f)
          ((and (eq? (ly:music-property (car arts) 'name) 'BeamEvent)
                (= (ly:music-property (car arts) 'span-direction) dir)) #t)
          (else (beamdirp (cdr arts) dir))))

#(define (singleBeams lastnote m state changed dml)
    (let* ((arts (ly:music-property m 'articulations))
           (haso (beamdirp arts -1))
           (hasc (beamdirp arts 1))
           (open (make-music 'BeamEvent 'span-direction -1))
           (close (make-music 'BeamEvent 'span-direction 1)))
          (if (> dml 2) (cond
              (hasc (set! state #f))
              (haso (set! state #t))
              ((not state)
                (ly:music-set-property! m 'articulations (append arts (list open close))))))
          state))

#(define (slurBeams lastnote m state changed dml)
    (let* ((arts (ly:music-property m 'articulations)))
          (for-each (lambda (a)
                        (if (eq? (ly:music-property a 'name) 'BeamEvent) (begin
                            (ly:music-set-property! a 'name 'SlurEvent)
                            (ly:music-set-property! a 'types '(post-event span-even event slur-event))))) arts)
          #f))

#(define (procnote_ lastnote mnote state changed)
    (let* ((m (ly:music-deep-copy mnote))
           (dml (ly:duration-log (ly:music-property mnote 'duration)))
           (lastl (if (null? lastnote) 0
                      (ly:duration-log (ly:music-property lastnote 'duration)))))
          ; force beaming on all quavers
          (set! state (if (string=? CipherLanguage "lisu")
                          (slurBeams lastnote m state changed dml)
                          (singleBeams lastnote m state changed dml)))
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
                  (cons state (append res (list m))))
            (list state m))))

prepCipher = #(define-music-function (parser location tonic notes) (ly:music? ly:music?)
    "Split long notes into invisibly slured shorter special ones. Force beaming everywhere"
    (let* ((tonic (ly:music-property tonic 'pitch))
           (lastnote '())
           (state #f)
           (changed #t))
        (define (proconenote_ music)
            (let* ((t (ly:music-property music 'name))
                   (p (ly:music-property music 'pitch))
                   (res '())
                   (status #f))
                (cond ((or (eq? t 'NoteEvent) (eq? t 'RestEvent)) (begin
                       (set! changed (not (eq? t (if (null? lastnote) '() (ly:music-property lastnote 'name)))))
                       (if (ly:pitch? p)
                           (ly:music-set-property! music 'pitch (ly:pitch-diff p tonic)))
                       (set! res (procnote_ lastnote music state changed))
                       (set! state (car res))
                       (set! lastnote (car (reverse res)))
                       (cdr res)))
                      ((eq? t 'KeyChangeEvent) (let*
                            ((tp (ly:music-property music 'tonic))
                             (tpa (ly:pitch-alteration tp))
                             (tpn (ly:pitch-notename tp))
                             (tpo (ly:pitch-octave tonic)))
                            (set! tonic (ly:make-pitch tpo tpn tpa))
                            (list music)))
                      (else (list music)))))
        (define (procmus_ music)
            (let* ((e (ly:music-property music 'element))
                   (res (proconenote_ music)))
                (if (null? e) (begin
                    (set! e (ly:music-property music 'elements))
                    (if (not (null? e))
                        (ly:music-set-property! (car res) 'elements (append-map procmus_ e))))
                    (ly:music-set-property! (car res) 'element (car (procmus_ e))))
                res))
        (car (procmus_ notes))))

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
    (cond ((string=? lang "lisu")
           (ly:parser-include-string "\\override Beam #'transparent = ##t \
                \\override TupletBracket #'padding = #-1.8 \\override TupletBracket #'direction = #DOWN"))
          ((string=? lang "kepatihan")
           (ly:parser-include-string "\\override Stem #'direction = #UP \
                \\override Slur #'positions = #'(0.3 . 0.3) \\override Beam #'positions = #'(3.3 . 3.3) \
                \\override TupletBracket #'padding = #-2 \\override TupletBracket #'direction = #DOWN")))
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
        \override TupletBracket #'direction = #UP
        \override TupletBracket #'padding = #0.5
        \override Slur #'staff-position = #3.0
        \override Beam #'positions = #'(0.2 . 0.2)
        \override Beam #'transparent = ##f
        \override NoteHead #'Y-offset = #1
        \CipherVoiceAdjust \CipherLanguage
        \override NoteHead #'transparent = ##f
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
        \override Accidental #'Y-offset = #0.75
        \override Stem #'length-fraction = #0
        \override Beam #'beam-thickness = #0.1
        \override Beam #'length-fraction = #0.5
        \override Tie #'staff-position = #3
        \override Slur #'height-limit = #0.5
        \override TupletBracket #'bracket-visibility = ##t
        % \override TupletBracket #'outside-staff-priority = #1
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

CipherVoiceTwoAdjust = #(define-music-function (parser location lang) (string?)
    (cond ((string=? lang "lisu")
           (ly:parser-include-string "\\override NoteHead #'Y-offset = #-2 \\override TupletBracket #'padding = #-0.5"))
          ((string=? lang "kepatihan")
           (ly:parser-include-string "\\override Beam #'positions = #'(-0.8 . -0.8) \
                \\override Slur #'positions = #'(-1.1 . -1.1) \\override TupletBracket #'padding = #0.5")))
    (make-music 'SequentialMusic 'void #t))

    \context {
        \CipherVoice
        \name CipherTwo
        \alias CipherVoice
        \override NoteHead #'Y-offset = #-3
        \override Beam #'positions = #'(-3.8 . -3.8)
        \override TupletBracket #'padding = #-2.2
        \CipherVoiceTwoAdjust \CipherLanguage
    }

CipherStaffAdjust = #(define-music-function (parser location lang) (string?)
    (cond ((string=? lang "lisu")
           (ly:parser-include-string "\\remove \"Accidental_engraver\""))
          ((string=? lang "kepatihan")
           (ly:parser-include-string "\\remove \"Accidental_engraver\"")))
    (make-music 'SequentialMusic 'void #t))

    \context {
        \Staff
        \name CipherStaff
        \alias Staff
        \accepts "CipherVoice"
        \accepts "CipherTwo"
        \remove "Clef_engraver"
        \remove "Key_engraver"
        \CipherStaffAdjust \CipherLanguage
        \override StaffSymbol #'line-count = #0
        \override BarLine #'bar-extent = #'(-2.5 . 3.5)
        \override StaffSymbol #'Y-extent = #'(-1.5 . 1.5)
        \override StaffGrouper #'staff-staff-spacing = #'((minimum-distance . 3) (padding . 1) (stretchability . 5) (basic-distance . 3))
        \override Staff #'padding = #0
    }
}

