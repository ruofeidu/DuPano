import htmlmin

FILES = ['index']

output_html = ''
for file_name in FILES:
  with open(file_name + '.src.html', 'r') as f:
    output_html += f.read()

with open('index.html', 'w') as f:
  f.write(htmlmin.minify(output_html))
