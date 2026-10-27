#!/usr/bin/env python3
"""Generates the board emblems into assets/emblems/*.svg.

Flat, outlined style. Brand marks are loose look-alikes of the logos from the
2001 original: a private nostalgia build, not for public distribution.
Usage: python3 tool/emblems.py
"""
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / 'assets' / 'emblems'
INK = '#263238'
S = f'stroke="{INK}" stroke-width="2.5" stroke-linejoin="round" stroke-linecap="round"'


def svg(body: str) -> str:
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">{body}</svg>\n'


def wheel(cx, cy, r=8.5):
    return (f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="#37474F" {S}/>'
            f'<circle cx="{cx}" cy="{cy}" r="{r * 0.4:.1f}" fill="#CFD8DC"/>')


def motorcycle(body, accent, style):
    """style: sport | cruiser | classic | cross"""
    frame = f'<path d="M15 45 L27 31 L41 31 L49 45" fill="none" {S}/>'
    if style == 'sport':
        shell = (f'<path d="M20 33 C24 22 38 20 46 26 L52 33 L44 38 L28 38 Z" fill="{body}" {S}/>'
                 f'<path d="M46 26 L50 18 L55 19" fill="none" {S}/>'
                 f'<path d="M30 28 L42 27" stroke="{accent}" stroke-width="3" stroke-linecap="round"/>')
    elif style == 'cruiser':
        shell = (f'<path d="M14 34 C18 28 26 28 30 31 L44 30 C48 30 50 33 50 36 L30 38 Z" fill="{body}" {S}/>'
                 f'<path d="M44 30 L46 16 L54 15" fill="none" {S}/>'
                 f'<path d="M12 31 h9" stroke="{accent}" stroke-width="4" stroke-linecap="round"/>')
    elif style == 'classic':
        shell = (f'<path d="M24 32 C24 25 34 23 40 27 L42 33 L26 35 Z" fill="{body}" {S}/>'
                 f'<path d="M15 30 h12" stroke="{INK}" stroke-width="4" stroke-linecap="round"/>'
                 f'<path d="M41 28 L45 19 L52 18" fill="none" {S}/>'
                 f'<circle cx="49" cy="25" r="3.5" fill="{accent}" {S}/>')
    else:  # cross
        shell = (f'<path d="M18 30 L30 26 L44 26 L50 31 L40 34 L26 34 Z" fill="{body}" {S}/>'
                 f'<path d="M44 26 L47 15 L55 14" fill="none" {S}/>'
                 f'<path d="M40 22 L52 24" stroke="{accent}" stroke-width="4" stroke-linecap="round"/>'
                 f'<path d="M50 31 L56 31" fill="none" {S}/>')
    return svg(wheel(15, 45, 9) + wheel(49, 45, 9) + frame + shell)


def car(body, accent, style):
    """style: sedan | coupe | limo | hatch | van | suv | pickup"""
    shapes = {
        'sedan': 'M6 42 L8 34 L18 31 L24 23 L42 23 L50 31 L58 33 L58 42 Z',
        'coupe': 'M6 42 L8 35 L20 31 L28 24 L40 24 L50 32 L58 34 L58 42 Z',
        'limo': 'M4 42 L5 34 L14 31 L20 24 L46 24 L52 31 L60 33 L60 42 Z',
        'hatch': 'M8 42 L9 33 L18 30 L24 22 L44 22 L50 31 L56 33 L56 42 Z',
        'van': 'M7 42 L7 22 Q7 18 11 18 L44 18 L54 30 L57 32 L57 42 Z',
        'suv': 'M6 42 L6 30 L14 28 L20 19 L46 19 L52 28 L58 30 L58 42 Z',
        'pickup': 'M5 42 L5 31 L30 31 L30 21 L44 21 L51 30 L59 32 L59 42 Z',
    }
    windows = {
        'sedan': 'M21 31 L26 25 L33 25 L33 31 Z M36 31 L36 25 L41 25 L46 31 Z',
        'coupe': 'M23 31 L29 26 L38 26 L45 31 Z',
        'limo': 'M17 31 L22 26 L30 26 L30 31 Z M33 31 L33 26 L40 26 L40 31 Z M43 31 L43 26 L46 26 L49 31 Z',
        'hatch': 'M21 30 L26 24 L34 24 L34 30 Z M37 30 L37 24 L43 24 L47 30 Z',
        'van': 'M11 29 L11 22 L22 22 L22 29 Z M25 29 L25 22 L36 22 L36 29 Z M39 29 L39 22 L44 22 L50 29 Z',
        'suv': 'M18 28 L23 22 L32 22 L32 28 Z M35 28 L35 22 L44 22 L48 28 Z',
        'pickup': 'M33 30 L33 24 L43 24 L47 30 Z',
    }
    lights = (f'<rect x="{"55" if style != "limo" else "57"}" y="34" width="3" height="3" rx="1" fill="#FFEB3B"/>'
              f'<path d="M8 38 h48" stroke="{accent}" stroke-width="2"/>')
    return svg(f'<path d="{shapes[style]}" fill="{body}" {S}/>'
               f'<path d="{windows[style]}" fill="#B3E5FC" {S}/>'
               + lights + wheel(17, 43, 7) + wheel(47, 43, 7))


