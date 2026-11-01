# Familias de movimiento para las animaciones por ataque (decisión del usuario 2026-11-01): en vez de una animación por
# ataque y especie, cada ataque cae en una familia (morder, puño, patada, embestida, soplar por la boca...) y por especie
# se genera solo la familia de cada ataque que aprende. Lo que distingue a Mordisco de Triturar es el efecto encima
# (aparte, VfxSprite), no el cuerpo: los prompts piden la pose sola, sin efectos.
#
#   python -I -B tools/comfy/move_families.py            → cuántos ataques por familia y los sin familia
#   python -I -B tools/comfy/move_families.py <n.º>      → familias de esa especie y con qué ataques
#
# Sale de data/source/official.json (nombre en inglés, categoría, tipo, objetivo).
import json, os, sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

# familia → (nombre para mostrar, acción para el prompt; {dir} = hacia dónde, {n} = la especie)
FAMILIES = {
    "embestida": ("Embestida", "frame 1 {n} crouches low and pulls back, frame 2 it springs forward, frame 3 it rams {dir} "
                  "with its whole body stretched out in a powerful tackle, frame 4 it lands back in its normal stance."),
    "morder": ("Mordisco", "frame 1 {n} pulls its head back with its mouth closed, frame 2 it lunges forward opening its "
               "mouth wide, frame 3 it bites hard {dir} with its jaws snapping shut and teeth showing, frame 4 it returns "
               "to its normal stance."),
    "aranar": ("Arañazo / corte", "frame 1 {n} raises its claws or arms high, frame 2 it leans in, frame 3 it slashes {dir} "
               "with a fast swipe, body twisted from the swing, frame 4 it returns to its normal stance."),
    "puno": ("Puño / golpe de mano", "frame 1 {n} pulls its arm far back and leans back, frame 2 it twists its body, "
             "frame 3 it lunges {dir} and punches with its arm fully extended, frame 4 it returns to its normal stance."),
    "patada": ("Patada", "frame 1 {n} lifts one leg back, frame 2 it swings the leg forward, frame 3 it kicks {dir} with "
               "the leg fully extended, frame 4 it returns to its normal stance."),
    "picotazo": ("Picotazo", "frame 1 {n} pulls its head back, frame 2 it leans forward, frame 3 it lunges {dir} and pecks "
                 "hard with its beak, neck stretched out, frame 4 it settles back into its normal stance."),
    "ala": ("Ala", "frame 1 {n} raises its wings high, frame 2 it swoops forward, frame 3 it strikes {dir} with its wings "
            "spread wide in a powerful flap, frame 4 it settles back into its normal stance."),
    "cabezazo": ("Cabezazo", "frame 1 {n} rears its head far back, frame 2 it lowers its head, frame 3 it slams its head "
                 "{dir} in a hard headbutt, frame 4 it returns to its normal stance."),
    "cola": ("Cola / látigo", "frame 1 {n} turns its body and draws its tail or vines back, frame 2 it spins, frame 3 it "
             "whips its tail or vines hard {dir}, frame 4 it returns to its normal stance."),
    "cuerno": ("Cuerno / aguijón", "frame 1 {n} lowers its head and pulls back, frame 2 it charges forward, frame 3 it "
               "thrusts its horn or stinger hard {dir}, frame 4 it returns to its normal stance."),
    "pisoton": ("Pisotón / temblor", "frame 1 {n} rears up as high as it can, frame 2 it stays at the top, frame 3 it slams "
                "down hard on the ground with its whole weight, frame 4 it returns to its normal stance."),
    "lanzar": ("Lanzar algo", "frame 1 {n} leans back as if winding up a throw, frame 2 it swings forward, frame 3 it "
               "throws {dir} with its body stretched forward (draw nothing being thrown), frame 4 it returns to its "
               "normal stance."),
    "boca": ("Soplar / escupir por la boca", "frame 1 {n} breathes in, leaning back with its chest puffed, frame 2 it leans "
             "forward, frame 3 it opens its mouth very wide {dir} as if blasting something out (draw nothing coming out of "
             "its mouth, no fire, no water, no effects), frame 4 it closes its mouth and returns to its normal stance."),
    "descarga": ("Descarga de energía", "frame 1 {n} hunches and tenses up, frame 2 it stretches its body out, frame 3 it "
                 "strikes a powerful pose facing {dir} with every muscle tense as if releasing energy (no effects drawn), "
                 "frame 4 it returns to its normal stance."),
    "mental": ("Mirada / poder mental", "frame 1 {n} closes its eyes and concentrates, frame 2 it raises its head, frame 3 "
               "it opens its eyes wide and stares hard {dir}, body tense and leaning in (no effects drawn), frame 4 it "
               "returns to its normal stance."),
    "grito": ("Grito / sonido", "frame 1 {n} takes a deep breath, frame 2 it throws its head back, frame 3 it shouts "
              "loudly {dir} with its mouth wide open (no effects drawn), frame 4 it returns to its normal stance."),
    "sacudirse": ("Sacudirse (polvos, esporas)", "frame 1 {n} crouches, frame 2 it shakes its whole body vigorously, "
                  "frame 3 it shakes even harder with its body puffed up (draw no powder), frame 4 it returns to its "
                  "normal stance."),
    "potenciarse": ("Potenciarse (mejoras, curas)", "frame 1 {n} crouches and gathers strength, frame 2 it rises up, "
                    "frame 3 it strikes a proud powered-up pose with its chest out (no effects drawn), frame 4 it returns "
                    "to its normal stance."),
}

