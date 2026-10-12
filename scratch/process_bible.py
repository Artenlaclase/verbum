import os
import re
import html
import json

SOURCE_DIR = os.path.join('assets', 'bible', 'extracted', 'json')
OUTPUT_DIR = os.path.join('assets', 'bible', 'books')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Lista de libros ordenada del 1 al 66
# Los archivos fuente son 01.content.json hasta 66.content.json
for i in range(1, 67):
    filename = f"{i:02d}.content.json"
    filepath = os.path.join(SOURCE_DIR, filename)
    if not os.path.exists(filepath):
        print(f"Advertencia: no se encontró {filepath}")
        continue
    
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    book_chapters = {}
    
    for item in data:
        # index_reference tiene formato "BBCCCVVV" (ej: "01002001" para libro 1, cap 2, ver 1)
        # o sacamos del title "Génesis 2:1"
        ref = item.get('index_reference', '')
        if len(ref) >= 8:
            chapter_num = int(ref[2:5])
            verse_num = int(ref[5:])
        else:
            m = re.search(r'(\d+):(\d+)', item.get('title', ''))
            if m:
                chapter_num = int(m.group(1))
                verse_num = int(m.group(2))
            else:
                continue
                
        raw = item.get('content', '')
        # Eliminar tags HTML
        clean = re.sub(r'<[^>]+>', '', raw)
        clean = html.unescape(clean).strip()
        # Eliminar posible numero inicial si esta duplicado
        clean = re.sub(r'^\d+\s*', '', clean).strip()
        
        chap_str = str(chapter_num)
        if chap_str not in book_chapters:
            book_chapters[chap_str] = {}
        book_chapters[chap_str][str(verse_num)] = clean
        
    out_file = os.path.join(OUTPUT_DIR, f"{i}.json")
    with open(out_file, 'w', encoding='utf-8') as out_f:
        json.dump(book_chapters, out_f, ensure_ascii=False)
        
    print(f"Libro {i} procesado -> {len(book_chapters)} capítulos guardados en {out_file}")

print("Procesamiento completado con éxito!")
