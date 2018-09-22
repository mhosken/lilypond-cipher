\include "cipher.ly"

condmus = #(define-music-function (parser location sym music) (string? string?)
    (define (my1 x y) x)
    (if (> (length (filter (lambda (x) (string=? (symbol->string x) sym)) 
                           (hash-map->list my1 (struct-ref (current-module) 0)))) 0)
        (ly:parser-include-string music))
    (make-music 'SequentialMusic 'void #t))

westernScore = \score {
\header { }
\context ChoirStaff <<
    \context StaffGroup = "top" <<
        \new ChordNames \with { 
                % \override ChordName #'font-size = #-1
                \override VerticalAxisGroup #'minimum-Y-extent = #'(0 . 2) } <<
            \set chordChanges = ##t
            \harmonies
        >>
        \context Staff = upper <<
          \context Voice = soprano { \voiceOne \melody }
          \context Voice = altos { \voiceTwo \alto } 
        >>
    >>
    \new Lyrics \lyricsto soprano <<
        { \verseOne }
        \condmus "verseTwo" "\\new Lyrics \lyricsto soprano { \verseTwo }"
        \condmus "verseThree" "\\new Lyrics \lyricsto soprano { \verseThree }"
        \condmus "verseFour" "\\new Lyrics \lyricsto soprano { \verseFour }"
        \condmus "verseFive" "\\new Lyrics \lyricsto soprano { \verseFive }"
    >>
    \context StaffGroup = "bottom" <<
        \context Staff = lower <<
            \clef bass
            \context Voice = tenors { << \voiceOne \tenor >> }
            \context Voice = basses { << \voiceTwo \bass >> }
        >>
    >>
>>

\layout {
    indent = #0
    \context {
        \Score
        \remove "Bar_number_engraver"
    }
}
}

cipherScore = \score {
\header { }
\context ChoirStaff <<
    \context StaffGroup = "top" <<
        \new ChordNames \with { 
                % \override ChordName #'font-size = #-1
                \override VerticalAxisGroup #'minimum-Y-extent = #'(0 . 2) } <<
            \set chordChanges = ##t
            \harmonies
        >>
        \new CipherStaff = "one" <<
            \context CipherVoice = "ciphersop" { \prepCipher \melody }
            \context CipherTwo = "cipheralto" { \prepCipher \alto } 
            \new NullVoice = "soprano" { \melody }
        >>
    >>
    \new Lyrics \lyricsto soprano <<
        { \verseOne }
        \condmus "verseTwo" "\\new Lyrics \lyricsto soprano { \verseTwo }"
        \condmus "verseThree" "\\new Lyrics \lyricsto soprano { \verseThree }"
        \condmus "verseFour" "\\new Lyrics \lyricsto soprano { \verseFour }"
        \condmus "verseFive" "\\new Lyrics \lyricsto soprano { \verseFive }"
    >>
    \context StaffGroup = "bottom" <<
        \new CipherStaff = "three" << 
            \context CipherVoice { \prepCipher \tenor }
            \context CipherTwo { \prepCipher \bass }
        >> 
    >>
>>

\layout {
    indent = #0
    \context {
        \Score
        \remove "Bar_number_engraver"
    }
    \context {
        \StaffGroup
        \accepts "CipherStaff"
    }
}
}

cipherOuterScore = \score {
\header { }
\context ChoirStaff <<
    \context StaffGroup = "top" <<
        \new ChordNames \with { 
                \override ChordName #'font-size = #-1
                \override VerticalAxisGroup #'minimum-Y-extent = #'(0 . 2) } <<
            \set chordChanges = ##t
            \harmonies
        >>
        \new CipherStaff = "one" <<
            \context CipherVoice = "ciphersop" { \prepCipher \melody }
            \context CipherTwo = "cipheralto" { \prepCipher \alto } 
        >>
        \context Staff = upper <<
          \context Voice = soprano { \voiceOne \melody }
          \context Voice = altos { \voiceTwo \alto } 
        >>
    >>
    \new Lyrics \lyricsto soprano <<
        { \verseOne }
        \condmus "verseTwo" "\\new Lyrics \lyricsto soprano { \verseTwo }"
        \condmus "verseThree" "\\new Lyrics \lyricsto soprano { \verseThree }"
        \condmus "verseFour" "\\new Lyrics \lyricsto soprano { \verseFour }"
        \condmus "verseFive" "\\new Lyrics \lyricsto soprano { \verseFive }"
    >>
    \context StaffGroup = "bottom" <<
        \context Staff = lower <<
            \clef bass
            \context Voice = tenors { << \voiceOne \tenor >> }
            \context Voice = basses { << \voiceTwo \bass >> }
        >>
        \new CipherStaff = "three" << 
            \context CipherVoice { \prepCipher \tenor }
            \context CipherTwo { \prepCipher \bass }
        >> 
    >>
>>

\layout {
    indent = #0
    \context {
        \Score
        \remove "Bar_number_engraver"
    }
    \context {
        \StaffGroup
        \accepts "CipherStaff"
    }
}
}

cipherInnerScore = \score {
\header { }
\context ChoirStaff <<
    \context StaffGroup = "top" <<
        \new ChordNames \with { 
                \override ChordName #'font-size = #-1
                \override VerticalAxisGroup #'minimum-Y-extent = #'(0 . 2) } <<
            \set chordChanges = ##t
            \harmonies
        >>
        \context Staff = upper <<
          \context Voice = soprano { \voiceOne \melody }
          \context Voice = altos { \voiceTwo \alto } 
        >>
        \new CipherStaff = "one" <<
            \context CipherVoice = "ciphersop" { \prepCipher \melody }
            \context CipherTwo = "cipheralto" { \prepCipher \alto } 
        >>
    >>
    \new Lyrics \lyricsto soprano <<
        { \verseOne }
        \condmus "verseTwo" "\\new Lyrics \lyricsto soprano { \verseTwo }"
        \condmus "verseThree" "\\new Lyrics \lyricsto soprano { \verseThree }"
        \condmus "verseFour" "\\new Lyrics \lyricsto soprano { \verseFour }"
        \condmus "verseFive" "\\new Lyrics \lyricsto soprano { \verseFive }"
    >>
    \context StaffGroup = "bottom" <<
        \new CipherStaff = "three" << 
            \context CipherVoice { \prepCipher \tenor }
            \context CipherTwo { \prepCipher \bass }
        >> 
        \context Staff = lower <<
            \clef bass
            \context Voice = tenors { << \voiceOne \tenor >> }
            \context Voice = basses { << \voiceTwo \bass >> }
        >>
    >>
>>
\layout {
    indent = #0
    \context {
        \Score
        \remove "Bar_number_engraver"
    }
    \context {
        \StaffGroup
        \accepts "CipherStaff"
    }
}
}

\paper {
  ragged-bottom = ##t
  top-margin = 0.25\in
  bottom-margin = 0.25\in
  between-system-space = 2\in
  system-system-spacing = #'((basic-distance . 15) (padding . 5))
}