# Por nombre en inglés (lo claro). Lo que no está acá sale de las reglas de `family_of`.
BY_NAME = {
    "morder": "bite crunch hyper-fang super-fang poison-fang clamp",
    "aranar": "scratch slash fury-swipes crush-claw dragon-claw metal-claw cut false-swipe leaf-blade fury-cutter "
              "razor-wind vice-grip guillotine",
    "puno": "comet-punch mega-punch fire-punch ice-punch thunder-punch dizzy-punch dynamic-punch focus-punch mach-punch "
            "meteor-mash shadow-punch sky-uppercut karate-chop cross-chop brick-break arm-thrust pound double-slap "
            "crabhammer vital-throw seismic-toss counter beat-up needle-arm hammer-arm rock-smash",
    "patada": "double-kick mega-kick jump-kick high-jump-kick rolling-kick low-kick triple-kick blaze-kick",
    "picotazo": "peck drill-peck",
    "ala": "wing-attack fly sky-attack aerial-ace steel-wing gust whirlwind air-cutter feather-dance silver-wind "
           "twister aeroblast",
    "cabezazo": "headbutt skull-bash zen-headbutt",
    "cola": "iron-tail tail-whip slam wrap bind constrict vine-whip poison-tail lick",
    "cuerno": "horn-attack fury-attack horn-drill megahorn poison-sting twineedle pin-missile",
    "pisoton": "stomp earthquake magnitude fissure",
    "lanzar": "rock-throw rock-tomb rock-slide bone-club bonemerang bone-rush mud-slap sand-attack barrage egg-bomb "
              "spikes present ice-ball razor-leaf magical-leaf leaf-blade-x pay-day",
    "boca": "ember flamethrower fire-blast fire-spin heat-wave overheat sacred-fire water-gun hydro-pump bubble "
            "bubble-beam surf water-pulse water-spout octazooka muddy-water ice-beam aurora-beam blizzard powder-snow "
            "icy-wind dragon-breath dragon-rage acid sludge sludge-bomb smog poison-gas smokescreen string-shot "
            "spider-web mud-shot mud-sport water-sport spit-up sand-tomb mist haze hyper-beam tri-attack swift "
            "mist-ball luster-purge signal-beam absorb mega-drain giga-drain leech-life solar-beam spike-cannon "
            "sludge-wave",
    "descarga": "thunder-shock thunderbolt thunder zap-cannon shock-wave thunder-wave spark charge discharge",
    "grito": "growl roar sing supersonic screech perish-song snore uproar metal-sound grass-whistle heal-bell "
             "hyper-voice howl fake-tears",
    "sacudirse": "sleep-powder stun-spore poison-powder spore cotton-spore sweet-scent aromatherapy",
    "embestida": "tackle take-down double-edge body-slam quick-attack extreme-speed rapid-spin rollout flame-wheel "
                 "volt-tackle submission thrash outrage petal-dance superpower reversal flail dig dive bounce waterfall "
                 "astonish pursuit faint-attack covet thief knock-off endeavor struggle facade return frustration "
                 "rage revenge smelling-salts secret-power self-destruct explosion",
}
_NAME = {n: fam for fam, names in BY_NAME.items() for n in names.split()}
# sin animación propia (dormir ya tiene la suya; los demás no hacen nada visible con el cuerpo)
SKIP = set("rest sleep-talk splash".split())


def family_of(move):
    """Familia de un ataque de official.json (None = sin animación)."""
    n = move["name_en"]
    if n in SKIP:
        return None
    if n in _NAME:
        return _NAME[n]
    cat, typ, target = move["category"], move["type"], move["target"]
    if cat == "physical":
        return "embestida"
    if cat == "special":
        if typ == "electric":
            return "descarga"
        if typ in ("psychic", "ghost", "dark", "fighting", "grass", "normal", "bug", "rock", "ground", "steel"):
            return "mental" if typ in ("psychic", "ghost", "dark") else "boca"
        if typ == "flying":
            return "ala"
        return "boca"
    # estado: a uno mismo (o su lado, el campo) → potenciarse; al rival → mirada
    # (Malicioso o Cara Susto son "net-good-stats" porque bajan al rival: manda el objetivo)
    if target in ("user", "users-field", "user-and-allies", "entire-field", "ally", "all-pokemon"):
        return "potenciarse"
    if target in ("selected-pokemon", "all-opponents", "random-opponent", "all-other-pokemon", "opponents-field"):
        return "mental"
    return "potenciarse"


def data():
    return json.load(open(os.path.join(ROOT, "data", "source", "official.json"), encoding="utf-8"))


def by_en(d):
    return {m["name_en"]: m for m in d["moves"].values()}


def species_families(d, dex):
    """{familia: [nombres en español de sus ataques]} de lo que aprende por nivel en FRLG."""
    sp = next(s for s in d["species"].values() if s["dex"] == dex) if isinstance(d["species"], dict) \
        else next(s for s in d["species"] if s["dex"] == dex)
    moves = by_en(d)
    out = {}
    for _, name in sp["learnset_frlg"]:
        m = moves.get(name)
        if m is None:
            continue
        f = family_of(m)
        if f is not None and m["name_es"] not in out.setdefault(f, []):
            out[f].append(m["name_es"])
    return {f: out[f] for f in FAMILIES if f in out}


if __name__ == "__main__":
    d = data()
    if len(sys.argv) > 1:
        for f, names in species_families(d, int(sys.argv[1])).items():
            print("%-12s %s" % (f, ", ".join(names)))
    else:
        import collections
        c = collections.Counter(family_of(m) for m in d["moves"].values())
        for f, k in c.most_common():
            print(f, k)
        sp = d["species"].values() if isinstance(d["species"], dict) else d["species"]
        fams = [len(species_families(d, s["dex"])) for s in sp]
        print("familias por especie: media %.1f, máx %d" % (sum(fams) / len(fams), max(fams)))