E = {}

# --- sport ---------------------------------------------------------------
E['puma'] = svg(
    f'<path d="M32 55 C22 55 16 50 16 44 C16 37 24 34 32 34 C40 34 48 37 48 44 C48 50 42 55 32 55 Z" fill="#4E342E" {S}/>'
    + ''.join(f'<ellipse cx="{x}" cy="{y}" rx="5.5" ry="7" transform="rotate({a} {x} {y})" fill="#4E342E" {S}/>'
              for x, y, a in [(14, 28, -25), (24, 17, -8), (40, 17, 8), (50, 28, 25)])
    + '<ellipse cx="27" cy="41" rx="4" ry="2.5" fill="#fff" opacity=".35"/>')
E['montana'] = svg(
    '<circle cx="15" cy="16" r="7" fill="#FFC107"/>'
    f'<path d="M3 52 L22 22 L31 35 L42 16 L61 52 Z" fill="#78909C" {S}/>'
    f'<path d="M42 16 L36 27 L41 25 L45 29 L48 26 Z" fill="#fff" {S}/>'
    f'<path d="M22 22 L18 29 L22 27 L26 29 Z" fill="#fff" {S}/>'
    '<path d="M3 52 L61 52" stroke="#388E3C" stroke-width="4"/>')
E['adidas'] = svg(
    f'<path d="M6 46 L58 46 L58 52 L6 52 Z" fill="#fff" {S}/>'
    f'<path d="M8 46 C8 36 12 28 18 26 L28 33 C36 36 44 36 50 38 C55 40 58 43 58 46 Z" fill="#1E88E5" {S}/>'
    f'<path d="M24 32 l4 -3 M29 34 l4 -3 M34 35 l4 -3" {S}/>'
    f'<path d="M18 26 L16 20 L22 19 L26 30" fill="#1E88E5" {S}/>')
E['goldcup'] = svg(
    f'<path d="M20 16 C14 16 13 26 22 29" fill="none" {S}/>'
    f'<path d="M44 16 C50 16 51 26 42 29" fill="none" {S}/>'
    f'<path d="M19 10 L45 10 L45 20 C45 31 39 37 32 37 C25 37 19 31 19 20 Z" fill="#FFC107" {S}/>'
    f'<path d="M28 37 L36 37 L36 45 L28 45 Z" fill="#FFB300" {S}/>'
    f'<path d="M20 45 L44 45 L44 53 L20 53 Z" fill="#6D4C41" {S}/>'
    '<path d="M32 15 l2.2 4.6 5 .7 -3.6 3.5 .9 5 -4.5 -2.4 -4.5 2.4 .9 -5 -3.6 -3.5 5 -.7 Z" fill="#FFF59D"/>')
E['botas'] = svg(
    f'<path d="M17 9 L33 9 L33 33 L47 39 C52 41 55 44 55 48 L55 50 L15 50 Z" fill="#A1887F" {S}/>'
    f'<path d="M13 50 L57 50 L57 56 L13 56 Z" fill="#424242" {S}/>'
    f'<path d="M23 16 h6 M23 22 h6 M23 28 h6 M27 34 h7" {S}/>'
    f'<path d="M17 9 L33 9" stroke="#6D4C41" stroke-width="5"/>')

# --- motorcycles ---------------------------------------------------------
E['suzuki'] = motorcycle('#1E88E5', '#E3F2FD', 'sport')
E['yamaha'] = motorcycle('#3949AB', '#FFFFFF', 'cruiser')
E['honda'] = motorcycle('#E53935', '#FFEB3B', 'classic')
E['kawasaki'] = motorcycle('#43A047', '#C8E6C9', 'cross')

# --- cars ----------------------------------------------------------------
E['audi'] = car('#B0BEC5', '#78909C', 'sedan')
E['bmw'] = car('#1E88E5', '#0D47A1', 'coupe')
E['mercedes'] = car('#37474F', '#90A4AE', 'limo')
E['opel'] = car('#FDD835', '#F57F17', 'hatch')
E['volkswagen'] = car('#4FC3F7', '#0277BD', 'van')
E['nissan'] = car('#E53935', '#B71C1C', 'suv')
E['toyota'] = car('#ECEFF1', '#E53935', 'pickup')

