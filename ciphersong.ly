\include "cipher.ly"

condmus = #(define-music-function (parser location sym music) (string? string?)
    (define (my1 x y) x)
    (if (> (length (filter (lambda (x) (string=? (symbol->string x) sym)) 
                           (hash-map->list my1 (struct-ref (current-module) 0)))) 0)
        (ly:parser-include-string music))
    (make-music 'SequentialMusic 'void #t))


cipherChords = \new ChordNames \with {
        % \override ChordName #'font-size = #-1
        \override VerticalAxisGroup #'minimum-Y-extent = #'(0 . 2) } <<
    \set chordChanges = ##t
    \harmonies
>>
cipherWesternUpper = \context Staff = upper <<
  \context Voice = soprano { \voiceOne \melody }
  \context Voice = altos { \voiceTwo \alto }
>>
cipherWesternLower = \context Staff = lower <<
    \clef bass
    \context Voice = tenors { << \voiceOne \tenor >> }
    \context Voice = basses { << \voiceTwo \bass >> }
>>
cipherLyrics = \new Lyrics \lyricsto soprano <<
    \condmus "verseOne" "{ \verseOne }"
    \condmus "verseTwo" "\\new Lyrics \lyricsto soprano { \verseTwo }"
    \condmus "verseThree" "\\new Lyrics \lyricsto soprano { \verseThree }"
    \condmus "verseFour" "\\new Lyrics \lyricsto soprano { \verseFour }"
    \condmus "verseFive" "\\new Lyrics \lyricsto soprano { \verseFive }"
>>
cipherCipherUpper = \new CipherStaff = "one" <<
    \context CipherVoice = "ciphersop" { \prepCipher \melody }
    \context CipherTwo = "cipheralto" { \prepCipher \alto }
    \new NullVoice = "soprano" { \melody }
>>
cipherCipherLower = \new CipherStaff = "three" <<
    \context CipherVoice { \prepCipher \tenor }
    \context CipherTwo { \prepCipher \bass }
>>

westernScore = \score {
\header { }
\context ChoirStaff <<
    \context StaffGroup = "top" <<
        \cipherChords
        \cipherWesternUpper
    >>
    \cipherLyrics
    \context StaffGroup = "bottom" <<
        \cipherWesternLower
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
        \cipherChords
        \cipherCipherUpper
    >>
    \cipherLyrics
    \context StaffGroup = "bottom" <<
        \cipherCipherLower
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
        \cipherChords
        \cipherCipherUpper
        \cipherWesternUpper
    >>
    \cipherLyrics
    \context StaffGroup = "bottom" <<
        \cipherWesternLower
        \cipherCipherLower
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
        \cipherChords
        \cipherWesternUpper
        \cipherCipherUpper
    >>
    \cipherLyrics
    \context StaffGroup = "bottom" <<
        \cipherCipherLower
        \cipherWesternLower
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

