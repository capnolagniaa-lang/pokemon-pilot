"""Genera los efectos de sonido del juego por código, con sonido retro tipo GBA (onda cuadrada, triangular y ruido,
como el chip de la Game Boy), y unas cortinas cortas por defecto (pedido del usuario 2026-10-26). Son sonidos
propios, no copiados: se pueden reemplazar poniendo otro archivo con el mismo nombre (ver docs/AUDIO.md).

  audio/efectos/<efecto>.wav   menú, golpes (uno por tipo), Poké Ball, puertas, saltos...
  audio/musica/<cortina>.wav   curacion, captura, subir_nivel, victoria_salvaje, evolucion_fin (solo si no hay ya
                               un archivo con ese nombre: no pisa tu música)

Uso: python -I -B tools/make_sfx.py <carpeta del proyecto> [--force]   (--force también pisa las cortinas)
"""
import math
import os
import random
import struct
import sys
import wave

RATE = 22050


def square(f, t, duty=0.5):
    return 1.0 if (f * t) % 1.0 < duty else -1.0


def tri(f, t):
    x = (f * t) % 1.0
    return 4.0 * x - 1.0 if x < 0.5 else 3.0 - 4.0 * x


def tone(dur, f0, f1=None, wave_fn="square", duty=0.5, vol=0.5, attack=0.005, release=0.06, vib=0.0, vib_rate=8.0):
    """Un tono de f0 a f1 Hz (barrido), con envolvente y vibrato opcional."""
    f1 = f0 if f1 is None else f1
    out = []
    n = int(dur * RATE)
    phase = 0.0
    for i in range(n):
        t = i / RATE
        k = i / max(1, n - 1)
        f = f0 + (f1 - f0) * k
        if vib:
            f *= 1.0 + vib * math.sin(2 * math.pi * vib_rate * t)
        phase += f / RATE
        if wave_fn == "square":
            s = 1.0 if phase % 1.0 < duty else -1.0
        elif wave_fn == "tri":
            x = phase % 1.0
            s = 4.0 * x - 1.0 if x < 0.5 else 3.0 - 4.0 * x
        else:
            s = math.sin(2 * math.pi * phase)
        env = min(1.0, t / attack) if attack > 0 else 1.0
        env *= min(1.0, (dur - t) / release) if release > 0 else 1.0
        out.append(s * vol * env)
    return out


def noise(dur, vol=0.5, release=0.08, lowpass=1.0, attack=0.002, seed=1):
    """Ruido (como el canal de ruido de la Game Boy); lowpass < 1 lo vuelve más grave."""
    rnd = random.Random(seed)
    out, last = [], 0.0
    n = int(dur * RATE)
    for i in range(n):
        t = i / RATE
        v = rnd.uniform(-1, 1)
        last = last + lowpass * (v - last)
        env = min(1.0, t / attack) * min(1.0, (dur - t) / release)
        out.append(last * vol * env)
    return out


def mix(*tracks):
    n = max(len(t) for t in tracks)
    return [sum(t[i] for t in tracks if i < len(t)) for i in range(n)]


def seq(*parts):
    out = []
    for p in parts:
        out.extend(p)
    return out


def silence(dur):
    return [0.0] * int(dur * RATE)


def notes(melody, wave_fn="square", duty=0.5, vol=0.35):
    """[(nota midi o None, duración)] → audio."""
    out = []
    for note, d in melody:
        if note is None:
            out.extend(silence(d))
        else:
            f = 440.0 * 2 ** ((note - 69) / 12.0)
            out.extend(tone(d, f, wave_fn=wave_fn, duty=duty, vol=vol, release=min(0.05, d * 0.4)))
    return out


def write(path, samples):
    peak = max(0.001, max(abs(s) for s in samples))
    k = min(1.0, 0.9 / peak)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * k)) * 32767)) for s in samples))