# --- electronics ---------------------------------------------------------
E['canon'] = svg(
    f'<path d="M8 22 L22 22 L26 15 L38 15 L42 22 L56 22 L56 50 L8 50 Z" fill="#424242" {S}/>'
    f'<circle cx="32" cy="36" r="11" fill="#90A4AE" {S}/>'
    f'<circle cx="32" cy="36" r="6" fill="#263238"/>'
    '<circle cx="29.5" cy="33.5" r="2" fill="#fff"/>'
    '<rect x="46" y="26" width="6" height="4" rx="1" fill="#E53935"/>')
E['fisher'] = svg(
    f'<rect x="16" y="6" width="32" height="52" rx="4" fill="#6D4C41" {S}/>'
    f'<circle cx="32" cy="20" r="7" fill="#37474F" {S}/>'
    f'<circle cx="32" cy="42" r="11" fill="#37474F" {S}/>'
    '<circle cx="32" cy="42" r="4" fill="#90A4AE"/><circle cx="32" cy="20" r="2.5" fill="#90A4AE"/>')
E['national'] = svg(
    f'<path d="M14 22 L44 8" {S}/>'
    f'<rect x="6" y="22" width="52" height="32" rx="5" fill="#C62828" {S}/>'
    f'<circle cx="21" cy="38" r="9" fill="#FFCDD2" {S}/>'
    + ''.join(f'<path d="M{x} 32 v12" stroke="#B71C1C" stroke-width="1.5"/>' for x in (17, 21, 25))
    + f'<rect x="35" y="29" width="17" height="7" rx="1.5" fill="#FFF59D" {S}/>'
    f'<circle cx="40" cy="45" r="3" fill="#fff" {S}/><circle cx="48" cy="45" r="3" fill="#fff" {S}/>')
E['philips'] = svg(
    '<g stroke="#FFC107" stroke-width="3" stroke-linecap="round">'
    '<path d="M32 3 v5 M12 12 l4 4 M52 12 l-4 4 M5 30 h5 M54 30 h5"/></g>'
    f'<path d="M32 12 C21 12 16 21 16 28 C16 35 22 39 24 44 L40 44 C42 39 48 35 48 28 C48 21 43 12 32 12 Z" fill="#FFF176" {S}/>'
    f'<path d="M24 44 L40 44 L40 54 L24 54 Z" fill="#B0BEC5" {S}/>'
    f'<path d="M24 49 h16" {S}/><path d="M28 54 L28 58 L36 58 L36 54" fill="#78909C" {S}/>'
    f'<path d="M28 44 L28 32 L32 36 L36 32 L36 44" fill="none" stroke="#FF8F00" stroke-width="2"/>')
E['sharp'] = svg(
    f'<rect x="13" y="5" width="38" height="54" rx="5" fill="#455A64" {S}/>'
    f'<rect x="18" y="10" width="28" height="11" rx="2" fill="#C5E1A5" {S}/>'
    '<text x="44" y="19" font-family="monospace" font-size="9" font-weight="bold" fill="#33691E" text-anchor="end">1000</text>'
    + ''.join(f'<rect x="{18 + c * 8}" y="{26 + r * 8}" width="6" height="6" rx="1.5" fill="{"#FF7043" if c == 3 else "#ECEFF1"}"/>'
              for r in range(4) for c in range(4)))
E['ayva'] = svg(
    f'<path d="M14 18 L50 18 M20 18 L24 10 L40 10 L44 18" fill="none" {S}/>'
    f'<rect x="4" y="18" width="56" height="34" rx="6" fill="#FDD835" {S}/>'
    f'<circle cx="17" cy="36" r="9" fill="#424242" {S}/><circle cx="47" cy="36" r="9" fill="#424242" {S}/>'
    '<circle cx="17" cy="36" r="3.5" fill="#9E9E9E"/><circle cx="47" cy="36" r="3.5" fill="#9E9E9E"/>'
    f'<rect x="27" y="28" width="10" height="16" rx="1.5" fill="#fff" {S}/>'
    '<circle cx="32" cy="33" r="2" fill="#424242"/><circle cx="32" cy="39" r="2" fill="#424242"/>')
E['akai'] = svg(
    f'<rect x="4" y="12" width="56" height="40" rx="5" fill="#7E57C2" {S}/>'
    + ''.join(f'<circle cx="{x}" cy="28" r="10" fill="#ECEFF1" {S}/><circle cx="{x}" cy="28" r="3" fill="#455A64"/>'
              f'<path d="M{x} 19 v5 M{x - 8} 31 l4 -2 M{x + 8} 31 l-4 -2" stroke="#455A64" stroke-width="2"/>'
              for x in (18, 46))
    + f'<path d="M18 38 L32 46 L46 38" fill="none" stroke="#3E2723" stroke-width="2"/>')
