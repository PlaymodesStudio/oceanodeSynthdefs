(
// ─────────────────────────────────────────────────────────────
//  InFeedbackGain
//  -----------------------------------------------------------
//  • Llegeix el senyal que arriba pel port “In” (OceanodeInput)
//  • Llegeix el contingut anterior del bus de sortida amb
//    InFeedback.ar → 1 bloc de retard, estable
//  • Barreja: input + (feedback * gain)
//  • Opcional: limitador suau amb tanh per evitar explosions
//  • Escriu-ho tot al port “Out” (OceanodeOutput)
// ─────────────────────────────────────────────────────────────
~synthCreator.value(
    "InFeedback",
    {|n|
        var input, fb, gain, sig;

        /* ─── Paràmetre de feedback (suau amb lag 1/30 s) ─── */
        gain = OceanodeParameterLag.ar(\gain, 0.5, n,   // default 0.5
                                       0, 1, "vf", 1/30, true);

        /* ─── Lectura de senyals ─── */
        input = In.ar(OceanodeInput.kr(\in), n);                 // senyal entrant
        fb    = InFeedback.ar(OceanodeOutput.kr(\out), n);       // eco intern

        /* ─── Mescla i petita protecció ─── */
        sig = tanh(input + (fb * gain));     // tanh evita runaway dur

        /* ─── Sortida ─── */
        Out.ar(OceanodeOutput.kr(\out), sig);

    },
    description: "Feedback unitari: suma l'entrada amb InFeedback.ar controlat per gain",
    category: "Utilities/Feedback"
);
)