# --- Efectos -------------------------------------------------------------------------------
EFFECTS = {
    "menu_mover": lambda: tone(0.035, 1300, vol=0.25, duty=0.25),
    "menu_aceptar": lambda: seq(tone(0.04, 1050, vol=0.3), tone(0.06, 1570, vol=0.3)),
    "menu_volver": lambda: seq(tone(0.04, 1050, vol=0.3), tone(0.06, 700, vol=0.3)),
    "golpe": lambda: mix(noise(0.09, 0.6, lowpass=0.6), tone(0.06, 220, 90, vol=0.4)),
    "golpe_fuerte": lambda: mix(noise(0.18, 0.8, lowpass=0.35, release=0.12), tone(0.15, 160, 50, vol=0.6)),
    "esquive": lambda: noise(0.12, 0.35, lowpass=0.9, release=0.1, attack=0.05),
    "debilitado": lambda: tone(0.5, 600, 90, wave_fn="square", duty=0.25, vol=0.4, release=0.15),
    "bola_lanzar": lambda: seq(tone(0.08, 500, 1400, vol=0.3), noise(0.08, 0.2, lowpass=0.9)),
    "bola_sacudir": lambda: mix(noise(0.06, 0.4, lowpass=0.3), tone(0.05, 300, 200, vol=0.3)),
    "bola_captura": lambda: seq(tone(0.06, 400, vol=0.3), silence(0.04), tone(0.12, 1200, vol=0.35, duty=0.25)),
    "bola_escapa": lambda: seq(noise(0.1, 0.5, lowpass=0.5), tone(0.2, 900, 300, vol=0.3)),
    "puerta": lambda: seq(noise(0.05, 0.35, lowpass=0.4), tone(0.12, 330, 260, wave_fn="tri", vol=0.4)),
    "saltar": lambda: tone(0.14, 300, 900, vol=0.3, duty=0.25),
    "subir_nivel": lambda: notes([(72, 0.06), (76, 0.06), (79, 0.06), (84, 0.16)]),
    "dinero": lambda: seq(tone(0.05, 1975, vol=0.25), tone(0.12, 2637, vol=0.25, duty=0.25)),
    "mensaje": lambda: tone(0.03, 900, vol=0.2, duty=0.125),
    "firma": lambda: tone(0.25, 700, 1700, vol=0.25, duty=0.25, vib=0.02),
    "curacion": lambda: notes([(76, 0.08), (79, 0.08), (84, 0.2)], wave_fn="tri"),
    "cambio": lambda: seq(tone(0.06, 700, 1100, vol=0.3), tone(0.08, 1100, 1500, vol=0.25, duty=0.25)),
    # Un golpe por tipo (el que más se oye en combate).
    "golpe_normal": lambda: mix(noise(0.08, 0.6, lowpass=0.7), tone(0.05, 240, 110, vol=0.35)),
    "golpe_fuego": lambda: mix(noise(0.25, 0.6, lowpass=0.25, release=0.15, seed=3), tone(0.2, 300, 120, wave_fn="tri", vol=0.3)),
    "golpe_agua": lambda: mix(tone(0.18, 300, 900, wave_fn="sine", vol=0.5), noise(0.12, 0.2, lowpass=0.8, seed=5)),
    "golpe_electrico": lambda: mix(seq(*[tone(0.025, f, vol=0.35, duty=0.25) for f in (1800, 1200, 2200, 1500, 2600, 1300)]),
                                   noise(0.15, 0.3, lowpass=1.0, seed=7)),
    "golpe_planta": lambda: mix(noise(0.16, 0.4, lowpass=0.55, attack=0.03, seed=9), tone(0.12, 500, 700, wave_fn="tri", vol=0.2)),
    "golpe_hielo": lambda: mix(tone(0.2, 2400, 2000, wave_fn="sine", vol=0.35, vib=0.03, vib_rate=30), noise(0.08, 0.3, lowpass=1.0, seed=11)),
    "golpe_lucha": lambda: mix(noise(0.1, 0.8, lowpass=0.3, seed=13), tone(0.1, 140, 60, vol=0.6)),
    "golpe_veneno": lambda: tone(0.22, 260, 180, vol=0.4, duty=0.25, vib=0.08, vib_rate=14),
    "golpe_tierra": lambda: mix(noise(0.3, 0.7, lowpass=0.12, release=0.2, seed=15), tone(0.25, 90, 45, wave_fn="tri", vol=0.5)),
    "golpe_volador": lambda: noise(0.2, 0.5, lowpass=0.8, attack=0.06, release=0.12, seed=17),
    "golpe_psiquico": lambda: tone(0.3, 500, 1300, wave_fn="sine", vol=0.4, vib=0.06, vib_rate=10),
    "golpe_bicho": lambda: tone(0.16, 380, 320, vol=0.35, duty=0.125, vib=0.1, vib_rate=40),
    "golpe_roca": lambda: mix(noise(0.16, 0.8, lowpass=0.2, seed=19), tone(0.12, 120, 70, vol=0.5, duty=0.25)),
    "golpe_fantasma": lambda: tone(0.35, 700, 200, wave_fn="sine", vol=0.4, vib=0.08, vib_rate=6),
    "golpe_dragon": lambda: mix(tone(0.3, 110, 80, vol=0.5, duty=0.25, vib=0.05, vib_rate=12), noise(0.2, 0.3, lowpass=0.2, seed=21)),
    "golpe_siniestro": lambda: mix(noise(0.14, 0.6, lowpass=0.25, seed=23), tone(0.14, 180, 120, vol=0.3, duty=0.125)),
    "golpe_acero": lambda: mix(tone(0.25, 1560, wave_fn="square", duty=0.125, vol=0.3), tone(0.25, 2340, wave_fn="sine", vol=0.25)),
    "golpe_hada": lambda: seq(*[tone(0.04, f, wave_fn="tri", vol=0.35) for f in (1568, 2093, 2637, 3136)]),
}