E['panasonic'] = svg(
    f'<path d="M24 6 L32 14 L40 6" fill="none" {S}/>'
    f'<rect x="5" y="14" width="54" height="38" rx="6" fill="#455A64" {S}/>'
    f'<rect x="10" y="19" width="36" height="28" rx="4" fill="#4FC3F7" {S}/>'
    '<path d="M14 40 L22 30 L28 36 L34 27 L42 40 Z" fill="#81C784"/>'
    '<circle cx="18" cy="25" r="3" fill="#FFF59D"/>'
    '<circle cx="53" cy="24" r="2.5" fill="#ECEFF1"/><circle cx="53" cy="32" r="2.5" fill="#ECEFF1"/>'
    f'<path d="M14 52 L12 58 M50 52 L52 58" {S}/>')
E['sanyo'] = svg(
    f'<rect x="4" y="22" width="56" height="22" rx="4" fill="#B0BEC5" {S}/>'
    f'<rect x="10" y="27" width="28" height="9" rx="2" fill="#263238" {S}/>'
    '<rect x="13" y="30" width="22" height="3" rx="1" fill="#546E7A"/>'
    '<text x="52" y="34" font-family="monospace" font-size="7" font-weight="bold" fill="#00E676" text-anchor="end">12:00</text>'
    + ''.join(f'<rect x="{42 + i * 4.5}" y="38" width="3" height="3" rx=".8" fill="#455A64"/>' for i in range(3))
    + f'<path d="M10 44 L10 48 M54 44 L54 48" {S}/>')
E['casio'] = svg(
    f'<rect x="22" y="2" width="20" height="16" rx="3" fill="#455A64" {S}/>'
    f'<rect x="22" y="46" width="20" height="16" rx="3" fill="#455A64" {S}/>'
    f'<rect x="12" y="15" width="40" height="34" rx="8" fill="#43A047" {S}/>'
    f'<rect x="17" y="21" width="30" height="16" rx="2" fill="#C5E1A5" {S}/>'
    '<text x="32" y="33" font-family="monospace" font-size="10" font-weight="bold" fill="#1B5E20" text-anchor="middle">8:88</text>'
    '<circle cx="20" cy="43" r="1.8" fill="#fff"/><circle cx="44" cy="43" r="1.8" fill="#fff"/>'
    f'<path d="M52 24 h3 M52 40 h3" {S}/>')

# --- band ----------------------------------------------------------------
E['band'] = svg(
    f'<path d="M14 36 C14 22 50 22 50 36 C50 50 42 58 32 58 C22 58 14 50 14 36 Z" fill="#FFCC80" {S}/>'
    f'<path d="M14 33 L50 33 L50 41 C44 39 38 41 32 43 C26 41 20 39 14 41 Z" fill="#212121" {S}/>'
    '<ellipse cx="24" cy="37" rx="3" ry="2" fill="#fff"/><ellipse cx="40" cy="37" rx="3" ry="2" fill="#fff"/>'
    '<circle cx="24" cy="37" r="1.2" fill="#212121"/><circle cx="40" cy="37" r="1.2" fill="#212121"/>'
    f'<path d="M22 49 C26 45 30 47 32 49 C34 47 38 45 42 49 C38 51 34 51 32 50 C30 51 26 51 22 49 Z" fill="#212121"/>'
    f'<path d="M4 26 C12 22 52 22 60 26 C56 29 8 29 4 26 Z" fill="#212121" {S}/>'
    f'<path d="M18 25 C18 10 22 6 32 6 C42 6 46 10 46 25 Z" fill="#212121" {S}/>'
    '<path d="M18 21 C26 23 38 23 46 21" stroke="#B71C1C" stroke-width="3"/>')

# --- drinks --------------------------------------------------------------
E['pepsi'] = svg(
    f'<path d="M38 2 L34 16" stroke="#fff" stroke-width="4" stroke-linecap="round"/>'
    f'<path d="M38 2 L34 16" stroke="{INK}" stroke-width="1"/>'
    f'<path d="M20 12 L44 12 L46 16 L46 52 L44 56 L20 56 L18 52 L18 16 Z" fill="#1565C0" {S}/>'
    f'<path d="M22 8 L42 8 L44 12 L20 12 Z" fill="#B0BEC5" {S}/>'
    '<path d="M18 30 L46 30 L46 40 L18 40 Z" fill="#0D47A1"/>'
    '<circle cx="27" cy="23" r="2.5" fill="#fff" opacity=".8"/><circle cx="35" cy="20" r="1.6" fill="#fff" opacity=".8"/>'
    '<circle cx="38" cy="46" r="2.2" fill="#fff" opacity=".8"/><circle cx="29" cy="49" r="1.4" fill="#fff" opacity=".8"/>'
    '<path d="M22 18 v32" stroke="#fff" stroke-width="2.5" opacity=".35" stroke-linecap="round"/>')
