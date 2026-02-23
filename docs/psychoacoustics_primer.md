# Psychoacoustics Primer for Dance Music Analysis

## What Is Psychoacoustics?

Psychoacoustics is the scientific study of how humans perceive sound. In dance music analysis, psychoacoustic principles explain *why* certain audio features make people move, feel energy, or perceive a track as "hot."

---

## The 8 Dimensions: Perceptual Basis

### Dimension 1: BPM Stability
**What it measures**: How consistent the tempo is over time.

**Perceptual basis**: Humans entrain (synchronize movement) to rhythmic stimuli. Stable tempos between 120-130 BPM naturally match walking/dancing cadence. Tempo stability gives dancers confidence in the groove — deviations create tension or disorientation.

**Psychoacoustic principle**: Motor-auditory coupling and sensorimotor synchronization (SMS). The brain's supplementary motor area activates even during passive listening to rhythmic stimuli.

**DJ relevance**: Stable BPM is essential for beatmatching. Variable BPM tracks require manual adjustment.

---

### Dimension 2: Bass Energy
**What it measures**: RMS energy in the 20-250 Hz frequency band.

**Perceptual basis**: Low frequencies are felt physically through bone conduction and tactile vibration, not just heard. Club sound systems emphasize sub-bass (20-80 Hz) and mid-bass (80-250 Hz). Bass creates the "chest thump" sensation central to dance music.

**Psychoacoustic principle**: The threshold of hearing is highest at low frequencies (Fletcher-Munson curves), meaning bass must be physically loud to be perceived. Below ~80 Hz, pitch perception degrades and rhythm perception dominates.

**DJ relevance**: Bass levels must complement between mixed tracks to avoid muddiness or cancellation.

---

### Dimension 3: Vocal Presence
**What it measures**: Spectral energy and harmonicity in the 300-3400 Hz band.

**Perceptual basis**: Human hearing is most sensitive in the 1-4 kHz range (ear canal resonance). Vocals occupy this "speech frequency" band. The brain has dedicated cortical areas for voice processing, making vocals immediately attention-grabbing.

**Psychoacoustic principle**: The cocktail party effect — humans can isolate voices from complex sound mixtures. Vocal presence creates emotional connection and narrative in dance tracks.

**DJ relevance**: Avoid layering two vocal tracks simultaneously. Vocal segments are best used as focal points, not blend points.

---

### Dimension 4: Beat Strength
**What it measures**: Peak amplitude of the onset detection envelope.

**Perceptual basis**: Strong onsets (transients) trigger the startle reflex and rhythmic entrainment. The auditory cortex is particularly sensitive to sudden amplitude changes. In dance music, the kick drum is the primary beat marker.

**Psychoacoustic principle**: Temporal integration — the ear integrates sound energy over ~200ms windows. Onsets faster than this threshold feel "sharp" and rhythmic. The beat strength directly influences perceived groove and danceability.

**DJ relevance**: Beat strength alignment is critical for seamless transitions. Misaligned beats create rhythmic confusion.

---

### Dimension 5: Spectral Flux
**What it measures**: Frame-to-frame change in spectral content.

**Perceptual basis**: The auditory system is tuned to detect change — spectral stability is perceived as "static" while rapid spectral change creates excitement, tension, or surprise. Filter sweeps, risers, and drops all create high spectral flux.

**Psychoacoustic principle**: Auditory stream segregation — the brain groups stable spectral patterns as single "objects." High flux disrupts this, creating a sense of multiple events or transformation.

**DJ relevance**: High spectral flux segments (builds, transitions) are natural mix points. Low flux segments (grooves) are stable blend zones.

---

### Dimension 6: Rhythm Complexity
**What it measures**: Onset density + syncopation (inter-onset interval variation).

**Perceptual basis**: Simple rhythms (four-on-the-floor) are immediately accessible. Complex rhythms with syncopation and polyrhythm engage deeper cognitive processing and can create a stronger groove sensation through "controlled surprise."

**Psychoacoustic principle**: Predictive coding — the brain constantly predicts the next beat. Syncopation violates predictions, releasing dopamine (the "pleasure of groove"). Moderate complexity maximizes enjoyment; too much complexity causes confusion.

**DJ relevance**: Matching rhythm complexity prevents jarring transitions. House → DnB transitions work because both have clear pulse despite different complexity levels.

---

### Dimension 7: Harmonic Richness
**What it measures**: Number of significant harmonic peaks + spectral tonality.

**Perceptual basis**: Rich harmonics create warmth, depth, and emotional content. The ear perceives harmonically related frequencies as a single pitch with varying timbre. Dense chords and pads feel "full" while sparse harmonics feel "thin."

**Psychoacoustic principle**: The missing fundamental — the brain infers pitch from harmonic series even without the fundamental frequency. Harmonic richness directly maps to perceived timbral complexity and musical interest.

**DJ relevance**: Harmonically rich segments can clash if mixed with tracks in different keys. Use Camelot wheel for harmonic mixing.

---

### Dimension 8: Dynamic Range
**What it measures**: Crest factor (peak/RMS ratio) per segment.

**Perceptual basis**: Dynamic variation creates the tension-release cycle essential to dance music. Builds increase tension (lower dynamics, compression), drops release it (high dynamics, full range). The loudness war has reduced dynamic range in modern productions, but local dynamics within tracks still drive emotional response.

**Psychoacoustic principle**: Loudness perception follows Weber's law — we perceive relative changes, not absolute levels. A quiet breakdown followed by a loud drop *feels* more impactful than sustained loudness, even at lower absolute SPL.

**DJ relevance**: Dynamic range matching prevents volume jumps during transitions. Track sections with similar dynamics blend more naturally.

---

## The Hotness Model

**H(t) = Σ w_i × D_i(t)**

The weighted sum model assumes that perceived "hotness" (energy, excitement, danceability) is a linear combination of the 8 dimensions. This simplification works because:

1. **Additive perception**: Psychoacoustic research shows that multiple simultaneous features contribute additively to arousal ratings
2. **Configurable weights**: Different genres weight dimensions differently (techno = beat strength, trance = harmonics, house = bass)
3. **Statistical threshold (μ + σ)**: The "hot" classification uses a one-sigma threshold, capturing the top ~16% of segments — corresponding to the memorable peaks of a track

## References
- Fastl, H., & Zwicker, E. (2007). *Psychoacoustics: Facts and Models*. Springer.
- Grahn, J. A., & Brett, M. (2007). Rhythm and beat perception in motor areas of the brain. *Journal of Cognitive Neuroscience*, 19(5), 893-906.
- Madison, G. (2006). Experiencing groove induced by music. *Music Perception*, 24(2), 201-208.
- Witek, M. A. G., et al. (2014). Syncopation, body-movement and pleasure in groove music. *PLoS ONE*, 9(4), e94446.