# --- Cortinas por defecto (melodías propias; se reemplazan con la música original si la tenés) --------------------
JINGLES = {
    "curacion": lambda: notes([(72, 0.12), (76, 0.12), (79, 0.12), (84, 0.12), (None, 0.06), (79, 0.12), (84, 0.4)],
                              wave_fn="tri", vol=0.4),
    "captura": lambda: notes([(67, 0.1), (72, 0.1), (76, 0.1), (79, 0.2), (76, 0.1), (79, 0.45)], duty=0.25),
    "subir_nivel": lambda: notes([(76, 0.08), (79, 0.08), (83, 0.08), (88, 0.3)], duty=0.25),
    "victoria_salvaje": lambda: notes([(72, 0.12), (72, 0.12), (72, 0.12), (76, 0.3), (74, 0.12), (77, 0.12), (79, 0.5)],
                                      duty=0.5),
    "evolucion_fin": lambda: notes([(72, 0.1), (76, 0.1), (79, 0.1), (84, 0.1), (88, 0.1), (91, 0.5)], wave_fn="tri"),
}


def main():
    root = sys.argv[1]
    force = "--force" in sys.argv
    fx = os.path.join(root, "audio", "efectos")
    mus = os.path.join(root, "audio", "musica")
    os.makedirs(fx, exist_ok=True)
    os.makedirs(mus, exist_ok=True)
    for name, make in EFFECTS.items():
        write(os.path.join(fx, name + ".wav"), make())
    made = []
    for name, make in JINGLES.items():
        exists = any(os.path.exists(os.path.join(mus, "%s.%s" % (name, ext))) for ext in ("ogg", "mp3", "wav"))
        if exists and not force:
            continue
        write(os.path.join(mus, name + ".wav"), make())
        made.append(name)
    print("efectos: %d · cortinas: %s" % (len(EFFECTS), made))


if __name__ == "__main__":
    main()