E['fanta'] = svg(
    f'<path d="M27 4 L37 4 L37 14 C37 18 44 22 44 30 L44 56 C44 58 42 60 40 60 L24 60 C22 60 20 58 20 56 L20 30 C20 22 27 18 27 14 Z" fill="#FF9800" {S}/>'
    f'<rect x="26" y="2" width="12" height="5" rx="1.5" fill="#1565C0" {S}/>'
    f'<rect x="20" y="34" width="24" height="14" fill="#1565C0" {S}/>'
    '<circle cx="32" cy="41" r="4.5" fill="#FF9800"/><path d="M32 36 l2 -3" stroke="#43A047" stroke-width="2"/>'
    '<path d="M24 24 v30" stroke="#fff" stroke-width="2.5" opacity=".35" stroke-linecap="round"/>')
E['7up'] = svg(
    f'<path d="M18 10 L46 10 L48 14 L48 52 L46 56 L18 56 L16 52 L16 14 Z" fill="#2E7D32" {S}/>'
    f'<path d="M20 6 L44 6 L46 10 L18 10 Z" fill="#B0BEC5" {S}/>'
    '<text x="32" y="38" font-family="sans-serif" font-size="17" font-weight="bold" fill="#fff" text-anchor="middle">7</text>'
    '<circle cx="41" cy="44" r="5" fill="#FFEB3B"/><circle cx="41" cy="44" r="5" fill="none" stroke="#C0CA33" stroke-width="1.5"/>'
    '<circle cx="24" cy="44" r="2.2" fill="#fff" opacity=".8"/><circle cx="28" cy="49" r="1.5" fill="#fff" opacity=".8"/>'
    '<path d="M20 16 v34" stroke="#fff" stroke-width="2.5" opacity=".3" stroke-linecap="round"/>')

# --- shaft ---------------------------------------------------------------
E['turbo'] = svg(
    f'<rect x="8" y="16" width="48" height="32" rx="4" fill="#E53935" {S}/>'
    f'<path d="M8 22 L56 22 M8 42 L56 42" stroke="#FFEB3B" stroke-width="2.5"/>'
    '<path d="M34 24 L26 33 L32 33 L28 40 L38 30 L32 30 Z" fill="#FFEB3B" stroke="#263238" stroke-width="1.5" stroke-linejoin="round"/>'
    '<text x="48" y="34" font-family="sans-serif" font-size="7" font-weight="bold" fill="#fff" text-anchor="middle">GUM</text>')
E['donald'] = svg(
    f'<circle cx="34" cy="26" r="20" fill="#F48FB1" {S}/>'
    '<ellipse cx="27" cy="18" rx="6" ry="4" fill="#fff" opacity=".6" transform="rotate(-30 27 18)"/>'
    f'<path d="M14 54 C14 44 22 42 30 46 C36 42 46 44 46 54 Z" fill="#FFCC80" {S}/>'
    f'<path d="M28 46 C30 50 34 50 36 46" fill="#F48FB1" {S}/>')
E['tiptop'] = svg(
    f'<path d="M32 36 L32 60" stroke="#ECEFF1" stroke-width="5" stroke-linecap="round"/>'
    f'<path d="M32 36 L32 60" stroke="{INK}" stroke-width="1" fill="none"/>'
    f'<circle cx="32" cy="22" r="17" fill="#FF1744" {S}/>'
    '<path d="M32 22 C32 16 38 14 41 18 C44 23 40 30 32 30 C24 30 19 24 21 17 C23 10 32 8 37 11" fill="none" stroke="#fff" stroke-width="3" stroke-linecap="round"/>')

# --- special cells -------------------------------------------------------
E['start'] = svg(
    f'<path d="M14 6 L14 60" {S}/>'
    f'<path d="M14 8 L54 8 L54 34 L14 34 Z" fill="#fff" {S}/>'
    + ''.join(f'<rect x="{14 + c * 8}" y="{8 + r * 6.5}" width="8" height="6.5" fill="#263238"/>'
              for r in range(4) for c in range(5) if (r + c) % 2 == 0)
    + f'<path d="M14 8 L54 8 L54 34 L14 34 Z" fill="none" {S}/>')
E['bank'] = svg(
    f'<path d="M6 22 L32 7 L58 22 Z" fill="#1565C0" {S}/>'
    + ''.join(f'<rect x="{x}" y="25" width="6" height="22" fill="#E3F2FD" {S}/>' for x in (11, 22, 36, 47))
    + f'<rect x="6" y="47" width="52" height="8" fill="#1565C0" {S}/>'
    '<text x="32" y="20" font-family="sans-serif" font-size="10" font-weight="bold" fill="#FFEB3B" text-anchor="middle">$</text>')
