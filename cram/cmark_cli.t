The native CLI reads from stdin when no file is provided.

  $ printf '# Hello\n' | cmark_cli.exe
  <h1>Hello</h1>

Use `-` explicitly to read stdin when passing options.

  $ printf 'line break\\\nnext\n' | cmark_cli.exe -t xhtml -
  <p>line break<br />
  next</p>

The CLI also accepts one or more file paths.

  $ cat > input.md <<'EOF'
  > A paragraph with *emphasis*.
  > EOF
  $ cmark_cli.exe input.md
  <p>A paragraph with <em>emphasis</em>.</p>

Raw HTML and unsafe links are allowed by default, matching `cmark --unsafe`.

  $ printf '<span>raw</span>\n\n[bad](javascript:alert(1))\n' | cmark_cli.exe
  <p><span>raw</span></p>
  <p><a href="javascript:alert(1)">bad</a></p>

Use `--safe` to sanitize raw HTML and unsafe links.

  $ printf '<script>x</script>\n\n[bad](javascript:alert(1))\n' | cmark_cli.exe --safe
  <!--CommonMark HTML block omitted-->
  <p><a href="">bad</a></p>
