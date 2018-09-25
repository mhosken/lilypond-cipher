% Version 1.1
% Last edit: March 24, 2006
% The music and words produced by this source code are believed
% to be in the public domain in the United States. The source
% code itself is covered by the Creative Commons Attribution-
% NonCommercial license, 
% http://creativecommons.org/licenses/by-nc/2.5/
% Attribution: Geoff Horton

% Minor modifications that makes this typesetting unsuitable for actual music
% The modifications are there to test various typesetting issues.

\version "2.18.0"
\include "english.ly"

#(set-global-staff-size 16)
\pointAndClickOff

\header {
    title = "I Need Thee Ev'ry Hour"
    composer = "Robert Lowry"
    poet = "Annie Sherwood Hawkes"
    translator = "Refrain by Robert Lowry"
    piece = "Need"
    meter = "64.64, with Refrain"
    arranger = ""
    tagline = ##f
}

chorus = #(define-music-function () ()
    #{\mark \markup {\vcenter \rounded-box Chorus } #})

world = {
  \key g \major
  \time 3/4
  \partial 4*1
  \autoBeamOff
}

melody = \relative c'' {
  \world
  g | b4. a8 g fs | g2 g4 | g4.( a8) g[ fs] | d2 d4 | a'4. b8 a d, | b'2 g4 |
  fs4.( g8) fs[ e] | d2 \chorus b'4 | b4. a8 c b | b4 a2 | a4. g8 b a | a4 g g | g4. a8 g e |
  d4 g a | b4.( g8) a4 | g2 \bar "|."
}


alto = \relative c' {
  \world
  b4 | d4. c8 b a | b2 b4 | c2 c4 | b2 d4 | d4. d8 d d | d2 d4 | d4.( e8) d[ cs] |
  d2 d4 | d4. d8 \tuplet 3/2 { g[ fs g] } | g4 fs2 | d4. d8 d d | d4 d d | e4. e8 e c | b4 d e |
  d4.( b8) c4 | b2 
}

tenor = \relative c {
  \world
  d4 | g4. e8 d d | d2 d4 | e2 \tuplet 3/2 { e8[ f g] } | g2 fs4 | fs4 r8 g8 fs fs | g2 b4 | a2 a8[ g] |
  fs2 g4 | g4. b8 e d | d4 r2 | c4. b8 d c | c4 b g | g4. g8 g g | g4 g g |
  g2 fs4 | g2
}

bass = \relative c {
  \world
  g4 | g4. c8 d d | g,2. | c2 c4 | g2 d'4 | d4. d8 d d | g2 g,4 | a2 a4 |
  d2 g4 | g4. g8 g g | d4 d2 | d4. d8 d d | g,4 g b | c4. c8 c c | g4 b c |
  d2 d4 | g2
}

verseOne = \lyricmode {
  \set stanza = "1. "
  I need thee ev- 'ry hour,
  Most gra- cious Lord;
  No ten- der voice like thine
  Can peace af- ford.
  I need thee, O I need thee,
  Ev- 'ry hour I need thee,
  O bless me now, my Sa -- viour,
  I come to thee.
}

verseTwo = \lyricmode {
  \set stanza = "2. "
  I need thee ev- 'ry hour;
  Stay thou near by;
  Temp- ta- tions lose their pow'r
  When thou art nigh.
}

verseThree = \lyricmode {
  \set stanza = "3. "
  I need thee ev- 'ry hour;
  In joy or_in pain;
  Come quick- ly and a- bide,
  Or life is vain.
}

verseFour = \lyricmode {
  \set stanza = "4. "
  I need thee ev- 'ry hour;
  Teach me thy will;
  And thy rich prom- is- es
  In me ful- fill.
} 

harmonies = \chordmode {
    g4 | g4. a8:m g d | g2 g4 | c2 c4 | g2 d4 | d4. g8 d8 d8 | g2 g4 | d2 d8 a8:7 |
    d2 g4 | g4. d8 a:7 g | g4 d2 | d4.:7 g8 g8 d8:7 | d4:sus4.7 g4 g4 | c4. a8:m c8 c8 |
    g4 g a:m | g2 d4:7 | g2
}

% CipherLanguage = "jianpu"
% CipherLanguage = "lisu"
% CipherLanguage = "kepatihan"

\include "ciphersong.ly"

\bookpart {
\westernScore
}

\bookpart {
\cipherScore
}

\bookpart {
\cipherOuterScore
}

\bookpart {
\cipherInnerScore
}

%{
  Per _The Hymnal 1940_, 438 first tune.
  Change log:
  3-24-06 Move to 2.8 and current formatting
%}