E['treasure'] = svg(
    '<circle cx="18" cy="16" r="5" fill="#FFD54F" stroke="#FF8F00" stroke-width="1.5"/>'
    '<circle cx="30" cy="12" r="5" fill="#FFD54F" stroke="#FF8F00" stroke-width="1.5"/>'
    '<circle cx="44" cy="15" r="5" fill="#FFD54F" stroke="#FF8F00" stroke-width="1.5"/>'
    f'<path d="M8 28 C8 16 56 16 56 28 Z" fill="#8D6E63" {S}/>'
    '<path d="M10 25 L54 25" stroke="#FFD54F" stroke-width="4"/>'
    f'<rect x="8" y="28" width="48" height="28" rx="2" fill="#795548" {S}/>'
    f'<path d="M8 36 h48 M20 28 v28 M44 28 v28" stroke="#FFC107" stroke-width="2.5"/>'
    f'<rect x="27" y="31" width="10" height="11" rx="2" fill="#FFC107" {S}/>'
    '<circle cx="32" cy="36" r="1.8" fill="#263238"/>')
E['crisis'] = svg(
    f'<path d="M8 8 L8 56 L58 56" fill="none" {S}/>'
    '<path d="M12 16 L24 26 L32 22 L42 38 L52 46" fill="none" stroke="#E53935" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>'
    '<path d="M44 48 L54 48 L53 38 Z" fill="#E53935"/>'
    f'<path d="M16 50 v-6 M26 50 v-10 M36 50 v-4 M46 50 v-2" stroke="#90A4AE" stroke-width="5"/>')
E['elevator'] = svg(
    f'<rect x="10" y="4" width="44" height="56" rx="3" fill="#90A4AE" {S}/>'
    f'<rect x="15" y="14" width="34" height="42" fill="#CFD8DC" {S}/>'
    f'<path d="M32 14 L32 56" {S}/>'
    '<rect x="24" y="6" width="16" height="6" rx="1" fill="#263238"/>'
    '<path d="M28 11 l2 -3 2 3 Z M34 8 l2 3 2 -3 Z" fill="#FF5252"/>')
E['pot'] = svg(
    f'<path d="M24 16 C18 26 8 34 8 46 C8 55 18 60 32 60 C46 60 56 55 56 46 C56 34 46 26 40 16 Z" fill="#A1887F" {S}/>'
    f'<path d="M22 10 L42 10 L38 17 L26 17 Z" fill="#8D6E63" {S}/>'
    '<path d="M24 17 C28 19 36 19 40 17" stroke="#FFC107" stroke-width="3"/>'
    '<text x="32" y="50" font-family="sans-serif" font-size="22" font-weight="bold" fill="#FFEB3B" text-anchor="middle" stroke="#5D4037" stroke-width="1">$</text>')


# --- 2001-style brand marks (override the generic emblems above) ----------
import math


def ring(r, color, width=4, cx=32, cy=32):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{color}" stroke-width="{width}"/>'


def star_arm(angle, r=21, w=4.5):
    a = math.radians(angle)
    tip = (32 + r * math.cos(a), 32 + r * math.sin(a))
    l = (32 + w * math.cos(a - 2.1), 32 + w * math.sin(a - 2.1))
    rr = (32 + w * math.cos(a + 2.1), 32 + w * math.sin(a + 2.1))
    return f'M32 32 L{l[0]:.1f} {l[1]:.1f} L{tip[0]:.1f} {tip[1]:.1f} L{rr[0]:.1f} {rr[1]:.1f} Z'


E['puma'] = svg(
    '<path d="M61 16 C60 13 57 11 54 11 L52 6 L49.5 10.5 '
    'C44 12 38 16 31 20 C24 24 17 27 12 29 '
    'C8 28 5.5 24 5 18 C4.6 15.5 1.8 16 2.2 19.5 C3 26 6 30.5 10 32.5 '
    'C7 35.5 4 39 1 42 L2.5 45.5 C7 43 11 40 15.5 37.5 '
    'C21 38.5 27 36.5 33 33.5 C39 31 44 30 49 29.5 L61 29 L61.5 25 '
    'C57 25 53 24 50 23 C53 20.5 57 19.5 60.5 18.5 Z" fill="#212121"/>'
    '<circle cx="56" cy="14" r="1" fill="#fff"/>')
E['montana'] = svg(
    ''.join(f'<rect x="{x}" y="23" width="17" height="17" fill="{c}" {S}/>'
            for x, c in ((4, '#E53935'), (23.5, '#43A047'), (43, '#1E88E5'))))
