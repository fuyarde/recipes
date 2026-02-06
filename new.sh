#!/bin/bash

title="$1"
[ -z "$title" ] && { echo "usage: $0 TITLE"; exit 1; }

filename="${title// /-}"
filename="${filename,,}"

nano "${filename}.md"

prep_time=$(sed -n '/## Infos/,/##/p' "${filename}.md" | grep "Préparation:" | sed 's/.*: //')
cook_time=$(sed -n '/## Infos/,/##/p' "${filename}.md" | grep "Cuisson:" | sed 's/.*: //')
serve=$(sed -n '/## Infos/,/##/p' "${filename}.md" | grep "Part:" | sed 's/.*: //')

ingredients=$(sed -n '/## Ingrédients/,/^##/p' "${filename}.md" | grep -v "##" | sed 's/^- //; s/^/<li>/; s/$/<\/li>/; s/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g' | sed '/^<li><\/li>$/d')
preparation=$(sed -n '/## Préparation/,/^##/p' "${filename}.md" | grep -v "##" | sed '/^[0-9]/!d; s/^[0-9]\+\. //; s/^/<li>/; s/$/<\/li>/; s/\*\*\([^*]*\)\*\*/<strong>\1<\/strong>/g' | sed '/^<li><\/li>$/d')

mkdir -p recettes

cat > "recettes/${filename}.html" <<EOF
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <link rel="stylesheet" href="../style.css">
    <link rel="icon" href="../favicon.svg" />
</head>
<body>
    <div class="container">
        <h1>$title</h1>
        <div class="infos">
            <p><strong>Préparation</strong> : $prep_time</p>
            <p><strong>Cuisson</strong> : $cook_time</p>
            <p><strong>Parts</strong> : $serve</p>
        </div>
        <h2>Ingrédients</h2>
        <ul>
            $ingredients
        </ul>
        <h2>Instructions</h2>
        <ol>
            $preparation
        </ol>
    </div>
</body>
</html>
EOF

# Mettre à jour l'index.html
if ! grep -q "<li><a href=\"recettes/${filename}.html\">$title</a></li>" index.html; then
  sed -i "/<ul class=\"recipe-list\">/a \ \ \ \ \ \ \ \ <li><a href=\"recettes/${filename}.html\">$title<\/a><\/li>" index.html
fi

rm "${filename}.md"
