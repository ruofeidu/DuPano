import htmlmin

FILES = ['header', 'vertex', 'fragment', 'footer']

with open('fragment.glsl', 'r') as i:
  with open('fragment.php', 'w') as o:
    o.write(
        '<script type="x-shader/x-fragment" id="fragment_shader">%s</script>' %
        i.read())

output_html = ''
for file_name in FILES:
  with open(file_name + '.php', 'r') as f:
    output_html += f.read()

with open('index.html', 'w') as f:
  f.write(htmlmin.minify(output_html))