E['adidas'] = svg(
    '<g transform="translate(0 8)"><g fill="#1565C0">'
    '<ellipse cx="32" cy="22" rx="8" ry="16"/>'
    '<ellipse cx="32" cy="22" rx="8" ry="16" transform="rotate(-58 32 38)"/>'
    '<ellipse cx="32" cy="22" rx="8" ry="16" transform="rotate(58 32 38)"/></g>'
    '<path d="M4 29 L60 29 M4 34.5 L60 34.5" stroke="#fff" stroke-width="2.6"/>'
    '<rect x="4" y="38" width="56" height="6" fill="#fff"/></g>')

E['suzuki'] = svg(
    '<g transform="translate(0 4)"><path d="M50 9 L24 9 L12 21 L34 33 L28 39 L12 39 L12 47 L38 47 L52 33 L30 21 L34 17 L50 17 Z" fill="#D32F2F" stroke="#7f0000" stroke-width="1.5" stroke-linejoin="round"/></g>')
_fork = ('<path d="M32 30 L32 9 M27 9 L27 16 Q27 21 32 21 Q37 21 37 16 L37 9" '
         'fill="none" stroke="#4527A0" stroke-width="3.2" stroke-linecap="round"/>')
E['yamaha'] = svg(
    ring(25, '#4527A0', 3.5)
    + ''.join(f'<g transform="rotate({a} 32 32)">{_fork}</g>' for a in (0, 120, 240))
    + '<circle cx="32" cy="32" r="4" fill="#4527A0"/>')
E['honda'] = svg(
    '<g transform="translate(0 6)"><path d="M6 44 C14 24 32 12 59 13 C48 17 40 22 35 28 C42 25 50 25 56 26 '
    'C46 29 39 33 35 38 C40 36 46 36 50 37 C40 41 26 46 6 44 Z" fill="#E53935" stroke="#7f0000" stroke-width="1.5" stroke-linejoin="round"/>'
    '<path d="M14 40 C22 30 32 23 44 19" stroke="#fff" stroke-width="1.5" fill="none" opacity=".7"/></g>')
E['kawasaki'] = svg(
    '<rect x="6" y="6" width="52" height="52" rx="12" fill="#2E7D32" stroke="#1B5E20" stroke-width="2"/>'
    '<path d="M17 13 h9 v15 l13 -15 h11 l-15 17 l16 21 h-11 l-11 -15 l-3 3 v12 h-9 Z" fill="#fff"/>')

E['audi'] = svg(''.join(ring(9, '#9E9E9E', 3.6, cx, 32) for cx in (14, 26, 38, 50)))
E['bmw'] = svg(
    '<circle cx="32" cy="32" r="29" fill="#212121"/>'
    '<circle cx="32" cy="32" r="18" fill="#fff"/>'
    '<path d="M32 32 L32 14 A18 18 0 0 1 50 32 Z M32 32 L32 50 A18 18 0 0 1 14 32 Z" fill="#1E88E5"/>'
    + ring(18, '#BDBDBD', 1.5)
    + '<text x="32" y="11.5" font-family="PTSans" font-weight="bold" font-size="7.5" fill="#fff" text-anchor="middle">B M W</text>')
E['mercedes'] = svg(
    ring(26, '#78909C', 3.5)
    + f'<path d="{star_arm(-90)} {star_arm(30)} {star_arm(150)}" fill="#607D8B" stroke="#37474F" stroke-width="1"/>')
E['opel'] = svg(
    '<circle cx="32" cy="32" r="22" fill="#FFEB3B"/>' + ring(22, '#424242', 4)
    + '<path d="M3 31 L35 31 L29 25.5 L61 33 L29 33 L35 38.5 Z" fill="#424242" stroke="#424242" stroke-width="1.5" stroke-linejoin="round"/>')
E['volkswagen'] = svg(
    '<circle cx="32" cy="32" r="28" fill="#1565C0"/>' + ring(24, '#fff', 3)
    + '<path d="M21 14 L32 34 L43 14 M13 24 L23 49 L32 35 L41 49 L51 24" fill="none" stroke="#fff" stroke-width="4" stroke-linejoin="round"/>')
E['nissan'] = svg(
    ring(24, '#90A4AE', 4.5)
    + '<rect x="3" y="24" width="58" height="16" fill="#1565C0" stroke="#0D47A1" stroke-width="1.5"/>'
    '<text x="12" y="36.5" font-family="PTSans" font-weight="bold" font-size="11.5" fill="#fff">NISSAN</text>')
E['toyota'] = svg(
    '<ellipse cx="32" cy="34" rx="28" ry="19" fill="none" stroke="#E53935" stroke-width="4"/>'
    '<ellipse cx="32" cy="34" rx="8.5" ry="19" fill="none" stroke="#E53935" stroke-width="4"/>'
    '<ellipse cx="32" cy="25" rx="17" ry="8.5" fill="none" stroke="#E53935" stroke-width="4"/>')

