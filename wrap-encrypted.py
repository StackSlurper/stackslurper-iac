#!/usr/bin/env python3
import sys
import re
import textwrap

def wrap_enc(match):
    key_indent = match.group(1)
    content = match.group(2).strip()
    wrapped = "\n".join(
        textwrap.wrap(content, width=80 - len(key_indent) - 2)  # Adjust width for indentation
    )
    wrapped = wrapped.replace("\n", "\n" + key_indent + "  ")
    return f"{key_indent}>-\n{key_indent}  {wrapped}"

if len(sys.argv) != 2:
    print("Usage: ./wrap-encrypted.py secrets/global.enc.yaml")
    sys.exit(1)

filepath = sys.argv[1]

with open(filepath, 'r') as file:
    yaml_lines = file.readlines()

pattern = re.compile(r'^(\s*\w+:\s*)ENC\[(.*)\]')

with open(filepath, 'w') as file:
    for line in yaml_lines:
        match = pattern.match(line)
        if match:
            file.write(wrap_enc(match) + '\n')
        else:
            file.write(line)

print(f"✅ Wrapped ENC strings at 80 chars in {filepath}")
