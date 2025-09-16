#!/usr/bin/env python3
import sys
from pathlib import Path

SKIP_LEADING_TOKENS = {
    'syntax', 'package', 'import', 'option', 'service', 'rpc', 'returns'
}

def should_transform(line_before_comment: str) -> bool:
    s = line_before_comment.strip()
    if not s:
        return False
    # Skip braces or block starters
    if s in {'{', '}'} or s.endswith('{'):
        return False
    # Must look like a field/enum definition with '=' and ';'
    if '=' not in s or ';' not in s:
        return False
    # Skip obvious non-field lines by leading token
    token = s.split()[0]
    if token in SKIP_LEADING_TOKENS:
        return False
    # Allow enum values (IDENT = number;) and message fields (type name = number;)
    return True

def process_file(path: Path) -> bool:
    original = path.read_text(encoding='utf-8')
    lines = original.splitlines(keepends=True)
    out_lines = []
    changed = False
    for line in lines:
        # Only handle inline '//' comments that are not at line start
        stripped = line.lstrip()
        if '//' in line and not stripped.startswith('//'):
            idx = line.find('//')
            code = line[:idx].rstrip('\n').rstrip()
            comment = line[idx+2:].rstrip('\n').strip()
            if comment and should_transform(code):
                # Preserve indentation from the code part
                indent_len = len(code) - len(code.lstrip(' \t'))
                indent = code[:indent_len]
                out_lines.append(f"{indent}// {comment}\n")
                out_lines.append(code + "\n")
                changed = True
                continue
        out_lines.append(line)
    if changed:
        path.write_text(''.join(out_lines), encoding='utf-8')
    return changed

def main(argv):
    if len(argv) <= 1:
        print("Usage: rewrite_proto_comments.py <proto files...>")
        return 2
    changed_any = False
    for arg in argv[1:]:
        p = Path(arg)
        if not p.exists() or p.suffix != '.proto':
            continue
        if process_file(p):
            changed_any = True
            print(f"Rewrote comments in: {p}")
    return 0 if changed_any else 0

if __name__ == '__main__':
    raise SystemExit(main(sys.argv))