E['philips'] = svg(
    '<path d="M10 6 L54 6 L54 34 C54 48 44 56 32 60 C20 56 10 48 10 34 Z" fill="#1565C0" stroke="#0D47A1" stroke-width="2"/>'
    '<path d="M14 30 Q20 24 26 30 T38 30 T50 30 M14 38 Q20 32 26 38 T38 38 T50 38 M14 46 Q20 40 26 46 T38 46" fill="none" stroke="#fff" stroke-width="2.5"/>'
    + ''.join(f'<path d="M{x} {y - 4} L{x + 1} {y - 1} L{x + 4} {y} L{x + 1} {y + 1} L{x} {y + 4} L{x - 1} {y + 1} L{x - 4} {y} L{x - 1} {y - 1} Z" fill="#fff"/>'
              for x, y in ((20, 15), (44, 15), (30, 52), (40, 49))))

E['pepsi'] = svg(
    '<circle cx="32" cy="32" r="26" fill="#1565C0"/>'
    '<path d="M6 32 A26 26 0 0 1 58 32 C46 24 34 34 22 28 C16 25 10 27 6 32 Z" fill="#E53935"/>'
    '<path d="M6 32 C10 27 16 25 22 28 C34 34 46 24 58 32 C58 33.5 57.8 35 57.6 36.4 C46 30 34 40 22 34 C15 31 9.5 33 6.4 36.5 C6.1 35 6 33.5 6 32 Z" fill="#fff"/>'
    + ring(26, '#0D47A1', 2))
E['fanta'] = svg(
    '<path d="M32 16 C30 8 22 5 16 8 C20 14 26 16 32 16 Z" fill="#43A047" stroke="#1B5E20" stroke-width="1.5"/>'
    '<path d="M32 16 C35 9 43 7 48 11 C43 16 37 17 32 16 Z" fill="#66BB6A" stroke="#1B5E20" stroke-width="1.5"/>'
    '<circle cx="32" cy="38" r="21" fill="#FF9800" stroke="#E65100" stroke-width="2"/>'
    '<ellipse cx="25" cy="31" rx="6" ry="4" fill="#fff" opacity=".35" transform="rotate(-30 25 31)"/>'
    '<text x="32" y="44" font-family="RussoOne" font-size="13" fill="#1565C0" text-anchor="middle" stroke="#fff" stroke-width=".6">Fanta</text>')
E['7up'] = svg(
    '<rect x="6" y="6" width="52" height="52" rx="8" fill="#2E7D32" stroke="#1B5E20" stroke-width="2"/>'
    '<text x="25" y="45" font-family="RussoOne" font-size="36" fill="#fff" text-anchor="middle">7</text>'
    '<text x="45" y="30" font-family="RussoOne" font-size="12" fill="#fff" text-anchor="middle">UP</text>'
    '<circle cx="45" cy="42" r="7" fill="#E53935" stroke="#fff" stroke-width="1.5"/>')

E['donald'] = svg(
    '<path d="M14 26 C14 14 22 8 32 8 C42 8 50 14 50 26 C50 40 42 50 32 50 C22 50 14 40 14 26 Z" fill="#fff" stroke="#263238" stroke-width="2.5"/>'
    '<path d="M18 16 C22 6 42 6 46 16 L50 18 L14 18 Z" fill="#1E88E5" stroke="#263238" stroke-width="2.5" stroke-linejoin="round"/>'
    '<path d="M36 6 C40 2 44 4 42 8" fill="#1E88E5" stroke="#263238" stroke-width="2"/>'
    '<ellipse cx="26" cy="27" rx="3.5" ry="5" fill="#fff" stroke="#263238" stroke-width="1.5"/><circle cx="27" cy="28" r="1.8" fill="#263238"/>'
    '<ellipse cx="38" cy="27" rx="3.5" ry="5" fill="#fff" stroke="#263238" stroke-width="1.5"/><circle cx="37" cy="28" r="1.8" fill="#263238"/>'
    '<path d="M20 38 C26 32 38 32 44 38 C46 42 40 46 32 46 C24 46 18 42 20 38 Z" fill="#FFA000" stroke="#263238" stroke-width="2" stroke-linejoin="round"/>'
    '<path d="M22 40 C28 42 36 42 42 40" stroke="#263238" stroke-width="1.5" fill="none"/>'
    '<path d="M24 50 L32 58 L40 50" fill="#E53935" stroke="#263238" stroke-width="2" stroke-linejoin="round"/>')


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, data in E.items():
        (OUT / f'{name}.svg').write_text(data)
    print(f'{len(E)} emblems -> {OUT}')


if __name__ == '__main__':
    main()
