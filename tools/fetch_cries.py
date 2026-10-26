"""Baja los gritos de los Pokémon N.º 1-386 (pedido del usuario 2026-10-26) de PokeAPI (repositorio público
PokeAPI/cries, los "legacy": los de la época de GBA/DS) → audio/gritos/<n.º>.ogg. No vuelve a bajar lo que ya está.

Uso: python -I -B tools/fetch_cries.py <carpeta del proyecto>
Para reemplazar uno: poné tu archivo con el mismo nombre (ej. audio/gritos/25.ogg para Pikachu); .ogg, .mp3 o .wav.
"""
import os
import sys
import time
import urllib.request

URL = "https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/legacy/%d.ogg"


def main():
    out = os.path.join(sys.argv[1], "audio", "gritos")
    os.makedirs(out, exist_ok=True)
    got, skipped, failed = 0, 0, []
    for n in range(1, 387):
        path = os.path.join(out, "%d.ogg" % n)
        if os.path.exists(path) and os.path.getsize(path) > 0:
            skipped += 1
            continue
        try:
            with urllib.request.urlopen(URL % n, timeout=30) as r:
                data = r.read()
            if not data.startswith(b"OggS"):
                raise ValueError("no es un .ogg")
            with open(path, "wb") as f:
                f.write(data)
            got += 1
            time.sleep(0.05)
        except Exception as e:  # noqa: BLE001 — se informa y se sigue con el resto
            failed.append((n, str(e)))
    print("gritos: %d bajados, %d ya estaban, %d fallaron %s" % (got, skipped, len(failed), failed[:5]))


if __name__ == "__main__":
    main()
